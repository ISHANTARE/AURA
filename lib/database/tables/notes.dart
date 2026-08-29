import 'package:drift/drift.dart';

import 'items.dart';
import 'workspaces.dart';

/// Notes table: standalone note records and rich attachments.
/// Reference: overhaul-docs/03-database-schema.md Section 2.5
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text().nullable().references(Items, #id)();
  TextColumn get workspaceId => text().nullable().references(Workspaces, #id)();
  TextColumn get content => text()();
  TextColumn get type => text().withDefault(
      const Constant('text'))(); // 'text' | 'link' | 'ocr' | 'audio'
  TextColumn get filePath => text().nullable()();
  TextColumn get url => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
