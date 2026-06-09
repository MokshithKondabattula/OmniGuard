from fastapi import APIRouter
from state import incidents, alerts
from playbooks import playbook_history
router = APIRouter()

@router.get("/api/incidents")
def get_incidents():
    return incidents[-20:]

@router.get("/api/playbooks/history")
def get_playbook_history():
    return playbook_history[-20:]

@router.post("/api/incidents/{incident_id}/respond")
def respond(incident_id: str):

    for incident in incidents:

        if incident["id"] == incident_id:

            incident["status"] = "contained"

            incident["playbook"] = "isolate_host"

            actions = [
                "Host isolated",
                "Suspicious IP blocked",
                "SOC analyst notified",
                "Alert marked resolved",
            ]

            incident["response_actions"] = actions

            for alert in alerts:
                if alert.get("title") == incident.get("title"):
                    alert["status"] = "resolved"

            playbook_history.append({
                "incident": incident_id,
                "playbook": "isolate_host",
                "status": "executed",
                "actions": actions,
            })

            return {
                "incident": incident_id,
                "playbook": "isolate_host",
                "status": "executed",
                "actions": actions,
            }

    return {
        "incident": incident_id,
        "status": "not_found",
    }