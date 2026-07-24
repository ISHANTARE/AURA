import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/workspaces_table.dart';
import 'tables/workspace_sections_table.dart';
import 'tables/tasks_table.dart';
import 'tables/reminders_table.dart';
import 'tables/events_table.dart';
import 'tables/notes_table.dart';
import 'tables/shared_content_table.dart';
import 'tables/notification_log_table.dart';
import 'tables/ai_actions_log_table.dart';
import 'tables/offline_queue_table.dart';
import 'tables/daily_log_table.dart';
import 'tables/sync_queue_table.dart';
import 'daos/task_dao.dart';
import 'daos/workspace_dao.dart';
import 'daos/reminder_dao.dart';
import 'daos/event_dao.dart';
import 'daos/notification_dao.dart';

part 'app_database.g.dart';

/// AURA's single SQLite database.
/// Schema version 1 — matches 06_Database/SCHEMA.md exactly.
///
/// All writes go through DAOs. Never use the database instance directly
/// in feature code — always go through a DAO provider.
@DriftDatabase(
  tables: [
    Workspaces,
    WorkspaceSections,
    Tasks,
    Reminders,
    Events,
    Notes,
    SharedContents,
    NotificationLogs,
    AiActionsLogs,
    OfflineQueues,
    DailyLogs,
    SyncQueues,
  ],
  daos: [
    TaskDao,
    WorkspaceDao,
    ReminderDao,
    EventDao,
    NotificationDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Future migrations added here as schema evolves:
          // if (from < 2) { await m.addColumn(tasks, tasks.newColumn); }
        },
        beforeOpen: (details) async {
          // Enable foreign key enforcement (critical for relational integrity)
          await customStatement('PRAGMA foreign_keys = ON');
          // WAL mode: better concurrent read performance
          await customStatement('PRAGMA journal_mode = WAL');
          // Optimize for mobile: reduce memory usage
          await customStatement('PRAGMA cache_size = 2000');
        },
      );
}

/// Opens the SQLite database file from the app's documents directory.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'aura.db'));
    return NativeDatabase.createInBackground(file);
  });
}

// ── Riverpod Provider ─────────────────────────────────────────────────────────

/// Singleton provider for the database.
/// All DAO providers depend on this.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
