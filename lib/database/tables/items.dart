import 'package:drift/drift.dart';

import 'workspaces.dart';

/// Items table: unified core entity for Tasks, Alarms, Reminders, Events, and Notes.
/// Reference: overhaul-docs/03-database-schema.md Section 2.3
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().nullable().references(Workspaces, #id)();
  TextColumn get sectionId =>
      text().nullable().references(WorkspaceSections, #id)();
  TextColumn get parentId => text().nullable().references(Items, #id)();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get category =>
      text().withDefault(const Constant('reminder'))(); // 'reminder' | 'alarm'
  TextColumn get kind => text().withDefault(
      const Constant('generic'))(); // 'generic' | 'task' | 'event' | 'note'
  IntColumn get fireAt => integer().nullable()();
  IntColumn get deadline => integer().nullable()();
  IntColumn get startTime => integer().nullable()();
  IntColumn get endTime => integer().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get priority =>
      text().withDefault(const Constant('medium'))(); // 'high'|'medium'|'low'
  TextColumn get status => text().withDefault(
      const Constant('pending'))(); // 'pending'|'completed'|'cancelled'
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurrenceRule => text().nullable()();
  TextColumn get soundUri => text().nullable()();
  TextColumn get orbSourceApp => text().nullable()();
  TextColumn get aiTranscript => text().nullable()();
  RealColumn get confidence => real().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
