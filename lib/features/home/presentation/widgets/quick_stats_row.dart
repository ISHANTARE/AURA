import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../providers/home_providers.dart';
import 'bento_card.dart';
import 'overdue_triage_sheet.dart';

/// Top Quick Stats summary row — always shows TODAY'S Pending / Completed + Overdue counts.
/// Sits at the top of the Bento cockpit as a lightweight, interactive real-time data snapshot.
class QuickStatsRow extends ConsumerWidget {
  const QuickStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayStatsAsync = ref.watch(todayStatsProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryTextColor = AuraColors.textSecondaryOf(context);
    final borderColor = AuraColors.borderOf(context);

    return todayStatsAsync.when(
      loading: () => const _StatsShimmer(),
      error: (_, __) => const SizedBox.shrink(),
      data: (s) => BentoCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AuraSpacing.md,
          vertical: AuraSpacing.sm + 2,
        ),
        child: Row(
          children: [
            _StatChip(
              icon: LucideIcons.clock,
              label: 'TODAY PENDING',
              count: s.pending,
              color: primaryColor,
              secondaryColor: secondaryTextColor,
              onTap: () {
                // Focus active day to today
                final now = DateTime.now();
                ref.read(selectedDateProvider.notifier).state =
                    DateTime(now.year, now.month, now.day);
                ref.read(selectedDayFilterProvider.notifier).state =
                    DayFilter.pendingOnly;
              },
            ),
            _VerticalDivider(color: borderColor),
            _StatChip(
              icon: LucideIcons.checkCircle,
              label: 'TODAY DONE',
              count: s.completed,
              color: AuraColors.accentGreen,
              secondaryColor: secondaryTextColor,
              onTap: () {
                // Focus active day to today
                final now = DateTime.now();
                ref.read(selectedDateProvider.notifier).state =
                    DateTime(now.year, now.month, now.day);
                ref.read(selectedDayFilterProvider.notifier).state =
                    DayFilter.completedOnly;
              },
            ),
            _VerticalDivider(color: borderColor),
            _StatChip(
              icon: LucideIcons.alertCircle,
              label: 'OVERDUE',
              count: s.overdue,
              color: s.overdue > 0
                  ? AuraColors.accentRed
                  : AuraColors.textMutedOf(context),
              secondaryColor: secondaryTextColor,
              onTap: s.overdue > 0
                  ? () {
                      HapticFeedback.lightImpact();
                      OverdueTriageSheet.show(context);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.secondaryColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final Color secondaryColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 5),
                Text(
                  '$count',
                  style: AuraTypography.bentoMetricValue.copyWith(
                    color: color,
                    fontSize: 20,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AuraTypography.label.copyWith(
                color: secondaryColor,
                fontSize: 9,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: color.withValues(alpha: 0.35),
      margin: const EdgeInsets.symmetric(horizontal: AuraSpacing.xs),
    );
  }
}

class _StatsShimmer extends StatelessWidget {
  const _StatsShimmer();

  @override
  Widget build(BuildContext context) {
    final borderColor = AuraColors.borderOf(context);

    return BentoCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AuraSpacing.md,
        vertical: AuraSpacing.sm + 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          3,
          (i) => Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }
}
