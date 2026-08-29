import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Flutter local notifications plugin instance, shared across the app.
final _plugin = FlutterLocalNotificationsPlugin();

// ── Action IDs ────────────────────────────────────────────────────────────────

/// Notification action ID for the "Mark Done" quick-action button.
const _actionMarkDone = 'MARK_DONE';

/// Notification action ID for the "Snooze 30 min" quick-action button.
const _actionSnooze30m = 'SNOOZE_30M';

// ── Background tap handler ─────────────────────────────────────────────────

/// Called by the OS when a notification action is triggered while the app
/// is terminated or in the background. Stores the action payload into
/// [SharedPreferences] so it can be processed on the next app foreground.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  final actionId = response.actionId;
  final payload = response.payload;
  final prefs = await SharedPreferences.getInstance();
  if (actionId == _actionMarkDone) {
    await prefs.setString('pending_bg_action', 'MARK_DONE:$payload');
  } else if (actionId == _actionSnooze30m) {
    await prefs.setString('pending_bg_action', 'SNOOZE_30M:$payload');
  }
}

/// Central notification service managing Android channels, permissions, and
/// scheduling APIs for AURA reminders and alarms.
class NotificationService {
  // Public action ID constants for external consumers.
  static const String actionMarkDone = _actionMarkDone;
  static const String actionSnooze30m = _actionSnooze30m;

  // ── Android Channel IDs ────────────────────────────────────────────────────
  static const String remindersChannelId = 'aura_reminders_v2';
  static const String alarmsChannelId = 'aura_alarms_v2';

  bool _initialized = false;

  /// Initialises timezone database and registers Android notification channels.
  /// Safe to call multiple times; will not re-initialise if already done.
  Future<void> initialize() async {
    if (_initialized) return;

    // Timezone setup
    tz.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone));

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onForegroundTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _createChannels();
    _initialized = true;
  }

  /// Creates the two permanent Android notification channels required by AURA.
  Future<void> _createChannels() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    // Reminders channel – max importance, standard notification sound
    const remindersChannel = AndroidNotificationChannel(
      remindersChannelId,
      'AURA Reminders & Notifications',
      description: 'High priority reminders, event alerts, and DND replay summaries.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    // Alarms channel – max importance, alarm audio usage, full-screen intent
    const alarmsChannel = AndroidNotificationChannel(
      alarmsChannelId,
      'AURA Alarms',
      description: 'Ringing time-of-day alarms from AURA.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    await androidPlugin.createNotificationChannel(remindersChannel);
    await androidPlugin.createNotificationChannel(alarmsChannel);
  }

  /// Reports whether the OS grants exact alarm permission (Android 14+).
  Future<bool> alarmCapability() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return false;
    return await androidPlugin.canScheduleExactNotifications() ?? false;
  }

  /// Schedules a reminder notification at [scheduledDate].
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String channelId,
    String? payload,
    bool fullScreenIntent = false,
  }) async {
    final canExact = await alarmCapability();
    final scheduleMode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == alarmsChannelId ? 'AURA Alarms' : 'AURA Reminders & Notifications',
          importance: Importance.max,
          priority: channelId == alarmsChannelId ? Priority.max : Priority.high,
          fullScreenIntent: fullScreenIntent,
          ongoing: channelId == alarmsChannelId,
          autoCancel: channelId != alarmsChannelId,
          category: channelId == alarmsChannelId
              ? AndroidNotificationCategory.alarm
              : AndroidNotificationCategory.reminder,
          actions: channelId == remindersChannelId
              ? const [
                  AndroidNotificationAction(
                    _actionMarkDone,
                    'Mark Done',
                    cancelNotification: true,
                  ),
                  AndroidNotificationAction(
                    _actionSnooze30m,
                    'Snooze 30m',
                    cancelNotification: true,
                  ),
                ]
              : null,
        ),
      ),
      payload: payload,
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Shows an immediate (non-scheduled) notification.
  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
    String channelId = remindersChannelId,
    String? payload,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == alarmsChannelId ? 'AURA Alarms' : 'AURA Reminders & Notifications',
          importance: Importance.max,
          priority: Priority.high,
          autoCancel: true,
          actions: const [
            AndroidNotificationAction(
              _actionMarkDone,
              'Mark Done',
              cancelNotification: true,
            ),
            AndroidNotificationAction(
              _actionSnooze30m,
              'Snooze 30m',
              cancelNotification: true,
            ),
          ],
        ),
      ),
      payload: payload,
    );
  }

  /// Cancels the notification with the given [id].
  Future<void> cancel(int id) => _plugin.cancel(id);

  /// Cancels all pending notifications.
  Future<void> cancelAll() => _plugin.cancelAll();

  void _onForegroundTap(NotificationResponse response) {
    // Foreground taps are handled via GoRouter navigation in app.dart
  }
}
