import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_database.dart';
import '../tables/notification_log_table.dart';

part 'notification_dao.g.dart';

@DriftAccessor(tables: [NotificationLogs])
class NotificationDao extends DatabaseAccessor<AppDatabase> with _$NotificationDaoMixin {
  NotificationDao(super.db);

  Future<List<NotificationLog>> getUnreplayed() =>
      (select(notificationLogs)
            ..where((n) => n.wasDnd.equals(true))
            ..where((n) => n.replayedAt.isNull()))
          .get();

  Future<void> markReplayed(String id) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(notificationLogs)..where((n) => n.id.equals(id))).write(
      NotificationLogsCompanion(replayedAt: Value(now)),
    );
  }
}

final notificationDaoProvider = Provider<NotificationDao>(
  (ref) => NotificationDao(ref.watch(databaseProvider)),
);
