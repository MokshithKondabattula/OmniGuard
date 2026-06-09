import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/alerts_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/compliance_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/incidents_screen.dart';
import '../screens/kibana_screen.dart';
import '../screens/logs_screen.dart';
import '../screens/threat_intel_screen.dart';
import '../widgets/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/logs', builder: (_, __) => const LogsScreen()),
          GoRoute(path: '/alerts', builder: (_, __) => const AlertsScreen()),
          GoRoute(path: '/incidents', builder: (_, __) => const IncidentsScreen()),
          GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
          GoRoute(path: '/threat-intel', builder: (_, __) => const ThreatIntelScreen()),
          GoRoute(path: '/kibana', builder: (_, __) => const KibanaScreen()),
          GoRoute(path: '/compliance', builder: (_, __) => const ComplianceScreen()),
        ],
      ),
    ],
  );
});
