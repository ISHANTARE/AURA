# Startup Sequence & Background Services

> **Forensic Rebuild Specification**  
> Complete specification for AURA's cold start sequence, app resume lifecycle, background job orchestration, and boot recovery strategy.

---

## 1. Cold Start (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Step 1: Load environment overrides (silent fail if missing)
  await dotenv.load(fileName: '.env');

  // Step 2: One-time migration of any legacy plaintext API key → encrypted
  await SecretStore().migrateLegacyKey();

  // Step 3: Initialize timezone database (required for zonedSchedule)
  tz.initializeTimeZones();
  final localTz = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(localTz));

  // Step 4: Initialize Flutter Local Notifications (channels, permissions)
  await NotificationService().initialize();
  await NotificationService().requestPermissions();

  // Step 5: Mount Flutter UI with Riverpod scope
  runApp(const ProviderScope(child: AuraApp()));
}
```

---

## 2. `NotificationService.initialize()` Contract

Must execute in this order:

1. Create Android notification channels **before** any notification is posted:
   - Channel `aura_reminders_v2` (Importance: `max`, standard sound attribute).
   - Channel `aura_alarms_v2` (Importance: `max`, alarm sound attribute, full-screen intent enabled).
2. Initialize `flutter_local_notifications` with `selectNotification` callback using a `BehaviorSubject<String?>` so the first tap is never missed if the listener attaches late.
3. Register `notificationTapBackground` as `@pragma('vm:entry-point')` handler for background notification action buttons (`MARK_DONE`, `SNOOZE_30M`).

---

## 3. `AuraApp.initState()` Lifecycle Hooks

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);

  // 1. Subscribe to notification tap payload stream
  _notificationSub = NotificationService()
      .selectNotificationStream
      .listen(_onNotificationTapPayload);

  // 2. Register Orb Tap Handler (from AuraOverlayService native)
  OverlayChannel.listenToOrbTaps(() {
    ref.read(appRouterProvider).push(Routes.captureOverlay);
  });

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // 3. Eagerly start DND monitor stream
    ref.read(dndServiceProvider);

    // 4. Start offline queue processor (CRITICAL: must be kept alive)
    final processor = ref.read(offlineQueueProcessorProvider);
    processor.start();

    // 5. Auto-start floating orb if permission was previously granted
    OverlayChannel.autoStartIfPermitted();

    // 6. Run all background health-check jobs
    _onAppActive();
  });
}
```

---

## 4. `_onAppActive()` Background Job Chain

Fires on cold start **and** on every app `resumed` lifecycle transition. Each job is wrapped in individual error isolation to prevent single failures from blocking subsequent jobs:

| Order | Job Label | Description | Service Provider |
|---|---|---|---|
| 1 | `pending-bg-actions` | Process `MARK_DONE` / `SNOOZE_30M` written to `SharedPreferences['pending_bg_action']` by background notification handler. Clears key before executing. | Direct `SharedPreferences` read |
| 2 | `briefing-scheduler` | Schedule today's morning briefing (1×/day guard, late-wake 9 AM fallback). | `briefingSchedulerProvider` |
| 3 | `recurring-reset` | Advance completed recurring tasks to next recurrence slot. | `recurringTaskResetProvider` |
| 4 | `nudge-engine` | Evaluate and fire proactive nudge (quiet hours guard, 3h spacing, 3/day cap). | `nudgeEngineProvider` |
| 5 | `overdue-check` | Query overdue items; post overdue summary notification ID `10002` if > 0. | `overdueReminderUseCaseProvider` |
| 6 | `schedule-resync` | Heal DB↔OS notification drift (`resynchronizeAll(reason: 'appActive')`). | `reminderSchedulingServiceProvider` |

---

## 5. Background Notification Action Dispatch

```
Notification Action Tapped (App Backgrounded)
         │
         ▼
@pragma('vm:entry-point')
notificationTapBackground(NotificationResponse response)
  1. Parse response.actionId and response.payload
  2. Write to SharedPreferences['pending_bg_action']:
     - "MARK_DONE:item:<uuid>"
     - "SNOOZE_30M:item:<uuid>"
  3. Return (background isolate exits)

App Foregrounded → _onAppActive() Job 1
  1. Read pending_bg_action
  2. Clear key immediately (prevent double-execution)
  3. Parse action type and item ID
  4. Execute:
     - MARK_DONE  → itemDao.updateStatus(id, 'completed') + cancelForItem
     - SNOOZE_30M → snoozeReminderUseCase.execute(id, SnoozePreset.minutes30)
```

---

## 6. Deep Link / Notification Tap Routing (`_onNotificationTapPayload`)

| Payload String | Target Route | Behavior |
|---|---|---|
| `"route:/briefing"` | `/briefing` | Opens `MorningBriefingScreen`. |
| `"route:/"` | `/` | Navigates to home tab. |
| `"route:/search"` | `/search` (or home) | Opens item search. |
| `"item:<uuid>"` | `/task/<uuid>` | Pushes `TaskDetailScreen` for the specified item. |
| (none / `null`) | `/` | Default home navigation. |

---

## 7. Boot Recovery (`AuraBootReceiver`)

When device reboots, the OS wipes all scheduled alarms and `AlarmManager` registrations. The boot receiver restores AURA's scheduling state:

1. Checks `SharedPreferences['orb_enabled']` — restarts `AuraOverlayService` if true.
2. Invokes `ReminderSchedulingService.resynchronizeAll(reason: 'boot')`:
   - Advances past-due recurring items to next future slot.
   - Re-registers all future reminder and alarm slots with Android `AlarmManager`.

Declared in `AndroidManifest.xml`:
```xml
<receiver
    android:name=".AuraBootReceiver"
    android:exported="false">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED" />
    <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
  </intent-filter>
</receiver>
```
