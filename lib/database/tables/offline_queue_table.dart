import 'package:drift/drift.dart';

class OfflineQueues extends Table {
  TextColumn get id          => text()();
  TextColumn get type        => text().withDefault(const Constant('transcript'))();
  TextColumn get content     => text()();
  TextColumn get contextJson => text().nullable()();
  TextColumn get status      => text().withDefault(const Constant('pending'))();
  IntColumn  get attempts    => integer().withDefault(const Constant(0))();
  IntColumn  get createdAt   => integer()();
  IntColumn  get processedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
