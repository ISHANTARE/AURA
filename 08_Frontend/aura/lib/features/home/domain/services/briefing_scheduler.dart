import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../reminders/data/services/notification_service.dart';

/// Schedules the daily morning briefing notification for AURA.
///
/// Design rules (from SPRINTS.md S8):
/// - Default briefing time: 7:00 AM
/// - Late-wake detection: if phone not unlocked before briefing time, fire at 9:00 AM instead
/// - Schedule once per day — guard via SharedPreferences `briefing_scheduled_date`
/// - Deep-link payload: `route:/briefing`
class BriefingSchedulerService {
  final NotificationService _notifications;

  static const String _keyScheduledDate = 'briefing_scheduled_date';
  static const String _keyFirstUnlockMs = 'briefing_first_unlock_ms';
  static const String _keyBriefingHour = 'BRIEFING_HOUR'; // set by Settings
  static const int _defaultBriefingHour = 7;
  static const int _lateWakeFallbackHour = 9;
  static const int _briefingNotificationId = 10001;

  BriefingSchedulerService({NotificationService? notifications})
      : _notifications = notifications ?? NotificationService();

  /// Call this on every app resume / first launch.
  /// Records the first unlock time and schedules the briefing if not yet done today.
  Future<void> onAppActive() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = _todayKey(now);

    // Record first unlock time for today (once only)
    final existingUnlock = prefs.getInt(_keyFirstUnlockMs);
    final existingUnlockDate = existingUnlock != null
        ? DateTime.fromMillisecondsSinceEpoch(existingUnlock)
        : null;
    final isFirstUnlockToday = existingUnlockDate == null ||
        !_isSameDay(existingUnlockDate, now);
    if (isFirstUnlockToday) {
      await prefs.setInt(_keyFirstUnlockMs, now.millisecondsSinceEpoch);
    }

    // Only schedule once per day
    final lastScheduled = prefs.getString(_keyScheduledDate);
    if (lastScheduled == todayKey) return;

    await _scheduleTodaysBriefing(prefs, now);
    await prefs.setString(_keyScheduledDate, todayKey);
  }

  Future<void> _scheduleTodaysBriefing(
      SharedPreferences prefs, DateTime now) async {
    final briefingHour =
        prefs.getInt(_keyBriefingHour) ?? _defaultBriefingHour;

    // Build the target DateTime for today at briefing hour
    DateTime target = DateTime(
      now.year,
      now.month,
      now.day,
      briefingHour,
    );

    // If we're already past the briefing time:
    // - Use late-wake fallback (9AM) if still before fallback hour
    // - Otherwise skip (too late today, will fire tomorrow)
    if (now.isAfter(target)) {
      final fallback = DateTime(
        now.year,
        now.month,
        now.day,
        _lateWakeFallbackHour,
      );
      if (now.isBefore(fallback)) {
        target = fallback;
        debugPrint('[BriefingScheduler] Past $briefingHour AM — using 9AM fallback');
      } else {
        // Schedule for tomorrow at briefing hour
        target = target.add(const Duration(days: 1));
        debugPrint('[BriefingScheduler] Past fallback — scheduling for tomorrow');
      }
    }

    final greetingLine = _greetingLine(now.hour);

    await _notifications.scheduleNotification(
      id: _briefingNotificationId,
      title: 'AURA Morning Briefing ☀️',
      body: greetingLine,
      scheduledDate: target,
      payload: 'route:/briefing',
    );

    debugPrint('[BriefingScheduler] Briefing scheduled for ${target.toIso8601String()}');
  }

  String _greetingLine(int hour) {
    if (hour < 12) return 'Your daily summary is ready. Tap to start your day.';
    if (hour < 17) return 'Afternoon check-in — see what needs your attention.';
    return 'Evening briefing — wrap up your day with AURA.';
  }

  String _todayKey(DateTime dt) =>
      'briefing_${dt.year}_${dt.month}_${dt.day}';

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
