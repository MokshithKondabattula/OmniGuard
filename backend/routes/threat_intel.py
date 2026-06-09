# routes/threat_intel.py

from fastapi import APIRouter
from datetime import datetime
import re

from routes.logs import get_logs
from collectors.network_iocs import network_iocs
from services.elasticsearch_service import es

router = APIRouter()


def detect_ioc_type(value: str):
    if not value:
        return "unknown"

    value = str(value)

    ip_pattern = r"^\d{1,3}(?:\.\d{1,3}){3}$"
    domain_pattern = r"^(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$"
    hash_pattern = r"^[a-fA-F0-9]{32,64}$"

    if re.match(ip_pattern, value):
        return "ip"

    if re.match(domain_pattern, value):
        return "domain"

    if re.match(hash_pattern, value):
        return "hash"

    return "unknown"


def extract_iocs(text: str):
    if not text:
        return []

    ip_regex = r"\b\d{1,3}(?:\.\d{1,3}){3}\b"
    domain_regex = r"\b(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}\b"
    hash_regex = r"\b[a-fA-F0-9]{32,64}\b"

    found = []
    found += re.findall(ip_regex, text)
    found += re.findall(domain_regex, text)
    found += re.findall(hash_regex, text)

    return list(set(found))


def index_threat_indicator(indicator: dict):
    doc = {
        **indicator,
        "indexed_at": datetime.now().isoformat(),
    }

    try:
        es.index(
            index="omniguard-threat-intel",
            id=indicator.get("value"),
            document=doc,
        )
    except Exception as e:
        print("Threat intel index error:", e)


@router.get("/api/threat-intel/feeds")
def threat_intel():
    indicators = []

    logs = get_logs(limit=200)

    for log in logs:
        text = f"{log.get('source', '')} {log.get('message', '')}"

        for ioc in extract_iocs(text):
            indicator = {
                "value": ioc,
                "type": detect_ioc_type(ioc),
                "source": "Windows Event Logs",
                "severity": log.get("severity", "medium"),
                "first_seen": log.get(
                    "timestamp",
                    datetime.now().isoformat(),
                ),
            }

            indicators.append(indicator)
            index_threat_indicator(indicator)

    for item in list(network_iocs)[-100:]:
        indicator = {
            "value": item.get("value", "unknown"),
            "type": item.get("type", "ip"),
            "source": item.get("source", "Live Network Capture"),
            "severity": item.get("severity", "medium"),
            "first_seen": item.get(
                "first_seen",
                datetime.now().isoformat(),
            ),
        }

        indicators.append(indicator)
        index_threat_indicator(indicator)

    unique = {}
    for item in indicators:
        key = item["value"]
        unique[key] = item

    return list(unique.values())[-50:]