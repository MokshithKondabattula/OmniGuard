import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const _items = <_NavItem>[
    _NavItem('/', 'Overview', Icons.shield_moon_outlined),
    _NavItem('/logs', 'Logs', Icons.terminal),
    _NavItem('/alerts', 'Alerts', Icons.notifications_active_outlined),
    _NavItem('/incidents', 'Incidents', Icons.local_fire_department_outlined),
    _NavItem('/analytics', 'Analytics', Icons.insights_outlined),
    _NavItem('/threat-intel', 'Threat Intel', Icons.public),
    _NavItem('/kibana', 'Kibana', Icons.dashboard_customize_outlined),
    _NavItem('/compliance', 'Compliance', Icons.verified_user_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final extended = width >= 1280;
    final selected = _items.indexWhere((e) => e.path == location).clamp(0, _items.length - 1);

    return Scaffold(
      body: Row(
        children: [
          _Sidebar(items: _items, selected: selected, extended: extended),
          Expanded(
            child: Column(
              children: [
                const _TopBar(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String path;
  final String label;
  final IconData icon;
  const _NavItem(this.path, this.label, this.icon);
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.items, required this.selected, required this.extended});
  final List<_NavItem> items;
  final int selected;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: extended ? 240 : 76,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(right: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            child: Row(
              mainAxisAlignment: extended ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                    ),
                  ),
                  child: const Icon(Icons.shield, color: Color(0xFF001018), size: 22),
                ),
                if (extended) ...[
                  const SizedBox(width: 12),
                  const Text(
                    'OmniGuard',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final isSel = i == selected;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Material(
                    color: isSel ? const Color(0x226EE7FF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => context.go(item.path),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        child: Row(
                          mainAxisAlignment:
                              extended ? MainAxisAlignment.start : MainAxisAlignment.center,
                          children: [
                            Icon(item.icon,
                                size: 20,
                                color: isSel ? AppTheme.primary : AppTheme.textLo),
                            if (extended) ...[
                              const SizedBox(width: 12),
                              Text(
                                item.label,
                                style: TextStyle(
                                  color: isSel ? AppTheme.textHi : AppTheme.textLo,
                                  fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (extended)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('SOC online · Tier 2',
                          style: TextStyle(fontSize: 12, color: AppTheme.textLo)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: const BoxDecoration(
        color: AppTheme.bg,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppTheme.textLo),
          const SizedBox(width: 10),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search hosts, IPs, alert IDs, KQL…',
                hintStyle: TextStyle(color: AppTheme.textLo, fontSize: 13),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isCollapsed: true,
              ),
              style: TextStyle(fontSize: 14),
            ),
          ),
          const _StatusPill(label: 'INGEST', value: 'OK', color: AppTheme.success),
          const SizedBox(width: 8),
          const _StatusPill(label: 'MODEL', value: 'IForest v3', color: AppTheme.primary),
          const SizedBox(width: 8),
          const _StatusPill(label: 'THREATCON', value: '3', color: AppTheme.warning),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: AppTheme.textHi,
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.surfaceAlt,
            child: Text('AM', style: TextStyle(fontSize: 12, color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text('$label ',
              style: const TextStyle(fontSize: 11, color: AppTheme.textLo, letterSpacing: 1)),
          Text(value,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
