import 'package:drift/drift.dart';
import 'workspaces_table.dart';

/// Source: 06_Database/SCHEMA.md — workspace_sections table
class WorkspaceSections extends Table {
  TextColumn get id          => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get name        => text()();
  IntColumn  get sortOrder   => integer().withDefault(const Constant(0))();
  TextColumn get createdBy   => text().withDefault(const Constant('USER_EXPLICIT'))();
  BoolColumn get isArchived  => boolean().withDefault(const Constant(false))();
  IntColumn  get createdAt   => integer()();
  IntColumn  get updatedAt   => integer()();
  IntColumn  get deletedAt   => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
