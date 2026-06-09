/// Lightweight DTOs. Swap for freezed if you want immutability + json_serializable.
library;
// Use dart:ui for Color to avoid depending on Flutter material package in this
// lightweight models library.
import 'dart:ui' show Color;

enum Severity { info, low, medium, high, critical }

extension SeverityX on Severity {
  String get label => switch (this) {
        Severity.info => 'INFO',
        Severity.low => 'LOW',
        Severity.medium => 'MED',
        Severity.high => 'HIGH',
        Severity.critical => 'CRIT',
      };

  Color get color => switch (this) {
        Severity.info => const Color(0xFF6EE7FF),
        Severity.low => const Color(0xFF22D3A0),
        Severity.medium => const Color(0xFFF4B740),
        Severity.high => const Color(0xFFFF8A4C),
        Severity.critical => const Color(0xFFFF5D73),
      };

  static Severity parse(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'critical':
        return Severity.critical;
      case 'high':
        return Severity.high;
      case 'medium':
        return Severity.medium;
      case 'low':
        return Severity.low;
      default:
        return Severity.info;
    }
  }
}

class LogEntry {
  final String id;
  final DateTime timestamp;
  final String source;
  final String host;
  final Severity severity;
  final String message;

  LogEntry({
    required this.id,
    required this.timestamp,
    required this.source,
    required this.host,
    required this.severity,
    required this.message,
  });

  factory LogEntry.fromJson(Map<String, dynamic> j) => LogEntry(
        id: j['id']?.toString() ?? '',
        timestamp: DateTime.tryParse(j['timestamp']?.toString() ?? '') ?? DateTime.now(),
        source: j['source']?.toString() ?? 'unknown',
        host: j['host']?.toString() ?? '-',
        severity: SeverityX.parse(j['severity']?.toString()),
        message: j['message']?.toString() ?? '',
      );
}

class Alert {

  final String id;
  final DateTime timestamp;
  final String title;
  final Severity severity;
  final String source;
  final String status;
  final double score;

  Alert({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.severity,
    required this.source,
    required this.status,
    required this.score,
  });

  factory Alert.fromJson(
    Map<String, dynamic> j,
  ) {

    return Alert(

      id: j["id"].toString(),

      timestamp: DateTime.now(),

      title: j["title"] ?? "Unknown",

      severity: SeverityX.parse(
        j["severity"] ?? "medium",
      ),

      source: j["source"] ?? "Unknown",

      status: j["status"] ?? "OPEN",

      score: double.tryParse(
            j["score"].toString(),
          ) ??
          0,
    );
  }
}

class Incident {
  final String id;
  final DateTime opened;
  final String title;
  final Severity severity;
  final String assignee;
  final String status;
  final int alertCount;

  Incident({
    required this.id,
    required this.opened,
    required this.title,
    required this.severity,
    required this.assignee,
    required this.status,
    required this.alertCount,
  });

  factory Incident.fromJson(Map<String, dynamic> j) => Incident(
        id: j['id']?.toString() ?? '',
        opened: DateTime.tryParse(j['opened']?.toString() ?? '') ?? DateTime.now(),
        title: j['title']?.toString() ?? 'Incident',
        severity: SeverityX.parse(j['severity']?.toString()),
        assignee: j['assignee']?.toString() ?? 'unassigned',
        status: j['status']?.toString() ?? 'triage',
        alertCount: (j['alert_count'] as num?)?.toInt() ?? 0,
      );
}

class ThreatIndicator {
  final String value;
  final String type;
  final String source;
  final Severity severity;
  final DateTime firstSeen;

  ThreatIndicator({
    required this.value,
    required this.type,
    required this.source,
    required this.severity,
    required this.firstSeen,
  });

  factory ThreatIndicator.fromJson(Map<String, dynamic> j) => ThreatIndicator(
        value: j['value']?.toString() ?? '',
        type: j['type']?.toString() ?? 'ioc',
        source: j['source']?.toString() ?? '-',
        severity: SeverityX.parse(j['severity']?.toString()),
        firstSeen: DateTime.tryParse(j['first_seen']?.toString() ?? '') ?? DateTime.now(),
      );
}
