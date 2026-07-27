import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Top-level background notification action handler callback required by flutter_local_notifications.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  final actionId = notificationResponse.actionId;
  final payload = notificationResponse.payload;
  debugPrint('Notification background tap action: $actionId, payload: $payload');

  // Handle background actions (e.g. mark done or quick snooze)
  // Actual database updates will be synced via WorkManager or DAO when app starts / runs task.
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String channelRemindersId = 'aura_reminders';
  static const String channelBriefingId = 'aura_briefing';
  static const String channelNudgesId = 'aura_nudges';

  static const String actionMarkDone = 'action_mark_done';
  static const String actionSnooze = 'action_snooze';

  final _selectNotificationSubject = StreamController<String?>.broadcast();
  Stream<String?> get selectNotificationStream => _selectNotificationSubject.stream;

  bool _initialized = false;

  /// Initialize local notification channels, timezones, and permission requests.
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize Timezone database
    tz.initializeTimeZones();
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          _selectNotificationSubject.add(response.payload);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _createNotificationChannels();
    _initialized = true;
  }

  /// Create Android Notification Channels matching PRD F-07 specs
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel remindersChannel = AndroidNotificationChannel(
      channelRemindersId,
      'AURA Reminders',
      description: 'Notifications for task deadlines, events, and scheduled reminders',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel briefingChannel = AndroidNotificationChannel(
      channelBriefingId,
      'AURA Morning Briefing',
      description: 'Daily morning briefing notifications',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    const AndroidNotificationChannel nudgesChannel = AndroidNotificationChannel(
      channelNudgesId,
      'AURA Proactive Nudges',
      description: 'Context-aware AI nudges and reminders',
      importance: Importance.defaultImportance,
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(remindersChannel);
      await androidImplementation.createNotificationChannel(briefingChannel);
      await androidImplementation.createNotificationChannel(nudgesChannel);

      // Request permissions
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelId = channelRemindersId,
    String? payload,
    List<AndroidNotificationAction>? actions,
  }) async {
    await initialize();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      _channelName(channelId),
      channelDescription: _channelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFC6FF00), // AURA Lime accent
      actions: actions ?? defaultReminderActions(),
    );

    final NotificationDetails details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(id, title, body, details, payload: payload);
  }

  /// Schedule a notification at a specific [DateTime]
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String channelId = channelRemindersId,
    String? payload,
    List<AndroidNotificationAction>? actions,
  }) async {
    await initialize();

    // Do not schedule past notifications
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      _channelName(channelId),
      channelDescription: _channelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFC6FF00),
      actions: actions ?? defaultReminderActions(),
    );

    final NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Default notification actions for reminders ("Mark Done" and "Snooze")
  List<AndroidNotificationAction> defaultReminderActions() {
    return const [
      AndroidNotificationAction(
        actionMarkDone,
        'Mark Done',
        showsUserInterface: false,
      ),
      AndroidNotificationAction(
        actionSnooze,
        'Snooze',
        showsUserInterface: true,
      ),
    ];
  }

  /// Cancel a scheduled notification by ID
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  String _channelName(String channelId) {
    switch (channelId) {
      case channelBriefingId:
        return 'AURA Morning Briefing';
      case channelNudgesId:
        return 'AURA Proactive Nudges';
      default:
        return 'AURA Reminders';
    }
  }

  String _channelDescription(String channelId) {
    switch (channelId) {
      case channelBriefingId:
        return 'Daily morning briefing notifications';
      case channelNudgesId:
        return 'Context-aware AI nudges and reminders';
      default:
        return 'Notifications for task deadlines, events, and scheduled reminders';
    }
  }
}
