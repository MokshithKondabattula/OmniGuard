from fastapi import APIRouter

from collectors.system_metrics import get_metrics
from collectors.windows_logs import get_windows_logs

router = APIRouter()

@router.get("/api/metrics/overview")
def metrics():

    metrics = get_metrics()

    logs = get_windows_logs(500)

    failed_logins = sum(
        1
        for log in logs
        if log["event_id"] == 4625
    )

    critical = failed_logins

    high = int(len(logs) * 0.15)

    medium = int(len(logs) * 0.25)

    low = int(len(logs) * 0.35)

    info = len(logs) - (
        critical +
        high +
        medium +
        low
    )

    timeline = [0] * 24

    for log in logs:

        try:

            hour = int(
                str(log["timestamp"])[11:13]
            )

            if 0 <= hour <= 23:
                timeline[hour] += 1

        except:
            pass

    return {

        "events_ingested": len(logs),

        "active_alerts": failed_logins,

        "open_incidents":
            1 if failed_logins > 10 else 0,

        "hosts_monitored": 1,

        "events_timeline": timeline,

        "severity_breakdown": {

            "info": info,

            "low": low,

            "medium": medium,

            "high": high,

            "critical": critical
        },

        "top_sources": [

            {
                "name": "Windows Logs",
                "count": len(logs)
            },

            {
                "name": "Processes",
                "count": metrics["processes"]
            }
        ],

        "cpu": metrics["cpu"],

        "memory": metrics["memory"],

        "disk": metrics["disk"]
    }