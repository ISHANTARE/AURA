# Database Schema Specification (Drift / SQLite v4)

> **Forensic Rebuild Specification**  
> Complete schema specification for AURA's local SQLite database managed via Drift ORM v2.18.0.
> All tables enforce foreign keys (`PRAGMA foreign_keys = ON`), WAL journal mode (`PRAGMA journal_mode = WAL`), and memory cache sizing (`PRAGMA cache_size = 2000`).

---

## 1. Schema Migration History & Versioning

```
Schema Version: 4
```

| Version | Migration Step | Actions & Changes |
|---|---|---|
| **v1** | Initial Schema | Created `workspaces`, `workspace_sections`, `items`, `reminders_schedule`, `notes`, `shared_contents`, `notification_logs`, `ai_actions_logs`, `offline_queues`, `daily_logs`, `sync_queues`. |
| **v2** | Complete Table Idempotency | Added explicit `m.createTable(...)` calls for all tables to ensure clean initialization. |
| **v3** | Subtask Hierarchy | Added `parent_id` (TextColumn nullable) to `items` table referencing `items(id)`. |
| **v4** | Custom Ringtone Support | Added `sound_uri` (TextColumn nullable) to `items` table for per-alarm/per-reminder ringtone audio URIs. |

```dart
// Drift Migration Strategy (lib/database/app_database.dart)
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
```

---

## 2. Forensic Table Definitions

### 2.1 Table: `workspaces`

Organizational folders grouping items and sections.

```sql
CREATE TABLE workspaces (
    id TEXT NOT NULL PRIMARY KEY,            -- UUID v4
    name TEXT NOT NULL,                      -- Display name (e.g. "Work", "Personal")
    color_hex TEXT DEFAULT '#C8FF00',        -- Hex accent color string
    icon_key TEXT DEFAULT 'custom',          -- Lucide icon identifier
    sort_order INTEGER DEFAULT 0,            -- Custom ordering index
    created_by TEXT DEFAULT 'user',          -- Origin ('user' | 'system')
    is_archived INTEGER DEFAULT 0,           -- 0 = active, 1 = archived
    created_at INTEGER NOT NULL,             -- Epoch milliseconds
    updated_at INTEGER NOT NULL,             -- Epoch milliseconds
    deleted_at INTEGER                       -- Epoch milliseconds (null = active)
);
```

### 2.2 Table: `workspace_sections`

Sub-sections / Kanban columns within a workspace.

```sql
CREATE TABLE workspace_sections (
    id TEXT NOT NULL PRIMARY KEY,            -- UUID v4
    workspace_id TEXT NOT NULL REFERENCES workspaces(id),
    name TEXT NOT NULL,                      -- Section title
    sort_order INTEGER DEFAULT 0,            -- Column ordering index
    created_by TEXT DEFAULT 'user',          -- Origin ('user' | 'system')
    is_archived INTEGER DEFAULT 0,           -- 0 = active, 1 = archived
    created_at INTEGER NOT NULL,             -- Epoch milliseconds
    updated_at INTEGER NOT NULL,             -- Epoch milliseconds
    deleted_at INTEGER                       -- Epoch milliseconds (null = active)
);
```

### 2.3 Table: `items`

Unified core entity for Tasks, Alarms, Reminders, Events, and Notes.

```sql
CREATE TABLE items (
    id TEXT NOT NULL PRIMARY KEY,            -- UUID v4
    workspace_id TEXT REFERENCES workspaces(id), -- Null = unassigned
    section_id TEXT REFERENCES workspace_sections(id),
    parent_id TEXT REFERENCES items(id),     -- Self-reference for subtasks (v3 migration)
    title TEXT NOT NULL,                     -- Main display title
    notes TEXT,                              -- Detailed notes / transcript body
    category TEXT NOT NULL DEFAULT 'reminder', -- 'reminder' | 'alarm'
    kind TEXT NOT NULL DEFAULT 'generic',    -- 'generic' | 'task' | 'event' | 'note'
    fire_at INTEGER,                         -- Exact anchor time to fire OS alarm/notification
    deadline INTEGER,                        -- Task deadline / due timestamp
    start_time INTEGER,                      -- Event start timestamp
    end_time INTEGER,                        -- Event end timestamp
    location TEXT,                           -- Event physical/virtual location
    priority TEXT NOT NULL DEFAULT 'medium', -- 'high' | 'medium' | 'low'
    status TEXT NOT NULL DEFAULT 'pending',  -- 'pending' | 'completed' | 'cancelled'
    is_recurring INTEGER NOT NULL DEFAULT 0, -- 0 = false, 1 = true
    recurrence_rule TEXT,                    -- 'DAYS:1,3,5' | 'SPECIFIC_DATE:yyyy-MM-dd' | 'daily' | 'weekly'
    sound_uri TEXT,                          -- Custom ringtone URI (v4 migration)
    orb_source_app TEXT,                     -- Android package name of originating app
    ai_transcript TEXT,                      -- Raw spoken transcript
    confidence REAL,                         -- AI extraction confidence (0.0 to 1.0)
    created_at INTEGER NOT NULL,             -- Epoch milliseconds
    updated_at INTEGER NOT NULL,             -- Epoch milliseconds
    deleted_at INTEGER                       -- Epoch milliseconds (null = active)
);
```

