import 'package:drift/drift.dart';
import 'workspaces_table.dart';
import 'workspace_sections_table.dart';

/// Source: 06_Database/SCHEMA.md — tasks table
class Tasks extends Table {
  TextColumn get id             => text()();
  TextColumn get workspaceId    => text().references(Workspaces, #id)();
  TextColumn get sectionId      => text().references(WorkspaceSections, #id).nullable()();
  TextColumn get parentTaskId   => text().nullable()();
  TextColumn get name           => text()();
  TextColumn get description    => text().nullable()();
  IntColumn  get deadline       => integer().nullable()();
  RealColumn get estimatedHours => real().nullable()();
  TextColumn get priority       => text().withDefault(const Constant('medium'))();
  TextColumn get status         => text().withDefault(const Constant('todo'))();
  BoolColumn get isRecurring    => boolean().withDefault(const Constant(false))();
  TextColumn get recurrenceType => text().nullable()();
  TextColumn get recurrenceDays => text().nullable()();
  IntColumn  get recurrenceStart => integer().nullable()();
  IntColumn  get recurrenceEnd   => integer().nullable()();
  TextColumn get contact         => text().nullable()();
  TextColumn get voiceNotePath   => text().nullable()();
  TextColumn get source          => text().withDefault(const Constant('text'))();
  TextColumn get aiRawTranscript => text().nullable()();
  BoolColumn get aiGenerated     => boolean().withDefault(const Constant(false))();
  IntColumn  get completedAt     => integer().nullable()();
  IntColumn  get createdAt       => integer()();
  IntColumn  get updatedAt       => integer()();
  IntColumn  get deletedAt       => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
