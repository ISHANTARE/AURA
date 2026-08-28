import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:drift/drift.dart' show Value;

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../reminders/domain/services/reminder_scheduling_service.dart';
import '../providers/home_providers.dart';

/// Modal bottom sheet for quick triage of all accumulated overdue tasks.
class OverdueTriageSheet extends ConsumerWidget {
  const OverdueTriageSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const OverdueTriageSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdueAsync = ref.watch(overdueItemsProvider);
    const accentColor = AuraColors.accentPrimary;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: AuraColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AuraColors.border, width: 2),
          left: BorderSide(color: AuraColors.border, width: 2),
          right: BorderSide(color: AuraColors.border, width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AuraColors.textDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AuraSpacing.md,
              vertical: AuraSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.alertCircle,
                      color: AuraColors.accentRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'OVERDUE TASKS',
                      style: AuraTypography.screenHeader.copyWith(fontSize: 16),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20, color: AuraColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(color: AuraColors.border, height: 1),

          // Content
          Flexible(
            child: overdueAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error loading overdue tasks: $err', style: AuraTypography.bodySmall),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.checkCircle2, color: AuraColors.accentGreen, size: 48),
                        const SizedBox(height: 12),
                        Text('All caught up!', style: AuraTypography.cardTitle),
                        const SizedBox(height: 4),
                        Text(
                          'No overdue tasks remaining.',
                          style: AuraTypography.bodySmall.copyWith(color: AuraColors.textMuted),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AuraSpacing.md),
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _OverdueItemCard(
                      item: item,
                      accentColor: accentColor,
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _OverdueItemCard extends ConsumerWidget {
  const _OverdueItemCard({
    required this.item,
    required this.accentColor,
  });

  final Item item;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadlineMs = item.deadline ?? item.fireAt ?? item.startTime;
    final deadlineDt = deadlineMs != null ? DateTime.fromMillisecondsSinceEpoch(deadlineMs) : null;
    final timeStr = deadlineDt != null
        ? 'Due ${DateFormat('MMM d · h:mm a').format(deadlineDt)}'
        : 'Past due';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AuraColors.bgElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AuraColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: AuraTypography.cardTitle.copyWith(fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AuraColors.accentRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  timeStr,
                  style: AuraTypography.caption.copyWith(
                    color: AuraColors.accentRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (item.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              item.notes!,
              style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          // Action Buttons: Move to Today | +1 Day | Mark Done
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionButton(
                icon: LucideIcons.calendar,
                label: 'Today',
                onTap: () async {
                  final now = DateTime.now();
                  final newTime = DateTime(now.year, now.month, now.day, 23, 59, 0).millisecondsSinceEpoch;
                  await ref.read(itemDaoProvider).updateItemPartial(
                    ItemsCompanion(
                      id: Value(item.id),
                      deadline: Value(newTime),
                      updatedAt: Value(now.millisecondsSinceEpoch),
                    ),
                  );
                  final updated = await ref.read(itemDaoProvider).getById(item.id);
                  if (updated != null) {
                    await ReminderSchedulingService(
                      db: ref.read(databaseProvider),
                    ).syncForItem(updated);
                  }
                },
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: LucideIcons.clock,
                label: '+1 Day',
                onTap: () async {
                  final now = DateTime.now().add(const Duration(days: 1));
                  final newTime = DateTime(now.year, now.month, now.day, 23, 59, 0).millisecondsSinceEpoch;
                  await ref.read(itemDaoProvider).updateItemPartial(
                    ItemsCompanion(
                      id: Value(item.id),
                      deadline: Value(newTime),
                      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
                    ),
                  );
                  final updated = await ref.read(itemDaoProvider).getById(item.id);
                  if (updated != null) {
                    await ReminderSchedulingService(
                      db: ref.read(databaseProvider),
                    ).syncForItem(updated);
                  }
                },
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: LucideIcons.check,
                label: 'Done',
                isPrimary: true,
                accentColor: AuraColors.accentGreen,
                onTap: () async {
                  await ref.read(itemDaoProvider).updateStatus(item.id, 'completed');
                  await ReminderSchedulingService(
                    db: ref.read(databaseProvider),
                  ).cancelForItem(item.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.accentColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AuraColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary ? color.withValues(alpha: 0.2) : AuraColors.bgBase,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPrimary ? color : AuraColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AuraTypography.badgeText.copyWith(
                color: color,
                fontSize: 11,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
