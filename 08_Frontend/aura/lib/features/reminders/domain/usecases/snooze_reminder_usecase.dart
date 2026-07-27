import '../../../../database/daos/reminder_dao.dart';
import '../../../notifications/services/notification_service.dart';
import '../entities/reminder_models.dart';

class SnoozeReminderUseCase {
  final ReminderDao _reminderDao;
  final NotificationService _notificationService;

  SnoozeReminderUseCase({
    required ReminderDao reminderDao,
    NotificationService? notificationService,
  })  : _reminderDao = reminderDao,
        _notificationService = notificationService ?? NotificationService();

  /// Snooze a reminder using a preset or custom DateTime
  Future<void> execute({
    required String reminderId,
    required String taskTitle,
    required String taskId,
    required SnoozePreset preset,
    DateTime? customDateTime,
  }) async {
    final targetTime = preset.calculateTargetTime(customTime: customDateTime);

    // Update DB status to 'snoozed' with snoozedUntil timestamp
    await _reminderDao.snooze(reminderId, targetTime);

    // Cancel old notification if pending
    final notifId = reminderId.hashCode.abs();
    await _notificationService.cancelNotification(notifId);

    // Schedule re-fire notification at targetTime
    await _notificationService.scheduleNotification(
      id: notifId,
      title: taskTitle,
      body: 'Snoozed reminder · Due soon',
      scheduledDate: targetTime,
      payload: 'task:$taskId',
    );
  }
}
