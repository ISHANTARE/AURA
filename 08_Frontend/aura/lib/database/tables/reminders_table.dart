import 'package:drift/drift.dart';
import 'tasks_table.dart';
import 'events_table.dart';

/// Source: 06_Database/SCHEMA.md — reminders table
class Reminders extends Table {
  TextColumn get id           => text()();
  TextColumn get taskId       => text().references(Tasks, #id).nullable()();
  TextColumn get eventId      => text().references(Events, #id).nullable()();
  IntColumn  get fireAt       => integer()();
  TextColumn get type         => text().withDefault(const Constant('notification'))();
  TextColumn get status       => text().withDefault(const Constant('pending'))();
  IntColumn  get snoozedUntil => integer().nullable()();
  BoolColumn get hasFired     => boolean().withDefault(const Constant(false))();
  BoolColumn get missedDnd    => boolean().withDefault(const Constant(false))();
  IntColumn  get replayedAt   => integer().nullable()();
  IntColumn  get createdAt    => integer()();
  IntColumn  get updatedAt    => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
