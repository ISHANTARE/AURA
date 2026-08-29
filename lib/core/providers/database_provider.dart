import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/app_database.dart';
import '../../database/daos/item_dao.dart';
import '../../database/daos/notification_dao.dart';
import '../../database/daos/offline_queue_dao.dart';
import '../../database/daos/shared_content_dao.dart';
import '../../database/daos/workspace_dao.dart';

/// Singleton Drift AppDatabase provider.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// ItemDao provider.
final itemDaoProvider = Provider<ItemDao>((ref) {
  return ref.watch(databaseProvider).itemDao;
});

/// WorkspaceDao provider.
final workspaceDaoProvider = Provider<WorkspaceDao>((ref) {
  return ref.watch(databaseProvider).workspaceDao;
});

/// NotificationDao provider.
final notificationDaoProvider = Provider<NotificationDao>((ref) {
  return ref.watch(databaseProvider).notificationDao;
});

/// OfflineQueueDao provider.
final offlineQueueDaoProvider = Provider<OfflineQueueDao>((ref) {
  return ref.watch(databaseProvider).offlineQueueDao;
});

/// SharedContentDao provider.
final sharedContentDaoProvider = Provider<SharedContentDao>((ref) {
  return ref.watch(databaseProvider).sharedContentDao;
});
