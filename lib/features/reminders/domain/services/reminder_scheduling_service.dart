import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show DateTimeComponents;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/providers.dart';
import '../../data/services/notification_service.dart';
import '../../../capture/domain/entities/intent_result.dart';
import 'notification_ids.dart';
import 'recurrence_resolver.dart';

/// Outcome of a scheduling pass — surfaced so callers can tell the user when
/// something was degraded (inexact alarms) or skipped (stale past times).
class ScheduleOutcome {
  final int scheduledCount;
  final bool usedInexactFallback;
  final List<String> warnings;

  const ScheduleOutcome({
    required this.scheduledCount,
    this.usedInexactFallback = false,
    this.warnings = const [],
  });

  static const ScheduleOutcome empty = ScheduleOutcome(scheduledCount: 0);
}

/// Single authoritative path for turning an [Item] into OS notifications:
///
///   persist RemindersSchedule rows → cancel prior notifications →
///   schedule (exact or inexact) → write NotificationLogs.
///
/// Used by voice capture, manual task/alarm editors, background actions and
/// the startup sweep. Nothing else in the app may call the plugin's
/// zonedSchedule for item-derived reminders/alarms.
class ReminderSchedulingService {
  static const Uuid _uuid = Uuid();

  /// Reminders within this window past their time still fire immediately as a
  /// "missed" alert instead of being skipped.
  static const Duration _missedGrace = Duration(minutes: 15);

  final AppDatabase _db;
  final ItemDao _itemDao;
  final NotificationService _notifications;
  final DateTime Function() _now;

  /// Upgrade guard: cancels every OS notification once so stale hashCode-era
  /// schedules can never double-fire alongside codec-based ones.
  static const String _schemeMigrationGuard = 'notif_scheme_migrated_v2';

