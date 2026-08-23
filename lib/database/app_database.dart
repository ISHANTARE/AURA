import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/workspaces_table.dart';
import 'tables/workspace_sections_table.dart';
import 'tables/items_table.dart';
import 'tables/reminders_schedule_table.dart';
import 'tables/notes_table.dart';
import 'tables/shared_content_table.dart';
import 'tables/notification_log_table.dart';
import 'tables/ai_actions_log_table.dart';
import 'tables/offline_queue_table.dart';
import 'tables/daily_log_table.dart';
import 'tables/sync_queue_table.dart';

import 'daos/item_dao.dart';
import 'daos/workspace_dao.dart';
import 'daos/notification_dao.dart';
import 'daos/offline_queue_dao.dart';

export 'tables/workspaces_table.dart';
export 'tables/workspace_sections_table.dart';
export 'tables/items_table.dart';
export 'tables/reminders_schedule_table.dart';
export 'tables/notes_table.dart';
export 'tables/shared_content_table.dart';
export 'tables/notification_log_table.dart';
export 'tables/ai_actions_log_table.dart';
export 'tables/offline_queue_table.dart';
export 'tables/daily_log_table.dart';
export 'tables/sync_queue_table.dart';

export 'daos/item_dao.dart';
export 'daos/workspace_dao.dart';
export 'daos/notification_dao.dart';
export 'daos/offline_queue_dao.dart';

part 'app_database.g.dart';

/// AURA v2 Single SQLite Database
///
/// Clean Architecture Rule: All database writes MUST go through DAOs or Use Cases.
/// Never access database instance directly inside widgets.
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Idempotently create any tables missing from schema v1.
            // Failures are logged — a real failure (disk full) must not be
            // indistinguishable from "table already exists".
            for (final table in allTables) {
              try {
                await m.createTable(table);
              } catch (e) {
                debugPrint('Migration v$from→v2: '
                    'createTable(${table.actualTableName}) skipped/failed: $e');
              }
            }
          }
          if (from < 3) {
            // Add parentId column for subtask support
            try {
              await m.addColumn(items, items.parentId);
            } catch (e) {
              debugPrint('Migration v$from→v3: addColumn(parent_id) '
                  'skipped/failed (may already exist): $e');
            }
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA cache_size = 2000');
        },
      );
}

/// Opens the SQLite database file in the application document directory.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'aura.db'));
    return NativeDatabase.createInBackground(file);
  });
}
