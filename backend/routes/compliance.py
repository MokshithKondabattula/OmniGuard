from fastapi import APIRouter
from datetime import datetime
import psutil

from state import alerts, incidents
from playbooks import playbook_history
from services.elasticsearch_service import es

router = APIRouter()


def index_compliance(item: dict):
    doc = {
        **item,
        "indexed_at": datetime.now().isoformat(),
    }

    try:
        es.index(
            index="omniguard-compliance",
            document=doc,
        )
    except Exception as e:
        print("Compliance index error:", e)


@router.get("/api/compliance")
def compliance():
    critical_alerts = len([
        a for a in alerts
        if a.get("severity") == "critical"
    ])

    open_incidents = len([
        i for i in incidents
        if i.get("status") != "contained"
    ])

    playbooks_executed = len(playbook_history)

    disk_usage = psutil.disk_usage("/").percent

    frameworks = [
        {
            "framework": "SOC Readiness",
            "score": max(0, 100 - critical_alerts * 5),
            "status": "warning" if critical_alerts > 0 else "healthy",
            "metric": "critical_alerts",
            "value": critical_alerts,
            "timestamp": datetime.now().isoformat(),
        },
        {
            "framework": "Incident Response",
            "score": max(0, 100 - open_incidents * 10),
            "status": "warning" if open_incidents > 0 else "healthy",
            "metric": "open_incidents",
            "value": open_incidents,
            "timestamp": datetime.now().isoformat(),
        },
        {
            "framework": "SOAR Automation",
            "score": min(100, playbooks_executed * 10),
            "status": "healthy" if playbooks_executed > 0 else "warning",
            "metric": "playbooks_executed",
            "value": playbooks_executed,
            "timestamp": datetime.now().isoformat(),
        },
        {
            "framework": "Host Health",
            "score": max(0, 100 - int(disk_usage)),
            "status": "critical" if disk_usage > 90 else "healthy",
            "metric": "disk_usage",
            "value": disk_usage,
            "timestamp": datetime.now().isoformat(),
        },
    ]

    for item in frameworks:
        index_compliance(item)

    return frameworks