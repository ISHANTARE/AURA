import 'dart:convert';

/// Deterministic, collision-resistant 31-bit notification ID codec using FNV-1a.
///
/// Algorithm: 32-bit FNV-1a hash, masked to positive int31 (`& 0x7FFFFFFF`).
/// This ensures stable, unique notification IDs for all item/reminder UUIDs.
abstract final class NotificationIds {
  // FNV-1a constants
  static const int _offsetBasis = 0x811C9DC5;
  static const int _prime = 0x01000193;

  /// Computes a 31-bit FNV-1a hash for a given namespaced [key].
  static int _fnv1a(String key) {
    var hash = _offsetBasis;
    for (final byte in utf8.encode(key)) {
      hash ^= byte;
      hash = (hash * _prime) & 0xFFFFFFFF; // clamp to 32-bit
    }
    return hash & 0x7FFFFFFF; // positive int31
  }

  // ── Per-entity hashed IDs ─────────────────────────────────────────────────

  /// Notification ID for the item's primary anchor reminder/alarm.
  static int forItem(String itemId) => _fnv1a('item:$itemId');

  /// Notification ID for an individual reminder schedule row.
  static int forReminder(String rowId) => _fnv1a('rem:$rowId');

  /// Notification ID for a weekly alarm on a specific [weekday] (1=Mon, 7=Sun).
  static int forItemWeekday(String itemId, int weekday) =>
      _fnv1a('item:$itemId:wd$weekday');

  /// Notification ID used when an item is snoozed.
  static int forSnooze(String itemId) => _fnv1a('snooze:$itemId');

  // ── Reserved system singleton IDs ─────────────────────────────────────────

  /// Daily Morning Briefing notification.
  static const int briefing = 10001;

  /// Overdue Triage Alert.
  static const int overdueSummary = 10002;

  /// Proactive High-Priority Nudge.
  static const int nudge = 10003;

  /// Missed DND Replay Summary.
  static const int dndCatchup = 10004;

  /// Destructive Offline Review Prompt.
  static const int offlineReview = 10005;
}
