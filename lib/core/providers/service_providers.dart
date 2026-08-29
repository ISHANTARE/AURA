import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/capture/domain/execute_ai_action_usecase.dart';
import '../../features/capture/services/offline_queue_processor.dart';
import '../../features/reminders/services/dnd_service.dart';
import '../../features/reminders/services/reminder_scheduling_service.dart';
import '../services/lifecycle_sync_service.dart';
import '../services/notification_service.dart';
import 'database_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final reminderSchedulingServiceProvider = Provider<ReminderSchedulingService>((ref) {
  return ReminderSchedulingService(
    itemDao: ref.watch(itemDaoProvider),
    notificationService: ref.watch(notificationServiceProvider),
    db: ref.watch(databaseProvider),
  );
});

final lifecycleSyncServiceProvider = Provider<LifecycleSyncService>((ref) {
  return LifecycleSyncService(
    itemDao: ref.watch(itemDaoProvider),
    scheduler: ref.watch(reminderSchedulingServiceProvider),
    notificationService: ref.watch(notificationServiceProvider),
    db: ref.watch(databaseProvider),
  );
});

final dndServiceProvider = Provider<DndService>((ref) {
  final service = DndService(
    notificationDao: ref.watch(notificationDaoProvider),
    notificationService: ref.watch(notificationServiceProvider),
  );
  service.startListening();
  return service;
});

final offlineQueueProcessorProvider = Provider<OfflineQueueProcessor>((ref) {
  return OfflineQueueProcessor(
    offlineQueueDao: ref.watch(offlineQueueDaoProvider),
    executeAiActionUseCase: ExecuteAiActionUseCase(
      db: ref.watch(databaseProvider),
      itemDao: ref.watch(itemDaoProvider),
      workspaceDao: ref.watch(workspaceDaoProvider),
      schedulingService: ref.watch(reminderSchedulingServiceProvider),
    ),
  );
});
