import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';

class DailyLogDao {
  final AppDatabase db;
  DailyLogDao(this.db);

  Future<void> insertLog(DailyLogsCompanion log, {InsertMode mode = InsertMode.insertOrReplace}) =>
      db.into(db.dailyLogs).insert(log, mode: mode);

  Future<List<DailyLog>> getLogsForItem(String itemId) =>
      (db.select(db.dailyLogs)..where((d) => d.itemId.equals(itemId))).get();

  Future<List<DailyLog>> getLogsForDate(int logDate) =>
      (db.select(db.dailyLogs)..where((d) => d.logDate.equals(logDate))).get();
}

final dailyLogDaoProvider = Provider<DailyLogDao>(
  (ref) => DailyLogDao(ref.watch(databaseProvider)),
);
