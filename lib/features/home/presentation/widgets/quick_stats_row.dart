import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import 'bento_card.dart';

/// Quick stats summary row — shows Pending / Completed / Overdue counts.
/// Sits at the top of the Bento grid as a lightweight data snapshot.
class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({super.key, required this.stats});

  final AsyncValue<QuickStats> stats;

  @override
  Widget build(BuildContext context) {
    return stats.when(
      loading: () => const _StatsShimmer(),
      error: (_, __) => const SizedBox.shrink(),
      data: (s) => BentoCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AuraSpacing.md,
          vertical: AuraSpacing.sm,
        ),
        child: Row(
          children: [
            _StatChip(
              icon: LucideIcons.clock,
              label: 'PENDING',
              count: s.pending,
              color: Theme.of(context).colorScheme.primary,
            ),
            _VerticalDivider(),
            _StatChip(
              icon: LucideIcons.checkCircle,
              label: 'DONE',
              count: s.completed,
              color: AuraColors.accentGreen,
            ),
            _VerticalDivider(),
            _StatChip(
              icon: LucideIcons.alertCircle,
              label: 'OVERDUE',
              count: s.overdue,
              color: s.overdue > 0 ? AuraColors.accentRed : AuraColors.textDisabled,
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
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: AuraTypography.bentoMetricValue.copyWith(
                  color: color,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AuraTypography.label.copyWith(
              color: AuraColors.textSecondary,
              fontSize: 9,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AuraColors.borderMuted,
      margin: const EdgeInsets.symmetric(horizontal: AuraSpacing.sm),
    );
  }
}

class _StatsShimmer extends StatelessWidget {
  const _StatsShimmer();

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AuraSpacing.md,
        vertical: AuraSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          3,
          (i) => Container(
            width: 60,
            height: 36,
            decoration: BoxDecoration(
              color: AuraColors.borderMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
