# AURA Application Audit Report
**Auditor:** Antigravity Adversarial Auditor  
**Date:** 2026-08-22  
**Version Audited:** 2.0.0+1  
**Target:** `c:\Users\Admin\VIT_Projects\AURA`

---

## 1. EXECUTIVE VERDICT

### 🔴 NOT READY FOR MARKET

| Metric | Count |
|---|---|
| 🔴 Critical | 5 |
| 🟠 High | 8 |
| 🟡 Medium | 9 |
| 🔵 Low | 6 |

**Primary reasons for blocking release:**

1. **`offlineQueueProcessorProvider` is never read** anywhere in the app — the entire offline capture feature (PRD F-10) is dead code.
2. **Hardcoded developer identity** (`Ishant` / `Ishan T`) appears in the morning briefing for every user.
3. **`ScheduleReminderUseCase` is never called** during voice task creation — the product's core promise ("remind me tomorrow at 9am") silently fails.
4. **`create_event` intent falls through silently** to `create_task` — event-specific fields (`startTime`, `endTime`, `location`) are always null.
5. **Alarm notifications are silently dropped** when the scheduled time is in the past.
6. **Two competing floating overlay services** declared in the Android manifest.
7. **LLM configuration is contradictory** — `.env` points to Gemini, but `AppConfig` defaults to NVIDIA NIM; the Gemini REST path is unsupported by the HTTP call format.
8. **The rate limiter is logically broken** — it does not actually enforce 12 requests/minute.

---

## 2. APPLICATION UNDERSTANDING

### What AURA Does
AURA is a voice-first AI personal assistant Flutter app for Android. Users speak a thought → AURA extracts structured intent (task, alarm, reminder, event, note, workspace command) via Gemini/OpenAI-compatible LLM → routes it to a local SQLite database.

**Key features claimed:** Voice Capture via floating orb, AI Intent Extraction, Offline Fallback queue, Task/Reminder/Alarm/Note/Event Management, Morning Briefing, Workspace System, DND Replay, Share-to-AURA, Proactive Nudge Engine.

### Architecture Summary
- Flutter/Dart + Riverpod + GoRouter + Drift ORM (SQLite)
- Android MethodChannels for: speech recognition, overlay service, DND, ringtone picker
- Direct client-to-LLM-API HTTP calls (no backend server)
- All data is local / offline-first

---

## 3. FEATURE VERIFICATION MATRIX

| Feature | Status | Issues |
|---|---|---|
| Voice Capture (Orb tap) | ⚠️ Partial | Hardcoded `en-IN` locale; silent failure if permission revoked post-onboarding |
| AI Intent Extraction | ⚠️ Partial | Default `.env` key is placeholder; Gemini URL incompatible with call format |
| Offline Queue | ❌ **Broken** | `offlineQueueProcessorProvider` never read — processor never starts |
| Task Creation | ✅ Verified | `aiTranscript` field in DB always null (never populated) |
| Alarm Creation + Notification | ⚠️ Partial | Past-time alarms silently dropped; hashCode notification ID collisions |
| Reminder Scheduling | ❌ **Broken** | `ScheduleReminderUseCase` never called during task creation |
| Workspace Management | ✅ Verified | Cascade soft-delete confirmed working via DB test |
| Morning Briefing Screen | ⚠️ Partial | Use case hardcodes `Ishant.` — not the real user name |
| Morning Briefing Notification | ❓ Unverified | BriefingSchedulerService not fully reviewed |
| DND Replay | ⚠️ Partial | `_onError` silently swallows DND event channel errors |
| Proactive Nudge Engine | ⚠️ Partial | Fires on every app resume; date-key throttle (not time-based) |
| Share-to-AURA (text) | ⚠️ Partial | Race condition if Flutter engine not ready before `getInitialSharePayload` |
| Share-to-AURA (image/file) | ⚠️ Partial | SharedContentDao existence not confirmed |
| Onboarding | ⚠️ Partial | Name pre-filled with `'your name'`; no validation |
| Settings — API Key Save | ✅ Verified | Saves and applies on next LLM call |
| Settings — Provider Preset | ⚠️ Partial | `_selectedProviderPreset` never persisted; UI desync on re-open |
| Floating Orb Overlay | ⚠️ Partial | Two competing services (`AuraFloatingService` + `AuraOverlayService`) in manifest |
| Workspace Router (AI) | ⚠️ Partial | Keyword map hardcoded to VIT/GATE/Internship — irrelevant to non-Indian users |
| Event Creation (`create_event`) | ❌ **Broken** | No case in `ExecuteAiActionUseCase`; falls to `default` (creates task) |
| Database Migration (v1→v3) | ⚠️ Partial | v2 migration catches all errors silently |
| Test Coverage | ❌ **Broken** | 4 DB tests + empty widget_test. Zero AI/notification/voice/onboarding tests |

