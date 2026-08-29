import 'package:drift/drift.dart' as drift;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../database/app_database.dart';
import '../../database/daos/item_dao.dart';
import '../../features/reminders/domain/recurrence_resolver.dart';
import '../../features/reminders/services/reminder_scheduling_service.dart';
import 'notification_ids.dart';
import 'notification_service.dart';

/// Orchestrates the 6-step health and synchronization chain executed on cold start
/// and on every `AppLifecycleState.resumed` transition.
/// Reference: overhaul-docs/09-startup-sequence.md Section 4
class LifecycleSyncService {
  final ItemDao _itemDao;
  final ReminderSchedulingService _scheduler;
  final NotificationService _notificationService;
  final AppDatabase _db;

  LifecycleSyncService({
    required ItemDao itemDao,
    required ReminderSchedulingService scheduler,
    required NotificationService notificationService,
    required AppDatabase db,
  })  : _itemDao = itemDao,
        _scheduler = scheduler,
        _notificationService = notificationService,
        _db = db;

  /// Runs all 6 health and background sync jobs with individual error isolation.
  Future<void> onAppActive() async {
    // ── Job 1: Pending Background Notification Actions ─────────────────────
    try {
      await _processPendingBgActions();
    } catch (_) {}

    // ── Job 2: Morning Briefing Scheduler ──────────────────────────────────
    try {
      await _scheduleMorningBriefing();
    } catch (_) {}

    // ── Job 3: Recurring Task Reset ────────────────────────────────────────
    try {
      await _resetRecurringTasks();
    } catch (_) {}

    // ── Job 4: Proactive Nudge Engine ──────────────────────────────────────
    try {
      await _evaluateProactiveNudge();
    } catch (_) {}

    // ── Job 5: Overdue Items Check ─────────────────────────────────────────
    try {
      await _checkOverdueItems();
    } catch (_) {}

    // ── Job 6: Schedule Reconciliation ────────────────────────────────────
    try {
      await _scheduler.resynchronizeAll('appActive');
    } catch (_) {}
  }

  // ── Job 1 Implementation ───────────────────────────────────────────────────

  Future<void> _processPendingBgActions() async {
    final prefs = await SharedPreferences.getInstance();
    final actionStr = prefs.getString('pending_bg_action');
    if (actionStr == null || actionStr.isEmpty) return;

    // Clear immediately to prevent double-execution
    await prefs.remove('pending_bg_action');

    final parts = actionStr.split(':');
    if (parts.length < 2) return;

    final actionType = parts[0];
    final itemId = parts.sublist(1).join(':').replaceFirst('item:', '');

    final item = await _itemDao.getItemById(itemId);
    if (item == null) return;

    if (actionType == 'MARK_DONE') {
      await _itemDao.completeItem(item.id, true, DateTime.now().millisecondsSinceEpoch);
      await _scheduler.cancelForItem(item.id);
    } else if (actionType == 'SNOOZE_30M') {
      final snoozeTarget = DateTime.now().add(const Duration(minutes: 30));
      await _scheduler.snooze(item, snoozeTarget);
    }
  }

  // ── Job 2 Implementation ───────────────────────────────────────────────────

  Future<void> _scheduleMorningBriefing() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = 'briefing_${now.year}_${now.month}_${now.day}';

    if (prefs.getBool(todayKey) == true) return;

    final briefingHour = prefs.getInt('BRIEFING_HOUR') ?? 7;
    var target = DateTime(now.year, now.month, now.day, briefingHour, 0);

    if (now.isAfter(target)) {
      if (now.hour < 9) {
        // Late wake fallback: 9:00 AM today
        target = DateTime(now.year, now.month, now.day, 9, 0);
      } else {
        // Schedule for tomorrow at briefingHour
        target = DateTime(now.year, now.month, now.day + 1, briefingHour, 0);
      }
    }

    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;
    final todayItems = await _itemDao.watchTodayItems(startOfDay, endOfDay).first;
    final pendingCount = todayItems.where((i) => i.status == 'pending' && i.parentId == null).length;

