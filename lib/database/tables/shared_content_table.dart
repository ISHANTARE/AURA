import 'package:drift/drift.dart';
import 'workspaces_table.dart';
import 'items_table.dart';

class SharedContents extends Table {
  TextColumn get id          => text()();
  TextColumn get type        => text()();
  TextColumn get rawPath     => text().nullable()();
  TextColumn get rawUrl      => text().nullable()();
  TextColumn get ocrText     => text().nullable()();
  TextColumn get aiSummary   => text().nullable()();
  TextColumn get pageTitle   => text().nullable()();
  TextColumn get status      => text().withDefault(const Constant('pending'))();
  TextColumn get workspaceId => text().references(Workspaces, #id).nullable()();
  TextColumn get itemId      => text().references(Items, #id).nullable()();
  IntColumn  get createdAt   => integer()();
  IntColumn  get updatedAt   => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
