import 'package:drift/drift.dart';
import 'tasks_table.dart';

class DailyLogs extends Table {
  TextColumn get id       => text()();
  TextColumn get taskId   => text().references(Tasks, #id)();
  IntColumn  get logDate  => integer()();
  TextColumn get status   => text()();
  IntColumn  get doneAt   => integer().nullable()();
  IntColumn  get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