### 2.4 Table: `reminders_schedule`

Scheduled notification occurrences derived from an item's timing.

```sql
CREATE TABLE reminders_schedule (
    id TEXT NOT NULL PRIMARY KEY,            -- UUID v4
    item_id TEXT NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    offset_value INTEGER NOT NULL,           -- 0 = anchor time, -1 = weekly repeat slot, >0 = offset before
    offset_unit TEXT NOT NULL,               -- 'minutes' | 'hours' | 'days' | 'weekly'
    fire_at INTEGER NOT NULL,                -- Target trigger timestamp (epoch ms)
    has_fired INTEGER NOT NULL DEFAULT 0,    -- 0 = pending, 1 = fired
    missed_dnd INTEGER DEFAULT 0             -- 1 = fired during active DND
);
```

### 2.5 Table: `notes`

Standalone note records and rich attachments.

```sql
CREATE TABLE notes (
    id TEXT NOT NULL PRIMARY KEY,            -- UUID v4
    item_id TEXT REFERENCES items(id),       -- Optional parent item link
    workspace_id TEXT REFERENCES workspaces(id),
    content TEXT NOT NULL,                   -- Note body text
    type TEXT NOT NULL DEFAULT 'text',       -- 'text' | 'link' | 'ocr' | 'audio'
    file_path TEXT,                          -- Local attachment path
    url TEXT,                                -- Extracted external web URL
    created_at INTEGER NOT NULL,             -- Epoch milliseconds
    updated_at INTEGER NOT NULL,             -- Epoch milliseconds
    deleted_at INTEGER                       -- Epoch milliseconds (null = active)
);
```

### 2.6 Table: `shared_contents`

Staging buffer for incoming Android Share Intents (`ACTION_SEND`).

```sql
CREATE TABLE shared_contents (
    id TEXT NOT NULL PRIMARY KEY,            -- UUID v4
    type TEXT NOT NULL,                      -- 'text' | 'image' | 'url' | 'file'
    raw_path TEXT,                           -- Local path to cached shared file
    raw_url TEXT,                            -- Shared web URL
    ocr_text TEXT,                           -- Extracted text from ML Kit OCR
    ai_summary TEXT,                         -- AI summary of shared content
    page_title TEXT,                         -- Extracted web page title
    status TEXT NOT NULL DEFAULT 'pending',  -- 'pending' | 'processed' | 'failed'
    workspace_id TEXT REFERENCES workspaces(id),
    item_id TEXT REFERENCES items(id),
    created_at INTEGER NOT NULL,             -- Epoch milliseconds
    updated_at INTEGER NOT NULL              -- Epoch milliseconds
);
```

### 2.7 Table: `notification_logs`

Audit history and DND catchup log for all dispatched notifications.

```sql
CREATE TABLE notification_logs (
    id TEXT NOT NULL PRIMARY KEY,            -- UUID v4
    reminder_id TEXT NOT NULL REFERENCES reminders_schedule(id),
    scheduled_at INTEGER NOT NULL,           -- Intended fire timestamp
    fired_at INTEGER,                        -- Actual fire timestamp (null if pending)
    was_dnd INTEGER DEFAULT 0,               -- 1 = device was in DND mode
    replayed_at INTEGER,                     -- Timestamp of DND catchup replay
    created_at INTEGER NOT NULL              -- Log creation timestamp
);
```

### 2.8 Table: `ai_actions_logs`

Immutable audit trail of all AI intent extractions.

```sql
CREATE TABLE ai_actions_logs (
    id TEXT NOT NULL PRIMARY KEY,            -- UUID v4
    input_text TEXT NOT NULL,                -- User spoken transcript
    raw_response TEXT NOT NULL,              -- LLM extraction title or 'LOCAL'
    parsed_json TEXT NOT NULL,               -- Full serialized IntentResult JSON Map
    confidence REAL,                         -- Intent extraction confidence score
    action_taken TEXT NOT NULL,              -- 'task_created' | 'alarm_set' | etc.
    item_id TEXT REFERENCES items(id),       -- Resulting created item ID
    user_edited INTEGER DEFAULT 0,           -- 1 = user modified fields in confirmation card
    created_at INTEGER NOT NULL              -- Epoch milliseconds
);
```

