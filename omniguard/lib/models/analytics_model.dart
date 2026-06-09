class AnalyticsData {
  final Map<String, dynamic> metrics;
  final Map<String, dynamic> anomaly;
  final int failedLogins;
  final double riskScore;

  AnalyticsData({
    required this.metrics,
    required this.anomaly,
    required this.failedLogins,
    required this.riskScore,
  });

  factory AnalyticsData.fromJson(
      Map<String, dynamic> json) {
    return AnalyticsData(
      metrics: Map<String, dynamic>.from(
        json["metrics"] ?? {},
      ),

      anomaly: Map<String, dynamic>.from(
        json["anomaly"] ?? {},
      ),

      failedLogins:
          json["failed_logins"] ?? 0,

      riskScore:
          (json["risk_score"] ?? 0)
              .toDouble(),
    );
  }
}