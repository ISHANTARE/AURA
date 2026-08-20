# AURA — Database Design

> **Version:** 1.0
> **Phase:** 6 — Database Design
> **Status:** Final
> **Last Updated:** 2026-07-24
> **References:** ADR-001, ADR-002, ADR-005, PRD F-04 through F-08, AI_ARCHITECTURE.md

This document defines the complete SQLite schema via Drift ORM.
Implement this exactly in Phase 8. Schema version 1 = this document.

---

## Design Rules (Binding)

1. **UUIDs as primary keys** — enables future cloud sync without ID conflicts.
2. **Every object has workspace_id** — non-nullable FK, enforced at DB level (ADR-005).
3. **Timestamps as INTEGER** — Unix epoch milliseconds for all datetime fields.
4. **Soft delete everywhere** — `deleted_at` column. Never hard-delete user data.
5. **Drift ORM only** — no raw SQLite queries outside of DAO files.
6. **Reactive streams** — use `.watch()` not `.get()` for all UI-driving queries.
7. **Index all FKs and filter columns** — workspace_id, deadline, status, fire_at.

---

## ER Diagram

```
┌──────────────┐         ┌──────────────────────────┐
│  workspaces  │◄────────│  workspace_sections       │
│  (id)        │  1:N    │  (id, workspace_id)       │
└──────┬───────┘         └──────────────────────────┘
       │
       │ 1:N (workspace_id)
       │
┌──────▼───────────────────────────────────────────┐
│  tasks                                            │
│  (id, workspace_id, section_id, parent_task_id)  │◄────┐ self-ref (subtasks)
└──────┬───────────────────────────────────────────┘     │
       │                                                  │
       ├──────────────────┐              ┌────────────────┘
       │ 1:N              │ 1:N          │
┌──────▼──────┐   ┌───────▼──────┐
│  reminders  │   │  notes       │
│  (task_id)  │   │  (task_id)   │
└──────┬──────┘   └──────────────┘
       │
       │ 1:N (reminder_id)
┌──────▼──────────────┐
│  notification_log   │
│  (reminder_id)      │
└─────────────────────┘

┌──────────────┐
│  events      │  (also has workspace_id, section_id)
└──────────────┘

┌──────────────────┐
│  shared_content  │  (linked to tasks optionally)
└──────────────────┘

┌──────────────────┐
│  ai_actions_log  │  (linked to tasks optionally)
└──────────────────┘

┌──────────────────┐
│  offline_queue   │  (transcript → pending AI processing)
└──────────────────┘

┌──────────────────┐
│  daily_log       │  (recurring task daily completion tracking)
└──────────────────┘

┌──────────────────┐
│  sync_queue      │  (future cloud sync — not used in MVP)
└──────────────────┘
```

---

## Table Definitions

### workspaces

```sql
CREATE TABLE workspaces (
  id          TEXT NOT NULL PRIMARY KEY,   -- UUID v4
  name        TEXT NOT NULL,               -- "VIT", "GATE Prep", "Internship"
  color_hex   TEXT NOT NULL,               -- "#C8FF00" (lime default)
  emoji       TEXT NOT NULL,               -- "📚"
  sort_order  INTEGER NOT NULL DEFAULT 0,  -- user-defined display order
  created_by  TEXT NOT NULL DEFAULT 'USER_EXPLICIT', -- USER_EXPLICIT | AI_DETECTED
  is_archived INTEGER NOT NULL DEFAULT 0,  -- 0=active, 1=archived
  created_at  INTEGER NOT NULL,            -- Unix ms
  updated_at  INTEGER NOT NULL,
  deleted_at  INTEGER                      -- NULL = active
);

-- No index needed on PK (auto-indexed)
```

**Drift table class:**
```dart
class Workspaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get colorHex => text()();
  TextColumn get emoji => text()();
  IntColumn  get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get createdBy => text().withDefault(const Constant('USER_EXPLICIT'))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn  get createdAt => integer()();
  IntColumn  get updatedAt => integer()();
  IntColumn  get deletedAt => integer().nullable()();

  @override Set<Column> get primaryKey => {id};
}
```

