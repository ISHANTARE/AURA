import '../../../../database/app_database.dart';
import '../../../notifications/services/notification_service.dart';
import '../entities/reminder_models.dart';

/// Snoozes an active reminder by cancelling and re-scheduling it.
class SnoozeReminderUseCase {
  // ignore: unused_field
  final AppDatabase _db;
  final NotificationService _notificationService;

  SnoozeReminderUseCase({
    required AppDatabase db,
    NotificationService? notificationService,
  })  : _db = db,
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

    // Cancel old notification if pending
    final notifId = reminderId.hashCode.abs();
    await _notificationService.cancelNotification(notifId);

    // Schedule re-fire notification at targetTime
    await _notificationService.scheduleNotification(
      id: notifId,
      title: taskTitle,
      body: 'Snoozed reminder · Due soon',
      scheduledDate: targetTime,
      payload: 'item:$taskId',
    );
  }
}
