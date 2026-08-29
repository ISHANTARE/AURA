# Phase 9: Comprehensive Test Suite Verification (81/81)

> **Authority Document:** [`overhaul-docs/10-testing-strategy.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/10-testing-strategy.md)  
> **Status:** Pending Execution  

---

## Phase Overview

Phase 9 implements the complete verified test suite covering all 17 test files and executes the test runner to achieve **81 passed tests, 0 failures, and 0 errors**.

---

## Sprint Breakdown

### Sprint 9.1: Database, Intent & Scheduler Unit Tests (Tests 1–6)
**Objective:** Verify persistence integrity, intent parsing regexes, rate limiting, and notification ID collision safety.

#### Tasks:
- [ ] **Task 9.1.1: Database Schema & Migration Tests (`test/database/app_database_test.dart`)**
  - In-memory SQLite DB initialization.
  - Foreign key constraints enforcement.
  - v1 $\rightarrow$ v4 migration schema preservation.
  - Cascade soft-deletion (workspace $\rightarrow$ sections $\rightarrow$ items).
- [ ] **Task 9.1.2: RateLimiter & Injectable Clock Tests (`test/features/capture/rate_limiter_test.dart`)**
  - 12 requests allowed in 60s; 13th delayed until window slides.
- [ ] **Task 9.1.3: LLM API Data Source & Fallback Tests (`test/features/capture/llm_api_datasource_test.dart`)**
  - Base URL / Model config hierarchy.
  - Triple-backtick and bare JSON extraction.
  - Empty API key and network error fallback.
- [ ] **Task 9.1.4: Offline LocalIntentParser Tests (`test/features/capture/local_intent_parser_test.dart`)**
  - Alarms, reminders, tasks with workspace hints, notes, workspaces, and unknown inputs.
- [ ] **Task 9.1.5: NotificationIds FNV-1a Hash Tests (`test/features/reminders/notification_ids_test.dart`)**
  - Distinct UUIDs yield distinct positive 31-bit IDs.
  - Zero collisions across `forItem`, `forReminder`, `forItemWeekday`, `forSnooze`, and reserved IDs.
- [ ] **Task 9.1.6: RecurrenceResolver Tests (`test/features/reminders/recurrence_resolver_test.dart`)**
  - Daily, weekly, `DAYS:1,3,5`, `SPECIFIC_DATE:yyyy-MM-dd`.

---

### Sprint 9.2: Scheduling Service, DND & Core Domain Tests (Tests 7–12)
**Objective:** Verify background scheduler healing, DND replay, briefing triggers, and nudge logic.

#### Tasks:
- [ ] **Task 9.2.1: ReminderSchedulingService Tests (`test/features/reminders/reminder_scheduling_service_test.dart`)**
  - Anchor vs offset scheduling.
  - Past alarm vs reminder grace periods (15m threshold).
  - Drift healing `resynchronizeAll` and `cancelForItem`.
- [ ] **Task 9.2.2: DND Catch-up Replay Tests (`test/features/reminders/dnd_service_test.dart`)**
  - Missed notifications queued during DND; replayed when DND exits.
- [ ] **Task 9.2.3: Day Agenda & Cockpit Tests (`test/features/home/day_cockpit_test.dart`)**
  - Chronological ordering of timed items vs anytime checklist.
- [ ] **Task 9.2.4: Briefing Scheduler Tests (`test/features/home/briefing_scheduler_test.dart`)**
  - 7 AM schedule, 9 AM late-wake fallback, 1x/day execution guard.
- [ ] **Task 9.2.5: NudgeEngine Tests (`test/features/home/nudge_engine_test.dart`)**
  - Quiet hours protection (10 PM – 8 AM), 3-hour minimum spacing, 3 nudges/day cap.
- [ ] **Task 9.2.6: WorkspaceRouter Tests (`test/features/capture/workspace_router_test.dart`)**
  - Exact match $\rightarrow$ alias $\rightarrow$ fuzzy $\rightarrow$ fallback.

---

### Sprint 9.3: State Notifiers, Onboarding & Full Suite Execution (Tests 13–17)
**Objective:** Verify Riverpod state notifiers, onboarding route guards, theme persistence, and run full test suite.

#### Tasks:
- [ ] **Task 9.3.1: CaptureNotifier Tests (`test/features/capture/capture_notifier_test.dart`)**
  - State machine transitions: `idle` $\rightarrow$ `listening` $\rightarrow$ `processing` $\rightarrow$ `confirming`.
- [ ] **Task 9.3.2: WorkspaceNotifier Tests (`test/features/workspaces/workspace_notifier_test.dart`)**
  - Reactive CRUD and active workspace filtering.
- [ ] **Task 9.3.3: OnboardingGate & Route Guard Tests (`test/features/onboarding/onboarding_gate_test.dart`)**
  - Unauthenticated routes redirect to `/onboarding`; `/capture-overlay` whitelisted.
- [ ] **Task 9.3.4: Theme & Greeting Tests (`test/core/theme_test.dart`, `test/features/home/greeting_test.dart`)**
  - 6 accent tokens generate valid ThemeDatas; greeting reflects local hour.
- [ ] **Task 9.3.5: Full 81/81 Test Suite Execution**
  - Execute command:
    ```bash
    flutter test --reporter expanded
    ```
  - Verify result: **81 tests passed in 17 test files, 0 failures, 0 errors**.

---

## Phase 9 Acceptance Criteria & Verification

```
flutter test --reporter expanded
✓ 81 tests passed in 17 test files (0 failures, 0 errors)
```
