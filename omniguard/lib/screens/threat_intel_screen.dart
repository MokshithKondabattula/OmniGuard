import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/panel.dart';
import '../models/models.dart';

class ThreatIntelScreen extends ConsumerWidget {
  const ThreatIntelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(threatIntelProvider);

    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Threat Intelligence',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'IOC feeds: OTX · Abuse.ch · MISP · PhishTank',
            style: TextStyle(
              color: AppTheme.textLo,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(
                  color: AppTheme.border,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: feed.when(
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

                data: (list) {
                  if (list.isEmpty) {
                    return const Center(
                      child: Text(
                        'No threat intelligence indicators found',
                        style: TextStyle(
                          color: AppTheme.textLo,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Text(
                              'INDICATORS · ${list.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),

                            const Spacer(),

                            const Text(
                              'Live IOC reputation feed',
                              style: TextStyle(
                                color: AppTheme.textLo,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),

                          itemCount: list.length,

                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),

                          itemBuilder: (_, i) {
                            final ioc = list[i];

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              constraints: const BoxConstraints(
                                minHeight: 72,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 90,
                                    child: SeverityBadge(
                                      label: ioc.severity.label,
                                      color: ioc.severity.color,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  SizedBox(
                                    width: 90,
                                    child: Text(
                                      ioc.type.toUpperCase(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.accent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      ioc.value,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textHi,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      ioc.source,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textLo,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  SizedBox(
                                    width: 130,
                                    child: Text(
                                      DateFormat('MMM d, HH:mm')
                                          .format(ioc.firstSeen),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textLo,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}