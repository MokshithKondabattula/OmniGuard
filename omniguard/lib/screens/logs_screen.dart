import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../providers/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/panel.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  String _query = '';
  Severity? _minSeverity;

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(logsProvider);

    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Log Stream',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Real-time Windows Event Logs',
              style: TextStyle(color: AppTheme.textLo, fontSize: 12)),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Search source, host, event id...',
                    prefixIcon: Icon(Icons.search, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<Severity?>(
                value: _minSeverity,
                hint: const Text('All severities'),
                dropdownColor: AppTheme.surface,
                underline: const SizedBox.shrink(),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All severities'),
                  ),
                  for (final s in Severity.values)
                    DropdownMenuItem(
                      value: s,
                      child: Text(s.label),
                    ),
                ],
                onChanged: (v) => setState(() => _minSeverity = v),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: logsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (logs) {
                  final q = _query.toLowerCase();

                  final filtered = logs.where((l) {
                    final matchesQuery = q.isEmpty ||
                        l.id.toLowerCase().contains(q) ||
                        l.source.toLowerCase().contains(q) ||
                        l.host.toLowerCase().contains(q) ||
                        l.message.toLowerCase().contains(q);

                    final matchesSeverity = _minSeverity == null ||
                        l.severity.index >= _minSeverity!.index;

                    return matchesQuery && matchesSeverity;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No logs found',
                        style: TextStyle(color: AppTheme.textLo),
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
                              'EVENTS · ${filtered.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Live Windows Events',
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
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (_, i) =>
                              _LogRow(entry: filtered[i]),
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

class _LogRow extends StatelessWidget {
  const _LogRow({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              DateFormat('HH:mm:ss').format(entry.timestamp),
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textLo,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          SeverityBadge(
            label: entry.severity.label,
            color: entry.severity.color,
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              entry.source,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              entry.host,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textLo,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              entry.message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textHi,
              ),
            ),
          ),
        ],
      ),
    );
  }
}