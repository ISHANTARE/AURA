import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// AURA Notification Service
/// Handles 3 notification channels:
///   - AURA_REMINDERS: Task + event reminders (high priority)
///   - AURA_BRIEFING:  Morning briefing (default priority)
///   - AURA_NUDGES:    Proactive nudges (low priority)
///
/// Full implementation in Sprint 6. This module initializes the channels.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelReminders = AndroidNotificationChannel(
    'AURA_REMINDERS',
    'Task & Event Reminders',
    description: 'Deadline and event reminders from AURA',
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
  );

  static const _channelBriefing = AndroidNotificationChannel(
    'AURA_BRIEFING',
    'Morning Briefing',
    description: 'Your daily morning briefing from AURA',
    importance: Importance.defaultImportance,
    enableVibration: false,
    playSound: false,
  );

  static const _channelNudges = AndroidNotificationChannel(
    'AURA_NUDGES',
    'Proactive Nudges',
    description: 'Gentle reminders and nudges from AURA',
    importance: Importance.low,
    enableVibration: false,
    playSound: false,
  );

  static const _channelSystem = AndroidNotificationChannel(
    'AURA_SYSTEM',
    'System',
    description: 'DND replay, offline queue processed',
    importance: Importance.min,
    enableVibration: false,
    playSound: false,
  );

  /// Initialize notification plugin, create Android channels, and request permissions.
  /// Call once from main() before runApp().
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // 1. Create notification channels
      await androidPlugin.createNotificationChannel(_channelReminders);
      await androidPlugin.createNotificationChannel(_channelBriefing);
      await androidPlugin.createNotificationChannel(_channelNudges);
      await androidPlugin.createNotificationChannel(_channelSystem);

      // 2. Request POST_NOTIFICATIONS permission (Android 13+ / API 33+)
      await androidPlugin.requestNotificationsPermission();

      // 3. Request SCHEDULE_EXACT_ALARM permission (Android 12+ / API 31+)
      await androidPlugin.requestExactAlarmsPermission();
    }
  }


  /// Handle notification tap — navigation happens via deep link in Sprint 6.
  static void _onNotificationTapped(NotificationResponse response) {
    // TODO(sprint6): Navigate to task/briefing based on payload
  }

  /// Show a task reminder notification.
  static Future<void> showReminder({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'AURA_REMINDERS',
        'Task & Event Reminders',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(''),
      ),
    );
    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Cancel a specific notification.
  static Future<void> cancel(int id) => _plugin.cancel(id);

  /// Cancel all notifications.
  static Future<void> cancelAll() => _plugin.cancelAll();
}
