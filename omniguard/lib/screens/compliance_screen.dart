import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/panel.dart';

class ComplianceScreen extends StatelessWidget {
  const ComplianceScreen({super.key});

  static const _frameworks = [
    ('SOC 2 Type II', 94, AppTheme.success),
    ('ISO 27001', 88, AppTheme.success),
    ('PCI-DSS 4.0', 71, AppTheme.warning),
    ('HIPAA', 82, AppTheme.success),
    ('GDPR', 67, AppTheme.warning),
    ('NIST 800-53', 59, AppTheme.danger),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Compliance',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Continuous control monitoring · PDF audit exports',
            style: TextStyle(color: AppTheme.textLo, fontSize: 12)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.6,
          children: [
            for (final f in _frameworks)
              Panel(
                title: f.$1.toUpperCase(),
                subtitle: '${f.$2}% controls passing',
                trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.primary),
                  tooltip: 'Export PDF report',
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${f.$2}%',
                      style: TextStyle(
                          fontSize: 36, fontWeight: FontWeight.w700, color: f.$3)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: f.$2 / 100,
                      minHeight: 6,
                      backgroundColor: AppTheme.surfaceAlt,
                      valueColor: AlwaysStoppedAnimation(f.$3),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Last audit run: 2h ago',
                      style: TextStyle(fontSize: 11, color: AppTheme.textLo)),
                ]),
              )
          ],
        ),
      ]),
    );
  }
}
