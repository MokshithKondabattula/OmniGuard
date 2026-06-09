# OmniGuard — SOC Dashboard (Flutter Web)

AI-powered SOC dashboard: log ingestion, anomaly detection, incident response,
threat intel feeds, Kibana embedding, and compliance reporting.

## Stack

- **Flutter Web** (Material 3, dark cybersecurity theme)
- **Riverpod** for state management
- **go_router** for routing
- **fl_chart** for analytics charts
- **Dio** for FastAPI REST integration
- **google_fonts** (Inter) for typography
- Pluggable backend: **FastAPI · PyOD · Scikit-learn · Celery · Elasticsearch · Logstash · Kibana**

## Project structure

```
omniguard/
├── pubspec.yaml
├── web/                       # Flutter Web bootstrap
│   ├── index.html
│   └── manifest.json
└── lib/
    ├── main.dart
    ├── theme/app_theme.dart    # Dark cyber palette + Material 3 theme
    ├── router/app_router.dart  # go_router shell routes
    ├── models/models.dart      # LogEntry, Alert, Incident, ThreatIndicator
    ├── services/api_client.dart  # Dio → FastAPI client
    ├── providers/data_providers.dart  # Riverpod providers (mock + live)
    ├── widgets/
    │   ├── app_shell.dart      # Sidebar + top status bar
    │   └── panel.dart          # Panel / StatCard / SeverityBadge
    └── screens/
        ├── dashboard_screen.dart   # Overview: KPIs, line/pie/bar charts
        ├── logs_screen.dart        # Streaming log search (KQL-style)
        ├── alerts_screen.dart      # AI-scored alert table
        ├── incidents_screen.dart   # Incident cards + run playbook
        ├── analytics_screen.dart   # Anomaly score histogram + MTTD/MTTR
        ├── threat_intel_screen.dart  # IOC feed
        ├── kibana_screen.dart      # Embedded Kibana iframe
        └── compliance_screen.dart  # SOC2/ISO/PCI/HIPAA/GDPR/NIST
```

## Setup

```bash
# 1. Make sure Flutter is installed and web is enabled
flutter --version
flutter config --enable-web

# 2. Create the project files (copy this folder), then:
cd omniguard
flutter pub get

# 3. Run in Chrome (mock data, no backend needed)
flutter run -d chrome

# 4. Run against your FastAPI backend
flutter run -d chrome \
  --dart-define=USE_MOCK=false \
  --dart-define=API_BASE_URL=http://localhost:8000 \
  --dart-define=KIBANA_URL=https://kibana.local/app/dashboards#/view/<id>?embed=true

# 5. Production build
flutter build web --release \
  --dart-define=USE_MOCK=false \
  --dart-define=API_BASE_URL=https://api.omniguard.example.com
# output: build/web/  → serve with any static host (nginx, S3+CloudFront, etc.)
```

## Backend contract (FastAPI)

The Dio client expects these endpoints (`lib/services/api_client.dart`):

| Method | Path                                         | Returns |
|--------|----------------------------------------------|---------|
| GET    | `/api/logs?limit=200`                        | `List[LogEntry]` |
| GET    | `/api/alerts`                                | `List[Alert]` |
| GET    | `/api/incidents`                             | `List[Incident]` |
| GET    | `/api/metrics/overview`                      | `OverviewMetrics` |
| GET    | `/api/threat-intel/feeds`                    | `List[ThreatIndicator]` |
| POST   | `/api/incidents/{id}/respond`                | `{ "playbook": "isolate_host" }` |
| GET    | `/api/compliance/{framework}/report`         | PDF bytes |

JSON shapes match the `fromJson` factories in `lib/models/models.dart`.

## Auth (OAuth 2.0 / SAML)

Wire your IdP into the FastAPI backend and pass the bearer token via a Dio
interceptor in `services/api_client.dart` (look for the `LogInterceptor`
registration). Store tokens in `flutter_secure_storage` if you add a real login
flow.

## Notes

- The Kibana screen uses an `<iframe>` via `HtmlElementView` (Flutter Web only).
  Make sure your Kibana instance allows your origin in
  `xpack.security.sameSiteCookies` / CORS.
- All charts use `fl_chart`; swap colors via `lib/theme/app_theme.dart`.
- Mock data lives in `providers/data_providers.dart` under `_MockData` — flip
  `USE_MOCK=false` at build time to switch to the live API.
