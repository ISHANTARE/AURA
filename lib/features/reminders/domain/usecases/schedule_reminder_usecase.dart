import '../../../../database/app_database.dart';
import '../../data/services/notification_service.dart';

/// Schedules notifications for a given item (task/event).
class ScheduleReminderUseCase {
  // ignore: unused_field
  final AppDatabase _db;
  final NotificationService _notificationService;

  ScheduleReminderUseCase({
    required AppDatabase db,
    NotificationService? notificationService,
  })  : _db = db,
        _notificationService = notificationService ?? NotificationService();

  /// Schedule notifications for a given item (task/event)
  Future<void> execute({
    required String itemId,
    required String title,
    required DateTime deadline,
    bool isProject = false,
    bool isEvent = false,
    List<DateTime>? customReminderTimes,
  }) async {
    final now = DateTime.now();
    final List<DateTime> timesToSchedule = [];

    if (customReminderTimes != null && customReminderTimes.isNotEmpty) {
      timesToSchedule.addAll(customReminderTimes.where((t) => t.isAfter(now)));
    } else {
      final oneDayBefore = deadline.subtract(const Duration(days: 1));
      final sixHoursBefore = deadline.subtract(const Duration(hours: 6));
      if (oneDayBefore.isAfter(now)) timesToSchedule.add(oneDayBefore);
      if (sixHoursBefore.isAfter(now)) timesToSchedule.add(sixHoursBefore);
    }

    for (final fireTime in timesToSchedule) {
      await _notificationService.scheduleNotification(
        id: '${itemId}_${fireTime.millisecondsSinceEpoch}'.hashCode.abs(),
        title: title,
        body: 'Due at ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}',
        scheduledDate: fireTime,
        payload: 'item:$itemId',
      );
    }
  }
}
