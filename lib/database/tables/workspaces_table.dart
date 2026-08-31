import 'package:drift/drift.dart';

/// Source: 06_Database/SCHEMA.md — workspaces table
class Workspaces extends Table {
  TextColumn get id        => text()();
  TextColumn get name      => text()();
  TextColumn get colorHex  => text().withDefault(const Constant('#C8FF00'))();
  TextColumn get iconKey   => text().withDefault(const Constant('custom'))();
  IntColumn  get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get createdBy => text().withDefault(const Constant('USER_EXPLICIT'))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn  get createdAt => integer()();
  IntColumn  get updatedAt => integer()();
  IntColumn  get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
