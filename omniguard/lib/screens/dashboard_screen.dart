import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../providers/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/panel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(overviewMetricsProvider);
    final alerts = ref.watch(alertsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: metrics.when(
        loading: () => const Center(child: Padding(
          padding: EdgeInsets.all(80), child: CircularProgressIndicator())),
        error: (e, _) => Text('Failed to load metrics: $e'),
        data: (m) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 18),
              LayoutBuilder(builder: (context, c) {
                final cross = c.maxWidth > 1100 ? 4 : c.maxWidth > 700 ? 2 : 1;
                return GridView.count(
                  crossAxisCount: cross,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 2.4,
                  children: [
                    StatCard(
                        label: 'Events ingested · 24h',
                        value: NumberFormat.compact().format(m.eventsIngested),
                        icon: Icons.swap_vert,
                        delta: '+12.4%'),
                    StatCard(
                        label: 'Active alerts',
                        value: '${m.activeAlerts}',
                        icon: Icons.notifications_active_outlined,
                        accent: AppTheme.warning,
                        delta: '+3'),
                    StatCard(
                        label: 'Open incidents',
                        value: '${m.openIncidents}',
                        icon: Icons.local_fire_department_outlined,
                        accent: AppTheme.danger,
                        delta: '+1'),
                    StatCard(
                        label: 'Hosts monitored',
                        value: '${m.hostsMonitored}',
                        icon: Icons.dns_outlined,
                        accent: AppTheme.success,
                        delta: '-2'),
                  ],
                );
              }),
              const SizedBox(height: 18),
              LayoutBuilder(builder: (context, c) {
                final wide = c.maxWidth > 1100;
                final left = Panel(
                  title: 'EVENTS · LAST 24 HOURS',
                  subtitle: 'Ingestion rate from Logstash collectors',
                  trailing: const _LegendDot(color: AppTheme.primary, label: 'events/min'),
                  child: SizedBox(height: 260, child: _EventsChart(values: m.eventsTimeline)),
                );
                final right = Panel(
                  title: 'SEVERITY BREAKDOWN',
                  subtitle: 'PyOD scored over last 24h',
                  child: SizedBox(height: 260, child: _SeverityChart(data: m.severityBreakdown)),
                );
                if (wide) {
                  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 2, child: left),
                    const SizedBox(width: 14),
                    Expanded(child: right),
                  ]);
                }
                return Column(children: [left, const SizedBox(height: 14), right]);
              }),
              const SizedBox(height: 18),
              LayoutBuilder(builder: (context, c) {
                final wide = c.maxWidth > 1100;
                final left = Panel(
                  title: 'TOP LOG SOURCES',
                  subtitle: 'Volume per collector',
                  child: SizedBox(height: 260, child: _TopSourcesChart(rows: m.topSources)),
                );
                final right = Panel(
                  title: 'LIVE ALERT FEED',
                  subtitle: 'Streaming from anomaly engine',
                  child: alerts.when(
                    loading: () => const SizedBox(
                        height: 240, child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => Text('$e'),
                    data: (list) => SizedBox(
                      height: 260,
                      child: ListView.separated(
                        itemCount: list.length.clamp(0, 8),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) => _AlertRow(alert: list[i]),
                      ),
                    ),
                  ),
                );
                if (wide) {
                  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: left),
                    const SizedBox(width: 14),
                    Expanded(child: right),
                  ]);
                }
                return Column(children: [left, const SizedBox(height: 14), right]);
              }),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Security Operations Center',
                  style: TextStyle(
                      color: AppTheme.textLo, fontSize: 12, letterSpacing: 1.4)),
              SizedBox(height: 4),
              Text('Threat Overview',
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w700, color: AppTheme.textHi)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.schedule, size: 14, color: AppTheme.textLo),
              SizedBox(width: 6),
              Text('Window: last 24h · UTC',
                  style: TextStyle(fontSize: 12, color: AppTheme.textLo)),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textLo)),
    ]);
  }
}

class _EventsChart extends StatelessWidget {
  const _EventsChart({required this.values});
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final spots = [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])];
    return LineChart(LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            const FlLine(color: AppTheme.border, strokeWidth: 1, dashArray: [4, 4]),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (v, _) => Text(
              NumberFormat.compact().format(v),
              style: const TextStyle(fontSize: 10, color: AppTheme.textLo),
            ),
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 4,
            getTitlesWidget: (v, _) => Text('${v.toInt()}h',
                style: const TextStyle(fontSize: 10, color: AppTheme.textLo)),
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppTheme.primary,
          barWidth: 2.5,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [AppTheme.primary.withValues(alpha:0.25), AppTheme.primary.withValues(alpha:0.00)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    ));
  }
}

class _SeverityChart extends StatelessWidget {
  const _SeverityChart({required this.data});
  final Map<Severity, int> data;
  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final total = entries.fold<int>(0, (a, e) => a + e.value).clamp(1, 1 << 30);
    return Row(children: [
      Expanded(
        flex: 3,
        child: PieChart(PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 50,
          sections: [
            for (final e in entries)
              PieChartSectionData(
                value: e.value.toDouble(),
                color: e.key.color,
                radius: 38,
                showTitle: false,
              )
          ],
        )),
      ),
      Expanded(
        flex: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final e in entries) ...[
              Row(children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: e.key.color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(e.key.label,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textHi)),
                const Spacer(),
                Text('${((e.value / total) * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textLo)),
              ]),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    ]);
  }
}

class _TopSourcesChart extends StatelessWidget {
  const _TopSourcesChart({required this.rows});
  final List<MapEntry<String, int>> rows;

  @override
  Widget build(BuildContext context) {
    final maxV = rows.map((e) => e.value).fold<int>(0, (a, b) => b > a ? b : a).toDouble();
    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceBetween,
      maxY: maxV * 1.15,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            const FlLine(color: AppTheme.border, strokeWidth: 1, dashArray: [4, 4]),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            getTitlesWidget: (v, _) => Text(NumberFormat.compact().format(v),
                style: const TextStyle(fontSize: 10, color: AppTheme.textLo)),
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= rows.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(rows[i].key.split('-').first,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textLo)),
              );
            },
          ),
        ),
      ),
      barGroups: [
        for (var i = 0; i < rows.length; i++)
          BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: rows[i].value.toDouble(),
              width: 22,
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: [AppTheme.accent, AppTheme.primary],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ])
      ],
    ));
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert});
  final Alert alert;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SeverityBadge(label: alert.severity.label, color: alert.severity.color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textHi)),
                const SizedBox(height: 2),
                Text('${alert.source} · score ${alert.score.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textLo)),
              ],
            ),
          ),
          Text(DateFormat.Hms().format(alert.timestamp),
              style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLo,
                  fontFeatures: [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}
