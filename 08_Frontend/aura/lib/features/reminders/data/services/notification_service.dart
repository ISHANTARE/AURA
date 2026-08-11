import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/constants/colors.dart';

/// Top-level background notification response handler
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  final actionId = response.actionId;
  final payload = response.payload;
  if (payload == null || payload.isEmpty) return;

  try {
    final prefs = await SharedPreferences.getInstance();
    if (actionId == NotificationService.actionMarkDone) {
      await prefs.setString('pending_bg_action', 'MARK_DONE:$payload');
    } else if (actionId == NotificationService.actionSnooze30m) {
      await prefs.setString('pending_bg_action', 'SNOOZE_30M:$payload');
    }
  } catch (e) {
    debugPrint('Background notification action error: $e');
  }
}

/// Central Notification Service for AURA.
/// Configures high-importance Android channels, timezone scheduling, and notification action handlers.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'aura_reminders_v2';
  static const String channelName = 'AURA Reminders & Notifications';
  static const String channelDescription =
      'High priority reminders, event alerts, and DND replay summaries.';

  static const String alarmChannelId = 'aura_alarms_v2';
  static const String alarmChannelName = 'AURA Alarms';
  static const String alarmChannelDescription =
      'Ringing time-of-day alarms from AURA.';

  static const String actionMarkDone = 'ACTION_MARK_DONE';
  static const String actionSnooze30m = 'ACTION_SNOOZE_30M';
  static const String actionSnooze1h = 'ACTION_SNOOZE_1H';

  final _selectNotificationSubject = StreamController<String?>.broadcast();
  Stream<String?> get selectNotificationStream => _selectNotificationSubject.stream;

  bool _initialized = false;

  /// Initialize local notifications and timezone data.
  Future<void> initialize({
    void Function(NotificationResponse)? onNotificationTap,
    void Function(NotificationResponse)? onBackgroundNotificationAction,
  }) async {
    if (_initialized) return;

    // 1. Initialize timezones and set device local timezone
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback to UTC if timezone name lookup fails
    }

    // 2. Android settings with app launcher icon
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS / macOS settings
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    // 4. Initialize plugin with tap callbacks
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (onNotificationTap != null) {
          onNotificationTap(response);
        }
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _selectNotificationSubject.add(payload);
        }
      },
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationAction ?? notificationTapBackground,
    );

    // 5. Create Android High Importance Channels
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );

      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          alarmChannelId,
          alarmChannelName,
          description: alarmChannelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      );
    }

    _initialized = true;
  }

  /// Request permissions for Android 13+ (POST_NOTIFICATIONS) & Android 12+ (EXACT_ALARM)
  Future<bool> requestPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
    return true;
  }

  /// Schedule an exact time notification using local timezone.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    List<AndroidNotificationAction>? actions,
  }) async {
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // If scheduled time is in the past, fire immediately
    if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      await showInstantNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
        actions: actions,
      );
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      color: AuraColors.accentLime,
      actions: actions ?? defaultActions(),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Schedule an exact ALARM notification (loud ringing, fullScreenIntent, alarm audio usage).
  Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const androidDetails = AndroidNotificationDetails(
      alarmChannelId,
      alarmChannelName,
      channelDescription: alarmChannelDescription,
      importance: Importance.max,
      priority: Priority.max,
      color: AuraColors.accentLime,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      ongoing: true,
      autoCancel: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Fire an instant notification.
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    List<AndroidNotificationAction>? actions,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      color: AuraColors.accentLime,
      actions: actions ?? defaultActions(),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Cancel a specific notification by ID
  Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all scheduled & active notifications
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Default notification action buttons [MARK DONE] & [SNOOZE 30M]
  static List<AndroidNotificationAction> defaultActions() {
    return [
      const AndroidNotificationAction(
        actionMarkDone,
        'MARK DONE',
        showsUserInterface: false,
      ),
      const AndroidNotificationAction(
        actionSnooze30m,
        'SNOOZE 30M',
        showsUserInterface: false,
      ),
    ];
  }
}