---

### workspace_sections

```sql
CREATE TABLE workspace_sections (
  id           TEXT NOT NULL PRIMARY KEY,
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  name         TEXT NOT NULL,              -- "Subjects", "Projects", "Fests & Events"
  sort_order   INTEGER NOT NULL DEFAULT 0,
  created_by   TEXT NOT NULL DEFAULT 'USER_EXPLICIT',
  is_archived  INTEGER NOT NULL DEFAULT 0,
  created_at   INTEGER NOT NULL,
  updated_at   INTEGER NOT NULL,
  deleted_at   INTEGER
);

CREATE INDEX idx_sections_workspace ON workspace_sections(workspace_id);
```

---

### tasks

```sql
CREATE TABLE tasks (
  id                  TEXT NOT NULL PRIMARY KEY,
  workspace_id        TEXT NOT NULL REFERENCES workspaces(id),   -- ADR-005: non-nullable
  section_id          TEXT REFERENCES workspace_sections(id),     -- nullable (unsectioned = null)
  parent_task_id      TEXT REFERENCES tasks(id),                  -- nullable (null = top-level)
  name                TEXT NOT NULL,
  description         TEXT,
  deadline            INTEGER,                                     -- Unix ms, nullable = no deadline
  estimated_hours     REAL,
  priority            TEXT NOT NULL DEFAULT 'medium',             -- 'low'|'medium'|'high'|'critical'
  status              TEXT NOT NULL DEFAULT 'todo',               -- 'todo'|'doing'|'done'|'cancelled'
  is_recurring        INTEGER NOT NULL DEFAULT 0,
  recurrence_type     TEXT,                                       -- 'daily'|'weekly'|'custom'|null
  recurrence_days     TEXT,                                       -- JSON array: '["MON","WED"]'|null
  recurrence_start    INTEGER,                                     -- Unix ms
  recurrence_end      INTEGER,                                     -- Unix ms, null = no end
  contact             TEXT,
  voice_note_path     TEXT,                                       -- local file path
  source              TEXT NOT NULL DEFAULT 'text',              -- 'voice'|'text'|'share'
  ai_raw_transcript   TEXT,                                       -- original voice transcript
  ai_generated        INTEGER NOT NULL DEFAULT 0,
  completed_at        INTEGER,                                     -- Unix ms, set when done
  created_at          INTEGER NOT NULL,
  updated_at          INTEGER NOT NULL,
  deleted_at          INTEGER
);

CREATE INDEX idx_tasks_workspace  ON tasks(workspace_id);
CREATE INDEX idx_tasks_section    ON tasks(section_id);
CREATE INDEX idx_tasks_deadline   ON tasks(deadline);
CREATE INDEX idx_tasks_status     ON tasks(status);
CREATE INDEX idx_tasks_parent     ON tasks(parent_task_id);
CREATE INDEX idx_tasks_recurring  ON tasks(is_recurring);
```

**Key queries this schema supports:**
```dart
// Watch all active tasks in a workspace, ordered by deadline
SELECT * FROM tasks
WHERE workspace_id = ? AND status != 'done' AND status != 'cancelled'
  AND deleted_at IS NULL
ORDER BY deadline ASC NULLS LAST;

// Watch overdue tasks (deadline passed, not done)
SELECT * FROM tasks
WHERE deadline < ? AND status = 'todo' AND deleted_at IS NULL;

// Watch today's recurring tasks
SELECT * FROM tasks
WHERE is_recurring = 1 AND status = 'todo'
  AND (recurrence_end IS NULL OR recurrence_end > ?)
  AND deleted_at IS NULL;
```

---

### reminders

