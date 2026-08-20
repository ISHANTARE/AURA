import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../database/app_database.dart';
import '../../../../database/daos/daily_log_dao.dart';

class RecurringTaskResetService {
  final ItemDao _itemDao;
  final DailyLogDao _dailyLogDao;
  static const _uuid = Uuid();

  RecurringTaskResetService({
    required ItemDao itemDao,
    required DailyLogDao dailyLogDao,
  })  : _itemDao = itemDao,
        _dailyLogDao = dailyLogDao;

  /// Check all recurring items and reset their status for the new day
  Future<int> checkAndResetRecurringTasks() async {
    final allItems = await _itemDao.watchAllActive().first;
    final recurringItems = allItems.where((t) => t.isRecurring).toList();

    final now = DateTime.now();
    final todayInt = now.year * 10000 + now.month * 100 + now.day;
    final nowMs = now.millisecondsSinceEpoch;

    int resetCount = 0;

    for (final item in recurringItems) {
      final isDone = item.status == 'completed';
      final logStatus = isDone ? 'done' : 'missed';

      await _dailyLogDao.insertLog(
        DailyLogsCompanion(
          id: Value(_uuid.v4()),
          itemId: Value(item.id),
          logDate: Value(todayInt),
          status: Value(logStatus),
          doneAt: Value(isDone ? nowMs : null),
          createdAt: Value(nowMs),
        ),
      );

      if (item.status == 'completed') {
        await _itemDao.updateItem(
          ItemsCompanion(
            id: Value(item.id),
            status: const Value('pending'),
            updatedAt: Value(nowMs),
          ),
        );
        resetCount++;
      }
    }

    return resetCount;
  }
}
