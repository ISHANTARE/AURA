import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../database/app_database.dart';
import '../../../reminders/data/services/notification_service.dart';
import '../../../reminders/domain/services/notification_ids.dart';

/// Schedules the daily morning briefing notification for AURA.
///
/// Design rules (from SPRINTS.md S8):
/// - Briefing hour configurable via Settings (prefs `BRIEFING_HOUR`, default 7)
/// - Late-wake fallback: fires 9 AM if the day's first unlock was earlier;
///   if the user first unlocked AFTER the fallback hour, today's briefing is
///   skipped (they're already up — it would be noise) and it moves to tomorrow
/// - Schedule once per day — guard via SharedPreferences `briefing_scheduled_date`
/// - Body is composed at schedule time from the live top focus item
/// - Deep-link payload: `route:/briefing`
class BriefingSchedulerService {
  final NotificationService _notifications;
  final AppDatabase? _db;

  static const String _keyScheduledDate = 'briefing_scheduled_date';
  static const String _keyFirstUnlockMs = 'briefing_first_unlock_ms';

  /// Prefs key written by Settings → Briefing hour.
  static const String keyBriefingHour = 'BRIEFING_HOUR';
  static const int _defaultBriefingHour = 7;
  static const int _lateWakeFallbackHour = 9;

  BriefingSchedulerService({NotificationService? notifications, AppDatabase? db})
      : _notifications = notifications ?? NotificationService(),
        _db = db;

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

    await _scheduleTodaysBriefing(prefs, now, isFirstUnlockToday);
    await prefs.setString(_keyScheduledDate, todayKey);
  }

  Future<void> _scheduleTodaysBriefing(
      SharedPreferences prefs, DateTime now, bool isFirstUnlockToday) async {
    final briefingHour = prefs.getInt(keyBriefingHour) ?? _defaultBriefingHour;

    DateTime target = DateTime(
      now.year,
      now.month,
      now.day,
      briefingHour,
    );

    if (now.isAfter(target)) {
      final fallback = DateTime(
        now.year,
        now.month,
        now.day,
        _lateWakeFallbackHour,
      );
      final firstUnlock = prefs.getInt(_keyFirstUnlockMs);
      final firstUnlockAfterFallback = firstUnlock != null &&
          DateTime.fromMillisecondsSinceEpoch(firstUnlock).isAfter(fallback);

      if (now.isBefore(fallback)) {
        target = fallback;
        debugPrint(
            '[BriefingScheduler] Past $briefingHour AM — using ${_lateWakeFallbackHour}AM fallback');
      } else if (firstUnlockAfterFallback && !isFirstUnlockToday) {
        // User has been up since before we could have helped — don't buzz now.
        target = target.add(const Duration(days: 1));
        debugPrint('[BriefingScheduler] Late unlock — scheduling for tomorrow');
      } else {
        target = target.add(const Duration(days: 1));
        debugPrint('[BriefingScheduler] Past fallback — scheduling for tomorrow');
      }
    }

    final body = await _composeBody();

    await _notifications.scheduleNotification(
      id: NotificationIds.briefing,
      title: 'AURA Morning Briefing',
      body: body,
      scheduledDate: target,
      payload: 'route:/briefing',
    );

    debugPrint('[BriefingScheduler] Briefing scheduled for ${target.toIso8601String()}');
  }

  /// Compose a one-line summary from live data at schedule time (the
  /// notification content is static once scheduled — a documented platform
  /// limitation; the deep-linked screen always shows the fresh picture).
  Future<String> _composeBody() async {
    final db = _db;
    if (db == null) return 'Your daily summary is ready. Tap to start your day.';
    try {
      final items = await ItemDao(db).watchTodayFocus().first;
      if (items.isEmpty) {
        return 'Nothing due today — enjoy the calm start.';
      }
      final top = items.first;
      final count = items.length;
      return count == 1
          ? '1 item today · Top: ${top.title}'
          : '$count items today · Top: ${top.title}';
    } catch (e) {
      debugPrint('[BriefingScheduler] body compose failed: $e');
      return 'Your daily summary is ready. Tap to start your day.';
    }
  }

  String _todayKey(DateTime dt) =>
      'briefing_${dt.year}_${dt.month}_${dt.day}';

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
