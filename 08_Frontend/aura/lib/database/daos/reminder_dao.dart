import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_database.dart';
import '../tables/reminders_table.dart';
import '../tables/notification_log_table.dart';

part 'reminder_dao.g.dart';

@DriftAccessor(tables: [Reminders, NotificationLogs])
class ReminderDao extends DatabaseAccessor<AppDatabase> with _$ReminderDaoMixin {
  ReminderDao(super.db);

  /// Watch reminders for a specific task.
  Stream<List<Reminder>> watchByTask(String taskId) =>
      (select(reminders)..where((r) => r.taskId.equals(taskId))).watch();

  /// Get all pending reminders (for notification scheduler on startup).
  Future<List<Reminder>> getPending() =>
      (select(reminders)
            ..where((r) => r.status.equals('pending'))
            ..orderBy([(r) => OrderingTerm(expression: r.fireAt)]))
          .get();

  /// Get reminders missed during DND that have not been replayed.
  Future<List<Reminder>> getDndMissedUnreplayed() =>
      (select(reminders)
            ..where((r) => r.missedDnd.equals(true))
            ..where((r) => r.replayedAt.isNull()))
          .get();

  /// Insert a reminder.
  Future<void> insertReminder(RemindersCompanion reminder) =>
      into(reminders).insert(reminder);

  /// Mark reminder as fired and log it.
  Future<void> markFired(String reminderId, {required bool wasDnd}) =>
      transaction(() async {
        final now = DateTime.now().millisecondsSinceEpoch;
        await (update(reminders)..where((r) => r.id.equals(reminderId))).write(
          RemindersCompanion(
            hasFired: const Value(true),
            missedDnd: Value(wasDnd),
            status: const Value('fired'),
            updatedAt: Value(now),
          ),
        );
        await into(notificationLogs).insert(NotificationLogsCompanion(
          id: Value(_uuid()),
          reminderId: Value(reminderId),
          scheduledAt: Value(now),
          firedAt: Value(now),
          wasDnd: Value(wasDnd),
          createdAt: Value(now),
        ));
      });

  /// Snooze a reminder.
  Future<void> snooze(String reminderId, DateTime until) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(reminders)..where((r) => r.id.equals(reminderId))).write(
      RemindersCompanion(
        status: const Value('snoozed'),
        snoozedUntil: Value(until.millisecondsSinceEpoch),
        updatedAt: Value(now),
      ),
    );
  }

  /// Cancel a reminder (e.g., when task is deleted or completed).
  Future<void> cancel(String reminderId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(reminders)..where((r) => r.id.equals(reminderId))).write(
      RemindersCompanion(
        status: const Value('cancelled'),
        updatedAt: Value(now),
      ),
    );
  }

  /// Cancel all reminders for a task.
  Future<void> cancelAllForTask(String taskId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(reminders)..where((r) => r.taskId.equals(taskId))).write(
      RemindersCompanion(
        status: const Value('cancelled'),
        updatedAt: Value(now),
      ),
    );
  }

  String _uuid() {
    // Simple UUID v4 — real impl uses uuid package
    final ms = DateTime.now().millisecondsSinceEpoch;
    return 'r-$ms';
  }
}

final reminderDaoProvider = Provider<ReminderDao>(
  (ref) => ReminderDao(ref.watch(databaseProvider)),
);
