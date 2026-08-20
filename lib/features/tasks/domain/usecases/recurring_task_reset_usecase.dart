import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../database/app_database.dart';
import '../../../../database/daos/daily_log_dao.dart';

/// Recurring Task Reset Use Case — Sprint 10 (F-12)
///
/// Design rules (SPRINTS.md S10):
/// - On each app-open, check if today's reset has already run.
/// - Guard with SharedPreferences key `recurring_reset_<year>_<month>_<day>`.
/// - For every item where isRecurring = true and status = 'completed',
///   reset status → 'pending' and write a DailyLog entry for the prior day.
/// - For items that are recurring and were NOT completed yesterday,
///   write a DailyLog entry with result = 'missed'.
class RecurringTaskResetUseCase {
  final AppDatabase _db;
  final DailyLogDao _dailyLogDao;

  static const _prefKeyPrefix = 'recurring_reset';

  RecurringTaskResetUseCase({required AppDatabase db, DailyLogDao? dailyLogDao})
      : _db = db,
        _dailyLogDao = dailyLogDao ?? DailyLogDao(db);

  Future<void> execute() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = '${_prefKeyPrefix}_${now.year}_${now.month}_${now.day}';

    // Run at most once per day
    if (prefs.getBool(todayKey) == true) return;

    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayLogDate = int.parse(
      '${yesterday.year}${yesterday.month.toString().padLeft(2, '0')}${yesterday.day.toString().padLeft(2, '0')}',
    );
    final nowMs = now.millisecondsSinceEpoch;

    // Query all recurring items
    final recurringItems = await (_db.select(_db.items)
          ..where((t) => t.isRecurring.equals(true) & t.deletedAt.isNull()))
        .get();

    for (final item in recurringItems) {
      final wasCompleted = item.status == 'completed';

      // Write daily log for yesterday
      await _dailyLogDao.insertLog(
        DailyLogsCompanion(
          id: Value('${item.id}_$yesterdayLogDate'),
          itemId: Value(item.id),
          logDate: Value(yesterdayLogDate),
          status: Value(wasCompleted ? 'completed' : 'missed'),
          doneAt: Value(wasCompleted ? nowMs : null),
          createdAt: Value(nowMs),
        ),
      );

      // Reset completed recurring items back to pending for today
      if (wasCompleted) {
        await (_db.update(_db.items)..where((t) => t.id.equals(item.id)))
            .write(ItemsCompanion(
          status: const Value('pending'),
          updatedAt: Value(nowMs),
        ));
      }
    }

    await prefs.setBool(todayKey, true);
  }
}
