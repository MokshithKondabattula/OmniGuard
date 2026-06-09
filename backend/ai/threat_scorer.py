def calculate_risk(
    anomaly_score,
    threat_intel_score,
    severity_score
):

    return round(
        anomaly_score * 0.5 +
        threat_intel_score * 0.3 +
        severity_score * 0.2,
        2
    )