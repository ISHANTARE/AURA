# Phase 3: Drift Database & Persistence Layer

> **Authority Document:** [`overhaul-docs/03-database-schema.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/03-database-schema.md)  
> **Status:** Complete (Verified)  

---

## Phase Overview

Phase 3 builds AURA's local-first single source of truth: 11 Drift tables under Schema Version 4, WAL journal mode, explicit foreign key enforcement, migration strategy (v1 $\rightarrow$ v4), and 5 reactive DAOs.

---

## Sprint Breakdown

### Sprint 3.1: 11 Drift Table Definitions (`lib/database/tables/`)
**Objective:** Define all 11 database tables with exact column types, nullabilities, and defaults.

#### Tasks:
- [x] **Task 3.1.1: Workspaces & Sections Tables**
  - `Workspaces` (`id` UUID, `name`, `color_hex` default `#C8FF00`, `icon_key`, `sort_order`, `created_by`, `is_archived`, `created_at`, `updated_at`, `deleted_at`).
  - `WorkspaceSections` (`id`, `workspace_id` FK, `name`, `sort_order`, `created_by`, `is_archived`, `created_at`, `updated_at`, `deleted_at`).
- [x] **Task 3.1.2: Unified Items Table (`items`)**
  - `id` UUID PK, `workspace_id` FK, `section_id` FK nullable, `title`, `notes` nullable.
  - `kind` ('task'|'event'|'reminder'|'alarm'|'note'), `category` ('academic'|'exam'|'personal'|'project'|'meeting'|'workout'|'habit'|'general').
  - `priority` ('high'|'medium'|'low'), `is_completed`, `completed_at` nullable.
  - `scheduled_date` (YYYY-MM-DD), `scheduled_time` (HH:MM), `deadline_date`, `deadline_time`, `duration_minutes`.
  - `fire_at` (epoch ms), `recurrence_rule`, `is_recurring`, `sound_uri` (v4 nullable), `parent_id` (v3 FK nullable), `sort_order`, `created_at`, `updated_at`, `deleted_at`.
- [x] **Task 3.1.3: Scheduling & Notes Tables**
  - `RemindersSchedule` (`id`, `item_id` FK, `trigger_time` epoch ms, `offset_minutes`, `status`, `created_at`).
  - `Notes` (`id`, `workspace_id` FK nullable, `item_id` FK nullable, `title`, `body`, `tags`, `is_pinned`, `created_at`, `updated_at`, `deleted_at`).
- [x] **Task 3.1.4: Logs, Queues & Sharing Tables**
  - `SharedContents` (`id`, `mime_type`, `raw_text`, `cached_file_path`, `ocr_extracted_text`, `source_app`, `status`, `created_at`).
  - `NotificationLogs` (`id`, `item_id` FK nullable, `notification_id` int, `channel_id`, `fired_at`, `action_taken`, `action_timestamp`).
  - `AiActionsLogs` (`id`, `raw_transcript`, `intent_detected`, `confidence`, `executed_action`, `success`, `error_message`, `created_at`).
  - `OfflineQueues` (`id`, `action_type`, `payload_json`, `status`, `retry_count`, `last_error`, `created_at`, `processed_at`).
  - `DailyLogs` (`id`, `log_date` unique, `briefing_shown`, `briefing_time`, `nudges_sent_count`, `tasks_completed_count`).
  - `SyncQueues` (`id`, `entity_type`, `entity_id`, `operation`, `status`, `retry_count`, `created_at`).

---

### Sprint 3.2: AppDatabase Class, Pragmas & Schema v4 Migration
**Objective:** Implement `lib/database/app_database.dart` with WAL, foreign keys, and migration strategy.

#### Tasks:
- [x] **Task 3.2.1: AppDatabase Setup & Pragmas**
  - Configure `schemaVersion = 4`.
  - In `beforeOpen`:
    ```dart
    await customStatement('PRAGMA foreign_keys = ON');
    await customStatement('PRAGMA journal_mode = WAL');
    await customStatement('PRAGMA cache_size = 2000');
    ```
- [x] **Task 3.2.2: Additive Migration Strategy (v1 $\rightarrow$ v4)**
  - Implement `onCreate`: `await m.createAll()`.
  - Implement `onUpgrade`:
    - `from < 2`: create missing auxiliary tables.
    - `from < 3`: add `items.parent_id`.
    - `from < 4`: add `items.sound_uri`.

---

### Sprint 3.3: 5 Type-Safe DAOs (`lib/database/daos/`)
**Objective:** Implement reactive Drift DAOs for all domain operations.

#### Tasks:
- [x] **Task 3.3.1: ItemDao**
  - CRUD operations with soft-delete filtering (`deleted_at IS NULL`).
  - Streams: `watchAllActiveItems()`, `watchTodayItems(date)`, `watchOverdueItems(now)`, `watchItemsByWorkspace(workspaceId)`.
  - Cascade soft-delete for subtasks.
- [x] **Task 3.3.2: WorkspaceDao & SectionDao**
  - CRUD operations for workspaces and sections.
  - Cascade soft-delete: Workspace $\rightarrow$ Sections $\rightarrow$ Items.
- [x] **Task 3.3.3: NotificationDao**
  - Log notification dispatches, actions, and DND queue entries.
- [x] **Task 3.3.4: OfflineQueueDao**
  - Enqueue actions, retrieve FIFO pending items, update retry counts and status.
- [x] **Task 3.3.5: SharedContentDao**
  - Ingest shared items, update OCR results, cleanup entries older than 24 hours.

---

### Sprint 3.4: Code Generation & Database Test Verification
**Objective:** Run `build_runner` and pass the comprehensive database test suite.

#### Tasks:
- [x] **Task 3.4.1: Drift Code Generation**
  - Execute `dart run build_runner build --delete-conflicting-outputs`.
  - Verify `app_database.g.dart` generated without errors.
- [x] **Task 3.4.2: In-Memory Database Tests**
  - Implement `test/database/app_database_test.dart` (in-memory SQLite, Foreign Key validation, v1 $\rightarrow$ v4 migration data preservation, soft-delete cascading).
  - Execute `flutter test test/database/app_database_test.dart`.

---

## Phase 3 Acceptance Criteria & Verification

1. `app_database.g.dart` builds cleanly.
2. All 11 tables verified with correct columns, types, and defaults.
3. `test/database/app_database_test.dart` passes with 100% assertions.
