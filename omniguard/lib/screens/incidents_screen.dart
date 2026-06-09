import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/data_providers.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/panel.dart';
import '../models/models.dart';

class IncidentsScreen extends ConsumerWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidents = ref.watch(incidentsProvider);
    final history = ref.watch(playbookHistoryProvider);

    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Incidents',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Celery-driven playbook automation',
            style: TextStyle(color: AppTheme.textLo, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                incidents.when(
                  loading: () => const SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Text(e.toString()),
                  data: (list) {
                    if (list.isEmpty) {
                      return const Panel(
                        title: 'INCIDENTS',
                        padding: EdgeInsets.all(18),
                        child: Text(
                          'No incidents detected yet',
                          style: TextStyle(color: AppTheme.textLo),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (final inc in list)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Panel(
                              title: inc.id,
                              subtitle:
                                  'Opened ${DateFormat('MMM d · HH:mm').format(inc.opened)}',
                              trailing: SeverityBadge(
                                label: inc.severity.label,
                                color: inc.severity.color,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    inc.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textHi,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 20,
                                    runSpacing: 10,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.person_outline,
                                            size: 14,
                                            color: AppTheme.textLo,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            inc.assignee,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textLo,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.notifications_active_outlined,
                                            size: 14,
                                            color: AppTheme.textLo,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${inc.alertCount} alerts',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textLo,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceAlt,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          inc.status.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            letterSpacing: 1.1,
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      OutlinedButton.icon(
                                        onPressed: inc.status.toLowerCase() ==
                                                'contained'
                                            ? null
                                            : () async {
                                                await ref
                                                    .read(apiClientProvider)
                                                    .triggerPlaybook(
                                                      inc.id,
                                                      'isolate_host',
                                                    );

                                                ref.invalidate(
                                                    incidentsProvider);
                                                ref.invalidate(
                                                    playbookHistoryProvider);

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Playbook executed for ${inc.id}',
                                                    ),
                                                  ),
                                                );
                                              },
                                        icon: const Icon(
                                          Icons.play_arrow,
                                          size: 16,
                                        ),
                                        label: Text(
                                          inc.status.toLowerCase() ==
                                                  'contained'
                                              ? 'Contained'
                                              : 'Run playbook',
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.primary,
                                          side: const BorderSide(
                                            color: AppTheme.border,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                history.when(
                  loading: () => const Panel(
                    title: 'PLAYBOOK HISTORY',
                    child: SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (e, _) => Panel(
                    title: 'PLAYBOOK HISTORY',
                    child: Text(e.toString()),
                  ),
                  data: (items) {
                    return Panel(
                      title: 'PLAYBOOK HISTORY',
                      subtitle: 'Recent automated responses',
                      padding: const EdgeInsets.all(14),
                      child: SizedBox(
                        height: 260,
                        child: items.isEmpty
                            ? const Center(
                                child: Text(
                                  'No playbooks executed yet',
                                  style: TextStyle(color: AppTheme.textLo),
                                ),
                              )
                            : ListView.separated(
                                itemCount:
                                    items.length > 5 ? 5 : items.length,
                                separatorBuilder: (_, __) => const Divider(
                                  color: AppTheme.border,
                                  height: 1,
                                ),
                                itemBuilder: (_, i) {
                                  final item = items.reversed.toList()[i];

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(
                                      Icons.bolt,
                                      color: AppTheme.primary,
                                    ),
                                    title: Text(
                                      '${item["incident"]} · ${item["playbook"]}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      item["status"]
                                          .toString()
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: AppTheme.textLo,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}