import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/app_database.dart';

import '../../features/home/domain/services/briefing_scheduler.dart';
import '../../features/reminders/domain/usecases/overdue_reminder_usecase.dart';
import '../../features/reminders/domain/usecases/replay_dnd_notifications_usecase.dart';
import '../../features/reminders/domain/usecases/schedule_reminder_usecase.dart';
import '../../features/reminders/domain/usecases/snooze_reminder_usecase.dart';
import '../../features/tasks/domain/usecases/recurring_task_reset_usecase.dart';

export '../../database/app_database.dart';
export '../../database/daos/item_dao.dart';
export '../../database/daos/workspace_dao.dart';
export '../../database/daos/notification_dao.dart';
export '../../database/daos/offline_queue_dao.dart';

export 'connectivity_provider.dart';

// ── Core Database Provider ────────────────────────────────────────────────────

/// Canonical singleton for AppDatabase. All DAOs derive from this.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ── DAO Providers ─────────────────────────────────────────────────────────────

/// ItemDao provider for all item queries (Alarms & Reminders)
final itemDaoProvider = Provider<ItemDao>((ref) {
  return ItemDao(ref.watch(databaseProvider));
});

/// WorkspaceDao provider for workspace CRUD & counts
final workspaceDaoProvider = Provider<WorkspaceDao>((ref) {
  return WorkspaceDao(ref.watch(databaseProvider));
});

/// NotificationDao provider
final notificationDaoProvider = Provider<NotificationDao>((ref) {
  return NotificationDao(ref.watch(databaseProvider));
});

/// OfflineQueueDao provider
final offlineQueueDaoProvider = Provider<OfflineQueueDao>((ref) {
  return OfflineQueueDao(ref.watch(databaseProvider));
});

// ── Reactive Stream Providers ─────────────────────────────────────────────────

/// Stream provider for all active items
final allActiveItemsProvider = StreamProvider<List<Item>>((ref) {
  return ref.watch(itemDaoProvider).watchAllActive();
});

/// Stream provider for urgent high-priority items
final urgentItemsProvider = StreamProvider<List<Item>>((ref) {
  return ref.watch(itemDaoProvider).watchUrgent();
});

/// Stream provider for today's focus items
final todayFocusItemsProvider = StreamProvider<List<Item>>((ref) {
  return ref.watch(itemDaoProvider).watchTodayFocus();
});

/// Stream provider for alarms
final alarmsListProvider = StreamProvider<List<Item>>((ref) {
  return ref.watch(itemDaoProvider).watchByCategory('alarm');
});

/// Stream provider for active workspaces list
final workspacesListProvider = StreamProvider<List<Workspace>>((ref) {
  return ref.watch(workspaceDaoProvider).watchAll();
});

/// Stream provider for notes (items with notes present or generic kind)
final notesListProvider = StreamProvider<List<Item>>((ref) {
  return ref.watch(itemDaoProvider).watchAllActive().map((allItems) {
    return allItems
        .where((i) =>
            (i.notes != null && i.notes!.isNotEmpty) || i.kind == 'generic')
        .toList();
  });
});

// ── User Preferences Providers ────────────────────────────────────────────────

/// FutureProvider for the user's display name from SharedPreferences.
/// Falls back to 'there' if not set during onboarding.
final userNameProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('USER_NAME') ?? 'there';
});

// ── Quick Stats Provider ──────────────────────────────────────────────────────

/// Model for home screen item statistics summary.
class QuickStats {
  final int pending;
  final int completed;
  final int overdue;

  const QuickStats({
    required this.pending,
    required this.completed,
    required this.overdue,
  });
}

/// Stream provider computing pending / completed / overdue item counts reactively.
final quickStatsProvider = StreamProvider<QuickStats>((ref) {
  final itemDao = ref.watch(itemDaoProvider);
  return itemDao.watchAllActive().map((allItems) {
    final now = DateTime.now().millisecondsSinceEpoch;
    int pending = 0;
    int completed = 0;
    int overdue = 0;

    for (final item in allItems) {
      if (item.status == 'completed') {
        completed++;
      } else if (item.status == 'pending') {
        final deadline = item.deadline ?? item.fireAt;
        if (deadline != null && deadline < now) {
          overdue++;
        } else {
          pending++;
        }
      }
    }

    return QuickStats(pending: pending, completed: completed, overdue: overdue);
  });
});

// ── Reminder Usecase Providers ────────────────────────────────────────────────

/// Provider for ScheduleReminderUseCase
final scheduleReminderUseCaseProvider = Provider<ScheduleReminderUseCase>((ref) {
  final db = ref.watch(databaseProvider);
  return ScheduleReminderUseCase(db: db);
});

/// Provider for SnoozeReminderUseCase
final snoozeReminderUseCaseProvider = Provider<SnoozeReminderUseCase>((ref) {
  final db = ref.watch(databaseProvider);
  return SnoozeReminderUseCase(db: db);
});

/// Provider for OverdueReminderUseCase
final overdueReminderUseCaseProvider = Provider<OverdueReminderUseCase>((ref) {
  final db = ref.watch(databaseProvider);
  return OverdueReminderUseCase(db: db);
});

/// Provider for ReplayDndNotificationsUseCase
final replayDndUseCaseProvider = Provider<ReplayDndNotificationsUseCase>((ref) {
  final db = ref.watch(databaseProvider);
  return ReplayDndNotificationsUseCase(db: db);
});

// ── Briefing Scheduler Provider ───────────────────────────────────────────────

/// Singleton provider for the daily morning briefing scheduler.
final briefingSchedulerProvider = Provider<BriefingSchedulerService>((ref) {
  return BriefingSchedulerService();
});

// ── Recurring Task Reset Provider ─────────────────────────────────────────

/// Provider for the recurring task daily reset.
final recurringTaskResetProvider = Provider<RecurringTaskResetUseCase>((ref) {
  final db = ref.watch(databaseProvider);
  return RecurringTaskResetUseCase(db: db);
});
