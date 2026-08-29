import 'package:drift/drift.dart';

import 'items.dart';

/// DailyLogs table: daily activity and completion log per item.
/// Reference: overhaul-docs/03-database-schema.md Section 2.10
class DailyLogs extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text().references(Items, #id)();
  IntColumn get logDate => integer()(); // Start of day timestamp (epoch ms)
  TextColumn get status =>
      text()(); // Status snapshot ('pending' | 'completed')
  IntColumn get doneAt => integer().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