```sql
CREATE TABLE reminders (
  id           TEXT NOT NULL PRIMARY KEY,
  task_id      TEXT REFERENCES tasks(id),    -- nullable if standalone reminder
  event_id     TEXT REFERENCES events(id),   -- nullable if task reminder
  fire_at      INTEGER NOT NULL,             -- Unix ms: exact time to fire
  type         TEXT NOT NULL DEFAULT 'notification', -- 'notification'|'alarm'
  status       TEXT NOT NULL DEFAULT 'pending',      -- 'pending'|'fired'|'snoozed'|'dismissed'|'cancelled'
  snoozed_until INTEGER,                             -- Unix ms if snoozed
  has_fired    INTEGER NOT NULL DEFAULT 0,
  missed_dnd   INTEGER NOT NULL DEFAULT 0,          -- ADR-009: fired during DND
  replayed_at  INTEGER,                             -- when DND replay happened
  created_at   INTEGER NOT NULL,
  updated_at   INTEGER NOT NULL
);

CREATE INDEX idx_reminders_task    ON reminders(task_id);
CREATE INDEX idx_reminders_event   ON reminders(event_id);
CREATE INDEX idx_reminders_fire_at ON reminders(fire_at);
CREATE INDEX idx_reminders_status  ON reminders(status);
```

**Critical query (DND replay — ADR-009):**
```sql
SELECT * FROM reminders
WHERE missed_dnd = 1 AND replayed_at IS NULL
ORDER BY fire_at ASC;
```

---

### events

```sql
CREATE TABLE events (
  id             TEXT NOT NULL PRIMARY KEY,
  workspace_id   TEXT NOT NULL REFERENCES workspaces(id),
  section_id     TEXT REFERENCES workspace_sections(id),
  title          TEXT NOT NULL,
  description    TEXT,
  start_at       INTEGER NOT NULL,             -- Unix ms
  end_at         INTEGER NOT NULL,             -- Unix ms (default = start + 1 hour)
  location       TEXT,
  is_recurring   INTEGER NOT NULL DEFAULT 0,
  recurrence_rule TEXT,                        -- iCal RRULE string (future)
  priority       TEXT NOT NULL DEFAULT 'medium',
  status         TEXT NOT NULL DEFAULT 'upcoming', -- 'upcoming'|'done'|'missed'|'cancelled'
  source         TEXT NOT NULL DEFAULT 'voice',
  ai_raw_transcript TEXT,
  external_cal_id TEXT,                        -- Google Calendar event ID (when synced, future)
  created_at     INTEGER NOT NULL,
  updated_at     INTEGER NOT NULL,
  deleted_at     INTEGER
);

CREATE INDEX idx_events_workspace ON events(workspace_id);
CREATE INDEX idx_events_start     ON events(start_at);
CREATE INDEX idx_events_status    ON events(status);
```

---

### notes

```sql
CREATE TABLE notes (
  id           TEXT NOT NULL PRIMARY KEY,
  task_id      TEXT REFERENCES tasks(id),      -- nullable (note may be standalone)
  event_id     TEXT REFERENCES events(id),     -- nullable
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  content      TEXT NOT NULL,
  type         TEXT NOT NULL DEFAULT 'text',   -- 'text'|'voice'|'image'|'link'
  file_path    TEXT,                           -- for voice/image types
  url          TEXT,                           -- for link type
  created_at   INTEGER NOT NULL,
  updated_at   INTEGER NOT NULL,
  deleted_at   INTEGER
);

CREATE INDEX idx_notes_task      ON notes(task_id);
CREATE INDEX idx_notes_workspace ON notes(workspace_id);
```

---

### shared_content

```sql
CREATE TABLE shared_content (
  id           TEXT NOT NULL PRIMARY KEY,
  type         TEXT NOT NULL,                  -- 'screenshot'|'link'|'document'|'text'
  raw_path     TEXT,                           -- local file path for images/docs
  raw_url      TEXT,                           -- for links
  ocr_text     TEXT,                           -- ML Kit extracted text
  ai_summary   TEXT,                           -- Gemini-processed summary
  page_title   TEXT,                           -- for links
  status       TEXT NOT NULL DEFAULT 'pending', -- 'pending'|'processed'|'dismissed'
  workspace_id TEXT REFERENCES workspaces(id), -- assigned after processing
  task_id      TEXT REFERENCES tasks(id),      -- linked task if created
  created_at   INTEGER NOT NULL,
  updated_at   INTEGER NOT NULL
);

CREATE INDEX idx_shared_status ON shared_content(status);
```

