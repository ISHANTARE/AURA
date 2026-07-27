import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../database/app_database.dart';
import '../../../../database/daos/reminder_dao.dart';
import '../../../notifications/services/notification_service.dart';
import '../entities/reminder_models.dart';

class ScheduleReminderUseCase {
  final ReminderDao _reminderDao;
  final NotificationService _notificationService;

  ScheduleReminderUseCase({
    required ReminderDao reminderDao,
    NotificationService? notificationService,
  })  : _reminderDao = reminderDao,
        _notificationService = notificationService ?? NotificationService();

  /// Schedule reminders for a given task or event
  Future<List<String>> execute({
    required String taskId,
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
    } else if (isEvent) {
      // Event default rule: 1 day before, 7 AM day of, 1 hr before, 15 min before
      final oneDayBefore = deadline.subtract(const Duration(days: 1));
      final morningOf = DateTime(deadline.year, deadline.month, deadline.day, 7, 0);
      final oneHourBefore = deadline.subtract(const Duration(hours: 1));
      final min15Before = deadline.subtract(const Duration(minutes: 15));

      for (final time in [oneDayBefore, morningOf, oneHourBefore, min15Before]) {
        if (time.isAfter(now) && time.isBefore(deadline)) {
          timesToSchedule.add(time);
        }
      }
    } else if (isProject) {
      // Project default rule: Twice daily (9 AM + 7 PM) starting 7 days before
      final startDate = deadline.subtract(const Duration(days: 7));
      for (int i = 0; i < 7; i++) {
        final day = startDate.add(Duration(days: i));
        final morning = DateTime(day.year, day.month, day.day, 9, 0);
        final evening = DateTime(day.year, day.month, day.day, 19, 0);

        if (morning.isAfter(now) && morning.isBefore(deadline)) timesToSchedule.add(morning);
        if (evening.isAfter(now) && evening.isBefore(deadline)) timesToSchedule.add(evening);
      }
    } else {
      // Standard Task default rule: 1 day before + 6 hours before
      final oneDayBefore = deadline.subtract(const Duration(days: 1));
      final sixHoursBefore = deadline.subtract(const Duration(hours: 6));

      if (oneDayBefore.isAfter(now)) timesToSchedule.add(oneDayBefore);
      if (sixHoursBefore.isAfter(now)) timesToSchedule.add(sixHoursBefore);
    }

    // Always ensure at least 1 reminder if deadline is in future and no other reminders matched
    if (timesToSchedule.isEmpty && deadline.isAfter(now)) {
      final defaultTime = deadline.subtract(const Duration(hours: 1));
      timesToSchedule.add(defaultTime.isAfter(now) ? defaultTime : deadline);
    }

    final List<String> createdReminderIds = [];

    for (final fireTime in timesToSchedule) {
      final reminderId = const Uuid().v4();
      final nowMs = now.millisecondsSinceEpoch;
      final fireAtMs = fireTime.millisecondsSinceEpoch;
      final notifId = reminderId.hashCode.abs();

      // Insert DB record
      await _reminderDao.insertReminder(
        RemindersCompanion(
          id: Value(reminderId),
          taskId: Value(taskId),
          fireAt: Value(fireAtMs),
          type: Value(isEvent ? ReminderType.eventReminder.toValue() : ReminderType.deadlineReminder.toValue()),
          status: const Value('pending'),
          hasFired: const Value(false),
          createdAt: Value(nowMs),
          updatedAt: Value(nowMs),
        ),
      );

      // Schedule local notification
      final String timeLabel = _formatTimeLabel(fireTime, deadline);
      await _notificationService.scheduleNotification(
        id: notifId,
        title: title,
        body: '$timeLabel · Due ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}',
        scheduledDate: fireTime,
        payload: 'task:$taskId',
      );

      createdReminderIds.add(reminderId);
    }

    return createdReminderIds;
  }

  String _formatTimeLabel(DateTime fireTime, DateTime deadline) {
    final diff = deadline.difference(fireTime);
    if (diff.inHours >= 24) {
      return 'Due in ${(diff.inHours / 24).round()} days';
    } else if (diff.inHours > 0) {
      return 'Due in ${diff.inHours} hours';
    } else {
      return 'Due in ${diff.inMinutes} minutes';
    }
  }
}
