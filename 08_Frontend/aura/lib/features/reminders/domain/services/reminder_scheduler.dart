import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../database/app_database.dart';
import '../../data/services/notification_service.dart';

/// Reminder Scheduling Engine for AURA v2.
class ReminderScheduler {
  // ignore: unused_field
  final AppDatabase _db;
  final NotificationService _notificationService;

  ReminderScheduler(this._db)
      : _notificationService = NotificationService();

  Future<void> initializeAndReschedulePending() async {
    // Sprint 4: Query _db.itemDao for pending reminders and reschedule on boot
    await _notificationService.initialize(
      onNotificationTap: _handleNotificationTap,
      onBackgroundNotificationAction: _handleNotificationAction,
    );
    await _notificationService.requestPermissions();
  }

  Future<void> scheduleAlarmDirect({
    required String alarmId,
    required String title,
    required DateTime fireAt,
  }) async {
    await _notificationService.scheduleAlarm(
      id: alarmId.hashCode,
      title: '⏰ ALARM: $title',
      body: 'Time to wake up or attend to your scheduled alarm!',
      scheduledDate: fireAt,
      payload: '$alarmId|alarm',
    );
  }

  static void _handleNotificationAction(NotificationResponse response) {}

  static void _handleNotificationTap(NotificationResponse response) {}
}
