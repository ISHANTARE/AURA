import 'package:drift/drift.dart';
import 'tasks_table.dart';

class AiActionsLogs extends Table {
  TextColumn get id           => text()();
  TextColumn get inputText    => text()();
  TextColumn get rawResponse  => text()();
  TextColumn get parsedJson   => text()();
  RealColumn get confidence   => real().nullable()();
  TextColumn get actionTaken  => text()();
  TextColumn get taskId       => text().references(Tasks, #id).nullable()();
  BoolColumn get userEdited   => boolean().withDefault(const Constant(false))();
  IntColumn  get createdAt    => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
