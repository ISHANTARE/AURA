import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';

/// Neubrutalist 5-Tab Bottom Navigation Bar for AURA v2
class AuraBottomNav extends StatelessWidget {
  const AuraBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AuraSpacing.bottomNavHeight + MediaQuery.paddingOf(context).bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        color: AuraColors.bgBase,
        border: Border(
          top: BorderSide(color: AuraColors.border, width: AuraSpacing.borderWidth),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: LucideIcons.home,
            label: 'HOME',
            isSelected: selectedIndex == 0,
            onTap: () => onDestinationSelected(0),
          ),
          _NavItem(
            icon: LucideIcons.alarmClock,
            label: 'ALARMS',
            isSelected: selectedIndex == 1,
            onTap: () => onDestinationSelected(1),
          ),
          _NavItem(
            icon: LucideIcons.layoutGrid,
            label: 'WORKSPACES',
            isSelected: selectedIndex == 2,
            onTap: () => onDestinationSelected(2),
          ),
          _NavItem(
            icon: LucideIcons.fileText,
            label: 'NOTES',
            isSelected: selectedIndex == 3,
            onTap: () => onDestinationSelected(3),
          ),
          _NavItem(
            icon: LucideIcons.settings,
            label: 'SETTINGS',
            isSelected: selectedIndex == 4,
            onTap: () => onDestinationSelected(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = isSelected ? AuraColors.accentLime : AuraColors.textSecondary;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.xs, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: activeColor,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: isSelected ? AuraTypography.labelLime : AuraTypography.label,
            ),
          ],
        ),
      ),
    );
  }
}
