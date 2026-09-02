import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';

/// Premium Dark 5-Tab Bottom Navigation Bar with Animated Pill Indicator
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
    final themePrimary = Theme.of(context).colorScheme.primary;
    final cardBg = AuraColors.cardOf(context);
    final borderCol = AuraColors.borderOf(context);
    final mutedText = AuraColors.textMutedOf(context);

    return Container(
      height: AuraSpacing.bottomNavHeight + MediaQuery.paddingOf(context).bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(
          top: BorderSide(color: borderCol, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: LucideIcons.home,
            label: 'Home',
            isSelected: selectedIndex == 0,
            activeColor: themePrimary,
            inactiveColor: mutedText,
            onTap: () => onDestinationSelected(0),
          ),
          _NavItem(
            icon: LucideIcons.alarmClock,
            label: 'Alarms',
            isSelected: selectedIndex == 1,
            activeColor: themePrimary,
            inactiveColor: mutedText,
            onTap: () => onDestinationSelected(1),
          ),
          _NavItem(
            icon: LucideIcons.layoutGrid,
            label: 'Spaces',
            isSelected: selectedIndex == 2,
            activeColor: themePrimary,
            inactiveColor: mutedText,
            onTap: () => onDestinationSelected(2),
          ),
          _NavItem(
            icon: LucideIcons.fileText,
            label: 'Notes',
            isSelected: selectedIndex == 3,
            activeColor: themePrimary,
            inactiveColor: mutedText,
            onTap: () => onDestinationSelected(3),
          ),
          _NavItem(
            icon: LucideIcons.settings,
            label: 'Settings',
            isSelected: selectedIndex == 4,
            activeColor: themePrimary,
            inactiveColor: mutedText,
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
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.16) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 20,
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AuraTypography.label.copyWith(
                    color: activeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

