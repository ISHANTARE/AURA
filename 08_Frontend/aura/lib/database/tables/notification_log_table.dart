import 'package:drift/drift.dart';
import 'reminders_table.dart';

class NotificationLogs extends Table {
  TextColumn get id             => text()();
  TextColumn get reminderId     => text().references(Reminders, #id)();
  IntColumn  get scheduledAt    => integer()();
  IntColumn  get firedAt        => integer().nullable()();
  BoolColumn get wasDnd         => boolean().withDefault(const Constant(false))();
  IntColumn  get replayedAt     => integer().nullable()();
  BoolColumn get userDismissed  => boolean().withDefault(const Constant(false))();
  IntColumn  get createdAt      => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
