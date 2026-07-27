import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/constants/spacing.dart';
import '../../domain/services/reminder_scheduler.dart';
import '../../../../database/app_database.dart';

/// Quick-snooze bottom sheet for notification action handling.
///
/// Shows 4 snooze options matching PRD F-07:
///   • 30 minutes
///   • 1 hour
///   • Tonight 9 PM
///   • Tomorrow 8 AM
class SnoozePicker extends ConsumerWidget {
  const SnoozePicker({
    super.key,
    required this.reminderId,
    required this.taskId,
    required this.taskName,
  });

  final String reminderId;
  final String taskId;
  final String taskName;

  static Future<void> show(
    BuildContext context, {
    required String reminderId,
    required String taskId,
    required String taskName,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SnoozePicker(
        reminderId: reminderId,
        taskId: taskId,
        taskName: taskName,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    final scheduler = ReminderScheduler(db);

    final now = DateTime.now();
    final tonight9pm = DateTime(now.year, now.month, now.day, 21, 0);
    final tomorrow8am = DateTime(now.year, now.month, now.day + 1, 8, 0);

    final options = [
      const _SnoozeOption(
        label: '30 min',
        icon: Icons.timer_outlined,
        duration: Duration(minutes: 30),
      ),
      const _SnoozeOption(
        label: '1 hour',
        icon: Icons.hourglass_empty_rounded,
        duration: Duration(hours: 1),
      ),
      _SnoozeOption(
        label: 'Tonight 9 PM',
        icon: Icons.nightlight_round,
        absoluteTime: tonight9pm.isAfter(now) ? tonight9pm : null,
      ),
      _SnoozeOption(
        label: 'Tomorrow 8 AM',
        icon: Icons.wb_sunny_outlined,
        absoluteTime: tomorrow8am,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AuraColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: AuraColors.border, width: 2),
          left: BorderSide(color: AuraColors.border, width: 1),
          right: BorderSide(color: AuraColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AuraSpacing.lg,
        AuraSpacing.md,
        AuraSpacing.lg,
        AuraSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AuraColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AuraSpacing.md),

          // Header
          Text('Snooze Reminder', style: AuraTypography.sectionHeader),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            taskName,
            style: AuraTypography.body.copyWith(color: AuraColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AuraSpacing.md),

          // Snooze options grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AuraSpacing.sm,
              mainAxisSpacing: AuraSpacing.sm,
              childAspectRatio: 2.8,
            ),
            itemCount: options.length,
            itemBuilder: (context, i) {
              final opt = options[i];
              final isDisabled =
                  opt.absoluteTime == null && opt.duration == null;

              return _SnoozeOptionTile(
                option: opt,
                isDisabled: isDisabled,
                onTap: isDisabled
                    ? null
                    : () async {
                        Navigator.of(context).pop();
                        final duration = opt.duration ??
                            opt.absoluteTime!.difference(DateTime.now());
                        await scheduler.snoozeReminder(
                          reminderId,
                          taskId,
                          duration,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Snoozed: ${opt.label}',
                                style: AuraTypography.body,
                              ),
                              backgroundColor: AuraColors.bgCard,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
              );
            },
          ),

          const SizedBox(height: AuraSpacing.sm),

          // Dismiss button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AuraColors.textSecondary,
              ),
              child: Text(
                'DISMISS',
                style: AuraTypography.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Option model ──────────────────────────────────────────────────────────────

class _SnoozeOption {
  const _SnoozeOption({
    required this.label,
    required this.icon,
    this.duration,
    this.absoluteTime,
  });

  final String label;
  final IconData icon;
  final Duration? duration;
  final DateTime? absoluteTime;
}

// ── Option tile ───────────────────────────────────────────────────────────────

class _SnoozeOptionTile extends StatelessWidget {
  const _SnoozeOptionTile({
    required this.option,
    required this.isDisabled,
    this.onTap,
  });

  final _SnoozeOption option;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tileColor = isDisabled ? AuraColors.bgBase.withValues(alpha: 0.4) : AuraColors.bgBase;
    final borderColor = isDisabled ? AuraColors.borderMuted : AuraColors.border;
    final iconColor = isDisabled
        ? AuraColors.textDisabled
        : AuraColors.accentLime;
    final textColor = isDisabled
        ? AuraColors.textDisabled
        : AuraColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.sm),
        child: Row(
          children: [
            Icon(option.icon, size: 18, color: iconColor),
            const SizedBox(width: AuraSpacing.xs),
            Expanded(
              child: Text(
                option.label,
                style: AuraTypography.overline.copyWith(color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
