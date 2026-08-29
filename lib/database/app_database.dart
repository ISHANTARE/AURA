import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'daos/item_dao.dart';
import 'daos/notification_dao.dart';
import 'daos/offline_queue_dao.dart';
import 'daos/shared_content_dao.dart';
import 'daos/workspace_dao.dart';
import 'tables/ai_actions_logs.dart';
import 'tables/daily_logs.dart';
import 'tables/items.dart';
import 'tables/notes.dart';
import 'tables/notification_logs.dart';
import 'tables/offline_queues.dart';
import 'tables/reminders_schedule.dart';
import 'tables/shared_contents.dart';
import 'tables/sync_queues.dart';
import 'tables/workspaces.dart';

part 'app_database.g.dart';

/// Central Drift Database for AURA.
/// Enforces Schema v4, SQLite WAL mode, foreign keys, and migrations.
/// Reference: overhaul-docs/03-database-schema.md
@DriftDatabase(
  tables: [
    Workspaces,
    WorkspaceSections,
    Items,
    RemindersSchedule,
    Notes,
    SharedContents,
    NotificationLogs,
    AiActionsLogs,
    OfflineQueues,
    DailyLogs,
    SyncQueues,
  ],
  daos: [
    ItemDao,
    WorkspaceDao,
    NotificationDao,
    OfflineQueueDao,
    SharedContentDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(workspaceSections);
            await m.createTable(remindersSchedule);
            await m.createTable(notes);
            await m.createTable(sharedContents);
            await m.createTable(notificationLogs);
            await m.createTable(aiActionsLogs);
            await m.createTable(offlineQueues);
            await m.createTable(dailyLogs);
            await m.createTable(syncQueues);
          }
          if (from < 3) {
            await m.addColumn(items, items.parentId);
          }
          if (from < 4) {
            await m.addColumn(items, items.soundUri);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA cache_size = 2000');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'aura.sqlite'));

    // Also work around limitations on older Android devices
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase.createInBackground(file);
  });
}
