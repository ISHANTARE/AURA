import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'core/constants/colors.dart';
import 'core/constants/typography.dart';
import 'core/router/app_router.dart';

/// Bottom navigation shell hosting all primary tabs.
class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  static const _tabs = [
    _NavTab(route: Routes.home, icon: LucideIcons.home, label: 'Home', id: 'nav_home'),
    _NavTab(route: Routes.alarms, icon: LucideIcons.alarmClock, label: 'Alarms', id: 'nav_alarms'),
    _NavTab(route: Routes.workspaces, icon: LucideIcons.layoutGrid, label: 'Spaces', id: 'nav_workspaces'),
    _NavTab(route: Routes.notes, icon: LucideIcons.fileText, label: 'Notes', id: 'nav_notes'),
    _NavTab(route: Routes.settings, icon: LucideIcons.settings, label: 'Settings', id: 'nav_settings'),
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    context.go(_tabs[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: widget.child,
      bottomNavigationBar: _AuraBottomNav(
        currentIndex: _currentIndex,
        tabs: _tabs,
        onTap: _onTabTapped,
      ),
    );
  }
}

class _NavTab {
  final String route;
  final IconData icon;
  final String label;
  final String id;
  const _NavTab({required this.route, required this.icon, required this.label, required this.id});
}

class _AuraBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavTab> tabs;
  final ValueChanged<int> onTap;

  const _AuraBottomNav({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: const BoxDecoration(
        color: AuraColors.bgBase,
        border: Border(top: BorderSide(color: AuraColors.border, width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: tabs.asMap().entries.map((entry) {
              final i = entry.key;
              final tab = entry.value;
              final isSelected = i == currentIndex;
              return Expanded(
                child: InkWell(
                  key: Key(tab.id),
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? accent.withValues(alpha: 0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          tab.icon,
                          size: 20,
                          color: isSelected ? accent : AuraColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab.label,
                        style: AuraTypography.caption.copyWith(
                          color: isSelected ? accent : AuraColors.textMuted,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
