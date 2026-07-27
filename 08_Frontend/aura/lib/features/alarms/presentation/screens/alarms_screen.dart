import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../database/app_database.dart';
import '../../../reminders/data/services/notification_service.dart';
import '../../../reminders/domain/services/reminder_scheduler.dart';

/// Alarms Screen — Dedicated Alarms & Time Alerts tab (Sprint 8)
class AlarmsScreen extends ConsumerWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AuraSpacing.md),
              child: Row(
                children: [
                  const Icon(LucideIcons.alarmClock, color: AuraColors.accentLime, size: 24),
                  const SizedBox(width: AuraSpacing.xs),
                  Text('Alarms & Time Alerts', style: AuraTypography.sectionHeader),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.plus, color: AuraColors.accentLime),
                    onPressed: () => _showAddAlarmSheet(context, db),
                    tooltip: 'Add Alarm',
                  ),
                ],
              ),
            ),

            // Alarms List
            Expanded(
              child: StreamBuilder<List<Reminder>>(
                stream: (db.select(db.reminders)
                      ..where((r) => r.type.equals('alarm'))
                      ..orderBy([(r) => OrderingTerm.asc(r.fireAt)]))
                    .watch(),
                builder: (context, snapshot) {
                  final alarms = snapshot.data ?? [];

                  if (alarms.isEmpty) {
                    return _buildEmptyAlarms();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AuraSpacing.md),
                    itemCount: alarms.length,
                    itemBuilder: (context, i) {
                      final item = alarms[i];
                      final dt = DateTime.fromMillisecondsSinceEpoch(item.fireAt);
                      final isPending = item.status == 'pending';

                      return GestureDetector(
                        onTap: () => _editAlarmTime(context, db, item, dt),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: AuraSpacing.sm),
                          padding: const EdgeInsets.all(AuraSpacing.md),
                          decoration: BoxDecoration(
                            color: AuraColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isPending ? AuraColors.accentLime : AuraColors.borderMuted,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _formatTime(dt),
                                style: AuraTypography.display.copyWith(
                                  fontSize: 26,
                                  color: isPending ? AuraColors.textPrimary : AuraColors.textDisabled,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, size: 18, color: AuraColors.accentRed),
                                onPressed: () async {
                                  await NotificationService().cancel(item.id.hashCode);
                                  await (db.delete(db.reminders)..where((r) => r.id.equals(item.id))).go();
                                },
                              ),
                              const SizedBox(width: 4),
                              Switch(
                                value: isPending,
                                activeColor: AuraColors.accentLime,
                                onChanged: (val) async {
                                  final newStatus = val ? 'pending' : 'cancelled';
                                  await (db.update(db.reminders)
                                        ..where((r) => r.id.equals(item.id)))
                                      .write(RemindersCompanion(status: Value(newStatus)));

                                  if (val) {
                                    final alarmScheduler = ReminderScheduler(db);
                                    await alarmScheduler.scheduleAlarmDirect(
                                      alarmId: item.id,
                                      title: 'Alarm ${_formatTime(dt)}',
                                      fireAt: dt,
                                    );
                                  } else {
                                    await NotificationService().cancel(item.id.hashCode);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
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

  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $ampm';
  }

  Widget _buildEmptyAlarms() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AuraColors.accentLime.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AuraColors.accentLime.withValues(alpha: 0.4), width: 1.5),
            ),
            child: const Icon(LucideIcons.alarmClock, color: AuraColors.accentLime, size: 28),
          ),
          const SizedBox(height: AuraSpacing.md),
          Text('No alarms set', style: AuraTypography.sectionHeader),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            'Tap the + button or floating orb to set an alarm',
            style: AuraTypography.body.copyWith(color: AuraColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddAlarmSheet(BuildContext context, AppDatabase db) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null || !context.mounted) return;

    final now = DateTime.now();
    var fireDt = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
    if (fireDt.isBefore(now)) {
      fireDt = fireDt.add(const Duration(days: 1));
    }

    final alarmId = DateTime.now().millisecondsSinceEpoch.toString();
    final nowEpoch = now.millisecondsSinceEpoch;

    await db.into(db.reminders).insert(
          RemindersCompanion.insert(
            id: alarmId,
            fireAt: fireDt.millisecondsSinceEpoch,
            type: const Value('alarm'),
            status: const Value('pending'),
            createdAt: nowEpoch,
            updatedAt: nowEpoch,
          ),
        );

    final alarmScheduler = ReminderScheduler(db);
    await alarmScheduler.scheduleAlarmDirect(
      alarmId: alarmId,
      title: 'Alarm ${_formatTime(fireDt)}',
      fireAt: fireDt,
    );
  }

  void _editAlarmTime(BuildContext context, AppDatabase db, Reminder item, DateTime currentDt) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDt),
    );

    if (selectedTime == null || !context.mounted) return;

    final now = DateTime.now();
    var fireDt = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
    if (fireDt.isBefore(now)) {
      fireDt = fireDt.add(const Duration(days: 1));
    }

    await (db.update(db.reminders)..where((r) => r.id.equals(item.id))).write(
      RemindersCompanion(
        fireAt: Value(fireDt.millisecondsSinceEpoch),
        status: const Value('pending'),
        updatedAt: Value(now.millisecondsSinceEpoch),
      ),
    );

    final alarmScheduler = ReminderScheduler(db);
    await alarmScheduler.scheduleAlarmDirect(
      alarmId: item.id,
      title: 'Alarm ${_formatTime(fireDt)}',
      fireAt: fireDt,
    );
  }
}