  ReminderSchedulingService({
    required AppDatabase db,
    NotificationService? notifications,
    DateTime Function()? clock,
  })  : _db = db,
        _itemDao = ItemDao(db),
        _notifications = notifications ?? NotificationService(),
        _now = clock ?? DateTime.now;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Full sync for one item. Persists reminder rows ([extractedReminders] as
  /// offsets before [anchor]; otherwise synthesizes from the item's own
  /// fields), cancels anything previously scheduled for it, schedules all
  /// future occurrences and logs them.
  Future<ScheduleOutcome> syncForItem(
    Item item, {
    List<ExtractedReminder>? extractedReminders,
    String? soundUri,
  }) async {
    await _runSchemeMigrationOnce();

    await cancelForItem(item.id);

    final anchorMs = item.fireAt ?? item.startTime ?? item.deadline;
    final anchor =
        anchorMs == null ? null : DateTime.fromMillisecondsSinceEpoch(anchorMs);

    if (anchor == null) return ScheduleOutcome.empty;

    final isWeeklyAlarm = item.category == 'alarm' &&
        RecurrenceResolver.isRecurringRule(item.recurrenceRule,
            isRecurring: item.isRecurring) &&
        (RecurrenceResolver.parseWeekdays(item.recurrenceRule)?.isNotEmpty ??
            false);

    // 1. Persist reminder rows.
    if (isWeeklyAlarm) {
      await _persistWeekdayRows(item, anchor);
    } else {
      await _persistOccurrenceRows(
        item,
        anchor: anchor,
        extracted: extractedReminders,
      );
    }

    // 2. Build the schedule list from persisted rows.
    final rows = await _itemDao.getRemindersForItem(item.id);
    final capability = await _notifications.alarmCapability();
    final isAlarmChannel = item.category == 'alarm';

    var scheduled = 0;
    final warnings = <String>[];

    for (final row in rows) {
      final fireAt = DateTime.fromMillisecondsSinceEpoch(row.fireAt);
      final id = NotificationIds.forReminder(row.id);

      // Weekly alarm rows are virtual placeholders for the native weekly
      // repeat; their notification id is weekday-stable instead of row-based.
      final effectiveId = isWeeklyAlarm && row.offsetValue == -1
          ? NotificationIds.forItemWeekday(
              item.id, fireAt.weekday)
          : id;

      final scheduledAt = await _scheduleOne(
        item: item,
        id: effectiveId,
        when: fireAt,
        isAlarmChannel: isAlarmChannel,
        weeklyRepeat: isWeeklyAlarm && row.offsetValue == -1,
        soundUri: soundUri,
        useExact: capability.exactAlarmsAllowed,
      );

      if (scheduledAt) {
        scheduled++;
      } else {
        warnings.add('Skipped stale reminder for ${_format(fireAt)}');
      }

      await _logScheduled(row.id, fireAt);
    }

    return ScheduleOutcome(
      scheduledCount: scheduled,
      usedInexactFallback: capability.usesInexactFallback,
      warnings: warnings,
    );
  }

  /// Cancel every notification that could belong to an item.
  Future<void> cancelForItem(String itemId) async {
    final rows = await _itemDao.getRemindersForItem(itemId);
    for (final row in rows) {
      await _notifications.cancel(NotificationIds.forReminder(row.id));
    }
    await _notifications.cancel(NotificationIds.forItem(itemId));
    for (var wd = 1; wd <= 7; wd++) {
      await _notifications.cancel(NotificationIds.forItemWeekday(itemId, wd));
    }
    await _notifications.cancel(NotificationIds.forSnooze(itemId));
  }

  /// Snooze: reschedules under a stable per-item ID AND syncs the database
  /// (`fireAt` moves), so overdue stats and Today's Focus stop counting the
  /// unsnoozed time.
  Future<ScheduleOutcome> snooze({
    required Item item,
    required DateTime target,
    String? title,
  }) async {
    await _runSchemeMigrationOnce();

    final nowEpoch = _now().millisecondsSinceEpoch;
    await cancelForItem(item.id);

    await _db.transaction(() async {
      await (_db.update(_db.items)..where((t) => t.id.equals(item.id))).write(
        ItemsCompanion(
          fireAt: Value(target.millisecondsSinceEpoch),
          status: const Value('pending'),
          updatedAt: Value(nowEpoch),
        ),
      );

      // Re-point this item's rows into the future relative to the new target
      // and mark them unfired so the sweep treats them as upcoming.
      final rows = await _itemDao.getRemindersForItem(item.id);
      for (final row in rows) {
        await (_db.update(_db.remindersSchedule)
              ..where((r) => r.id.equals(row.id)))
            .write(RemindersScheduleCompanion(
          fireAt: Value(target.millisecondsSinceEpoch),
          hasFired: const Value(false),
        ));
      }
    });

    final updated = await _itemDao.getById(item.id);
    if (updated == null) return ScheduleOutcome.empty;

    final capability = await _notifications.alarmCapability();
    var ok = true;
    try {
      await _notifications.scheduleNotification(
        id: NotificationIds.forSnooze(item.id),
        title: title ?? item.title,
        body: 'Snoozed reminder · due now',
        scheduledDate: target,
        payload: 'item:${item.id}',
        useExact: capability.exactAlarmsAllowed,
      );
    } catch (e) {
      debugPrint('Snooze schedule failed for ${item.id}: $e');
      ok = false;
    }

    return ScheduleOutcome(
      scheduledCount: ok ? 1 : 0,
      usedInexactFallback: capability.usesInexactFallback,
    );
  }

  /// Startup / resume / boot sweep. Heals drift between the DB and the OS:
  /// marks fired occurrences, advances recurring items to their next slot and
  /// re-schedules anything missing.
  Future<void> resynchronizeAll({String reason = 'periodic'}) async {
    try {
      await _runSchemeMigrationOnce();

      final items = await _itemDao.getAllActive();
      for (final item in items) {
        if (item.deletedAt != null) continue;
        if (item.status == 'completed') continue;

        final anchorMs = item.fireAt ?? item.startTime ?? item.deadline;
        if (anchorMs == null) continue;

        await _advanceAndReschedule(item, DateTime.now());
      }
    } catch (e, st) {
      debugPrint('resynchronizeAll($reason) failed: $e\n$st');
    }
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  /// Schedule one occurrence. Returns true when an OS schedule (or immediate
  /// missed-fire) happened, false when deliberately skipped as stale.
  Future<bool> _scheduleOne({
    required Item item,
    required int id,
    required DateTime when,
    required bool isAlarmChannel,
    required bool weeklyRepeat,
    String? soundUri,
    required bool useExact,
  }) async {
    final now = _now();
    final isPast = !when.isAfter(now);

    final payload =
        item.category == 'alarm' ? 'alarm:${item.id}' : 'item:${item.id}';
    final timeLabel = _format(when);

    if (isAlarmChannel) {
      // Alarms always surface — even late ones ring through the alarm channel.
      await _notifications.scheduleAlarm(
        id: id,
        title: item.title,
        body: 'Alarm: $timeLabel',
        scheduledDate: when,
        payload: payload,
        soundUri: soundUri,
        useExact: useExact,
        matchDateTimeComponents:
            weeklyRepeat ? DateTimeComponents.dayOfWeekAndTime : null,
      );
      return true;
    }

    if (isPast) {
      final lateBy = now.difference(when);
      if (lateBy > _missedGrace) {
        // Stale beyond grace — skipping beats nagging about yesterday.
        return false;
      }
      await _notifications.scheduleNotification(
        id: id,
        title: item.title,
        body: 'Due ${lateBy.inMinutes} min ago',
        scheduledDate: when, // past ⇒ instant "Missed:" fire inside service
        payload: payload,
        useExact: useExact,
        missedFire: true,
      );
      return true;
    }

    await _notifications.scheduleNotification(
      id: id,
      title: item.title,
      body: item.notes?.isNotEmpty == true ? item.notes! : 'Reminder',
      scheduledDate: when,
      payload: payload,
      useExact: useExact,
    );
    return true;
  }

  /// Persist rows for extracted offsets plus the anchor itself.
  ///
  /// The anchor becomes its own row with offsetValue 0, satisfying the
  /// NotificationLogs FK and giving DND replay full coverage.
  Future<void> _persistOccurrenceRows(
    Item item, {
    required DateTime anchor,
    List<ExtractedReminder>? extracted,
  }) async {
    await _deleteScheduleRowsForItem(item.id);

    final rows = <RemindersScheduleCompanion>[];
    var hasAnchorRow = false;

    if (extracted != null) {
      for (final r in extracted) {
        final fireAt =
            anchor.subtract(_offsetDuration(r.offsetValue, r.offsetUnit));
        if (r.offsetValue == 0) hasAnchorRow = true;
        rows.add(RemindersScheduleCompanion.insert(
          id: _uuid.v4(),
          itemId: item.id,
          offsetValue: r.offsetValue,
          offsetUnit: r.offsetUnit,
          fireAt: fireAt.millisecondsSinceEpoch,
        ));
      }
    }

    if (!hasAnchorRow) {
      rows.add(RemindersScheduleCompanion.insert(
        id: _uuid.v4(),
        itemId: item.id,
        // offsetValue 0 marks this as the anchor-time occurrence itself.
        offsetValue: 0,
        offsetUnit: 'minutes',
        fireAt: anchor.millisecondsSinceEpoch,
      ));
    }

    await _db.transaction(() async {
      for (final row in rows) {
        await _db.into(_db.remindersSchedule).insert(row);
      }
    });
  }

  /// One placeholder row per selected weekday (offsetValue -1 marks it as a
  /// virtual weekly slot advanced by the sweep).
  Future<void> _persistWeekdayRows(Item item, DateTime anchor) async {
    final weekdays =
        RecurrenceResolver.parseWeekdays(item.recurrenceRule) ?? <int>{};

    await _deleteScheduleRowsForItem(item.id);

    await _db.transaction(() async {
      for (final wd in weekdays) {
        final next = _nextWeekday(anchor, wd);
        await _db.into(_db.remindersSchedule).insert(
              RemindersScheduleCompanion.insert(
                id: _uuid.v4(),
                itemId: item.id,
                offsetValue: -1,
                offsetUnit: 'weekly',
                fireAt: next.millisecondsSinceEpoch,
              ),
            );
      }
    });
  }

  /// Deletes an item's schedule rows FK-safely: notification_logs rows
  /// reference RemindersSchedule, so logs go first. (Caught by tests — a
  /// bare delete of the schedule rows trips FOREIGN KEY constraints.)
  Future<void> _deleteScheduleRowsForItem(String itemId) async {
    final oldRows = await _itemDao.getRemindersForItem(itemId);
    if (oldRows.isEmpty) return;
    final oldIds = oldRows.map((r) => r.id).toList();
    await (_db.delete(_db.notificationLogs)
          ..where((n) => n.reminderId.isIn(oldIds)))
        .go();
    await (_db.delete(_db.remindersSchedule)
          ..where((r) => r.itemId.equals(itemId)))
        .go();
  }

  DateTime _nextWeekday(DateTime anchor, int weekday) {
    for (var offset = 0; offset <= 7; offset++) {
      final day = DateTime(anchor.year, anchor.month, anchor.day + offset);
      final candidate = DateTime(
          day.year, day.month, day.day, anchor.hour, anchor.minute);
      if (candidate.isAfter(_now()) && candidate.weekday == weekday) {
        return candidate;
      }
    }
    return anchor;
  }

  Future<void> _logScheduled(String reminderRowId, DateTime fireAt) async {
    final now = _now().millisecondsSinceEpoch;
    await _db.transaction(() async {
      // Replace any previous log rows for this occurrence (id stability means
      // re-syncs would otherwise stack duplicates).
      await (_db.delete(_db.notificationLogs)
            ..where((n) => n.reminderId.equals(reminderRowId)))
          .go();
      await _db.into(_db.notificationLogs).insert(
            NotificationLogsCompanion.insert(
              id: _uuid.v4(),
              reminderId: reminderRowId,
              scheduledAt: fireAt.millisecondsSinceEpoch,
              createdAt: now,
            ),
          );
    });
  }

  /// Marks past occurrences fired, stamps DND truth best-effort, advances
  /// recurring items and re-schedules rows whose OS slot went missing.
  Future<void> _advanceAndReschedule(Item item, DateTime now) async {
    final rows = await _itemDao.getRemindersForItem(item.id);
    if (rows.isEmpty) return;

    final dndSample = _sampleDnd();
    final capability = await _notifications.alarmCapability();
    final isWeeklyAlarm = item.category == 'alarm' &&
        (RecurrenceResolver.parseWeekdays(item.recurrenceRule)?.isNotEmpty ??
            false);

    for (final row in rows) {
      final fireAt = DateTime.fromMillisecondsSinceEpoch(row.fireAt);

      if (row.hasFired) continue;

      if (fireAt.isBefore(now)) {
        // Fired while we were away (or the OS delivered without us noticing).
        await (_db.update(_db.remindersSchedule)
              ..where((r) => r.id.equals(row.id)))
            .write(const RemindersScheduleCompanion(hasFired: Value(true)));
        await _markLogFired(row.id, fireAt, await dndSample);

        // Advance recurring slots to their next occurrence.
        if (RecurrenceResolver.isRecurringRule(item.recurrenceRule,
            isRecurring: item.isRecurring)) {
          final next = RecurrenceResolver.nextOccurrence(
            recurrenceRule: item.recurrenceRule,
            isRecurring: item.isRecurring,
            anchor: fireAt,
            after: now,
          );
          if (next != null) {
            await (_db.update(_db.remindersSchedule)
                  ..where((r) => r.id.equals(row.id)))
                .write(RemindersScheduleCompanion(
              fireAt: Value(next.millisecondsSinceEpoch),
              hasFired: const Value(false),
            ));
          }
        }
        continue;
      }

      // Upcoming: make sure the OS actually has it (reboot recovery, upgrades).
      if (isWeeklyAlarm && row.offsetValue == -1) {
        await _scheduleOne(
          item: item,
          id: NotificationIds.forItemWeekday(item.id, fireAt.weekday),
          when: fireAt,
          isAlarmChannel: true,
          weeklyRepeat: true,
          useExact: capability.exactAlarmsAllowed,
        );
      } else {
        await _scheduleOne(
          item: item,
          id: NotificationIds.forReminder(row.id),
          when: fireAt,
          isAlarmChannel: item.category == 'alarm',
          weeklyRepeat: false,
          useExact: capability.exactAlarmsAllowed,
        );
      }
    }
  }

  Future<void> _markLogFired(
      String reminderRowId, DateTime fireAt, bool wasDnd) async {
    try {
      final logs = await (_db.select(_db.notificationLogs)
            ..where((n) => n.reminderId.equals(reminderRowId))
            ..where((n) => n.firedAt.isNull()))
          .get();
      for (final log in logs) {
        await (_db.update(_db.notificationLogs)
              ..where((n) => n.id.equals(log.id)))
            .write(NotificationLogsCompanion(
          firedAt: Value(fireAt.millisecondsSinceEpoch),
          wasDnd: Value(wasDnd),
        ));
      }
    } catch (e) {
      debugPrint('Failed marking log fired for $reminderRowId: $e');
    }
  }

  Future<bool> _sampleDnd() async {
    // Best-effort DND sampling at sweep time; the platform provides no
    // history, so `wasDnd` is conservative here — ReplayDndNotificationsUseCase
    // refines replay decisions from DndService's own event stream.
    return false;
  }

  Future<void> _runSchemeMigrationOnce() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_schemeMigrationGuard) ?? false) return;
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Scheme migration cancelAll failed: $e');
    }
    await prefs.setBool(_schemeMigrationGuard, true);
  }

  Duration _offsetDuration(int value, String unit) {
    switch (unit) {
      case 'hours':
        return Duration(hours: value);
      case 'days':
        return Duration(days: value);
      case 'minutes':
      default:
        return Duration(minutes: value);
    }
  }

  String _format(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}

// ── Riverpod wiring ──────────────────────────────────────────────────────────

final reminderSchedulingServiceProvider = Provider<ReminderSchedulingService>(
  (ref) {
    final db = ref.watch(databaseProvider);
    return ReminderSchedulingService(db: db);
  },
);
