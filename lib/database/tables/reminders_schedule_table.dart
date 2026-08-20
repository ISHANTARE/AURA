import 'package:drift/drift.dart';
import 'items_table.dart';

/// Reminders Schedule Table for Sub-Reminders on Tasks and Events
@DataClassName('ReminderSchedule')
class RemindersSchedule extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text().references(Items, #id, onDelete: KeyAction.cascade)();

  IntColumn get offsetValue => integer()();
  TextColumn get offsetUnit => text()(); // 'minutes' | 'hours' | 'days'

  IntColumn get fireAt => integer()();
  BoolColumn get hasFired => boolean().withDefault(const Constant(false))();
  BoolColumn get missedDnd => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
