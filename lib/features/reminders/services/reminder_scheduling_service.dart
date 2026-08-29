import 'package:drift/drift.dart' show Value;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/services/notification_ids.dart';
import '../../../core/services/notification_service.dart';
import '../../../database/app_database.dart';
import '../../../database/daos/item_dao.dart';
import '../domain/recurrence_resolver.dart';

/// Single authoritative scheduler for converting an [Item] into OS alarm/reminder notifications.
///
/// **Architecture rule:** This is the ONLY class permitted to interact with
/// [NotificationService] for item-derived alarms and reminders.
class ReminderSchedulingService {
  final ItemDao _itemDao;
  final NotificationService _notificationService;
  final AppDatabase _db;

  ReminderSchedulingService({
    required ItemDao itemDao,
    required NotificationService notificationService,
    required AppDatabase db,
  })  : _itemDao = itemDao,
        _notificationService = notificationService,
        _db = db;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Schedules all OS notifications for [item].
  ///
  /// 1. Cancels any previously scheduled notifications for this item.
  /// 2. Resolves the anchor time from `fireAt`.
  /// 3. Schedules reminder rows and/or alarm rows.
  Future<void> syncForItem(Item item) async {
    await cancelForItem(item.id);

    final anchorMs = item.fireAt;
    if (anchorMs == null) return; // No time anchor; nothing to schedule.

    final anchor = DateTime.fromMillisecondsSinceEpoch(anchorMs);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final isAlarm = item.category == 'alarm';
    final isRecurringWeekly = item.isRecurring &&
        item.recurrenceRule != null &&
        item.recurrenceRule!.startsWith('DAYS:');

    if (isAlarm && isRecurringWeekly) {
      // Weekly alarm: schedule an alarm for each active weekday.
      final weekdays = RecurrenceResolver.parseWeekdays(item.recurrenceRule!);
      for (final wd in weekdays) {
        await _scheduleWeekdayAlarm(item, anchor, wd, nowMs);
      }
    } else {
      // Standard scheduling: anchor + any defined offset reminders.
      await _scheduleAnchorNotification(item, anchor, nowMs);
    }
  }

  /// Cancels all notification variants for [itemId] to prevent orphaned alerts.
  Future<void> cancelForItem(String itemId) async {
    // Cancel all per-reminder-row IDs from the database
    final rows = await _db.select(_db.remindersSchedule).get();
    for (final row in rows.where((r) => r.itemId == itemId)) {
      await _notificationService.cancel(NotificationIds.forReminder(row.id));
    }
    // Cancel all deterministic key variants
    await _notificationService.cancel(NotificationIds.forItem(itemId));
    await _notificationService.cancel(NotificationIds.forSnooze(itemId));
    for (var wd = 1; wd <= 7; wd++) {
      await _notificationService.cancel(NotificationIds.forItemWeekday(itemId, wd));
    }
  }

  /// Reschedules all future items. Called on app foreground and boot to
  /// self-heal any missed or OS-evicted alarm slots.
  Future<void> resynchronizeAll(String reason) async {
    final allActive = await _itemDao.watchAllActive().first;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    for (final item in allActive) {
      if (item.fireAt != null && item.fireAt! > nowMs) {
        await syncForItem(item);
      }
    }
  }

  /// Updates `fireAt` on [item] and reschedules with the snooze ID variant.
  Future<void> snooze(Item item, DateTime snoozeTo) async {
    final snoozeMs = snoozeTo.millisecondsSinceEpoch;
    await (_db.update(_db.items)..where((t) => t.id.equals(item.id))).write(
      ItemsCompanion(
        fireAt: Value(snoozeMs),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    final tzSnooze = tz.TZDateTime.from(snoozeTo, tz.local);
    await _notificationService.scheduleNotification(
      id: NotificationIds.forSnooze(item.id),
      title: '⏰ ${item.title}',
      body: 'Snoozed reminder',
      scheduledDate: tzSnooze,
      channelId: NotificationService.remindersChannelId,
      payload: 'item:${item.id}',
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _scheduleAnchorNotification(Item item, DateTime anchor, int nowMs) async {
    final isAlarm = item.category == 'alarm';
    final anchorMs = anchor.millisecondsSinceEpoch;
    final diffMs = anchorMs - nowMs;

    if (isAlarm) {
      // Alarms always fire regardless of past status.
      final tzAnchor = tz.TZDateTime.from(anchor, tz.local);
      await _notificationService.scheduleNotification(
        id: NotificationIds.forItem(item.id),
        title: '⏰ ${item.title}',
        body: item.notes ?? 'Alarm',
        scheduledDate: tzAnchor,
        channelId: NotificationService.alarmsChannelId,
        payload: 'item:${item.id}',
        fullScreenIntent: true,
      );
    } else {
      // Reminders: schedule if future; fire immediately if past ≤ 15 min.
      if (diffMs > 0) {
        final tzAnchor = tz.TZDateTime.from(anchor, tz.local);
        await _notificationService.scheduleNotification(
          id: NotificationIds.forItem(item.id),
          title: item.title,
          body: item.notes ?? 'Reminder',
          scheduledDate: tzAnchor,
          channelId: NotificationService.remindersChannelId,
          payload: 'item:${item.id}',
        );
      } else if (diffMs >= -15 * 60 * 1000) {
        // Past ≤ 15 minutes: fire a "missed" immediate notification.
        await _notificationService.showImmediate(
          id: NotificationIds.forItem(item.id),
          title: 'Missed: ${item.title}',
          body: 'Scheduled ${(-diffMs ~/ 60000)} minutes ago',
          payload: 'item:${item.id}',
        );
      }
      // Past > 15 minutes: stale, skip silently.
    }
  }

  Future<void> _scheduleWeekdayAlarm(
      Item item, DateTime anchor, int weekday, int nowMs) async {
    var target = DateTime(
      anchor.year,
      anchor.month,
      anchor.day,
      anchor.hour,
      anchor.minute,
    );
    // Advance to the next occurrence of the given weekday.
    for (var i = 0; i < 7; i++) {
      if (target.weekday == weekday && target.millisecondsSinceEpoch > nowMs) {
        break;
      }
      target = target.add(const Duration(days: 1));
    }

    final tzTarget = tz.TZDateTime.from(target, tz.local);
    await _notificationService.scheduleNotification(
      id: NotificationIds.forItemWeekday(item.id, weekday),
      title: '⏰ ${item.title}',
      body: item.notes ?? 'Alarm',
      scheduledDate: tzTarget,
      channelId: NotificationService.alarmsChannelId,
      payload: 'item:${item.id}',
      fullScreenIntent: true,
    );
  }
}
