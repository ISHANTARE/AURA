# Testing Strategy — Verified Suite Documentation

> **Forensic Rebuild Specification**  
> Complete specification for AURA's test architecture, verified passing test suite (81/81), testability requirements, and coverage targets.

---

## 1. Verified Test Suite Status

**All 81 tests pass as of forensic audit date.**

```
flutter test --reporter expanded
✓ 81 tests passed in 17 test files (0 failures, 0 errors)
```

---

## 2. Complete Test File Inventory

### 2.1 Database & DAO Tests

**`test/database/app_database_test.dart`**
- Drift in-memory DB initialization
- All 11 tables created with correct schema
- FK constraints enforced (`PRAGMA foreign_keys = ON`)
- WAL mode active (`PRAGMA journal_mode = WAL`)
- Migration v1 → v4 preserves existing data
- Soft-delete cascade: workspace → sections → items

---

### 2.2 AI Pipeline Tests

**`test/features/capture/llm_api_datasource_test.dart`**
- `LLM_BASE_URL` resolution hierarchy (user pref → dart-define → dotenv → hard default)
- `LLM_MODEL` resolution hierarchy
- Empty API key triggers LocalIntentParser fallback (no throw)
- HTTP 401 throws `LlmApiException(type: LlmErrorType.authError)`
- JSON extraction with triple-backtick wrapper
- JSON extraction with bare JSON block
- JSON extraction fallback for prefix-polluted responses
- Malformed JSON falls back to `LocalIntentParser`

**`test/features/capture/rate_limiter_test.dart`**
- Allows up to 12 requests in a 60-second window
- Blocks 13th request until window slides
- `waitDuration` returns correct delay when saturated
- Injectable clock for deterministic time control
- Works correctly for sequential single-threaded callers

**`test/features/capture/local_intent_parser_test.dart`**
- `"set alarm for 7:30 AM"` → `IntentResult(intentType: 'create_alarm', deadline: ...07:30)`
- `"in workspace work"` → `intentType: 'create_task', workspaceHint: 'work'`
- `"delete task meeting"` → `intentType: 'delete_task', targetTitle: 'meeting'`
- `"note: remember to..."` → `intentType: 'add_note'`
- `"create workspace Fitness"` → `intentType: 'create_workspace', workspaceName: 'Fitness'`
- `"remind me at 5pm"` → `intentType: 'create_reminder', deadline: ...17:00`
- Returns `IntentResult(intentType: 'unknown')` for unrecognized input

---

### 2.3 Reminder & Scheduling Tests

**`test/features/reminders/notification_ids_test.dart`**
- `forReminder(uuid)` produces positive 31-bit int
- Two distinct UUIDs produce different IDs
- `forItem` and `forReminder` IDs never collide for the same UUID
- `forItemWeekday(id, 1..7)` all produce distinct IDs
- `forSnooze` distinct from `forItem` for same UUID
- Reserved system IDs (`10001`–`10005`) do not collide with any hash-derived ID

**`test/features/reminders/reminder_scheduling_service_test.dart`**
- `syncForItem` schedules anchor row when no `extractedReminders`
- `syncForItem` schedules offset rows before anchor row
- Past alarm channel item → fires immediately (no skip)
- Past reminder within 15-minute grace → fires missed notification
- Past reminder beyond 15-minute grace → skips scheduling
- `resynchronizeAll` re-schedules future items only
- `cancelForItem` cancels all 4 ID variants (item, reminder row, weekday, snooze)
- `snooze` updates `items.fireAt` in DB and re-schedules with `forSnooze` ID

**`test/features/reminders/recurrence_resolver_test.dart`**
- `DAYS:1,3,5` resolves to next Mon/Wed/Fri after anchor
- `daily` advances exactly 1 day
- `weekly` advances exactly 7 days
- `SPECIFIC_DATE:yyyy-MM-dd` returns null if date is past
- `null` returns null (one-shot)

---

### 2.4 Home & Cockpit Tests

**`test/features/home/day_cockpit_test.dart`**
- `dayAgendaProvider` returns timed items chronologically
- `dayAgendaProvider` separates anytime checklist from timed events
- Empty date → empty lists returned (no exception)
- Date change causes reactive refresh

**`test/features/home/greeting_test.dart`**
- Hour 06 → `"Good morning, <name>"`
- Hour 13 → `"Good afternoon, <name>"`
- Hour 19 → `"Good evening, <name>"`
- Hour 23 → `"Working late, <name>"`
- Empty name → `"Good morning."` (no trailing comma)

---

### 2.5 Onboarding & Routing Tests

**`test/features/onboarding/onboarding_gate_test.dart`**
- Gate reads `SharedPreferences['onboarding_complete']` on init
- `.complete()` sets pref to `true`, state transitions to `true`
- `.reset()` sets pref to `false`, state transitions to `false`
- Routes whitelisted before onboarding: `/onboarding`, `/capture-overlay`, `/share`
- All other routes redirect to `/onboarding` when `state == false`

**`test/features/capture/workspace_router_test.dart`**
- Exact name match → `WorkspaceMatchResult(matchedWorkspace: ws)`
- Contains match → fuzzy `WorkspaceMatchResult`
- No match → `WorkspaceMatchResult(suggestedWorkspaceName: hint)`
- Null hint → `WorkspaceMatchResult(noHint: true)`

---

### 2.6 Background Processing Tests

**`test/features/capture/offline_queue_processor_test.dart`**
- Drains pending queue when `isOnline` transitions `false → true`
- Increments `attempts` on LLM failure
- Stops retrying after `maxAttempts = 5`
- Destructive intents (`delete_task`, `delete_workspace`) post `offlineReview` notification (no execution)

**`test/features/reminders/exact_alarm_diagnostics_test.dart`**
- `AlarmCapability.canScheduleExact()` returns correct result per Android API level
- Falls back gracefully to inexact scheduling on API < 31

**`test/features/capture/execute_ai_action_timed_test.dart`** & **`execute_ai_action_usecase_test.dart`**
- `create_task` → row inserted, `syncForItem` called, `logAiAction` called
- `create_alarm` → alarm channel item inserted, `syncForItem` called with alarm channel
- `create_workspace` → workspace row inserted, linked to created task
- `add_note` → note row inserted in `notes` table
- `unknown` intent → no write, returns empty outcome

**`test/core/phase2_sorting_theme_test.dart`**
- Items sorted high → medium → low priority
- Items sorted by `createdAt` within same priority tier

---

### 2.7 Widget Tests

**`test/widget_test.dart`**
- App renders without exceptions
- `AuraBottomNav` displays 5 tab destinations

---

## 3. Testability Requirements

All core services must support dependency injection for testability:

```dart
// ✅ Testable — injectable clock
ReminderSchedulingService({DateTime Function()? clock})

// ✅ Testable — injectable notification service mock
ReminderSchedulingService({NotificationService? notifications})

// ✅ Testable — in-memory Drift DB
AppDatabase.forTesting(executor: NativeDatabase.memory())

// ❌ Never — inline DateTime.now() in business logic
// ❌ Never — static NotificationService() in method body
```

---

## 4. Coverage Targets

| Layer | Minimum Coverage |
|---|---|
| `domain/usecases/` | 85% |
| `domain/services/` | 80% |
| `database/daos/` | 75% |
| `data/datasources/` | 70% |
| `presentation/screens/` | 50% (widget tests) |