---

### notification_log

```sql
CREATE TABLE notification_log (
  id              TEXT NOT NULL PRIMARY KEY,
  reminder_id     TEXT NOT NULL REFERENCES reminders(id),
  scheduled_at    INTEGER NOT NULL,            -- when it was supposed to fire
  fired_at        INTEGER,                     -- when it actually fired (null if not yet)
  was_dnd         INTEGER NOT NULL DEFAULT 0,  -- 1 if DND was active when fired
  replayed_at     INTEGER,                     -- when DND replay notification was sent
  user_dismissed  INTEGER NOT NULL DEFAULT 0,
  created_at      INTEGER NOT NULL
);

CREATE INDEX idx_notif_log_reminder ON notification_log(reminder_id);
CREATE INDEX idx_notif_log_dnd      ON notification_log(was_dnd);
```

---

### ai_actions_log

```sql
CREATE TABLE ai_actions_log (
  id            TEXT NOT NULL PRIMARY KEY,
  input_text    TEXT NOT NULL,                 -- transcript or content sent to AI
  raw_response  TEXT NOT NULL,                 -- full Gemini JSON response
  parsed_json   TEXT NOT NULL,                 -- our parsed result
  confidence    REAL,
  action_taken  TEXT NOT NULL,                 -- 'task_created'|'draft_saved'|'dismissed'|'manual_override'
  task_id       TEXT REFERENCES tasks(id),     -- linked task if created
  user_edited   INTEGER NOT NULL DEFAULT 0,    -- 1 if user changed AI output before confirming
  created_at    INTEGER NOT NULL
);
```

---

### offline_queue

```sql
CREATE TABLE offline_queue (
  id           TEXT NOT NULL PRIMARY KEY,
  type         TEXT NOT NULL DEFAULT 'transcript', -- 'transcript'|'link'|'screenshot'
  content      TEXT NOT NULL,                  -- raw transcript or URL or file path
  context_json TEXT,                           -- workspace context at time of capture
  status       TEXT NOT NULL DEFAULT 'pending', -- 'pending'|'processing'|'processed'|'failed'
  attempts     INTEGER NOT NULL DEFAULT 0,
  created_at   INTEGER NOT NULL,
  processed_at INTEGER
);

CREATE INDEX idx_queue_status ON offline_queue(status);
```

---

### daily_log

```sql
CREATE TABLE daily_log (
  id         TEXT NOT NULL PRIMARY KEY,
  task_id    TEXT NOT NULL REFERENCES tasks(id), -- recurring task
  log_date   INTEGER NOT NULL,                   -- Unix ms for midnight of that day
  status     TEXT NOT NULL,                      -- 'done'|'missed'|'skipped'
  done_at    INTEGER,                            -- Unix ms when marked done
  created_at INTEGER NOT NULL
);

CREATE INDEX idx_daily_log_task ON daily_log(task_id);
CREATE INDEX idx_daily_log_date ON daily_log(log_date);
```

---

### sync_queue (future cloud sync — not used in MVP)

```sql
CREATE TABLE sync_queue (
  id           TEXT NOT NULL PRIMARY KEY,
  entity_type  TEXT NOT NULL,                  -- 'task'|'event'|'reminder'|'workspace'
  entity_id    TEXT NOT NULL,
  operation    TEXT NOT NULL,                  -- 'create'|'update'|'delete'
  payload      TEXT NOT NULL,                  -- JSON snapshot of entity
  status       TEXT NOT NULL DEFAULT 'pending', -- 'pending'|'synced'|'failed'
  attempts     INTEGER NOT NULL DEFAULT 0,
  created_at   INTEGER NOT NULL,
  synced_at    INTEGER
);
```

---

## DAO Definitions

### TaskDao

