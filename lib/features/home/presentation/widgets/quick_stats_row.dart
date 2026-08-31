import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../providers/home_providers.dart';
import 'overdue_triage_sheet.dart';

/// Top stats split cards:
/// Card 1: Today's Tasks (Pending & Completed strictly for today).
/// Card 2: Cumulative Overdue Accumulator (Tappable → opens OverdueTriageSheet).
class QuickStatsRow extends ConsumerWidget {
  const QuickStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayStatsProvider);
    final overdueAsync = ref.watch(overdueItemsProvider);
    const accentColor = AuraColors.accentPrimary;

    final todayStats = todayAsync.value ?? const TodayStats(pending: 0, completed: 0);
    final overdueCount = overdueAsync.value?.length ?? 0;

    return Row(
      children: [
        // ── Card 1: Today's Focus (Pending & Done) ─────────────────────────
        Expanded(
          flex: 55,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AuraColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AuraColors.border, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.calendarCheck2, size: 13, color: accentColor),
                    const SizedBox(width: 6),
                    Text(
                      "TODAY'S TASKS",
                      style: AuraTypography.label.copyWith(
                        color: AuraColors.textSecondary,
                        fontSize: 9,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Pending
                    Column(
                      children: [
                        Text(
                          '${todayStats.pending}',
                          style: AuraTypography.bentoMetricValue.copyWith(
                            color: accentColor,
                            fontSize: 20,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'PENDING',
                          style: AuraTypography.caption.copyWith(
                            color: AuraColors.textMuted,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: AuraColors.borderMuted,
                    ),
                    // Done
                    Column(
                      children: [
                        Text(
                          '${todayStats.completed}',
                          style: AuraTypography.bentoMetricValue.copyWith(
                            color: AuraColors.accentGreen,
                            fontSize: 20,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'DONE',
                          style: AuraTypography.caption.copyWith(
                            color: AuraColors.textMuted,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AuraSpacing.sm),

        // ── Card 2: Cumulative Overdue Accumulator ──────────────────────────
        Expanded(
          flex: 45,
          child: InkWell(
            onTap: () => OverdueTriageSheet.show(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: overdueCount > 0
                    ? AuraColors.accentRed.withValues(alpha: 0.08)
                    : AuraColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: overdueCount > 0 ? AuraColors.accentRed : AuraColors.border,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.alertCircle,
                            size: 13,
                            color: overdueCount > 0 ? AuraColors.accentRed : AuraColors.textDisabled,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'OVERDUE',
                            style: AuraTypography.label.copyWith(
                              color: overdueCount > 0 ? AuraColors.accentRed : AuraColors.textSecondary,
                              fontSize: 9,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (overdueCount > 0)
                        Icon(LucideIcons.chevronRight, size: 13, color: AuraColors.accentRed.withValues(alpha: 0.7)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '$overdueCount',
                        style: AuraTypography.bentoMetricValue.copyWith(
                          color: overdueCount > 0 ? AuraColors.accentRed : AuraColors.textDisabled,
                          fontSize: 20,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        overdueCount == 1 ? 'task' : 'tasks',
                        style: AuraTypography.caption.copyWith(
                          color: overdueCount > 0 ? AuraColors.accentRed : AuraColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

