# Phase 4: Core Infrastructure, Security & Routing

> **Authority Documents:** [`overhaul-docs/02-architecture.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/02-architecture.md), [`overhaul-docs/06-features/02-reminders-alarms.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/06-features/02-reminders-alarms.md)  
> **Status:** Complete (Verified)  

---

## Phase Overview

Phase 4 builds the core system utilities: encrypted API key storage via Android Keystore, collision-resistant FNV-1a notification ID hashing, exact alarm scheduling pipelines, DND-aware notification replay, and declarative URL routing with onboarding gate guards.

---

## Sprint Breakdown

### Sprint 4.1: Encrypted Keystore SecretStore & App Config
**Objective:** Secure sensitive credentials and manage runtime config fallback hierarchies.

#### Tasks:
- [x] **Task 4.1.1: SecretStore Implementation (`lib/core/security/secret_store.dart`)**
  - Implement `FlutterSecureStorage` wrapper for Android Keystore.
  - Implement `getApiKey()`, `setApiKey(key)`, `deleteApiKey()`.
  - Implement `migrateLegacyKey()` to convert any legacy plaintext `SharedPreferences` key to encrypted Keystore.
- [x] **Task 4.1.2: AppConfig & Provider Resolution (`lib/core/config/app_config.dart`)**
  - Resolution hierarchy for `LLM_BASE_URL` and `LLM_MODEL`:
    1. User setting (`SharedPreferences`)
    2. Dart compile-time define (`--dart-define`)
    3. `.env` override
    4. Hardcoded fallback default (`gemini-2.0-flash`)

---

### Sprint 4.2: FNV-1a Notification ID Codec & Timezones
**Objective:** Implement deterministic, collision-resistant 31-bit notification IDs and timezone database.

#### Tasks:
- [x] **Task 4.2.1: NotificationIds Codec (`lib/core/services/notification_ids.dart`)**
  - Algorithm: 32-bit FNV-1a Hash (`offset_basis = 0x811C9DC5`, `prime = 0x01000193`).
  - Clamp to positive 31-bit integer (`hash & 0x7FFFFFFF`).
  - Codec Methods:
    - `forItem(String uuid)`
    - `forReminder(String uuid)`
    - `forItemWeekday(String uuid, int weekday)`
    - `forSnooze(String uuid)`
  - Reserved System IDs:
    - `10001`: Daily Morning Briefing
    - `10002`: Overdue Summary Triage
    - `10003`: Proactive Smart Nudge
    - `10004`: Offline Queue Drain Alert
    - `10005`: DND Replay Batch
- [x] **Task 4.2.2: Timezone Database Initialization**
  - Wire `tz.initializeTimeZones()` and `FlutterTimezone.getLocalTimezone()` for accurate `tz.zonedSchedule`.

---

### Sprint 4.3: NotificationService, Exact Alarm Channels, Recurrence & DND
**Objective:** Implement notification channels, exact alarm scheduler, recurrence grammar, and DND service.

#### Tasks:
- [x] **Task 4.3.1: Notification Channels & Service (`lib/core/services/notification_service.dart`)**
  - Initialize Android Channels:
    - `aura_reminders_v2` (Importance: Max, Sound, Vibration).
    - `aura_alarms_v2` (Importance: Max, Alarm Sound, FullScreenIntent enabled).
  - Register `notificationTapBackground` as `@pragma('vm:entry-point')`.
  - Expose `selectNotificationStream` using `BehaviorSubject<String?>`.
- [x] **Task 4.3.2: RecurrenceResolver (`lib/features/reminders/domain/recurrence_resolver.dart`)**
  - Parse and resolve recurrence rules: `daily`, `weekly`, `DAYS:1,3,5`, `SPECIFIC_DATE:yyyy-MM-dd`.
- [x] **Task 4.3.3: ReminderSchedulingService (`lib/features/reminders/services/reminder_scheduling_service.dart`)**
  - `syncForItem`: Schedule anchor reminder, offset reminders, weekday alarms.
  - `resynchronizeAll(reason)`: Drift-healing resync for all future items.
  - `cancelForItem`: Cancel all 4 ID variants.
  - `snooze`: Update `fireAt` and reschedule with `forSnooze` ID.
- [x] **Task 4.3.4: DndService (`lib/features/reminders/services/dnd_service.dart`)**
  - Monitor DND broadcast channel `com.aura.aura/dnd_events`.
  - Queue notifications while in DND; replay on DND exit without silent drops.

---

### Sprint 4.4: GoRouter Navigation & Onboarding Gate Notifier
**Objective:** Implement declarative routing with whitelist protection for overlay capture.

#### Tasks:
- [x] **Task 4.4.1: Route Definitions (`lib/core/router/app_router.dart`)**
  - Define routes: `/` (Home Bento), `/capture-overlay` (Voice Overlay), `/workspaces`, `/workspace-detail/:id`, `/alarms`, `/reminders`, `/briefing`, `/notes`, `/settings`, `/task-detail/:id`, `/share`, `/onboarding`.
- [x] **Task 4.4.2: OnboardingGateNotifier & Whitelist Redirects**
  - Check `SharedPreferences['ONBOARDING_COMPLETED']`.
  - Whitelist routes that bypass onboarding: `/capture-overlay`, `/splash`, `/onboarding`.
  - Redirect all other routes to `/onboarding` if incomplete.

---

## Phase 4 Acceptance Criteria & Verification

1. `test/features/reminders/notification_ids_test.dart` passes (zero collisions between distinct UUIDs and ID types).
2. `test/features/reminders/recurrence_resolver_test.dart` passes.
3. `test/features/reminders/reminder_scheduling_service_test.dart` passes.
4. Route redirect tests confirm `/capture-overlay` is accessible pre-onboarding.
