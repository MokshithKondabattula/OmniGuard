from fastapi import APIRouter

from collectors.system_metrics import get_metrics
from collectors.windows_logs import get_windows_logs

from ai.anomaly_detector import detector
from ai.threat_scorer import calculate_risk

router = APIRouter()

@router.get("/api/analytics")
def analytics():

    metrics = get_metrics()

    logs = get_windows_logs(200)

    failed_logins = sum(
        1
        for log in logs
        if log["event_id"] == 4625
    )

    features = [

        metrics["cpu"],

        metrics["memory"],

        metrics["disk"],

        failed_logins,

        metrics["processes"]
    ]

    anomaly = detector.predict(features)

    risk = calculate_risk(

        95 if anomaly["prediction"] == "anomaly" else 40,

        min(failed_logins * 5, 100),

        metrics["cpu"]
    )

    return {

        "metrics": metrics,

        "failed_logins": failed_logins,

        "anomaly": anomaly,

        "risk_score": risk
    }