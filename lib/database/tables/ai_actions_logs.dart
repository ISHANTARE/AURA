import 'package:drift/drift.dart';

import 'items.dart';

/// AiActionsLogs table: immutable audit trail of AI intent extractions.
/// Reference: overhaul-docs/03-database-schema.md Section 2.8
class AiActionsLogs extends Table {
  TextColumn get id => text()();
  TextColumn get inputText => text()();
  TextColumn get rawResponse => text()();
  TextColumn get parsedJson => text()();
  RealColumn get confidence => real().nullable()();
  TextColumn get actionTaken => text()();
  TextColumn get itemId => text().nullable().references(Items, #id)();
  BoolColumn get userEdited => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
