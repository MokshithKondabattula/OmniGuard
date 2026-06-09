from fastapi import APIRouter, WebSocket
import asyncio
import random
from datetime import datetime

from state import alerts, incidents
from services.elastic_client import index_document
from services.elasticsearch_service import index_alert, index_incident

router = APIRouter()


@router.websocket("/ws/anomalies")
async def anomalies(websocket: WebSocket):
    await websocket.accept()

    while True:
        severity = random.choice([
            "critical",
            "medium",
            "high",
        ])

        score = random.randint(70, 100)

        attack = random.choice([
            "SQL Injection",
            "Brute Force",
            "Privilege Escalation",
            "Credential Stuffing",
        ])

        source = random.choice([
            "Firewall",
            "Windows Logs",
            "VPN",
            "EDR",
        ])

        event = {
            "id": str(random.randint(1000, 9999)),
            "timestamp": datetime.now().isoformat(),
            "severity": severity,
            "score": score,
            "title": attack,
            "attack": attack,
            "source": source,
            "status": "open",
            "message": "AI detected suspicious activity",
        }

        alerts.append(event)
        index_alert(event)
        index_document(
            "omniguard-alerts",
            event
        )

        if severity == "critical":
            incident = {
                "id": f"INC-{random.randint(1000, 9999)}",
                "opened": datetime.now().isoformat(),
                "title": attack,
                "severity": severity,
                "assignee": "SOC Analyst",
                "status": "investigating",
                "alert_count": 1,
            }

            incidents.append(incident)
            index_incident(incident)

        await websocket.send_json(event)

        await asyncio.sleep(2)