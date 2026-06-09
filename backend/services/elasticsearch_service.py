from elasticsearch import Elasticsearch
from datetime import datetime

es = Elasticsearch(
    "http://localhost:9200",
    request_timeout=3,
)

ALERT_INDEX = "omniguard-alerts"
INCIDENT_INDEX = "omniguard-incidents"
LOG_INDEX = "omniguard-logs"
THREAT_INTEL_INDEX = "omniguard-threat-intel"
COMPLIANCE_INDEX = "omniguard-compliance"


def safe_index(index: str, document: dict, doc_id=None):
    try:
        now = datetime.now().isoformat()

        doc = {
            **document,
            "@timestamp": document.get("timestamp", now),
            "indexed_at": document.get("indexed_at", now),
        }

        es.index(
            index=index,
            id=doc_id,
            document=doc,
        )

    except Exception as e:
        print(f"ELASTIC INDEX ERROR [{index}]:", e)


def index_alert(alert: dict):
    safe_index(ALERT_INDEX, alert, alert.get("id"))


def index_incident(incident: dict):
    safe_index(INCIDENT_INDEX, incident, incident.get("id"))


def index_log(log: dict):
    safe_index(LOG_INDEX, log, log.get("id"))


def index_compliance(doc: dict):
    safe_index(COMPLIANCE_INDEX, doc, doc.get("framework") or doc.get("name"))


def index_threat_intel(doc: dict):
    safe_index(THREAT_INTEL_INDEX, doc, doc.get("value"))