```dart
@DriftAccessor(tables: [Tasks, Reminders, Notes])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {

  // Watch all active tasks for a workspace (reactive UI)
  Stream<List<Task>> watchActiveByWorkspace(String workspaceId) =>
      (select(tasks)
        ..where((t) => t.workspaceId.equals(workspaceId))
        ..where((t) => t.status.isNotIn(['done', 'cancelled']))
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm(expression: t.deadline, mode: OrderingMode.asc)]))
      .watch();

  // Watch overdue tasks
  Stream<List<Task>> watchOverdue() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (select(tasks)
      ..where((t) => t.deadline.isSmallerThan(Variable(now)))
      ..where((t) => t.status.equals('todo'))
      ..where((t) => t.deletedAt.isNull()))
    .watch();
  }

  // Insert task (always as batch with reminders)
  Future<void> insertTaskWithReminders(Task task, List<Reminder> reminders) =>
    transaction(() async {
      await into(tasks).insert(task.toCompanion());
      await batch((b) => b.insertAll(reminders, reminders.map((r) => r.toCompanion()).toList()));
    });

  // Soft delete
  Future<void> softDelete(String taskId) =>
    (update(tasks)..where((t) => t.id.equals(taskId)))
    .write(TasksCompanion(deletedAt: Value(DateTime.now().millisecondsSinceEpoch)));
}
```

### ReminderDao

```dart
@DriftAccessor(tables: [Reminders, NotificationLog])
class ReminderDao extends DatabaseAccessor<AppDatabase> with _$ReminderDaoMixin {

  // Get all pending reminders (for notification scheduler)
  Future<List<Reminder>> getPendingReminders() =>
    (select(reminders)
      ..where((r) => r.status.equals('pending'))
      ..orderBy([(r) => OrderingTerm(expression: r.fireAt)]))
    .get();

  // Get DND-missed reminders for replay (ADR-009)
  Future<List<Reminder>> getDndMissedUnreplayed() =>
    (select(reminders)
      ..where((r) => r.missedDnd.equals(true))
      ..where((r) => r.replayedAt.isNull()))
    .get();

  // Mark reminder as fired + log it
  Future<void> markFired(String reminderId, {required bool wasDnd}) =>
    transaction(() async {
      await (update(reminders)..where((r) => r.id.equals(reminderId))).write(
        RemindersCompanion(
          hasFired: const Value(true),
          missedDnd: Value(wasDnd),
          status: const Value('fired'),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
      await into(notificationLog).insert(NotificationLogCompanion(
        id: Value(UuidGenerator.v4()),
        reminderId: Value(reminderId),
        scheduledAt: Value(DateTime.now().millisecondsSinceEpoch),
        firedAt: Value(DateTime.now().millisecondsSinceEpoch),
        wasDnd: Value(wasDnd),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));
    });
}
```

---

## Migration Strategy

```dart
@DriftDatabase(tables: [
  Workspaces, WorkspaceSections, Tasks, Reminders, Events,
  Notes, SharedContent, NotificationLog, AiActionsLog,
  OfflineQueue, DailyLog, SyncQueue,
])
class AppDatabase extends _$AppDatabase {

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Insert default workspace color palette
      await _seedDefaults();
    },
    onUpgrade: (m, from, to) async {
      // Future migrations added here as:
      // if (from < 2) { await m.addColumn(tasks, tasks.newColumn); }
    },
    beforeOpen: (details) async {
      // Enable foreign key enforcement
      await customStatement('PRAGMA foreign_keys = ON');
      // Enable WAL mode for better concurrent read performance
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );
}
```

---

## Data Integrity Rules

| Rule | Enforcement |
|------|-------------|
| task.workspace_id never null | Column non-nullable + FK constraint |
| reminder.fire_at must be before task.deadline | Application-level validation in use case |
| task cannot be its own parent | Application-level validation in use case |
| Archiving workspace soft-deletes all its tasks | Cascade handled in WorkspaceDao.archive() |
| Deleting section → tasks move to unsectioned (section_id = null) | Handled in SectionDao.archive() |
| Two reminders on same task cannot have same fire_at | Unique constraint on (task_id, fire_at) |

---

*Database Design v1.0 — 2026-07-24*
*Schema Version: 1*
*Phase 6 complete. Next: Phase 7 — Development Roadmap (Sprints)*
