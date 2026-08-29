---
name: AURA-notification-scheduler
description: >
  Notification, alarm, and scheduling intelligence specialist for AURA. Use this skill when:
  implementing or modifying NotificationService, ReminderSchedulingService, NotificationIds (FNV-1a),
  RecurrenceResolver, DndService, ReplayDndNotificationsUseCase, SnoozeReminderUseCase, Android
  notification channels, exact alarm permissions, or when the user says "schedule reminder for X",
  "fix notification IDs", "alarms aren't ringing", "DND catchup not working", "implement recurrence",
  "add snooze options", or "fix background notification action".
---

# AURA Notification & Scheduling Specialist

You are implementing and maintaining the notification, alarm, and scheduling engine for AURA.
Every alarm, reminder, event alert, proactive nudge, morning briefing, and DND replay flows
through this subsystem.

> **Source of truth**: `overhaul-docs/06-features/02-reminders-alarms.md`,
> `overhaul-docs/01-tech-stack.md`, and `overhaul-docs/09-startup-sequence.md`.

---

## 1. Core Principles & Non-Negotiables

1. **Single Authoritative Scheduler**: `ReminderSchedulingService` is the **ONLY** class in the entire codebase allowed to call `NotificationService` for item-derived alarms and reminders. No UI widget or other use case may call `NotificationService.zonedSchedule()` directly.
2. **Deterministic Positive 31-bit IDs**: Never use Dart's `.hashCode` on UUID strings (causes collisions on Android 32-bit notification integers). Always use `NotificationIds` with the **32-bit FNV-1a hash algorithm**.
3. **No Silent Drops on DND**: Missed reminders during Do-Not-Disturb are logged and automatically summarized/replayed when DND exits.
4. **Alarms Always Ring**: Alarms (category `alarm`) use `AudioAttributesUsage.alarm`, `fullScreenIntent = true`, `Importance.max`, and must ring immediately even if past.
5. **Clean Cancellation on Soft-Delete**: Deleting or completing an item must immediately invoke `cancelForItem(itemId)` across all ID variants.

---

## 2. Notification Channels Specification

Two channels configured via `flutter_local_notifications`:

```dart
// 1. Reminders Channel
const AndroidNotificationChannel remindersChannel = AndroidNotificationChannel(
  'aura_reminders_v2',
  'AURA Reminders & Notifications',
  description: 'High priority reminders, event alerts, and DND replay summaries.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

// 2. Alarms Channel
const AndroidNotificationChannel alarmsChannel = AndroidNotificationChannel(
  'aura_alarms_v2',
  'AURA Alarms',
  description: 'Ringing time-of-day alarms from AURA.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  audioAttributesUsage: AudioAttributesUsage.alarm,
);
```

---

## 3. FNV-1a Notification ID Codec (`notification_ids.dart`)

```dart
import 'dart:convert';

int notificationId(String key) {
  var hash = 0x811c9dc5;
  for (final byte in utf8.encode(key)) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xFFFFFFFF; // 32-bit FNV-1a
  }
  return hash & 0x7FFFFFFF; // Masked to positive int31
}

abstract final class NotificationIds {
  // Hashed per-entity keys
  static int forItem(String itemId) => notificationId('item:$itemId');
  static int forReminder(String rowId) => notificationId('rem:$rowId');
  static int forItemWeekday(String itemId, int weekday) =>
      notificationId('item:$itemId:wd$weekday');
  static int forSnooze(String itemId) => notificationId('snooze:$itemId');

  // Reserved low integer slots (System Singletons)
  static const int briefing      = 10001; // Daily Morning Briefing
  static const int overdueSummary = 10002; // Overdue Triage Alert
  static const int nudge         = 10003; // Proactive High-Priority Nudge
  static const int dndCatchup    = 10004; // Missed DND Replay Summary
  static const int offlineReview = 10005; // Destructive Offline Review Prompt
}
```

---

## 4. Authoritative Scheduler (`ReminderSchedulingService`)

