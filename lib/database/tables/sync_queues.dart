import 'package:drift/drift.dart';

/// SyncQueues table: staging buffer for cloud sync mutations.
/// Reference: overhaul-docs/03-database-schema.md Section 2.11
class SyncQueues extends Table {
  TextColumn get id => text()();
  TextColumn get entityType =>
      text()(); // 'item' | 'workspace' | 'note' | etc.
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // 'INSERT' | 'UPDATE' | 'DELETE'
  TextColumn get payload => text()();
  TextColumn get status => text().withDefault(
      const Constant('pending'))(); // 'pending' | 'synced' | 'failed'
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get syncedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
