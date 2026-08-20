import 'package:drift/drift.dart';

class SyncQueues extends Table {
  TextColumn get id         => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId   => text()();
  TextColumn get operation  => text()();
  TextColumn get payload    => text()();
  TextColumn get status     => text().withDefault(const Constant('pending'))();
  IntColumn  get attempts   => integer().withDefault(const Constant(0))();
  IntColumn  get createdAt  => integer()();
  IntColumn  get syncedAt   => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