    final String body;
    if (pendingCount == 0) {
      body = 'Nothing due today — enjoy the calm start.';
    } else {
      final topItem = todayItems.firstWhere((i) => i.status == 'pending', orElse: () => todayItems.first);
      body = '$pendingCount items today · Top: ${topItem.title}';
    }

    final tzTarget = tz.TZDateTime.from(target, tz.local);
    await _notificationService.scheduleNotification(
      id: NotificationIds.briefing,
      title: '☀️ Daily Morning Briefing',
      body: body,
      scheduledDate: tzTarget,
      channelId: NotificationService.remindersChannelId,
      payload: 'route:/briefing',
    );

    await prefs.setBool(todayKey, true);
  }

  // ── Job 3 Implementation ───────────────────────────────────────────────────

  Future<void> _resetRecurringTasks() async {
    final allActive = await _itemDao.watchAllActive().first;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    for (final item in allActive) {
      if (!item.isRecurring || item.recurrenceRule == null) continue;
      final rule = item.recurrenceRule!;
      final anchorMs = item.fireAt ?? item.deadline;
      if (anchorMs == null) continue;

      if (item.status == 'completed' || anchorMs < nowMs) {
        final anchor = DateTime.fromMillisecondsSinceEpoch(anchorMs);
        final next = RecurrenceResolver.nextOccurrence(rule, anchor);
        if (next != null) {
          final nextMs = next.millisecondsSinceEpoch;
          await (_db.update(_db.items)..where((t) => t.id.equals(item.id))).write(
            ItemsCompanion(
              status: const drift.Value('pending'),
              fireAt: drift.Value(nextMs),
              deadline: drift.Value(nextMs),
              updatedAt: drift.Value(nowMs),
            ),
          );
          await _scheduler.syncForItem(item);
        }
      }
    }
  }

  // ── Job 4 Implementation ───────────────────────────────────────────────────

  Future<void> _evaluateProactiveNudge() async {
    final now = DateTime.now();
    // 1. Quiet hours guard: 11 PM to 7 AM
    if (now.hour >= 23 || now.hour < 7) return;

    final prefs = await SharedPreferences.getInstance();

    // 2. Spacing guard: at least 3 hours since last nudge
    final lastNudgeMs = prefs.getInt('last_nudge_ms') ?? 0;
    if (now.millisecondsSinceEpoch - lastNudgeMs < 3 * 60 * 60 * 1000) return;

    // 3. Daily cap guard: max 3 per day
    final dayKey = 'nudge_count_${now.year}_${now.month}_${now.day}';
    final count = prefs.getInt(dayKey) ?? 0;
    if (count >= 3) return;

    // 4. Candidate selection
    final all = await _itemDao.watchAllActive().first;
    final highPriority = all.where((i) => i.status == 'pending' && i.priority == 'high' && i.parentId == null).toList();
    if (highPriority.isEmpty) return;

    final rotateIdx = (prefs.getInt('nudge_rotate_idx') ?? 0) % highPriority.length;
    final targetItem = highPriority[rotateIdx];

    await _notificationService.showImmediate(
      id: NotificationIds.nudge,
      title: '✦ Focus Nudge',
      body: 'Focus time: Ready to complete "${targetItem.title}"?',
      payload: 'item:${targetItem.id}',
    );

    await prefs.setInt('last_nudge_ms', now.millisecondsSinceEpoch);
    await prefs.setInt(dayKey, count + 1);
    await prefs.setInt('nudge_rotate_idx', rotateIdx + 1);
  }

  // ── Job 5 Implementation ───────────────────────────────────────────────────

  Future<void> _checkOverdueItems() async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final overdue = await _itemDao.watchOverdue(nowMs).first;
    final overdueCount = overdue.where((i) => i.parentId == null).length;

    if (overdueCount > 0) {
      await _notificationService.showImmediate(
        id: NotificationIds.overdueSummary,
        title: '⚠️ Overdue Tasks Alert',
        body: 'You have $overdueCount overdue items requiring triage.',
        payload: 'route:/',
      );
    }
  }
}
