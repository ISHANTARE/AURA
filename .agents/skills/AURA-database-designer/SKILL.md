---
name: AURA-database-designer
description: >
  Database architect for AURA. Use this skill when: designing or modifying the Drift/SQLite schema,
  writing ER diagrams, planning database migrations, designing indexes, writing DAO queries,
  planning the data model for a new feature, or when the user says "design the DB for X",
  "what tables do I need for X", "write the schema for X", "add a column for X",
  "how should I store X", or "write the migration for X". This skill covers Phase 6 Database Design.
---

# AURA Database Designer

You are designing the SQLite database (via Drift ORM) for AURA. The database is the most critical
technical component — it must be designed perfectly because migration pain grows with every mistake.

## Core Design Rules

1. **AURA owns the schema.** External calendar formats are exported from AURA's model. (ADR-001)
2. **Every object has a workspaceId.** Non-nullable. This is enforced at the DB level. (ADR-005)
3. **Offline first means local first.** All data is written locally first. Sync is a separate layer.
4. **Use UUIDs for IDs.** Not autoincrement integers. UUIDs enable future cloud sync without conflicts.
5. **Soft delete everything.** Use deletedAt timestamp. Never hard delete user data.
6. **Timestamps on everything.** createdAt, updatedAt, deletedAt on every table.
7. **Design for queries, not just storage.** Add indexes based on actual app query patterns.

## Core Tables

### workspaces
```sql
CREATE TABLE workspaces (
  id          TEXT PRIMARY KEY,       -- UUID
  name        TEXT NOT NULL,
  color_hex   TEXT NOT NULL,          -- '#6C63FF'
  emoji       TEXT NOT NULL,          -- '📚'
  sort_order  INTEGER DEFAULT 0,
  created_at  INTEGER NOT NULL,       -- Unix timestamp ms
  updated_at  INTEGER NOT NULL,
  deleted_at  INTEGER                 -- NULL = active (soft delete)
);
```

### tasks
```sql
CREATE TABLE tasks (
  id              TEXT PRIMARY KEY,    -- UUID
  workspace_id    TEXT NOT NULL REFERENCES workspaces(id),
  name            TEXT NOT NULL,
  description     TEXT,
  deadline        INTEGER,             -- Unix timestamp ms, nullable
  estimated_hours REAL,
  priority        TEXT DEFAULT 'medium', -- 'critical','high','medium','low'
  status          TEXT DEFAULT 'todo',   -- 'todo','doing','done','cancelled'
  contact         TEXT,
  voice_note_path TEXT,               -- local file path
  ai_generated    INTEGER DEFAULT 0,  -- 0 or 1 (boolean)
  parent_task_id  TEXT REFERENCES tasks(id), -- for subtasks
  created_at      INTEGER NOT NULL,
  updated_at      INTEGER NOT NULL,
  deleted_at      INTEGER
);
CREATE INDEX idx_tasks_workspace ON tasks(workspace_id);
CREATE INDEX idx_tasks_deadline ON tasks(deadline);
CREATE INDEX idx_tasks_status ON tasks(status);
```

### reminders
```sql
CREATE TABLE reminders (
  id              TEXT PRIMARY KEY,    -- UUID
  task_id         TEXT NOT NULL REFERENCES tasks(id),
  fire_at         INTEGER NOT NULL,    -- Unix timestamp ms
  type            TEXT NOT NULL,       -- 'notification','alarm','gentle'
  has_fired       INTEGER DEFAULT 0,
  missed_dnd      INTEGER DEFAULT 0,   -- ADR-009: fired during DND
  replayed_at     INTEGER,             -- when DND replay happened
  created_at      INTEGER NOT NULL,
  updated_at      INTEGER NOT NULL
);
CREATE INDEX idx_reminders_task ON reminders(task_id);
CREATE INDEX idx_reminders_fire_at ON reminders(fire_at);
```

### events (distinct from tasks)
```sql
CREATE TABLE events (
  id           TEXT PRIMARY KEY,       -- UUID
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  title        TEXT NOT NULL,
  description  TEXT,
  start_at     INTEGER NOT NULL,       -- Unix timestamp ms
  end_at       INTEGER NOT NULL,
  location     TEXT,
  is_recurring INTEGER DEFAULT 0,
  recurrence_rule TEXT,               -- iCal RRULE string
  external_cal_id TEXT,               -- Google Calendar event ID if synced
  created_at   INTEGER NOT NULL,
  updated_at   INTEGER NOT NULL,
  deleted_at   INTEGER
);
CREATE INDEX idx_events_workspace ON events(workspace_id);
CREATE INDEX idx_events_start ON events(start_at);
```

