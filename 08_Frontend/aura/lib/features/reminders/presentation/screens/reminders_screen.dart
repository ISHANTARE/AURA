import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../database/app_database.dart';
import '../widgets/snooze_picker_sheet.dart';

/// Reminders Screen — Sprint 6 (F-07)
///
/// Lists all upcoming (pending/snoozed) reminders grouped by day.
/// Allows inline snoozing and cancellation.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App Bar ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AuraSpacing.lg,
                AuraSpacing.md,
                AuraSpacing.lg,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reminders', style: AuraTypography.sectionHeader),
                        const SizedBox(height: AuraSpacing.xs),
                        Text(
                          'Upcoming alerts & deadlines',
                          style: AuraTypography.body,
                        ),
                      ],
                    ),
                  ),
                  // Bell icon with notification indicator
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AuraColors.bgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AuraColors.border, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AuraColors.accentLime,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AuraSpacing.md),

            // ── Reminder List ────────────────────────────────────────────────
            Expanded(
              child: FutureBuilder<List<Reminder>>(
                future: db.reminderDao.getPending(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AuraColors.accentLime,
                        strokeWidth: 2,
                      ),
                    );
                  }

                  final reminders = snapshot.data ?? [];

                  if (reminders.isEmpty) {
                    return _EmptyRemindersState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AuraSpacing.lg,
                      vertical: AuraSpacing.md,
                    ),
                    itemCount: reminders.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AuraSpacing.sm),
                    itemBuilder: (context, index) {
                      final rem = reminders[index];
                      return _ReminderCard(
                        reminder: rem,
                        db: db,
                        onSnooze: () async {
                          final task = await db.taskDao.getById(rem.taskId ?? '');
                          if (context.mounted && task != null) {
                            await SnoozePicker.show(
                              context,
                              reminderId: rem.id,
                              taskId: task.id,
                              taskName: task.name,
                            );
                          }
                        },
                        onCancel: () async {
                          await db.reminderDao.cancel(rem.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Reminder cancelled',
                                  style: AuraTypography.body,
                                ),
                                backgroundColor: AuraColors.bgCard,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reminder Card ─────────────────────────────────────────────────────────────

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.db,
    required this.onSnooze,
    required this.onCancel,
  });

  final Reminder reminder;
  final AppDatabase db;
  final VoidCallback onSnooze;
  final VoidCallback onCancel;

  String _formatFireTime(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final now = DateTime.now();
    final diff = dt.difference(now);

    if (diff.isNegative) return 'Overdue';
    if (diff.inMinutes < 60) return 'In ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'In ${diff.inHours}h';
    if (diff.inDays == 1) return 'Tomorrow';
    return 'In ${diff.inDays} days';
  }

  String _absoluteTime(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final m = dt.minute.toString().padLeft(2, '0');
    final day =
        '${dt.day}/${dt.month}/${dt.year.toString().substring(2)}';
    return '$day · $h:$m $ampm';
  }

  Color _timeColor(int epochMs) {
    final diff = DateTime.fromMillisecondsSinceEpoch(epochMs).difference(DateTime.now());
    if (diff.isNegative) return AuraColors.accentRed;
    if (diff.inHours < 6) return AuraColors.accentOrange;
    return AuraColors.accentGreen;
  }

  @override
  Widget build(BuildContext context) {
    final fireAt = reminder.snoozedUntil ?? reminder.fireAt;
    final isSnoozed = reminder.status == 'snoozed';

    return FutureBuilder<Task?>(
      future: db.taskDao.getById(reminder.taskId ?? ''),
      builder: (context, snap) {
        final task = snap.data;
        final taskName = task?.name ?? 'Reminder';

        return Container(
          decoration: BoxDecoration(
            color: AuraColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AuraColors.border,
              width: AuraSpacing.borderWidth,
            ),
            boxShadow: const [
              BoxShadow(
                color: AuraColors.shadow,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AuraSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left — time badge
                Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(
                    vertical: AuraSpacing.xs,
                    horizontal: AuraSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _timeColor(fireAt).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _timeColor(fireAt).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSnoozed
                            ? Icons.snooze_rounded
                            : Icons.notifications_active_outlined,
                        size: 18,
                        color: _timeColor(fireAt),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatFireTime(fireAt),
                        style: AuraTypography.label.copyWith(
                          color: _timeColor(fireAt),
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AuraSpacing.md),

                // Center — task name + absolute time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskName,
                        style: AuraTypography.cardTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AuraSpacing.xs),
                      Row(
                        children: [
                          if (isSnoozed) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AuraColors.accentBlue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AuraColors.accentBlue.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                'SNOOZED',
                                style: AuraTypography.label.copyWith(
                                  color: AuraColors.accentBlue,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                            const SizedBox(width: AuraSpacing.xs),
                          ],
                          Text(
                            _absoluteTime(fireAt),
                            style: AuraTypography.body,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right — action buttons
                Column(
                  children: [
                    _ActionBtn(
                      icon: Icons.snooze_rounded,
                      color: AuraColors.accentBlue,
                      tooltip: 'Snooze',
                      onTap: onSnooze,
                    ),
                    const SizedBox(height: AuraSpacing.xs),
                    _ActionBtn(
                      icon: Icons.close,
                      color: AuraColors.accentRed,
                      tooltip: 'Cancel',
                      onTap: onCancel,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyRemindersState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AuraColors.accentLime.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: AuraColors.accentLime.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              color: AuraColors.accentLime,
              size: 32,
            ),
          ),
          const SizedBox(height: AuraSpacing.md),
          Text('All clear', style: AuraTypography.sectionHeader),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            'No upcoming reminders.\nVoice-capture a task to schedule one.',
            style: AuraTypography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
