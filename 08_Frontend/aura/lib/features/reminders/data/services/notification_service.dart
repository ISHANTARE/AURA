import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/constants/colors.dart';

/// Central Notification Service for AURA.
/// Configures high-importance Android channels, timezone scheduling, and notification action handlers.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'aura_reminders';
  static const String channelName = 'AURA Reminders & Notifications';
  static const String channelDescription =
      'High priority reminders, event alerts, and DND replay summaries.';

  static const String actionMarkDone = 'ACTION_MARK_DONE';
  static const String actionSnooze30m = 'ACTION_SNOOZE_30M';
  static const String actionSnooze1h = 'ACTION_SNOOZE_1H';

  bool _initialized = false;

  /// Initialize local notifications and timezone data.
  Future<void> initialize({
    void Function(NotificationResponse)? onNotificationTap,
    void Function(NotificationResponse)? onBackgroundNotificationAction,
  }) async {
    if (_initialized) return;

    // 1. Initialize timezones
    tz.initializeTimeZones();

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
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationAction,
    );

    // 5. Create Android High Importance Notification Channel
    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  /// Request permissions for Android 13+ (POST_NOTIFICATIONS) & iOS
  Future<bool> requestPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final grantedAndroid =
        await androidImplementation?.requestNotificationsPermission() ?? false;

    return grantedAndroid;
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
