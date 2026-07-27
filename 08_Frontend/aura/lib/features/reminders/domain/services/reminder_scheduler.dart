import 'package:drift/drift.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';

import '../../../../database/app_database.dart';
import '../../data/services/notification_service.dart';

/// Reminder Scheduling Engine for AURA.
/// Responsible for scheduling exact notifications, auto-template generation (F-07), and snooze handling.
class ReminderScheduler {
  final AppDatabase _db;
  final NotificationService _notificationService;
  static const _uuid = Uuid();

  ReminderScheduler(this._db)
      : _notificationService = NotificationService();

  /// Initialize and reschedule all pending reminders on app startup.
  Future<void> initializeAndReschedulePending() async {
    await _notificationService.initialize(
      onNotificationTap: _handleNotificationTap,
      onBackgroundNotificationAction: _handleNotificationAction,
    );

    await _notificationService.requestPermissions();

    final pending = await _db.reminderDao.getPending();
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    for (final rem in pending) {
      final fireAtMs = rem.snoozedUntil ?? rem.fireAt;
      if (fireAtMs > nowMs) {
        final task = await _db.taskDao.getById(rem.taskId ?? '');
        if (task != null && task.status != 'done' && task.deletedAt == null) {
          final scheduledDate = DateTime.fromMillisecondsSinceEpoch(fireAtMs);
          await _notificationService.scheduleNotification(
            id: rem.id.hashCode,
            title: task.name,
            body: _buildNotificationBody(task, scheduledDate),
            scheduledDate: scheduledDate,
            payload: '${rem.id}|${task.id}',
          );
        }
      }
    }
  }

  /// Schedule reminders for a newly created task or event.
  /// If [explicitReminders] is empty, auto-generates default templates per PRD F-07.
  Future<void> scheduleForTask(Task task, {List<Reminder>? explicitReminders}) async {
    final now = DateTime.now();
    final deadlineMs = task.deadline;

    if (explicitReminders != null && explicitReminders.isNotEmpty) {
      for (final rem in explicitReminders) {
        final fireDate = DateTime.fromMillisecondsSinceEpoch(rem.fireAt);
        if (fireDate.isAfter(now)) {
          await _notificationService.scheduleNotification(
            id: rem.id.hashCode,
            title: task.name,
            body: _buildNotificationBody(task, fireDate),
            scheduledDate: fireDate,
            payload: '${rem.id}|${task.id}',
          );
        }
      }
      return;
    }

    // Auto-generate default reminders per PRD F-07 template rules
    if (deadlineMs != null) {
      final deadline = DateTime.fromMillisecondsSinceEpoch(deadlineMs);
      final List<DateTime> fireTimes = [];

      // Assignment / Deadline: 1 day before + 6 hours before
      final dayBefore = deadline.subtract(const Duration(days: 1));
      final sixHoursBefore = deadline.subtract(const Duration(hours: 6));

      if (dayBefore.isAfter(now)) fireTimes.add(dayBefore);
      if (sixHoursBefore.isAfter(now)) fireTimes.add(sixHoursBefore);

      for (final fireTime in fireTimes) {
        final remId = _uuid.v4();
        await _db.reminderDao.insertReminder(
          RemindersCompanion.insert(
            id: remId,
            taskId: Value(task.id),
            fireAt: fireTime.millisecondsSinceEpoch,
            type: const Value('notification'),
            status: const Value('pending'),
            createdAt: now.millisecondsSinceEpoch,
            updatedAt: now.millisecondsSinceEpoch,
          ),
        );

        await _notificationService.scheduleNotification(
          id: remId.hashCode,
          title: task.name,
          body: _buildNotificationBody(task, fireTime),
          scheduledDate: fireTime,
          payload: '$remId|${task.id}',
        );
      }
    }
  }

  /// Snooze a reminder by specific duration.
  Future<void> snoozeReminder(String reminderId, String taskId, Duration duration) async {
    final now = DateTime.now();
    final snoozeUntil = now.add(duration);

    await _db.reminderDao.snooze(reminderId, snoozeUntil);

    final task = await _db.taskDao.getById(taskId);
    final title = task?.name ?? 'AURA Reminder';

    await _notificationService.scheduleNotification(
      id: reminderId.hashCode,
      title: title,
      body: 'Snoozed · Due ${_formatTime(snoozeUntil)}',
      scheduledDate: snoozeUntil,
      payload: '$reminderId|$taskId',
    );
  }

  /// Handle tapping notification action buttons (Background/Foreground).
  static void _handleNotificationAction(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null) return;
    final parts = payload.split('|');
    if (parts.length < 2) return;

    // parts[0] = reminderId, parts[1] = taskId — used in Sprint 7 deep links
    if (response.actionId == NotificationService.actionMarkDone) {
      // Mark task as complete — full implementation in Sprint 7
    } else if (response.actionId == NotificationService.actionSnooze30m) {
      // Snooze 30 minutes — full implementation in Sprint 7
    }
  }

  static void _handleNotificationTap(NotificationResponse response) {
    // Navigates to task detail when notification is tapped
  }

  String _buildNotificationBody(Task task, DateTime scheduledDate) {
    if (task.deadline != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(task.deadline!);
      return 'Due at ${_formatTime(dt)}';
    }
    return 'Scheduled reminder';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $ampm';
  }
}
