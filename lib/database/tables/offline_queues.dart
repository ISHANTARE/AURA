import 'package:drift/drift.dart';

/// OfflineQueues table: FIFO persistent buffer for voice captures recorded while offline.
/// Reference: overhaul-docs/03-database-schema.md Section 2.9
class OfflineQueues extends Table {
  TextColumn get id => text()();
  TextColumn get type => text().withDefault(
      const Constant('transcript'))(); // 'transcript' | 'action'
  TextColumn get content => text()();
  TextColumn get contextJson => text().nullable()();
  TextColumn get status => text().withDefault(
      const Constant('pending'))(); // 'pending'|'processing'|'processed'|'failed'
  IntColumn get attempts =>
      integer().withDefault(const Constant(0))(); // Max: 5 attempts
  IntColumn get createdAt => integer()();
  IntColumn get processedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
