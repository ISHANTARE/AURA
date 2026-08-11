import 'package:drift/drift.dart';
import 'items_table.dart';
import 'workspaces_table.dart';

class Notes extends Table {
  TextColumn get id          => text()();
  TextColumn get itemId      => text().references(Items, #id).nullable()();
  TextColumn get workspaceId => text().references(Workspaces, #id).nullable()();
  TextColumn get content     => text()();
  TextColumn get type        => text().withDefault(const Constant('text'))();
  TextColumn get filePath    => text().nullable()();
  TextColumn get url         => text().nullable()();
  IntColumn  get createdAt   => integer()();
  IntColumn  get updatedAt   => integer()();
  IntColumn  get deletedAt   => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