### 2.9 Table: `offline_queues`

FIFO persistent buffer for voice captures recorded while offline.

```sql
CREATE TABLE offline_queues (
    id TEXT NOT NULL PRIMARY KEY,            -- UUID v4
    type TEXT NOT NULL DEFAULT 'transcript', -- 'transcript' | 'action'
    content TEXT NOT NULL,                   -- Raw spoken transcript
    context_json TEXT,                       -- Optional ambient context metadata
    status TEXT NOT NULL DEFAULT 'pending',  -- 'pending' | 'processing' | 'processed' | 'failed'
    attempts INTEGER NOT NULL DEFAULT 0,     -- Retry counter (Max: 5 attempts)
    created_at INTEGER NOT NULL,             -- Epoch milliseconds
    processed_at INTEGER                     -- Completion timestamp (null if pending)
);
```

### 2.10 Table: `daily_logs`

Daily activity and completion log per item.

```sql
CREATE TABLE daily_logs (
    id TEXT NOT NULL PRIMARY KEY,            -- UUID v4
    item_id TEXT NOT NULL REFERENCES items(id),
    log_date INTEGER NOT NULL,               -- Start of day timestamp (epoch ms)
    status TEXT NOT NULL,                    -- Status snapshot ('pending' | 'completed')
    done_at INTEGER,                         -- Completion timestamp
    created_at INTEGER NOT NULL              -- Epoch milliseconds
);
```

### 2.11 Table: `sync_queues`

Staging buffer for cloud sync mutations.

```sql
CREATE TABLE sync_queues (
    id TEXT NOT NULL PRIMARY KEY,            -- UUID v4
    entity_type TEXT NOT NULL,               -- 'item' | 'workspace' | 'note'
    entity_id TEXT NOT NULL,                 -- Target entity UUID
    operation TEXT NOT NULL,                 -- 'INSERT' | 'UPDATE' | 'DELETE'
    payload TEXT NOT NULL,                   -- JSON payload of the mutation
    status TEXT NOT NULL DEFAULT 'pending',  -- 'pending' | 'synced' | 'failed'
    attempts INTEGER NOT NULL DEFAULT 0,     -- Retry counter
    created_at INTEGER NOT NULL,             -- Epoch milliseconds
    synced_at INTEGER                        -- Success timestamp
);
```

---

## 3. Data Access Objects (DAOs) & Query Behavior

| DAO Class | Target Table | Primary Watch Queries & Mutation Methods |
|---|---|---|
| `ItemDao` | `items`, `reminders_schedule` | `watchAllActive()`, `watchTodayFocus()`, `watchOverdue()`, `watchAlarms()`, `watchSubtasks(parentId)`, `insertItem()`, `updateItem()`, `softDelete()`, `completeItem()`, `search()`. |
| `WorkspaceDao` | `workspaces`, `workspace_sections` | `watchAll()`, `watchArchived()`, `watchSections(wsId)`, `watchItemCount(wsId)`, `insertWorkspace()`, `softDelete()`, `archive()`, `unarchive()`. |
| `NotificationDao` | `notification_logs` | `getUnreplayed()`, `markReplayed(id)`, `insertLog()`, `markFired()`. |
| `OfflineQueueDao` | `offline_queues` | `getPendingItems()`, `markProcessed(id)`, `markFailed(id)`, `incrementAttempt(id, attempts)`. (Max retries = `5`). |
| `SharedContentDao` | `shared_contents` | `getPending()`, `markProcessed(id)`, `insertContent()`. |

---

## 4. Foreign Key Cascades & Deletion Ordering

To avoid foreign key constraint violations in SQLite, data purge operations must follow strict dependency order:

```
Step 1: DELETE FROM notification_logs WHERE reminder_id IN (...)
Step 2: DELETE FROM reminders_schedule WHERE item_id = ...
Step 3: DELETE FROM daily_logs WHERE item_id = ...
Step 4: DELETE FROM notes WHERE item_id = ...
Step 5: DELETE FROM items WHERE id = ...
```

- When soft-deleting an item, set `deleted_at = nowMs` and immediately cancel all associated OS notifications via `ReminderSchedulingService.cancelForItem(itemId)`.
- When soft-deleting a workspace, cascade `deleted_at = nowMs` to all contained `workspace_sections` and `items`.
