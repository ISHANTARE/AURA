import 'package:drift/drift.dart';
import 'items_table.dart';

class DailyLogs extends Table {
  TextColumn get id       => text()();
  TextColumn get itemId   => text().references(Items, #id)();
  IntColumn  get logDate  => integer()();
  TextColumn get status   => text()();
  IntColumn  get doneAt   => integer().nullable()();
  IntColumn  get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
