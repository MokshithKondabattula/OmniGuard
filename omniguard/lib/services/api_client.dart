import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base URL for the FastAPI backend.
/// Override at build time with: flutter run -d chrome --dart-define=API_BASE_URL=https://api.omniguard.local
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: kApiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Accept': 'application/json'},
  ));
  dio.interceptors.add(LogInterceptor(
    requestBody: false,
    responseBody: false,
    error: true,
  ));
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(dioProvider)));

class ApiClient {
  ApiClient(this._dio);
  final Dio _dio;

  Future<List<Map<String, dynamic>>> fetchLogs({int limit = 200}) async {
    final res = await _dio.get('/api/logs', queryParameters: {'limit': limit});
    return List<Map<String, dynamic>>.from(res.data as List);
  }

  Future<List<Map<String, dynamic>>> fetchAlerts() async {
    final res = await _dio.get('/api/alerts');
    return List<Map<String, dynamic>>.from(res.data as List);
  }

  Future<List<Map<String, dynamic>>> fetchIncidents() async {
    final res = await _dio.get('/api/incidents');
    return List<Map<String, dynamic>>.from(res.data as List);
  }

  Future<Map<String, dynamic>> fetchMetrics() async {
    final res = await _dio.get('/api/metrics/overview');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<Map<String, dynamic>>> fetchThreatIntel() async {
    final res = await _dio.get('/api/threat-intel/feeds');
    return List<Map<String, dynamic>>.from(res.data as List);
  }

  Future<List<Map<String, dynamic>>> fetchPlaybookHistory() async {
  final res = await _dio.get('/api/playbooks/history');
  return List<Map<String, dynamic>>.from(res.data as List);
}

  Future<void> triggerPlaybook(String incidentId, String playbook) async {
    await _dio.post('/api/incidents/$incidentId/respond', data: {'playbook': playbook});
  }

  Future<Response> downloadComplianceReport(String framework) async {
    return _dio.get('/api/compliance/$framework/report',
        options: Options(responseType: ResponseType.bytes));
  }
}
