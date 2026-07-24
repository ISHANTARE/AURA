import 'package:drift/drift.dart';
import 'tasks_table.dart';
import 'events_table.dart';
import 'workspaces_table.dart';

class Notes extends Table {
  TextColumn get id          => text()();
  TextColumn get taskId      => text().references(Tasks, #id).nullable()();
  TextColumn get eventId     => text().references(Events, #id).nullable()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get content     => text()();
  TextColumn get type        => text().withDefault(const Constant('text'))();
  TextColumn get filePath    => text().nullable()();
  TextColumn get url         => text().nullable()();
  IntColumn  get createdAt   => integer()();
  IntColumn  get updatedAt   => integer()();
  IntColumn  get deletedAt   => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
