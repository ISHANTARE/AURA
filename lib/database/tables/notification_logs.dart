import 'package:drift/drift.dart';

import 'reminders_schedule.dart';

/// NotificationLogs table: audit history and DND catchup log for dispatched notifications.
/// Reference: overhaul-docs/03-database-schema.md Section 2.7
class NotificationLogs extends Table {
  TextColumn get id => text()();
  TextColumn get reminderId => text().references(RemindersSchedule, #id)();
  IntColumn get scheduledAt => integer()();
  IntColumn get firedAt => integer().nullable()();
  BoolColumn get wasDnd => boolean().withDefault(const Constant(false))();
  IntColumn get replayedAt => integer().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
