import 'package:drift/drift.dart';
import 'items_table.dart';

class AiActionsLogs extends Table {
  TextColumn get id           => text()();
  TextColumn get inputText    => text()();
  TextColumn get rawResponse  => text()();
  TextColumn get parsedJson   => text()();
  RealColumn get confidence   => real().nullable()();
  TextColumn get actionTaken  => text()();
  TextColumn get itemId       => text().references(Items, #id).nullable()();
  BoolColumn get userEdited   => boolean().withDefault(const Constant(false))();
  IntColumn  get createdAt    => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
