import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../models/analytics_model.dart';
import '../services/api_client.dart';
import '../services/websocket_service.dart';


// =======================
// LOGS
// =======================

final logsProvider = StreamProvider<List<LogEntry>>((ref) async* {
  while (true) {
    final raw = await ref.read(apiClientProvider).fetchLogs(limit: 200);

    final parsed = raw.map((e) {
      try {
        return LogEntry.fromJson(e);
      } catch (_) {
        return null;
      }
    }).whereType<LogEntry>().toList();

    yield parsed;

    await Future.delayed(const Duration(seconds: 2));
  }
});

// =======================
// ALERTS
// =======================

final alertsProvider = StreamProvider<List<Alert>>((ref) async* {
  while (true) {
    final raw = await ref.read(apiClientProvider).fetchAlerts();

    yield raw.map((e) => Alert.fromJson(e)).toList();

    await Future.delayed(const Duration(seconds: 2));
  }
});
// =======================
// INCIDENTS
// =======================

final incidentsProvider = StreamProvider<List<Incident>>((ref) async* {
  while (true) {
    final raw = await ref.read(apiClientProvider).fetchIncidents();
    yield raw.map(Incident.fromJson).toList();

    await Future.delayed(const Duration(seconds: 2));
  }
});


// =======================
// THREAT INTEL
// =======================

final threatIntelProvider =
    StreamProvider<List<ThreatIndicator>>((ref) async* {
  while (true) {
    final raw = await ref.read(apiClientProvider).fetchThreatIntel();

    yield raw.map(ThreatIndicator.fromJson).toList();

    await Future.delayed(const Duration(seconds: 5));
  }
});


// =======================
// ANALYTICS
// =======================

final analyticsProvider =
    FutureProvider<AnalyticsData>((ref) async {

  final raw =
      await ref.watch(apiClientProvider)
          .fetchMetrics();

  return AnalyticsData.fromJson(raw);
});


// =======================
// LIVE METRICS
// =======================

final liveMetricsProvider =
    StreamProvider<Map<String, dynamic>>(
        (ref) async* {

  while (true) {

    final metrics =
        await ref.read(apiClientProvider)
            .fetchMetrics();

    yield metrics;

    await Future.delayed(
      const Duration(seconds: 2),
    );
  }
});


// =======================
// WEBSOCKET
// =======================

final websocketServiceProvider =
    Provider<WebSocketService>((ref) {

  final service = WebSocketService();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});


// =======================
// REALTIME ALERT STREAM
// =======================

final anomalyStreamProvider =
    StreamProvider<Map<String, dynamic>>(
        (ref) {

  final ws =
      ref.watch(websocketServiceProvider);

  return ws.stream;
});


final playbookHistoryProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) async* {
  while (true) {
    final raw = await ref.read(apiClientProvider).fetchPlaybookHistory();
    yield raw;
    await Future.delayed(const Duration(seconds: 2));
  }
});


// =======================
// OVERVIEW METRICS
// =======================

class OverviewMetrics {

  final int eventsIngested;
  final int activeAlerts;
  final int openIncidents;
  final int hostsMonitored;

  final List<double> eventsTimeline;

  final Map<Severity, int>
      severityBreakdown;

  final List<MapEntry<String, int>>
      topSources;

  OverviewMetrics({
    required this.eventsIngested,
    required this.activeAlerts,
    required this.openIncidents,
    required this.hostsMonitored,
    required this.eventsTimeline,
    required this.severityBreakdown,
    required this.topSources,
  });
}

final overviewMetricsProvider =
    FutureProvider<OverviewMetrics>(
        (ref) async {

  final m =
      await ref.watch(apiClientProvider)
          .fetchMetrics();

  return OverviewMetrics(
    eventsIngested:
        (m["events_ingested"] ?? 0),

    activeAlerts:
        (m["active_alerts"] ?? 0),

    openIncidents:
        (m["open_incidents"] ?? 0),

    hostsMonitored:
        (m["hosts_monitored"] ?? 0),

    eventsTimeline:
        List<double>.from(
            m["events_timeline"]),

    severityBreakdown: {
      Severity.info:
          m["severity_breakdown"]["info"] ?? 0,

      Severity.low:
          m["severity_breakdown"]["low"] ?? 0,

      Severity.medium:
          m["severity_breakdown"]["medium"] ?? 0,

      Severity.high:
          m["severity_breakdown"]["high"] ?? 0,

      Severity.critical:
          m["severity_breakdown"]["critical"] ?? 0,
    },

    topSources:
        (m["top_sources"] as List)
            .map<MapEntry<String, int>>(
              (e) => MapEntry(
                e["name"],
                e["count"],
              ),
            )
            .toList(),
  );
});