### Scheduling Flow (`syncForItem`):
```dart
Future<void> syncForItem(
  Item item, {
  List<ExtractedReminder>? extractedReminders,
  String? soundUri,
}) async {
  // Step 1: Cancel any previously scheduled alerts for this item
  await cancelForItem(item.id);

  if (item.deletedAt != null || item.status == 'completed' || item.status == 'cancelled') {
    return;
  }

  final anchor = item.fireAt ?? item.startTime ?? item.deadline;
  if (anchor == null) return;

  // Step 2: Persist reminder schedule rows into Drift database
  // - If weekly recurring: persist virtual rows per active weekday
  // - If standard: persist offset rows + anchor row (offsetValue = 0)
  await _persistScheduleRows(item, anchor, extractedReminders);

  // Step 3: Query active schedule rows and schedule via NotificationService
  final rows = await _scheduleDao.getPendingForItem(item.id);
  final canExact = await _notificationService.canScheduleExactAlarms();
  final scheduleMode = canExact
      ? AndroidScheduleMode.exactAllowWhileIdle
      : AndroidScheduleMode.inexactAllowWhileIdle;

  final now = clock?.call() ?? DateTime.now();

  for (final row in rows) {
    final fireTime = DateTime.fromMillisecondsSinceEpoch(row.fireAt);
    final notifId = NotificationIds.forReminder(row.id);

    if (item.category == 'alarm') {
      // Alarms: always schedule (or ring immediately if past)
      await _notificationService.scheduleAlarm(
        id: notifId,
        title: item.title,
        body: item.notes ?? 'Alarm ringing',
        scheduledDate: fireTime,
        payload: 'item:${item.id}',
        soundUri: soundUri ?? item.soundUri,
        scheduleMode: scheduleMode,
      );
    } else {
      // Reminders:
      if (fireTime.isAfter(now)) {
        await _notificationService.scheduleReminder(
          id: notifId,
          title: item.title,
          body: item.notes ?? 'Reminder due',
          scheduledDate: fireTime,
          payload: 'item:${item.id}',
          scheduleMode: scheduleMode,
        );
      } else if (now.difference(fireTime).inMinutes <= 15) {
        // Within 15-min grace window -> fire immediate "Missed" notification
        await _notificationService.showImmediate(
          id: notifId,
          title: 'Missed: ${item.title}',
          body: 'Due ${now.difference(fireTime).inMinutes} min ago',
          payload: 'item:${item.id}',
        );
      }
      // Past > 15 min -> silently skip
    }

    // Record audit log
    await _notificationDao.insertLog(
      reminderId: row.id,
      scheduledAt: row.fireAt,
      wasDnd: _dndService.isDndActive,
    );
  }
}
```

### Full Cancellation Pattern (`cancelForItem`):
```dart
Future<void> cancelForItem(String itemId) async {
  final rows = await _scheduleDao.getPendingForItem(itemId);
  for (final row in rows) {
    await _notificationService.cancel(NotificationIds.forReminder(row.id));
  }
  await _notificationService.cancel(NotificationIds.forItem(itemId));
  for (var wd = 1; wd <= 7; wd++) {
    await _notificationService.cancel(NotificationIds.forItemWeekday(itemId, wd));
  }
  await _notificationService.cancel(NotificationIds.forSnooze(itemId));
  await _scheduleDao.deleteForItem(itemId);
}
```

---

## 5. Recurrence Grammar (`RecurrenceResolver`)

| Rule String | Meaning | Next Date Calculation |
|---|---|---|
| `DAYS:1,3,5` | Mon, Wed, Fri weekly | Scans 1..7 days forward for nearest matching weekday at anchor time. |
| `daily` | Every day | `after.add(const Duration(days: 1))` |
| `weekly` | Every 7 days | `after.add(const Duration(days: 7))` |
| `SPECIFIC_DATE:yyyy-MM-dd` | One-shot target | Returns date if future; else `null`. |
| `null` | One-shot item | Returns `null`. |

---

## 6. Background Notification Action Handler

In `lib/main.dart` or dedicated entry file:
```dart
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  final actionId = response.actionId;
  final payload = response.payload;
  if (payload == null) return;

  final prefs = await SharedPreferences.getInstance();
  if (actionId == 'MARK_DONE') {
    await prefs.setString('pending_bg_action', 'MARK_DONE:$payload');
  } else if (actionId == 'SNOOZE_30M') {
    await prefs.setString('pending_bg_action', 'SNOOZE_30M:$payload');
  }
}
```

On app foregrounding in `AuraApp._onAppActive()`:
```dart
final action = prefs.getString('pending_bg_action');
if (action != null) {
  await prefs.remove('pending_bg_action'); // Clear first!
  final parts = action.split(':');
  final type = parts[0];
  final itemId = parts.length > 2 ? parts[2] : parts[1];

  if (type == 'MARK_DONE') {
    await ref.read(itemDaoProvider).completeItem(itemId);
    await ref.read(reminderSchedulingServiceProvider).cancelForItem(itemId);
  } else if (type == 'SNOOZE_30M') {
    await ref.read(snoozeReminderUseCaseProvider).execute(itemId, SnoozePreset.minutes30);
  }
}
```
