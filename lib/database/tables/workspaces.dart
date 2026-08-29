import 'package:drift/drift.dart';

/// Workspaces table representing organizational folders grouping items and sections.
/// Reference: overhaul-docs/03-database-schema.md Section 2.1
class Workspaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get colorHex => text().withDefault(const Constant('#C8FF00'))();
  TextColumn get iconKey => text().withDefault(const Constant('custom'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get createdBy => text().withDefault(const Constant('user'))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// WorkspaceSections table representing sub-sections / Kanban columns in a workspace.
/// Reference: overhaul-docs/03-database-schema.md Section 2.2
class WorkspaceSections extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get createdBy => text().withDefault(const Constant('user'))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
