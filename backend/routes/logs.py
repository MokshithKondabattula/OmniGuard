from fastapi import APIRouter
import win32evtlog
from services.elasticsearch_service import index_log

router = APIRouter()


@router.get("/api/logs")
def get_logs(limit: int = 50):

    logs = []

    try:
        server = "localhost"
        logtype = "System"

        hand = win32evtlog.OpenEventLog(server, logtype)

        events = win32evtlog.ReadEventLog(
            hand,
            win32evtlog.EVENTLOG_BACKWARDS_READ
            | win32evtlog.EVENTLOG_SEQUENTIAL_READ,
            0,
        )

        for event in events[:limit]:
            log_item = {
                "id": str(event.RecordNumber),
                "timestamp": event.TimeGenerated.isoformat(),
                "source": str(event.SourceName),
                "host": server,
                "severity": (
                    "high"
                    if event.EventID in [4625, 4720]
                    else "medium"
                ),
                "message": f"Event ID {event.EventID & 0xFFFF}",
                "event_id": int(event.EventID & 0xFFFF),
                "log_type": logtype,
            }

            logs.append(log_item)

            try:
                index_log(log_item)
            except Exception:
                pass

        return logs

    except Exception as e:
        return {
            "error": str(e),
        }