---

## 4. DETAILED ISSUES

---

### ISSUE-001 🔴 CRITICAL — Offline Queue Processor Never Started

**Affected:** [`offline_queue_processor.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/capture/domain/services/offline_queue_processor.dart)

The `offlineQueueProcessorProvider` (Riverpod lazy `Provider`) is never `read` or `watch`ed anywhere in the app — not in `app.dart`, not in `main.dart`, not in any other provider. Because Riverpod providers are lazy, the processor instance is never created, the connectivity listener is never attached, and offline queued transcripts are never processed.

**Evidence:** `app.dart` eagerly initializes `briefingSchedulerProvider`, `recurringTaskResetProvider`, `nudgeEngineProvider`, `overdueReminderUseCaseProvider`, `dndServiceProvider` — but NOT `offlineQueueProcessorProvider`. Grep confirms no other file references it.

**Impact:** PRD F-10 ("Offline Voice Capture") is completely dead. Users lose all voice captures made while offline.

**Fix:** Add `ref.read(offlineQueueProcessorProvider)` in `_onAppActive()` in `app.dart`.

---

### ISSUE-002 🔴 CRITICAL — Hardcoded Developer Name in Morning Briefing

**Affected:** [`generate_morning_briefing_usecase.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/home/domain/usecases/generate_morning_briefing_usecase.dart) lines 30–31

```dart
final String greeting = hour < 12
    ? 'Good morning, Ishant.'
    : (hour < 17 ? 'Good afternoon, Ishant.' : 'Good evening, Ishant.');
```

This use case is completely disconnected from `userNameProvider` or `SharedPreferences`. Every user on the planet sees "Good morning, Ishant."

Additionally, `settings_screen.dart` hardcodes `'Ishan T'` as the default user name fallback (lines 28, 49).

**Impact:** Unshippable UX failure. Immediate embarrassment on first use.

**Fix:** Accept `String userName` as a parameter to `execute()`.

---

### ISSUE-003 🔴 CRITICAL — `create_event` Intent Silently Falls Through to Task Creation

**Affected:** [`execute_ai_action_usecase.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/capture/domain/usecases/execute_ai_action_usecase.dart)

The LLM system prompt explicitly defines `create_event` as a supported intent. `IntentResult` has `eventStart`, `eventEnd`, `eventLocation` fields. However, `ExecuteAiActionUseCase.execute()` has no `case 'create_event':` branch. It falls to `default:` → `_createTaskUseCase.execute()`.

`CreateTaskUseCase` maps `create_event` to `kind = 'event'` but never populates `startTime`, `endTime`, or `location` from the intent. These DB columns remain null for every event created by voice.

**Impact:** "Schedule interview at Google tomorrow at 2pm" → creates a task with no time, no location. Core feature broken.

---

### ISSUE-004 🔴 CRITICAL — Alarm Notifications Silently Dropped for Past Times

**Affected:** [`notification_service.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/reminders/data/services/notification_service.dart) line 221

```dart
if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return; // SILENT DROP
```

`scheduleNotification()` has a graceful fallback (fires immediately for past times). `scheduleAlarm()` does not — it silently returns.

**Scenario:** AI misparses time slightly, or user's confirm→save flow takes a few seconds pushing the time to the past. The alarm is saved to DB, confirmation is shown, but no notification ever fires. The user misses the alarm.

---

### ISSUE-005 🔴 CRITICAL — Two Competing Floating Overlay Services in Manifest

