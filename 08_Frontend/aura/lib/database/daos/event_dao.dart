import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_database.dart';
import '../tables/events_table.dart';

part 'event_dao.g.dart';

@DriftAccessor(tables: [Events])
class EventDao extends DatabaseAccessor<AppDatabase> with _$EventDaoMixin {
  EventDao(super.db);

  Stream<List<Event>> watchByWorkspace(String workspaceId) =>
      (select(events)
            ..where((e) => e.workspaceId.equals(workspaceId))
            ..where((e) => e.deletedAt.isNull())
            ..orderBy([(e) => OrderingTerm(expression: e.startAt)]))
          .watch();

  Stream<List<Event>> watchUpcoming() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (select(events)
          ..where((e) => e.startAt.isBiggerOrEqualValue(now))
          ..where((e) => e.deletedAt.isNull())
          ..orderBy([(e) => OrderingTerm(expression: e.startAt)]))
        .watch();
  }

  Future<void> insertEvent(EventsCompanion event) => into(events).insert(event);
  Future<bool> updateEvent(EventsCompanion event) => update(events).replace(event);

  Future<void> softDelete(String id) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(events)..where((e) => e.id.equals(id))).write(
      EventsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }
}

final eventDaoProvider = Provider<EventDao>(
  (ref) => EventDao(ref.watch(databaseProvider)),
);
