import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/notification_logs.dart';
import '../tables/reminders_schedule.dart';

part 'notification_dao.g.dart';

/// DAO managing Notification Logs and DND catchup operations.
/// Reference: overhaul-docs/03-database-schema.md Section 3
@DriftAccessor(tables: [NotificationLogs, RemindersSchedule])
class NotificationDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationDaoMixin {
  NotificationDao(super.db);

  /// Retrieves all notifications fired during DND that have not been replayed.
  Future<List<NotificationLog>> getUnreplayed() {
    return (select(notificationLogs)
          ..where((t) => t.wasDnd.equals(true) & t.replayedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
        .get();
  }

  /// Marks a DND notification as replayed.
  Future<void> markReplayed(String id, int replayedAt) {
    return (update(notificationLogs)..where((t) => t.id.equals(id))).write(
      NotificationLogsCompanion(replayedAt: Value(replayedAt)),
    );
  }

  /// Inserts a notification log entry.
  Future<int> insertLog(NotificationLogsCompanion log) {
    return into(notificationLogs).insert(log);
  }

  /// Updates a log when a notification fires.
  Future<void> markFired(String id, int firedAt, bool wasDnd) {
    return (update(notificationLogs)..where((t) => t.id.equals(id))).write(
      NotificationLogsCompanion(
        firedAt: Value(firedAt),
        wasDnd: Value(wasDnd),
      ),
    );
  }
}
