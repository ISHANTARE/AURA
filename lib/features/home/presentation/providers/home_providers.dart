import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/clock_providers.dart';
import '../../../../core/providers/providers.dart';
import '../../domain/services/nudge_engine.dart';

export '../../../../core/providers/providers.dart';

/// Filter mode for the active day's task list
enum DayFilter { all, pendingOnly, completedOnly }

/// The currently selected date in the Daily Cockpit
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// The active task status filter for the selected day
final selectedDayFilterProvider = StateProvider<DayFilter>((ref) {
  return DayFilter.all;
});

/// Watch item count for a workspace.
final workspaceItemCountProvider =
    StreamProvider.autoDispose.family<int, String>((ref, workspaceId) {
  final wsDao = ref.watch(workspaceDaoProvider);
  return wsDao.watchItemCount(workspaceId);
});

/// NudgeEngine provider for proactive nudges
final nudgeEngineProvider = Provider<NudgeEngine>((ref) {
  final itemDao = ref.watch(itemDaoProvider);
  return NudgeEngine(itemDao: itemDao);
});

/// Today's Focus Stats (Pending vs Completed strictly for Today)
class TodayStats {
  final int pending;
  final int completed;
  const TodayStats({required this.pending, required this.completed});
}

/// Stream provider for Today's pending and completed counts
final todayStatsProvider = StreamProvider<TodayStats>((ref) {
  ref.watch(dayRefreshProvider);
  final allActiveAsync = ref.watch(allActiveItemsProvider);
  return allActiveAsync.when(
    data: (items) {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;

      int pending = 0;
      int completed = 0;

      for (final item in items) {
        final targetTime = item.deadline ?? item.fireAt ?? item.startTime;
        final isToday = targetTime != null
            ? (targetTime >= startOfToday && targetTime <= endOfToday)
            : (item.createdAt >= startOfToday && item.createdAt <= endOfToday);

        if (isToday) {
          if (item.status == 'completed') {
            completed++;
          } else if (item.status == 'pending') {
            pending++;
          }
        }
      }
      return Stream.value(TodayStats(pending: pending, completed: completed));
    },
    loading: () => Stream.value(const TodayStats(pending: 0, completed: 0)),
    error: (_, __) => Stream.value(const TodayStats(pending: 0, completed: 0)),
  );
});

/// Stream provider for all overdue items across past days
final overdueItemsProvider = StreamProvider<List<Item>>((ref) {
  ref.watch(dayRefreshProvider);
  final allActive = ref.watch(allActiveItemsProvider);
  return allActive.when(
    data: (items) {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

      final overdueList = items.where((item) {
        if (item.status != 'pending') return false;
        final due = item.deadline ?? item.fireAt ?? item.startTime;
        return due != null && due < startOfToday;
      }).toList();

      // Sort with oldest past-due first
      overdueList.sort((a, b) {
        final aTime = a.deadline ?? a.fireAt ?? a.startTime ?? 0;
        final bTime = b.deadline ?? b.fireAt ?? b.startTime ?? 0;
        return aTime.compareTo(bTime);
      });

      return Stream.value(overdueList);
    },
    loading: () => Stream.value(<Item>[]),
    error: (_, __) => Stream.value(<Item>[]),
  );
});

/// Model separating timed items and anytime checklist items for a day
class DayAgendaModel {
  final List<Item> timedItems;
  final List<Item> anytimeItems;
  final int totalPending;
  final int totalCompleted;

  const DayAgendaModel({
    required this.timedItems,
    required this.anytimeItems,
    required this.totalPending,
    required this.totalCompleted,
  });

  bool get isEmpty => timedItems.isEmpty && anytimeItems.isEmpty;
}

/// Stream provider for items on the selected date
final dayAgendaProvider = StreamProvider<DayAgendaModel>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final filter = ref.watch(selectedDayFilterProvider);
  final allActiveAsync = ref.watch(allActiveItemsProvider);

  return allActiveAsync.when(
    data: (items) {
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day).millisecondsSinceEpoch;
      final endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59, 999).millisecondsSinceEpoch;

      final matchingItems = items.where((item) {
        final targetTime = item.deadline ?? item.fireAt ?? item.startTime;
        if (targetTime != null) {
          return targetTime >= startOfDay && targetTime <= endOfDay;
        }
        // No explicit deadline: show on creation date
        return item.createdAt >= startOfDay && item.createdAt <= endOfDay;
      }).toList();

      int pendingCount = 0;
      int completedCount = 0;

      for (final item in matchingItems) {
        if (item.status == 'completed') {
          completedCount++;
        } else if (item.status == 'pending') {
          pendingCount++;
        }
      }

      // Apply active filter
      final filteredList = matchingItems.where((item) {
        if (filter == DayFilter.pendingOnly) return item.status == 'pending';
        if (filter == DayFilter.completedOnly) return item.status == 'completed';
        return true;
      }).toList();

      final timed = <Item>[];
      final anytime = <Item>[];

      for (final item in filteredList) {
        final targetMs = item.startTime ?? item.fireAt ?? item.deadline;
        if (targetMs != null) {
          final dt = DateTime.fromMillisecondsSinceEpoch(targetMs);
          // Items with specific hour/minute (not 00:00 or 23:59:59) or events/alarms
          if (item.kind == 'event' || item.category == 'alarm' || (dt.hour != 0 && dt.hour != 23 && dt.minute != 59)) {
            timed.add(item);
            continue;
          }
        }
        anytime.add(item);
      }

      // Sort timed items chronologically
      timed.sort((a, b) {
        final aTime = a.startTime ?? a.fireAt ?? a.deadline ?? 0;
        final bTime = b.startTime ?? b.fireAt ?? b.deadline ?? 0;
        return aTime.compareTo(bTime);
      });

      return Stream.value(DayAgendaModel(
        timedItems: timed,
        anytimeItems: anytime,
        totalPending: pendingCount,
        totalCompleted: completedCount,
      ));
    },
    loading: () => Stream.value(const DayAgendaModel(
      timedItems: [],
      anytimeItems: [],
      totalPending: 0,
      totalCompleted: 0,
    )),
    error: (_, __) => Stream.value(const DayAgendaModel(
      timedItems: [],
      anytimeItems: [],
      totalPending: 0,
      totalCompleted: 0,
    )),
  );
});

/// Stream provider computing task count per day for a given 7-day week window
final weekActivityMapProvider = StreamProvider.autoDispose.family<Map<String, int>, DateTime>((ref, anchorDate) {
  final allActiveAsync = ref.watch(allActiveItemsProvider);

  return allActiveAsync.when(
    data: (items) {
      // Find Monday of the anchor's week
      final weekday = anchorDate.weekday; // 1 = Mon, 7 = Sun
      final monday = anchorDate.subtract(Duration(days: weekday - 1));

      final map = <String, int>{};
      for (int i = 0; i < 7; i++) {
        final d = monday.add(Duration(days: i));
        final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        map[key] = 0;
      }

      for (final item in items) {
        if (item.status == 'completed') continue;
        final targetMs = item.deadline ?? item.fireAt ?? item.startTime ?? item.createdAt;
        final dt = DateTime.fromMillisecondsSinceEpoch(targetMs);
        final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        if (map.containsKey(key)) {
          map[key] = (map[key] ?? 0) + 1;
        }
      }

      return Stream.value(map);
    },
    loading: () => Stream.value(<String, int>{}),
    error: (_, __) => Stream.value(<String, int>{}),
  );
});
