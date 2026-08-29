# Phase 8: App Lifecycle & Background Synchronization

> **Authority Document:** [`overhaul-docs/09-startup-sequence.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/09-startup-sequence.md)  
> **Status:** Pending Execution  

---

## Phase Overview

Phase 8 implements AURA's application lifecycle hooks, background sync chains, and offline recovery. It coordinates the 6-step `_onAppActive()` job chain executed on cold start and on every resume, processes background notification actions (`MARK_DONE`, `SNOOZE_30M`), and drains the offline action queue.

---

## Sprint Breakdown

### Sprint 8.1: Cold Start Bootstrap & AuraApp Lifecycle Hooks
**Objective:** Wire `lib/main.dart` and `lib/app.dart` with `WidgetsBindingObserver`.

#### Tasks:
- [ ] **Task 8.1.1: Cold Start Sequence (`lib/main.dart`)**
  - Step 1: `WidgetsFlutterBinding.ensureInitialized()`.
  - Step 2: `dotenv.load(fileName: '.env')` with graceful fallback.
  - Step 3: `SecretStore().migrateLegacyKey()`.
  - Step 4: Timezone initialization (`tz.initializeTimeZones()` and `FlutterTimezone.getLocalTimezone()`).
  - Step 5: `NotificationService().initialize()` and `requestPermissions()`.
  - Step 6: `runApp(ProviderScope(child: AuraApp()))`.
- [ ] **Task 8.1.2: AuraApp Lifecycle Hooks (`lib/app.dart`)**
  - Implement `WidgetsBindingObserver` in `AuraApp`.
  - In `initState()`:
    - Subscribe to `NotificationService().selectNotificationStream`.
    - Register native orb tap listener via `OverlayChannel.listenToOrbTaps`.
  - In `addPostFrameCallback`:
    - Eagerly initialize `dndServiceProvider`.
    - Start `offlineQueueProcessorProvider` (kept alive across sessions).
    - Trigger `OverlayChannel.autoStartIfPermitted()`.
    - Trigger initial `_onAppActive()`.
  - In `didChangeAppLifecycleState`:
    - When `AppLifecycleState.resumed`, trigger `_onAppActive()`.

---

### Sprint 8.2: `_onAppActive()` 6-Job Background Chain
**Objective:** Implement the sequential, error-isolated 6-step health and sync chain.

#### Tasks:
- [ ] **Task 8.2.1: Individual Job Implementations**
  - **Job 1 (`pending-bg-actions`):** Read `SharedPreferences['pending_bg_action']`, clear key immediately, execute `MARK_DONE` or `SNOOZE_30M` on target item.
  - **Job 2 (`briefing-scheduler`):** Schedule today's morning briefing (7:00 AM default, 9:00 AM fallback, guarded to fire $\le 1\times/\text{day}$).
  - **Job 3 (`recurring-reset`):** Scan completed recurring items past their deadline; advance them to their next recurrence slot.
  - **Job 4 (`nudge-engine`):** Evaluate candidate tasks for proactive smart nudges (respecting quiet hours, 3h spacing, max 3/day).
  - **Job 5 (`overdue-check`):** Query overdue tasks; trigger summary notification `10002` if count $> 0$.
  - **Job 6 (`schedule-resync`):** Reconcile Drift DB alarms/reminders with OS alarm manager via `ReminderSchedulingService.resynchronizeAll(reason: 'appActive')`.
- [ ] **Task 8.2.2: Error Isolation Wrapper**
  - Wrap each job in a separate `try-catch` block so that a failure in one job never blocks subsequent jobs.

---

### Sprint 8.3: Background Action Dispatch & Offline Auto-Drain
**Objective:** Wire VM entry points and connectivity-driven offline queue draining.

#### Tasks:
- [ ] **Task 8.3.1: Background VM Entry Point**
  - Annotate `@pragma('vm:entry-point')` on top-level `notificationTapBackground(NotificationResponse details)`.
  - Write action payload to `SharedPreferences['pending_bg_action']` for processing upon next app resume.
- [ ] **Task 8.3.2: Connectivity-Driven Queue Draining**
  - `OfflineQueueProcessor` listens to `ConnectivityMonitor`.
  - When connection changes from `none` to `wifi` or `mobile`, drain pending FIFO queue items.
  - Update `offline_queues` table status and retry counts.

---

## Phase 8 Acceptance Criteria & Verification

1. App cold starts and initializes all 5 services without exceptions.
2. Background action written in notification fires correctly on app resume.
3. `_onAppActive()` executes all 6 jobs in order and logs execution metrics.
4. Offline actions automatically sync when internet is toggled on.
