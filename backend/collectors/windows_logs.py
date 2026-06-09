import win32evtlog

def get_windows_logs(limit=200):

    logs = []

    try:

        hand = win32evtlog.OpenEventLog(
            "localhost",
            "System"
        )

        flags = (
            win32evtlog.EVENTLOG_BACKWARDS_READ
            | win32evtlog.EVENTLOG_SEQUENTIAL_READ
        )

        events = win32evtlog.ReadEventLog(
            hand,
            flags,
            0
        )

        for event in list(events)[:limit]:

            logs.append({

                "id": str(event.RecordNumber),

                "timestamp": str(event.TimeGenerated),

                "source": str(event.SourceName),

                "event_id": int(event.EventID & 0xFFFF)

            })

        return logs

    except Exception:

        return []