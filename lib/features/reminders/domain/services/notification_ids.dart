import 'dart:convert';

/// Deterministic notification-ID codec.
///
/// flutter_local_notifications requires `int` IDs, and cancelling must target
/// the exact ID used to schedule. Dart's `String.hashCode` gives no cross-run
/// stability guarantee and was previously applied inconsistently to different
/// key shapes for the same entity, so cancellations missed. Every scheduled
/// notification now derives its ID from a NAMESPACED KEY through this pure
/// FNV-1a hash.
///
/// The algorithm is pinned by unit tests (`test/domain/notification_ids_test.dart`).
/// NEVER change it without bumping the `notif_scheme_migrated_v2` guard and
/// running the reschedule sweep.
int notificationId(String key) {
  var hash = 0x811c9dc5;
  for (final byte in utf8.encode(key)) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xFFFFFFFF; // 32-bit FNV-1a
  }
  return hash & 0x7FFFFFFF; // positive int31
}

/// Key builders for every notification the app schedules.
///
/// Reserved low IDs (stable, un-hashed) are used for system-level summaries
/// where exactly one instance should ever be visible.
abstract final class NotificationIds {
  // ── Hashed, per-entity keys ────────────────────────────────────────────────

  /// Primary one-shot notification for an item (fires at its anchor time).
  static int forItem(String itemId) => notificationId('item:$itemId');

  /// Sub-reminder notification backed by a RemindersSchedule row.
  static int forReminder(String reminderScheduleId) =>
      notificationId('rem:$reminderScheduleId');

  /// Weekly repeating alarm occurrence (weekday 1=Mon … 7=Sun, DateTime.weekday).
  static int forItemWeekday(String itemId, int weekday) =>
      notificationId('item:$itemId:wd$weekday');

  /// Active snooze for an item — same ID replaces the prior snooze.
  static int forSnooze(String itemId) => notificationId('snooze:$itemId');

  // ── Reserved system slots ──────────────────────────────────────────────────

  static const int briefing = 10001;
  static const int overdueSummary = 10002;
  static const int nudge = 10003;
  static const int dndCatchup = 10004;
  static const int offlineReview = 10005;
}