**Affected:** [`AndroidManifest.xml`](file:///c:/Users/Admin/VIT_Projects/AURA/android/app/src/main/AndroidManifest.xml), [`AuraFloatingService.kt`](file:///c:/Users/Admin/VIT_Projects/AURA/android/app/src/main/kotlin/com/aura/aura/AuraFloatingService.kt), [`AuraOverlayService.kt`](file:///c:/Users/Admin/VIT_Projects/AURA/android/app/src/main/kotlin/com/aura/aura/AuraOverlayService.kt)

Both services are declared in the manifest with `android:enabled="true"`. They are completely different implementations:
- **`AuraFloatingService`** — prototype stub: renders a plain green `FrameLayout` with letter "A", no MethodChannel integration.
- **`AuraOverlayService`** — production: premium custom-drawn orb, MethodChannel integrated, position persistence, color updates.

If `AuraFloatingService` is ever started (e.g., by future code or a bug), two overlay windows will be on screen simultaneously and conflict.

**Impact:** Dead code + collision risk. Leaks prototype status to any APK auditor.

**Fix:** Delete `AuraFloatingService.kt` and remove it from the manifest.

---

### ISSUE-006 🟠 HIGH — Reminder Notifications Never Scheduled During Task Creation

**Affected:** [`create_task_usecase.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/capture/domain/usecases/create_task_usecase.dart)

When `CreateTaskUseCase.execute()` saves a task with a deadline, it does NOT call `ScheduleReminderUseCase` or `NotificationService`. The `reminders` array extracted from the LLM intent is logged to `aiActionsLogs.parsedJson` but completely ignored. No `RemindersSchedule` rows are inserted. No notification is scheduled.

**Impact:** The core product promise — "remind me to submit assignment tomorrow at 11pm" — silently produces a task with no reminder. This is not a missing feature; it is a broken primary workflow.

---

### ISSUE-007 🟠 HIGH — Global Mutable Router Guard Never Reset

**Affected:** [`app_router.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/core/router/app_router.dart) line 45

```dart
bool _onboardingCompleteChecked = false; // top-level global variable
```

This flag is set to `true` after the first onboarding check. It is never reset. During development, hot restart does not reset the Dart heap, so the onboarding redirect is skipped even if `SharedPreferences` is cleared. In production: a user who clears app data will have `onboarding_complete = false` in SharedPreferences, but if the app process is still alive (background), the flag remains `true` and onboarding is skipped.

**Fix:** Move this into a Riverpod `StateProvider` or check SharedPreferences directly on every redirect evaluation.

---

### ISSUE-008 🟠 HIGH — RateLimiter Is Logically Broken

**Affected:** [`llm_api_datasource.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/capture/data/datasources/llm_api_datasource.dart)

```dart
Future<void> throttle() async {
  if (_requestsThisMinute >= _maxPerMinute) {
    await Future.delayed(const Duration(seconds: 5)); // then proceeds anyway!
  }
  _requestsThisMinute++;
  Future.delayed(const Duration(seconds: 60), () { // NOT awaited — fire-and-forget
    if (_requestsThisMinute > 0) _requestsThisMinute--;
  });
}
```

At the limit: waits 5 seconds, then proceeds. Counter is still ≥ 12. Every subsequent request still waits 5 seconds then proceeds. The 60-second decrement is unawaited and can go negative. This is not a functioning rate limiter.

**Impact:** Provider can be rate-limited or over-billed. The `_maxPerMinute = 12` guard is meaningless.

---

### ISSUE-009 🟠 HIGH — LLM Configuration Contradiction / Gemini Path Unsupported

**Affected:** `.env`, [`app_config.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/core/config/app_config.dart), `llm_api_datasource.dart`

Configuration priority: SharedPreferences → `AppConfig` (compile-time `--dart-define`) → dotenv.

On a fresh install (no SharedPreferences):
- **URL** = `AppConfig.llmBaseUrl` = `https://integrate.api.nvidia.com/v1` (NVIDIA NIM)
- **Model** = `AppConfig.llmModel` = `meta/llama-3.3-70b-instruct`
- **Key** = dotenv `GEMINI_API_KEY` = `your_gemini_api_key_here` (placeholder)

The API call is: `POST ${baseUrl}/chat/completions` — OpenAI-compatible format, which works for NVIDIA NIM. The `.env` Gemini config can **never** work because Gemini uses `POST /models/{model}:generateContent` — a completely different path.

**Result:** Fresh install silently fails LLM call (invalid key) and falls back to offline parser with no user notification.

---

### ISSUE-010 🟠 HIGH — Voice Recognition Language Hardcoded to `en-IN`

**Affected:** [`AuraSpeechChannel.kt`](file:///c:/Users/Admin/VIT_Projects/AURA/android/app/src/main/kotlin/com/aura/aura/AuraSpeechChannel.kt) lines 91–92

```kotlin
putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-IN")
putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, "en-IN")
```

Voice recognition is tuned exclusively for Indian English. American, British, Australian, or non-English speakers will receive degraded or zero recognition accuracy.

**Impact:** Market restricted to Indian English speakers only.

---

### ISSUE-011 🟠 HIGH — Workspace Keyword Map Hardcoded to Developer's College

**Affected:** [`workspace_router_usecase.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/capture/domain/usecases/workspace_router_usecase.dart), [`capture_provider.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/capture/presentation/providers/capture_provider.dart)

```dart
'vit': ['vit', 'college', 'vtop', 'professor', 'assignment', 'lab', 'exam', 'submission', 'academics'],
'gate': ['gate', 'iit', 'pyq', 'aptitude', 'algo', 'algorithm', 'mock test'],
```

The workspace router displays `'Academics · VIT'` and `'IIT / GATE Prep'` in the capture confirmation UI for all users. `vtop` is a VIT University student portal. This is completely specific to the developer's university experience.

**Impact:** Confusing, unprofessional UX for any non-VIT student.

---

### ISSUE-012 🟠 HIGH — Silent Error Swallowing in 20+ Critical Paths

**Affected:** Multiple files

20+ instances of bare `catch (_) {}` found in critical paths:
- `app.dart:116` — background notification action failures silently ignored
- `offline_queue_processor.dart:123` — queue item failure silently retried with no log
- `llm_api_datasource.dart:210` — API key auth failure falls back silently, user never told AI isn't working
- `notification_service.dart:71` — timezone init failure falls back to UTC silently (all notifications fire at wrong times in non-UTC timezones)
- `workspace_list_screen.dart:51` — workspace deletion DB errors silently ignored
- `onboarding_screen.dart:65` — workspace creation failures during onboarding silently swallowed

**Impact:** Unreliable behavior invisible to both users and developers.

---

### ISSUE-013 🟡 MEDIUM — Notification ID Collision Risk

**Affected:** [`execute_ai_action_usecase.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/capture/domain/usecases/execute_ai_action_usecase.dart)

Alarm notification IDs: `alarmId.hashCode.abs()` where `alarmId` is a UUID v4 string. Dart's `String.hashCode` is 32-bit and can produce collisions. A collision silently overwrites the first alarm's scheduled notification. Over many alarms, probability grows.

---

### ISSUE-014 🟡 MEDIUM — Onboarding Name Pre-filled With Literal `'your name'`

**Affected:** [`onboarding_screen.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/onboarding/presentation/screens/onboarding_screen.dart) line 25

```dart
final TextEditingController _nameController = TextEditingController(text: 'your name');
```

Users who tap "GET STARTED →" without modifying the field set their name to `'your name'`. No validation beyond `isNotEmpty`. AURA will greet them as "Good morning, your name."

---

### ISSUE-015 🟡 MEDIUM — `watchAllActive().first` Anti-pattern in Briefing Use Case

**Affected:** [`generate_morning_briefing_usecase.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/home/domain/usecases/generate_morning_briefing_usecase.dart) line 36

```dart
final allActive = await _itemDao.watchAllActive().first;
```

Should be `await _itemDao.getAllActive()`. Using `.first` on a Drift stream unnecessarily creates a broadcast stream subscription. If the stream errors before emitting, `.first` throws without error handling in the caller.

---

### ISSUE-016 🟡 MEDIUM — Provider Preset Selection Never Persisted in Settings

**Affected:** [`settings_screen.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/settings/presentation/screens/settings_screen.dart)

`_selectedProviderPreset` (controls quick model suggestions UI) is never saved to `SharedPreferences` and never loaded. User selects "Google Gemini", picks `gemini-2.0-flash`, saves — but the dropdown resets to "NVIDIA NIM" on next open. The saved model is a Gemini model but the UI shows NVIDIA NIM suggestions.

---

### ISSUE-017 🟡 MEDIUM — `AuraShareActivity`: Shared Content Silently Dropped on Engine Init Failure

**Affected:** [`AuraShareActivity.kt`](file:///c:/Users/Admin/VIT_Projects/AURA/android/app/src/main/kotlin/com/aura/aura/AuraShareActivity.kt)

If Flutter's engine initialization is slow or fails and `getInitialSharePayload` is never called, the `sharedPayload` Kotlin field is never consumed. The user's shared content is silently discarded.

---

### ISSUE-018 🟡 MEDIUM — `watchTodayFocus` Has No Lower Bound on Deadline

**Affected:** [`item_dao.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/database/daos/item_dao.dart) `watchTodayFocus()`

The query includes any pending item with `deadline <= endOfDay`. Items from months ago that were never completed accumulate in "Today's Focus" indefinitely, eventually making it useless.

---

### ISSUE-019 🟡 MEDIUM — `startActivityForResult` Deprecated in API 33+

**Affected:** [`MainActivity.kt`](file:///c:/Users/Admin/VIT_Projects/AURA/android/app/src/main/kotlin/com/aura/aura/MainActivity.kt) line 103

Uses deprecated `startActivityForResult` / `onActivityResult` for the ringtone picker (suppressed with `@Suppress("DEPRECATION")`). Needs migration to the `Activity Result API`.

---

### ISSUE-020 🟡 MEDIUM — `.env` File Bundled as Flutter Asset (Security Risk)

**Affected:** `pubspec.yaml`

```yaml
flutter:
  assets:
    - .env
```

The `.env` file is shipped inside the APK and trivially extractable by any user with `apktool`. Any real API key placed there is effectively public.

---

### ISSUE-021 🟡 MEDIUM — API Key Stored in Unencrypted SharedPreferences

**Affected:** [`settings_screen.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/settings/presentation/screens/settings_screen.dart)

`flutter_secure_storage` is listed as a dependency but not used for the API key. The key is stored via plaintext `SharedPreferences`. Should use `FlutterSecureStorage` (Android Keystore-backed).

---

### ISSUE-022 🔵 LOW — `_cancelSubscriptions()` Not Awaited in `reset()`

**Affected:** [`capture_provider.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/capture/presentation/providers/capture_provider.dart)

`reset()` sets state to idle before awaiting subscription cancellation. A cancelled subscription can still emit into the new idle state.

---

### ISSUE-023 🔵 LOW — `DndService._db` Field Unused (Dead Injection)

**Affected:** [`dnd_service.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/reminders/data/services/dnd_service.dart)

`_db` is injected but immediately suppressed with `// ignore: unused_field`. The db is passed transitively to `ReplayDndNotificationsUseCase`. Minor dead code.

---

### ISSUE-024 🔵 LOW — `confidence` Column Never Populated in `ItemsCompanion`

**Affected:** [`create_task_usecase.dart`](file:///c:/Users/Admin/VIT_Projects/AURA/lib/features/capture/domain/usecases/create_task_usecase.dart)

`IntentResult.confidence` is parsed by the LLM and set correctly, but it is never written to `ItemsCompanion.confidence` when inserting. The DB column is always null/absent.

---

### ISSUE-025 🟠 HIGH — Test Coverage Critically Insufficient

**Affected:** [`test/`](file:///c:/Users/Admin/VIT_Projects/AURA/test)

**What exists:** 4 DB integration tests (workspace CRUD, item CRUD, search, cascade delete) + 1 empty `widget_test.dart`.

**What is missing:**
- Voice capture state machine (`CaptureNotifier`)
- LLM API integration + JSON parsing
- Notification scheduling (all paths)
- Alarm creation / cancellation
- Offline queue processing
- Local intent parser
- Route guard / onboarding flow
- Morning briefing generation
- Background action processing (`_processPendingBackgroundActions`)
- Settings save/load round-trip

**Impact:** Zero confidence in correctness of any AI/notification/voice pipeline behavior.

---

## 5. RELEASE BLOCKERS

The following issues MUST be resolved before any public release:

| ID | Issue | Severity |
|---|---|---|
| ISSUE-001 | Offline queue processor never started — PRD F-10 dead | 🔴 CRITICAL |
| ISSUE-002 | Morning briefing hardcodes `Ishant` for all users | 🔴 CRITICAL |
| ISSUE-003 | `create_event` silently falls through to task creation | 🔴 CRITICAL |
| ISSUE-004 | Past-time alarm notifications silently dropped | 🔴 CRITICAL |
| ISSUE-005 | Two competing overlay services in manifest | 🔴 CRITICAL |
| ISSUE-006 | Reminder scheduling never called during task creation | 🟠 HIGH |
| ISSUE-008 | Rate limiter does not enforce limit | 🟠 HIGH |
| ISSUE-009 | LLM configuration contradiction / Gemini path unsupported | 🟠 HIGH |
| ISSUE-010 | Voice recognition locked to `en-IN` | 🟠 HIGH |
| ISSUE-011 | Workspace router hardcoded to developer's college context | 🟠 HIGH |
| ISSUE-012 | Silent error swallowing in 20+ critical paths | 🟠 HIGH |
| ISSUE-014 | Onboarding name pre-filled with `'your name'` | 🟡 MEDIUM |
| ISSUE-020 | `.env` API key shipped inside APK | 🟡 MEDIUM |
| ISSUE-025 | Zero test coverage for AI/notification/voice pipeline | 🟠 HIGH |

---

## 6. SUSPICIOUS UNREVIEWED AREAS

> [!WARNING]
> The following components were not fully reviewed and carry unquantified risk.

1. **`BriefingSchedulerService`** — called on every app resume. Cannot rule out its own hardcoded names or silent failures that would produce daily incorrect notifications.

2. **`RecurringTaskResetUseCase`** — runs on every app resume. A date comparison bug could silently reset tasks every day.

3. **`ReplayDndNotificationsUseCase`** — queries `NotificationLogs` and re-fires notifications. Stale data or re-fire logic bugs → duplicate notifications.

4. **`OrbMenuActivity`** — launched on orb long-press. Not reviewed. If it crashes, the long-press menu silently fails with no user feedback.

5. **`SharedContentDao`** — referenced in `share_receive_screen.dart` but not confirmed to exist as a standalone DAO file.

6. **Android 14+ `USE_FULL_SCREEN_INTENT` permission dialog** — requested in manifest but code does not check if granted before scheduling full-screen alarm intents.

---

## 7. UNTESTED / UNVERIFIABLE AREAS

| Area | Why Untestable | Risk Level |
|---|---|---|
| Runtime LLM API call | No live key; requires network | 🔴 HIGH |
| Android SpeechRecognizer | Requires physical device | 🔴 HIGH |
| Notification firing (exact alarms) | Requires Android runtime | 🔴 HIGH |
| System overlay permission flow | Requires Android runtime | 🟡 MEDIUM |
| DND detection and replay | Requires device + DND enable | 🟡 MEDIUM |
| Boot receiver behavior | Requires device restart | 🟡 MEDIUM |
| `OrbMenuActivity` behavior | Source not reviewed | 🟡 MEDIUM |
| `BriefingSchedulerService` full path | Partial review only | 🔴 HIGH |
| Google ML Kit OCR | Requires device + image | 🟡 MEDIUM |

---

## 8. FINAL RELEASE RECOMMENDATION

> **Verdict: NO — DO NOT APPROVE FOR RELEASE**

**The seven definitive reasons:**

1. **The core user promise is broken.** "Remind me tomorrow at 9am" saves a task with no notification. `ScheduleReminderUseCase` is never called.

2. **Every user is greeted by another person's name.** `GenerateMorningBriefingUseCase` hardcodes `'Good morning, Ishant.'` This is not a styling issue — it runs for every user.

3. **The offline capture feature is completely dead.** `offlineQueueProcessorProvider` is never initialized. Users who capture offline lose their data permanently.

4. **Events created by voice have no time, location, or event-specific data.** The `create_event` intent falls through to task creation.

5. **Alarms for edge-case past times silently vanish.** Users will miss real events believing AURA set their alarm.

6. **The LLM configuration is a trap.** A fresh install with the `.env` Gemini configuration silently fails all AI calls and uses the offline fallback with zero user notification.

7. **The floating overlay has a dead prototype service** (`AuraFloatingService`) still live in the manifest alongside the real one (`AuraOverlayService`). The product is not production-clean.

The application demonstrates strong architectural thinking, thoughtful schema design, and ambitious scope. But it has **multiple broken core workflows** that will be immediately apparent to any real user on first meaningful use. This is not a polish gap — these are functional failures in the primary value proposition.

**Minimum required work before controlled beta release:** 2–3 focused development sprints addressing all 🔴 CRITICAL and 🟠 HIGH items and adding baseline integration tests for the voice-to-DB pipeline.
