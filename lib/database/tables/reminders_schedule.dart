import 'package:drift/drift.dart';

import 'items.dart';

/// RemindersSchedule table: scheduled notification occurrences derived from item timing.
/// Reference: overhaul-docs/03-database-schema.md Section 2.4
class RemindersSchedule extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text().references(Items, #id)();
  IntColumn get offsetValue => integer()();
  TextColumn get offsetUnit => text()(); // 'minutes' | 'hours' | 'days' | 'weekly'
  IntColumn get fireAt => integer()();
  BoolColumn get hasFired => boolean().withDefault(const Constant(false))();
  BoolColumn get missedDnd => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
