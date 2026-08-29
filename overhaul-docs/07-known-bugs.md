# Forensic Bug Registry & Resolved Architectural Defects

> **Forensic Rebuild Specification**  
> Complete audit history of historical defects, root cause analyses, and verified architectural invariants implemented to prevent regressions.

---

## 1. Defect & Invariant Matrix

| Bug ID | Component | Severity | Description & Root Cause | Verified Resolution Invariant |
|---|---|---|---|---|
| **BUG-01** | `OfflineQueueProcessor` | **Critical** | Lazy Riverpod evaluation resulted in processor garbage collection before offline captures were drained. | Provider is eagerly initialized on app launch (`processor.start()`) and listens to active `onConnectivityChanged` stream. Retries capped at `maxAttempts = 5`. Destructive intents prompt user review via notification. |
| **BUG-02** | `MorningBriefingScreen` | **Critical** | Hardcoded developer name string in greeting headers. | Time-aware greeting dynamically loads `userNameProvider` persisted in `SharedPreferences['USER_NAME']`. Defaults to `"Good morning."` if unset. |
| **BUG-03** | `NotificationIds` | **High** | Using Dart `.hashCode` on UUID strings produced collisions in Android's 32-bit int notification registry. | Replaced with deterministic **32-bit FNV-1a hash algorithm** masked to positive int31 on namespaced keys (`item:<id>`, `rem:<id>`, `snooze:<id>`), with reserved low integer slots for system summaries. |
| **BUG-04** | `CreateTaskUseCase` | **High** | Event fields (`event_start_iso`, `event_end_iso`, `event_location`) were ignored during intent parsing. | `IntentResult` and `create_task_usecase.dart` map event start/end timestamps and location into `items.start_time`, `items.end_time`, `items.location`, using `start_time` as scheduling anchor. |
| **BUG-05** | `ReminderSchedulingService` | **High** | Past-due reminders were dropped without alerting the user. | `ReminderSchedulingService` fires an immediate `"Missed: <title>"` notification (`body: "Due X min ago"`) if past within 15-minute grace window. Alarm channel items always ring immediately. |
| **BUG-06** | `AndroidManifest.xml` | **Medium** | Duplicate floating orb foreground service declarations (`FloatingOrbService` vs `AuraOverlayService`). | Consolidated strictly onto `AuraOverlayService` with `foregroundServiceType="specialUse"`. |
| **BUG-07** | `RateLimiter` | **Medium** | Burst requests allowed through if duration exceeded window. | Verified sliding-window throttle (12 req / 60s) with active timestamp queue and thread wait delay. |
| **BUG-08** | `ReplayDndNotificationsUseCase` | **Medium** | DND replay missed events due to missing live DND history. | `DndService` streams live `com.aura.aura/dnd_events`. On exit from DND, queries `notification_logs` and dispatches immediate catchup summaries. |
| **BUG-09** | `OnboardingGateNotifier` | **Medium** | Static boolean gate survived hot restarts and failed to re-lock on Reset App Data. | Implemented as reactive `StateNotifier<bool>`. Resetting app data invokes `.reset()`, instantly locking all gated routes without app restart. |
| **BUG-10** | `AppDatabase` Foreign Keys | **Medium** | Deleting schedule rows failed SQLite foreign key constraints from `notification_logs`. | Strict ordered deletion: `notification_logs` rows referencing `reminders_schedule.id` are deleted before parent `reminders_schedule` rows. |

---

## 2. Invariant Guidelines for Reconstruction

1. **Never Call `NotificationService.zonedSchedule` Directly**: Always route through `ReminderSchedulingService.syncForItem(item)`.
2. **Never Store Secrets in SharedPreferences**: Always write API keys to `SecretStore` (`FlutterSecureStorage`).
3. **Never Execute Destructive Background Actions Silently**: When processing offline queues, `delete_task` and `delete_workspace` MUST notify the user for confirmation.
4. **Always Clean Up Scheduled Alarms on Soft-Delete**: Soft-deleting an item must immediately invoke `ReminderSchedulingService.cancelForItem(itemId)`.
5. **Preserve Drift WAL & Foreign Key Pragmas**: Ensure `PRAGMA foreign_keys = ON` and `PRAGMA journal_mode = WAL` are executed in `beforeOpen`.
