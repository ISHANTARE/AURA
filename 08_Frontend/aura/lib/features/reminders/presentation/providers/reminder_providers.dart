import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aura/database/app_database.dart';
import 'package:aura/database/daos/notification_dao.dart';
import 'package:aura/database/daos/reminder_dao.dart';
import 'package:aura/database/daos/task_dao.dart';
import 'package:aura/platform/dnd_channel.dart';
import 'package:aura/features/reminders/domain/entities/reminder_models.dart';
import 'package:aura/features/reminders/domain/usecases/overdue_reminder_usecase.dart';
import 'package:aura/features/reminders/domain/usecases/replay_dnd_notifications_usecase.dart';
import 'package:aura/features/reminders/domain/usecases/schedule_reminder_usecase.dart';
import 'package:aura/features/reminders/domain/usecases/snooze_reminder_usecase.dart';

// Platform channel provider
final dndChannelProvider = Provider<DndChannel>((ref) => DndChannel());

// Stream of real-time DND state toggles
final dndStatusStreamProvider = StreamProvider<bool>((ref) {
  return ref.watch(dndChannelProvider).dndStateStream;
});

// Current DND status future provider
final isDndActiveProvider = FutureProvider<bool>((ref) async {
  return ref.watch(dndChannelProvider).isDndActive();
});

// Stream of reminders for a specific task
final taskRemindersStreamProvider = StreamProvider.family<List<Reminder>, String>((ref, taskId) {
  final reminderDao = ref.watch(reminderDaoProvider);
  return reminderDao.watchByTask(taskId);
});

// UseCase Providers
final scheduleReminderUseCaseProvider = Provider<ScheduleReminderUseCase>((ref) {
  return ScheduleReminderUseCase(reminderDao: ref.watch(reminderDaoProvider));
});

final snoozeReminderUseCaseProvider = Provider<SnoozeReminderUseCase>((ref) {
  return SnoozeReminderUseCase(reminderDao: ref.watch(reminderDaoProvider));
});

final replayDndNotificationsUseCaseProvider = Provider<ReplayDndNotificationsUseCase>((ref) {
  return ReplayDndNotificationsUseCase(
    notificationDao: ref.watch(notificationDaoProvider),
    reminderDao: ref.watch(reminderDaoProvider),
    taskDao: ref.watch(taskDaoProvider),
  );
});

final overdueReminderUseCaseProvider = Provider<OverdueReminderUseCase>((ref) {
  return OverdueReminderUseCase(taskDao: ref.watch(taskDaoProvider));
});

// StateNotifier for executing reminder actions
class ReminderActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ReminderActionNotifier(this._ref) : super(const AsyncData(null));

  Future<void> scheduleForTask({
    required String taskId,
    required String title,
    required DateTime deadline,
    bool isProject = false,
    bool isEvent = false,
    List<DateTime>? customReminderTimes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = _ref.read(scheduleReminderUseCaseProvider);
      await useCase.execute(
        taskId: taskId,
        title: title,
        deadline: deadline,
        isProject: isProject,
        isEvent: isEvent,
        customReminderTimes: customReminderTimes,
      );
    });
  }

  Future<void> snoozeReminder({
    required String reminderId,
    required String taskId,
    required String taskTitle,
    required SnoozePreset preset,
    DateTime? customDateTime,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = _ref.read(snoozeReminderUseCaseProvider);
      await useCase.execute(
        reminderId: reminderId,
        taskId: taskId,
        taskTitle: taskTitle,
        preset: preset,
        customDateTime: customDateTime,
      );
    });
  }

  Future<int> replayDnd() async {
    final useCase = _ref.read(replayDndNotificationsUseCaseProvider);
    return await useCase.execute();
  }

  Future<int> checkOverdue() async {
    final useCase = _ref.read(overdueReminderUseCaseProvider);
    return await useCase.execute();
  }
}

final reminderActionProvider =
    StateNotifierProvider<ReminderActionNotifier, AsyncValue<void>>((ref) {
  return ReminderActionNotifier(ref);
});