### notes
```sql
CREATE TABLE notes (
  id           TEXT PRIMARY KEY,
  task_id      TEXT REFERENCES tasks(id),
  workspace_id TEXT NOT NULL REFERENCES workspaces(id),
  content      TEXT NOT NULL,
  type         TEXT DEFAULT 'text',   -- 'text','voice','image','link'
  file_path    TEXT,                  -- for voice/image types
  url          TEXT,                  -- for link type
  created_at   INTEGER NOT NULL,
  updated_at   INTEGER NOT NULL,
  deleted_at   INTEGER
);
```

### shared_content (ADR-008: Share-to-AURA)
```sql
CREATE TABLE shared_content (
  id           TEXT PRIMARY KEY,
  type         TEXT NOT NULL,         -- 'screenshot','link','document','text'
  raw_path     TEXT,                  -- local file path for images/docs
  raw_url      TEXT,                  -- for links
  ocr_text     TEXT,                  -- extracted text
  ai_summary   TEXT,                  -- Gemini processed summary
  status       TEXT DEFAULT 'pending', -- 'pending','processed','dismissed'
  workspace_id TEXT REFERENCES workspaces(id), -- assigned after processing
  task_id      TEXT REFERENCES tasks(id),      -- linked task if created
  created_at   INTEGER NOT NULL,
  updated_at   INTEGER NOT NULL
);
```

### notification_log (ADR-009: DND replay)
```sql
CREATE TABLE notification_log (
  id              TEXT PRIMARY KEY,
  reminder_id     TEXT NOT NULL REFERENCES reminders(id),
  scheduled_at    INTEGER NOT NULL,
  fired_at        INTEGER,
  was_dnd         INTEGER DEFAULT 0,
  replayed_at     INTEGER,
  user_dismissed  INTEGER DEFAULT 0,
  created_at      INTEGER NOT NULL
);
```

### ai_actions_log (transparency per ADR-004)
```sql
CREATE TABLE ai_actions_log (
  id           TEXT PRIMARY KEY,
  input_text   TEXT NOT NULL,         -- what user said
  raw_response TEXT NOT NULL,         -- what Gemini returned
  parsed_json  TEXT NOT NULL,         -- our parsed output
  confidence   REAL,
  action_taken TEXT NOT NULL,         -- 'task_created','event_created','dismissed'
  task_id      TEXT REFERENCES tasks(id),
  user_edited  INTEGER DEFAULT 0,     -- did user change AI output before confirming?
  created_at   INTEGER NOT NULL
);
```

### sync_queue (for future cloud sync)
```sql
CREATE TABLE sync_queue (
  id           TEXT PRIMARY KEY,
  entity_type  TEXT NOT NULL,         -- 'task','event','reminder','workspace'
  entity_id    TEXT NOT NULL,
  operation    TEXT NOT NULL,         -- 'create','update','delete'
  payload      TEXT NOT NULL,         -- JSON
  status       TEXT DEFAULT 'pending', -- 'pending','synced','failed'
  attempts     INTEGER DEFAULT 0,
  created_at   INTEGER NOT NULL,
  synced_at    INTEGER
);
```

## Drift ORM Pattern

```dart
// Table definition
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get name => text()();
  IntColumn get deadline => integer().nullable()();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  // ...
  
  @override
  Set<Column> get primaryKey => {id};
}

// Always use migrations
@DriftDatabase(tables: [Workspaces, Tasks, Reminders, Events, Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);
  
  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Add migration steps here
    },
  );
}
```

## Query Performance Rules

- Always filter by workspaceId first (most selective filter in the app)
- Use .watch() for reactive UI streams (not .get() with polling)
- Paginate large lists (tasks list can grow to thousands)
- Cache morning briefing query result until next day or task update
- Index all foreign key columns

## Data Integrity Rules

- workspaceId is ALWAYS non-nullable and validated before insert
- deadline must be in the future when creating (warn if in past, don't block)
- fire_at for reminders must be before task deadline
- Subtask parent_task_id cannot be the same as the subtask id (no self-reference)
- Soft delete cascade: deleting workspace should soft-delete all its tasks
