import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../database/app_database.dart';
import '../../../../database/daos/daily_log_dao.dart';
import '../../../../database/daos/task_dao.dart';

class RecurringTaskResetService {
  final TaskDao _taskDao;
  final DailyLogDao _dailyLogDao;
  static const _uuid = Uuid();

  RecurringTaskResetService({
    required TaskDao taskDao,
    required DailyLogDao dailyLogDao,
  })  : _taskDao = taskDao,
        _dailyLogDao = dailyLogDao;

  /// Check all recurring tasks and reset their status for the new day
  Future<int> checkAndResetRecurringTasks() async {
    final allTasks = await _taskDao.getAll();
    final recurringTasks = allTasks.where((t) => t.isRecurring).toList();

    final now = DateTime.now();
    final todayInt = now.year * 10000 + now.month * 100 + now.day;
    final nowMs = now.millisecondsSinceEpoch;

    int resetCount = 0;

    for (final task in recurringTasks) {
      // Record daily log for yesterday's status
      final isDone = task.status == 'done';
      final logStatus = isDone ? 'done' : 'missed';

      await _dailyLogDao.insertLog(
        DailyLogsCompanion(
          id: Value(_uuid.v4()),
          taskId: Value(task.id),
          logDate: Value(todayInt),
          status: Value(logStatus),
          doneAt: Value(isDone ? nowMs : null),
          createdAt: Value(nowMs),
        ),
      );

      // Reset task status to 'todo' for the new day
      if (task.status == 'done') {
        await _taskDao.updateTask(
          TasksCompanion(
            id: Value(task.id),
            status: const Value('todo'),
            updatedAt: Value(nowMs),
          ),
        );
        resetCount++;
      }
    }

    return resetCount;
  }
}
