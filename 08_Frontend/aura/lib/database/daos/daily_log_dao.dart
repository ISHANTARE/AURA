import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_database.dart';

class DailyLogDao {
  final AppDatabase db;
  DailyLogDao(this.db);

  Future<void> insertLog(DailyLogsCompanion log) =>
      db.into(db.dailyLogs).insert(log);

  Future<List<DailyLog>> getLogsForTask(String taskId) =>
      (db.select(db.dailyLogs)..where((d) => d.taskId.equals(taskId))).get();

  Future<List<DailyLog>> getLogsForDate(int logDate) =>
      (db.select(db.dailyLogs)..where((d) => d.logDate.equals(logDate))).get();
}

final dailyLogDaoProvider = Provider<DailyLogDao>(
  (ref) => DailyLogDao(ref.watch(databaseProvider)),
);
