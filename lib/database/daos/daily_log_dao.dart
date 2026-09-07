import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';

part 'daily_log_dao.g.dart';

@DriftAccessor(tables: [DailyLogs])
class DailyLogDao extends DatabaseAccessor<AppDatabase> with _$DailyLogDaoMixin {
  DailyLogDao(super.db);

  Future<void> insertLog(DailyLogsCompanion log, {InsertMode mode = InsertMode.insertOrReplace}) =>
      into(dailyLogs).insert(log, mode: mode);

  Future<List<DailyLog>> getLogsForItem(String itemId) =>
      (select(dailyLogs)..where((d) => d.itemId.equals(itemId))).get();

  Future<List<DailyLog>> getLogsForDate(int logDate) =>
      (select(dailyLogs)..where((d) => d.logDate.equals(logDate))).get();
}

final dailyLogDaoProvider = Provider<DailyLogDao>(
  (ref) => DailyLogDao(ref.watch(databaseProvider)),
);
