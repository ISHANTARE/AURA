import 'package:drift/drift.dart';
import 'workspaces_table.dart';
import 'workspace_sections_table.dart';

/// Source: 06_Database/SCHEMA.md — events table
class Events extends Table {
  TextColumn get id             => text()();
  TextColumn get workspaceId    => text().references(Workspaces, #id)();
  TextColumn get sectionId      => text().references(WorkspaceSections, #id).nullable()();
  TextColumn get title          => text()();
  TextColumn get description    => text().nullable()();
  IntColumn  get startAt        => integer()();
  IntColumn  get endAt          => integer()();
  TextColumn get location       => text().nullable()();
  BoolColumn get isRecurring    => boolean().withDefault(const Constant(false))();
  TextColumn get recurrenceRule => text().nullable()();
  TextColumn get priority       => text().withDefault(const Constant('medium'))();
  TextColumn get status         => text().withDefault(const Constant('upcoming'))();
  TextColumn get source         => text().withDefault(const Constant('voice'))();
  TextColumn get aiRawTranscript => text().nullable()();
  TextColumn get externalCalId   => text().nullable()();
  IntColumn  get createdAt       => integer()();
  IntColumn  get updatedAt       => integer()();
  IntColumn  get deletedAt       => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
