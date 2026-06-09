import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/data_providers.dart';
import '../widgets/panel.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);

    final liveMetrics = ref.watch(
      liveMetricsProvider,
    );

    final anomalyStream = ref.watch(
      anomalyStreamProvider,
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: analytics.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),

          error: (e, _) => Center(
            child: Text(
              e.toString(),
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ),

          data: (data) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Analytics",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =================================
                  // TOP PANELS
                  // =================================

                  Row(
                    children: [
                      Expanded(
                        child: Panel(
                          title: "LIVE ANOMALY",
                          subtitle:
                              "WebSocket Threat Feed",
                          child:
                              anomalyStream.when(
                            loading: () =>
                                const CircularProgressIndicator(),

                            error: (e, _) =>
                                Text(
                              e.toString(),
                            ),

                            data: (live) {
                              final severity =
                                  live["severity"] ??
                                      "unknown";

                              final attack =
                                  live["attack"] ??
                                      "Unknown";

                              final score =
                                  live["score"] ??
                                      0;

                              return Column(
                                children: [
                                  Text(
                                    attack,
                                    textAlign:
                                        TextAlign
                                            .center,
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          18,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          10),

                                  Text(
                                    severity
                                        .toUpperCase(),
                                    style:
                                        TextStyle(
                                      fontSize:
                                          24,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      color: severity ==
                                              "critical"
                                          ? Colors
                                              .red
                                          : Colors
                                              .orange,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          10),

                                  Text(
                                    "Score: $score",
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Panel(
                          title: "ANOMALY STATUS",
                          subtitle:
                              "AI Classification",
                          child: Center(
                            child: Text(
                              data.anomaly["prediction"]
        ?.toString()
        .toUpperCase() ??
    "NORMAL",
                              textAlign:
                                  TextAlign.center,
                              style:
                                  const TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Panel(
                          title: "RISK SCORE",
                          subtitle:
                              "Threat Intelligence",
                          child: Center(
                            child: Text(
                              data.riskScore
                                  .toStringAsFixed(
                                      1),
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    data.riskScore >
                                            80
                                        ? Colors.red
                                        : Colors
                                            .orange,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // =================================
                  // LIVE METRICS CHART
                  // =================================

                  Panel(
                    title: "SYSTEM METRICS",
                    subtitle:
                        "Real-Time Host Monitoring",
                    child: SizedBox(
                      height: 320,
                      child:
                          liveMetrics.when(
                        loading: () =>
                            const Center(
                          child:
                              CircularProgressIndicator(),
                        ),

                        error: (e, _) =>
                            Center(
                          child: Text(
                            e.toString(),
                          ),
                        ),

                        data: (metrics) {
                          final cpu =
                              (metrics["cpu"]
                                      as num?)
                                  ?.toDouble() ??
                                  0;

                          final memory =
                              (metrics["memory"]
                                      as num?)
                                  ?.toDouble() ??
                                  0;

                          final disk =
                              (metrics["disk"]
                                      as num?)
                                  ?.toDouble() ??
                                  0;

                          return BarChart(
                            BarChartData(
                              maxY: 100,
                              borderData:
                                  FlBorderData(
                                show: false,
                              ),

                              gridData:
                                 const FlGridData(
                                show: true,
                              ),

                              titlesData:
                                 const FlTitlesData(
                                topTitles:
                                     AxisTitles(
                                  sideTitles:
                                      SideTitles(
                                    showTitles:
                                        false,
                                  ),
                                ),
                                rightTitles:
                                     AxisTitles(
                                  sideTitles:
                                      SideTitles(
                                    showTitles:
                                        false,
                                  ),
                                ),
                              ),

                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                      toY:
                                          cpu,
                                      color:
                                          Colors
                                              .blue,
                                    ),
                                  ],
                                ),

                                BarChartGroupData(
                                  x: 1,
                                  barRods: [
                                    BarChartRodData(
                                      toY:
                                          memory,
                                      color:
                                          Colors
                                              .orange,
                                    ),
                                  ],
                                ),

                                BarChartGroupData(
                                  x: 2,
                                  barRods: [
                                    BarChartRodData(
                                      toY:
                                          disk,
                                      color:
                                          Colors
                                              .red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =================================
                  // LIVE EVENT FEED
                  // =================================

                  Panel(
                    title: "LIVE SOC EVENTS",
                    subtitle:
                        "Streaming via FastAPI WebSocket",
                    child:
                        anomalyStream.when(
                      loading: () =>
                          const CircularProgressIndicator(),

                      error: (e, _) =>
                          Text(
                        e.toString(),
                      ),

                      data: (live) {
                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              "Attack: ${live["attack"]}",
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(
                                height: 8),

                            Text(
                              "Source: ${live["source"]}",
                            ),

                            const SizedBox(
                                height: 8),

                            Text(
                              "Severity: ${live["severity"]}",
                            ),

                            const SizedBox(
                                height: 8),

                            Text(
                              "Score: ${live["score"]}",
                            ),

                            const SizedBox(
                                height: 8),

                            Text(
                              "Message: ${live["message"]}",
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}