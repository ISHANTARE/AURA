import 'package:drift/drift.dart';

import 'items.dart';
import 'workspaces.dart';

/// SharedContents table: staging buffer for incoming Android Share Intents (ACTION_SEND).
/// Reference: overhaul-docs/03-database-schema.md Section 2.6
class SharedContents extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // 'text' | 'image' | 'url' | 'file'
  TextColumn get rawPath => text().nullable()();
  TextColumn get rawUrl => text().nullable()();
  TextColumn get ocrText => text().nullable()();
  TextColumn get aiSummary => text().nullable()();
  TextColumn get pageTitle => text().nullable()();
  TextColumn get status => text().withDefault(
      const Constant('pending'))(); // 'pending' | 'processed' | 'failed'
  TextColumn get workspaceId => text().nullable().references(Workspaces, #id)();
  TextColumn get itemId => text().nullable().references(Items, #id)();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
