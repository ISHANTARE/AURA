# Feature Specification: Reminders, Alarms & Notification Engine

> **Forensic Rebuild Specification**  
> Complete specification for AURA's notification scheduling engine, Android notification channels, FNV-1a ID codec, recurrence resolver, DND replay, and background action handling.

---

## 1. High-Importance Android Notification Channels

AURA configures two distinct Android Notification Channels via `NotificationService` (`flutter_local_notifications`):

| Property | Reminders Channel | Alarms Channel |
|---|---|---|
| **Channel ID** | `aura_reminders_v2` | `aura_alarms_v2` |
| **Channel Name** | `AURA Reminders & Notifications` | `AURA Alarms` |
| **Description** | High priority reminders, event alerts, and DND replay summaries. | Ringing time-of-day alarms from AURA. |
| **Importance** | `Importance.max` | `Importance.max` |
| **Priority** | `Priority.high` | `Priority.max` |
| **Audio Usage** | Default notification sound | `AudioAttributesUsage.alarm` |
| **Full-Screen Intent** | `false` | `true` (`fullScreenIntent = true`) |
| **Ongoing / Auto-Cancel** | `ongoing = false, autoCancel = true` | `ongoing = true, autoCancel = false` |
| **Category** | Default | `AndroidNotificationCategory.alarm` |
| **Action Buttons** | `[MARK DONE]` & `[SNOOZE 30M]` | None (Full-screen alarm intent) |

---

## 2. Deterministic Notification ID Codec (`notification_ids.dart`)

To prevent ID collisions across 64-bit UUID strings, AURA encodes namespaced keys using a **32-bit FNV-1a hash masked to positive 31-bit integer**:

```dart
int notificationId(String key) {
  var hash = 0x811c9dc5;
  for (final byte in utf8.encode(key)) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xFFFFFFFF; // 32-bit FNV-1a
  }
  return hash & 0x7FFFFFFF; // positive int31
}
```

### 2.1 Namespaced Key Builders & Reserved Slots

```dart
abstract final class NotificationIds {
  // Hashed per-entity keys
  static int forItem(String itemId) => notificationId('item:$itemId');
  static int forReminder(String rowId) => notificationId('rem:$rowId');
  static int forItemWeekday(String itemId, int weekday) => notificationId('item:$itemId:wd$weekday');
  static int forSnooze(String itemId) => notificationId('snooze:$itemId');

  // Reserved low integer slots (System Singletons)
  static const int briefing       = 10001; // Daily Morning Briefing
  static const int overdueSummary  = 10002; // Overdue Triage Alert
  static const int nudge          = 10003; // Proactive High-Priority Nudge
  static const int dndCatchup     = 10004; // Missed DND Replay Summary
  static const int offlineReview  = 10005; // Destructive Offline Review Prompt
}
```

---

## 3. Single Authoritative Scheduler (`ReminderSchedulingService`)

`ReminderSchedulingService` is the single point of entry for turning an `Item` into scheduled OS notifications:

```
Item Created / Edited
        │
        ▼
ReminderSchedulingService.syncForItem(item, {extractedReminders, soundUri})
  1. cancelForItem(item.id)
  2. Resolve anchor = item.fireAt ?? item.startTime ?? item.deadline
  3. Persist rows in `reminders_schedule`:
     - If weekly alarm: persist virtual rows (offsetValue = -1) per active weekday.
     - If standard: persist offset rows + anchor row (offsetValue = 0).
  4. Query persisted rows.
  5. Check OS capability: `NotificationService.alarmCapability()`.
     - Android 14+ exact-alarm allowed? → `AndroidScheduleMode.exactAllowWhileIdle`
     - Revoked/denied? → Fall back to `AndroidScheduleMode.inexactAllowWhileIdle`
  6. For each row:
     - Compute deterministic notification ID.
     - If category == 'alarm' → `scheduleAlarm()` (fires even if past).
     - If category == 'reminder':
       • Future → `scheduleNotification()`
       • Past <= 15 min → Immediate `"Missed: <title>"` fire.
       • Past > 15 min → Stale; skip silently.
  7. Insert audit log into `notification_logs`.
```

### 3.1 Cancellation & Cleanup (`cancelForItem`)

Cancelling an item removes all derivable ID variants to ensure no orphaned alerts fire:
1. Cancels all `NotificationIds.forReminder(row.id)` for existing rows.
2. Cancels `NotificationIds.forItem(item.id)`.
3. Cancels `NotificationIds.forItemWeekday(item.id, wd)` for weekdays 1..7.
4. Cancels `NotificationIds.forSnooze(item.id)`.

---

## 4. Recurrence Grammar & Resolver (`RecurrenceResolver`)

Grammar stored in `items.recurrenceRule`:

| Grammar Pattern | Target Cadence | Resolution Behavior |
|---|---|---|
| `DAYS:1,3,5` | Weekly on specific days (1=Mon, 7=Sun) | Iterates up to 7 days forward to find nearest matching weekday at anchor time. |
| `SPECIFIC_DATE:yyyy-MM-dd` | One-shot target date | Returns candidate date if in the future; otherwise `null` (never repeats). |
| `daily` | Simple daily cadence | Next occurrence = same wall-clock time next day (`after + 1 day`). |
| `weekly` | Simple weekly cadence | Next occurrence = same wall-clock time next week (`after + 7 days`). |

---

## 5. Do Not Disturb (DND) Catchup & Replay

1. `DndService` listens to Android broadcast `ACTION_INTERRUPTION_FILTER_CHANGED`.
2. When DND exits (`true` -> `false`), invokes `ReplayDndNotificationsUseCase.execute()`.
3. `ReplayDndNotificationsUseCase`:
   - Queries `notification_logs` for `was_dnd = 1` and `replayed_at IS NULL`.
   - If 1 item missed: Fires instant notification `"Missed while silent: Scheduled X mins ago"` (`payload = 'item:<id>'`).
   - If >1 items missed: Fires summary notification `"DND Catchup: You missed N reminders while DND was active"` (`id = 10004`, `payload = 'route:/briefing'`).
   - Marks logs as replayed (`replayed_at = nowMs`).

---

## 6. Snooze Engine & Background Notification Actions

### 6.1 Snooze Presets (`SnoozePreset`)

| Preset Enum | Display Label | Target Calculation |
|---|---|---|
| `minutes30` | `+30 minutes` | `now + 30 minutes` |
| `hour1` | `+1 hour` | `now + 1 hour` |
| `tonight9pm` | `Tonight (9 PM)` | Today at 21:00 (or Tomorrow 21:00 if already past 9 PM). |
| `tomorrow8am` | `Tomorrow (8 AM)` | Tomorrow at 08:00 AM. |
| `custom` | `Custom...` | User selected DateTime via picker sheet. |

- Snoozing moves `items.fireAt = targetTime`, updates `reminders_schedule.fireAt = targetTime, hasFired = false`, and schedules `NotificationIds.forSnooze(item.id)`.

### 6.2 Background Action Dispatcher (`notificationTapBackground`)

```dart
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  final actionId = response.actionId;
  final payload = response.payload;
  final prefs = await SharedPreferences.getInstance();
  if (actionId == NotificationService.actionMarkDone) {
    await prefs.setString('pending_bg_action', 'MARK_DONE:$payload');
  } else if (actionId == NotificationService.actionSnooze30m) {
    await prefs.setString('pending_bg_action', 'SNOOZE_30M:$payload');
  }
}
```

On app foregrounding, `app.dart` processes `pending_bg_action`, completing or snoozing the item in the database.
