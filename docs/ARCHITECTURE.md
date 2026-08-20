# AURA — System Architecture

> **Version:** 1.0
> **Phase:** 4 — System Design
> **Status:** Final
> **Last Updated:** 2026-07-24
> **References:** ADR-001 through ADR-011, PRD v0.3, UX Wireframes

This document defines every module, layer, dependency, and data flow in AURA.
During Phase 8 coding, reference this document for all architectural decisions.
Do not deviate from this structure without writing a new ADR first.

---

## 1. Architecture Overview

AURA is a **Flutter Android app** using **Clean Architecture** with a local-first data model.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        AURA APPLICATION                                 │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    PRESENTATION LAYER                            │   │
│  │  Flutter Widgets · Screens · Providers (Riverpod)               │   │
│  └──────────────────────────────┬───────────────────────────────────┘   │
│                                 │ calls                                  │
│  ┌──────────────────────────────▼───────────────────────────────────┐   │
│  │                      DOMAIN LAYER                                │   │
│  │  Use Cases · Entities · Repository Interfaces                   │   │
│  └──────────────────────────────┬───────────────────────────────────┘   │
│                                 │ implements                             │
│  ┌──────────────────────────────▼───────────────────────────────────┐   │
│  │                       DATA LAYER                                 │   │
│  │  ┌─────────────────────┐   ┌──────────────────────────────────┐  │   │
│  │  │  LOCAL DATA SOURCE  │   │    REMOTE DATA SOURCE            │  │   │
│  │  │  Drift ORM (SQLite) │   │    Gemini API · Future cloud     │  │   │
│  │  └──────────┬──────────┘   └──────────────┬───────────────────┘  │   │
│  └─────────────┼──────────────────────────────┼─────────────────────┘   │
│                │                              │                          │
│  ┌─────────────▼──────────────────────────────▼─────────────────────┐   │
│  │               PLATFORM / ANDROID LAYER                           │   │
│  │  Method Channels · Foreground Service · BroadcastReceiver        │   │
│  │  SpeechRecognizer · Overlay · DND · Share                        │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

**Core principles this architecture enforces:**
- **ADR-001**: Data layer owns all writes. Nothing reaches Drift without going through a use case.
- **ADR-002**: Local data source is the primary source of truth. Remote is always optional.
- **ADR-004**: Presentation layer never calls AI directly. AI calls flow through use cases that enforce the confirm step.
- **ADR-011**: Platform layer is a thin wrapper. All business logic stays in Dart.

---

## 2. Flutter Project Structure

```
AURA/
├── android/                          ← Native Android code (thin layer only)
│   └── app/src/main/kotlin/
│       └── com/aura/app/
│           ├── MainActivity.kt
│           ├── AuraOverlayService.kt    ← Floating orb foreground service
│           ├── AuraDNDReceiver.kt       ← DND state BroadcastReceiver
│           ├── AuraSpeechChannel.kt     ← SpeechRecognizer bridge
│           └── AuraShareActivity.kt     ← Android share target entry point
│
├── lib/
│   ├── main.dart                     ← App entry point, DI setup
│   ├── app.dart                      ← MaterialApp, theme, router
│   │
│   ├── core/                         ← Shared utilities, not feature-specific
│   │   ├── constants/
│   │   │   ├── colors.dart           ← All color tokens from design system
│   │   │   ├── typography.dart       ← All TextStyle definitions
│   │   │   ├── spacing.dart          ← All spacing constants
│   │   │   └── api_keys.dart         ← API key management (env-based)
│   │   ├── errors/
│   │   │   ├── failures.dart         ← Failure sealed class hierarchy
│   │   │   └── exceptions.dart       ← Exception types
│   │   ├── network/
│   │   │   ├── connectivity.dart     ← Network connectivity checker
│   │   │   └── retry_policy.dart     ← Retry with backoff logic
│   │   ├── storage/
│   │   │   └── secure_storage.dart   ← flutter_secure_storage wrapper
│   │   └── utils/
│   │       ├── date_formatter.dart   ← All date/time formatting
│   │       ├── uuid_generator.dart   ← UUID v4 generation
│   │       └── logger.dart           ← Structured logging (no print() in prod)
│   │
│   ├── features/                     ← Feature modules (vertical slices)
│   │   ├── capture/                  ← Voice capture + confirmation
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── speech_recognizer_datasource.dart
│   │   │   │   │   └── gemini_api_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── capture_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── voice_capture_result.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── capture_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── start_voice_capture.dart
│   │   │   │       ├── process_transcript.dart   ← calls Gemini
│   │   │   │       └── queue_offline_capture.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── capture_overlay_screen.dart
│   │   │       ├── widgets/
│   │   │       │   ├── voice_waveform.dart
│   │   │       │   ├── live_transcript.dart
│   │   │       │   └── confirmation_box.dart
│   │   │       └── providers/
│   │   │           └── capture_provider.dart
│   │   │
│   │   ├── tasks/                    ← Task CRUD + detail
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── task_local_datasource.dart   ← Drift DAO wrapper
│   │   │   │   └── repositories/
│   │   │   │       └── task_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── task.dart
│   │   │   │   │   ├── reminder.dart
│   │   │   │   │   └── subtask.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── task_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── create_task.dart
│   │   │   │       ├── update_task.dart
│   │   │   │       ├── complete_task.dart
│   │   │   │       ├── delete_task.dart
│   │   │   │       └── watch_tasks_by_workspace.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── task_detail_screen.dart
│   │   │       ├── widgets/
│   │   │       │   ├── task_card.dart
│   │   │       │   ├── task_list.dart
│   │   │       │   └── reminder_row.dart
│   │   │       └── providers/
│   │   │           └── task_provider.dart
│   │   │
│   │   ├── workspaces/               ← Workspace CRUD + detail
│   │   │   ├── data/ ...
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── workspace.dart
│   │   │   │   │   └── workspace_section.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── create_workspace.dart
│   │   │   │       ├── auto_create_workspace.dart  ← AI-triggered creation
│   │   │   │       └── watch_all_workspaces.dart
│   │   │   └── presentation/ ...
│   │   │
│   │   ├── home/                     ← Home screen + bento grid
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── home_screen.dart
│   │   │       ├── widgets/
│   │   │       │   ├── bento_card.dart
│   │   │       │   ├── urgent_cell.dart
│   │   │       │   ├── focus_cell.dart
│   │   │       │   ├── habits_cell.dart
│   │   │       │   └── workspace_chips_cell.dart
│   │   │       └── providers/
│   │   │           └── home_provider.dart
│   │   │
│   │   ├── briefing/                 ← Morning briefing generation + screen
│   │   │   ├── data/ ...
│   │   │   ├── domain/
│   │   │   │   └── usecases/
│   │   │   │       └── generate_morning_briefing.dart
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           └── morning_briefing_screen.dart
│   │   │
│   │   ├── notifications/            ← Reminder scheduling + DND replay
│   │   │   ├── data/ ...
│   │   │   ├── domain/
│   │   │   │   └── usecases/
│   │   │   │       ├── schedule_reminder.dart
│   │   │   │       ├── cancel_reminder.dart
│   │   │   │       └── replay_dnd_notifications.dart
│   │   │   └── services/
│   │   │       └── notification_service.dart
│   │   │
│   │   ├── share/                    ← Share-to-AURA: OCR + link reading
│   │   │   ├── data/
│   │   │   │   └── datasources/
│   │   │   │       ├── ocr_datasource.dart        ← ML Kit wrapper
│   │   │   │       └── link_reader_datasource.dart ← HTML fetch + parse
│   │   │   ├── domain/ ...
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           └── share_receive_screen.dart
│   │   │
│   │   ├── search/                   ← Full-text search
│   │   │   └── ...
│   │   │
│   │   ├── settings/                 ← App settings screen
│   │   │   └── ...
│   │   │
│   │   └── onboarding/               ← First launch flow
│   │       └── ...
│   │
│   ├── database/                     ← Drift database (global)
│   │   ├── app_database.dart         ← @DriftDatabase annotation, schema version
│   │   ├── tables/
│   │   │   ├── workspaces_table.dart
│   │   │   ├── workspace_sections_table.dart
│   │   │   ├── tasks_table.dart
│   │   │   ├── reminders_table.dart
│   │   │   ├── events_table.dart
│   │   │   ├── notes_table.dart
│   │   │   ├── shared_content_table.dart
│   │   │   ├── notification_log_table.dart
│   │   │   ├── ai_actions_log_table.dart
│   │   │   ├── offline_queue_table.dart
│   │   │   └── daily_log_table.dart
│   │   ├── daos/
│   │   │   ├── task_dao.dart
│   │   │   ├── workspace_dao.dart
│   │   │   ├── reminder_dao.dart
│   │   │   ├── event_dao.dart
│   │   │   └── notification_dao.dart
│   │   └── migrations/
│   │       └── migration_v1_to_v2.dart  ← Add as schema evolves
│   │
│   └── platform/                     ← Platform channel bridges (Dart side)
│       ├── channels.dart             ← Channel name constants
│       ├── overlay_channel.dart      ← Floating orb control
│       ├── speech_channel.dart       ← SpeechRecognizer bridge
│       ├── dnd_channel.dart          ← DND state listener
│       └── share_channel.dart        ← Share intent receiver
│
├── pubspec.yaml
└── pubspec.lock
```

---

## 3. Module Dependency Rules

```
presentation → domain ← data
     ↓            ↑
  providers    use cases
               ↑
           entities

RULE: No layer imports from a layer above it.
      Presentation imports domain only (via providers).
      Data imports domain (implements repository interfaces).
      Domain imports nothing except its own entities.
```

No `import 'package:aura/features/tasks/...'` from within `features/capture/`.
Features communicate via shared domain entities and use cases only.

---

## 4. State Management — Riverpod

All state is managed via **Riverpod** providers.

```dart
// Provider hierarchy
┌──────────────────────────────────────────────────────┐
│ DatabaseProvider          — AppDatabase singleton     │
│ TaskDaoProvider           — TaskDao from DB           │
│ WorkspaceDaoProvider      — WorkspaceDao from DB      │
│                                                       │
│ Feature Providers:                                    │
│ homeProvider              — Home screen state         │
│ captureProvider           — Voice capture state       │
│ workspaceListProvider     — All workspaces stream     │
│ tasksByWorkspaceProvider  — Tasks per workspace       │
│ morningBriefingProvider   — Today's briefing data     │
│ notificationProvider      — Reminder schedule state   │
└──────────────────────────────────────────────────────┘
```

**Riverpod rules:**
- Use `StreamProvider` for all Drift reactive queries (`.watch()`)
- Use `StateNotifierProvider` for complex UI state (capture flow states)
- Use `FutureProvider` for one-shot async operations
- Use `riverpod_generator` (code gen) for all providers — reduces boilerplate

---

## 5. Navigation — go_router

```dart
// Route structure
/                    → HomeScreen
/workspace/:id       → WorkspaceDetailScreen
/task/:id            → TaskDetailScreen
/calendar            → CalendarScreen (tabs: daily/weekly/monthly/kanban)
/search              → SearchScreen
/settings            → SettingsScreen
/settings/workspaces → WorkspaceManageScreen
/onboarding          → OnboardingFlow (only shown on first launch)
/briefing            → MorningBriefingScreen (deep link from notification)
/share               → ShareReceiveScreen (Android intent)

// Overlay routes (shown on top of any screen)
/capture             → VoiceCaptureOverlay (pushed as overlay)
/confirm             → ConfirmationBoxOverlay (pushed as overlay)
```

---

## 6. Android Platform Layer

### 6a. Floating Orb — AuraOverlayService.kt

```
Type:       Foreground Service (must survive RAM clearing + battery optimization)
Permission: SYSTEM_ALERT_WINDOW
Implementation:
  - WindowManager adds a View on top of all apps
  - View is a custom circular button (matches Flutter design exactly)
  - Drag handled by OnTouchListener → saves position to SharedPreferences
  - Tap → sends event to Flutter via MethodChannel → triggers voice capture
  - Must restart on boot (BOOT_COMPLETED BroadcastReceiver)
  - Must restart if killed (START_STICKY)

Method channel: 'aura/overlay'
  Flutter → Android: startOverlay(), stopOverlay(), updateOrbState(state)
  Android → Flutter: onOrbTapped(), onOrbLongPressed()
```

### 6b. DND Listener — AuraDNDReceiver.kt

```
Type:       BroadcastReceiver
Action:     NotificationManager.ACTION_INTERRUPTION_FILTER_CHANGED
Implementation:
  - Monitors DND on/off transitions
  - When DND turns OFF → calls Flutter via MethodChannel → triggers DND replay use case

Method channel: 'aura/dnd'
  Android → Flutter: onDndLifted(timestamp), onDndEnabled(timestamp)
```

### 6c. Speech Bridge — AuraSpeechChannel.kt

```
Type:       MethodChannel handler in MainActivity
Implementation:
  - SpeechRecognizer.createSpeechRecognizer(context)
  - startListening(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
  - Streams: partial results → liveTranscript EventChannel
             final result → onTranscriptReady MethodChannel
             audio level → audioLevel EventChannel (drives waveform)

Method channel: 'aura/speech'
  Flutter → Android: startListening(), stopListening()
  Android → Flutter: onTranscriptReady(text), onError(code)

Event channels:
  'aura/speech/partial'    → partial transcript updates (String)
  'aura/speech/audioLevel' → amplitude 0.0–1.0 (double, 60fps)
```

### 6d. Share Target — AuraShareActivity.kt

```
Type:       Activity registered as share target in AndroidManifest
Handles:    ACTION_SEND (image/*, text/plain, application/pdf, text/uri-list)
Implementation:
  - Receives intent data
  - Copies shared file to AURA's private storage if needed
  - Passes data to Flutter via MethodChannel on launch
  - Flutter displays ShareReceiveScreen

Method channel: 'aura/share'
  Android → Flutter: onShareReceived(type, filePath?, url?, text?)
```

---

## 7. Background Services

### 7a. Notification Service (Flutter side)

```
Package:    flutter_local_notifications
Scheduling: WorkManager (Android) for reliable background scheduling
            android_alarm_manager_plus as fallback for exact alarms

Notification channels (Android):
  AURA_REMINDERS   — Task and event reminders (high priority)
  AURA_BRIEFING    — Morning briefing (default priority)
  AURA_NUDGES      — Proactive nudges (low priority)
  AURA_SYSTEM      — DND replay, offline queue processed (silent channel)

Each reminder in DB has a corresponding WorkManager task:
  - tag: "reminder_{reminder_id}"
  - one-time, exact time
  - constraints: none (must fire even offline)
```

### 7b. Offline Queue Processor

```
Trigger:    ConnectivityProvider state change → online
Action:     Query offline_queue table for pending items
            Process each: send transcript to Gemini → parse → create task draft
            Push notification: "AURA processed X offline captures — tap to review"
            User reviews confirmation cards (same flow as online)
```

### 7c. Recurring Task Reset

```
Trigger:    WorkManager periodic task at midnight daily
Action:     Reset all recurring tasks to PENDING for new day
            Log yesterday's completion in daily_log table
            Generate nudge if yesterday had uncompleted recurring tasks
```

### 7d. Morning Briefing Generator

```
Trigger:    WorkManager one-time task at calculated briefing time
Recalculate time: Every Sunday, recalculate from last 7 days unlock pattern
                  OR use manual override from settings
Action:     Query all urgent tasks, today's tasks, habits, upcoming items
            Call Gemini API to generate motivational line
            Build briefing notification
            Fire notification
            If user taps → deep link to /briefing route
```

---

## 8. Data Flow — Voice Capture to DB

```
User taps orb
     │
     ▼ (MethodChannel: 'aura/overlay' → onOrbTapped)
CaptureProvider.startCapture()
     │
     ▼
SpeechChannel.startListening()    [Android SpeechRecognizer]
     │
     ▼ (EventChannel: partial results)
CaptureProvider.updateTranscript(partial)   → LiveTranscript widget rebuilds
     │
     ▼ (MethodChannel: onTranscriptReady OR user taps STOP)
CaptureProvider.processCaptured(finalTranscript)
     │
     ├── Online?
     │     ▼
     │   ProcessTranscriptUseCase
     │     ↓
     │   GeminiApiDataSource.extractIntent(transcript)
     │     ↓
     │   Parse JSON response → VoiceCaptureResult entity
     │     ↓
     │   CaptureProvider.showConfirmation(result)
     │     ↓
     │   ConfirmationBox widget shown
     │     ↓
     │   User confirms
     │     ↓
     │   CreateTaskUseCase(task) → TaskLocalDataSource.insertTask()
     │     ↓
     │   ScheduleReminderUseCase → WorkManager jobs created
     │     ↓
     │   AiActionsLogDao.insert(log)   ← Transparency log (ADR-004)
     │     ↓
     │   Success: orb flash + haptic
     │
     └── Offline?
           ▼
         QueueOfflineCaptureUseCase
           ↓
         OfflineQueueDao.insert(transcript, timestamp)
           ↓
         Show "Saved as draft" message
           ↓
         ConnectivityProvider watches for online
           ↓ (when back online)
         Process queue → same flow as online
```

---

## 9. AI Integration Architecture

### Gemini API Client

```dart
class GeminiApiDataSource {
  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const _model = 'gemini-2.0-flash';
  static const _timeout = Duration(seconds: 8);
  static const _maxRetries = 1;

  Future<IntentResult> extractIntent(String transcript, IntentContext context);
  Future<String> generateBriefingLine(BriefingData data);
  Future<String> summarizeLink(String htmlContent, int wordCount);
}
```

**Rate limiting (Gemini free tier: 15 req/min):**
- Implement token bucket rate limiter
- Queue requests if limit approached
- Show "AI is busy, queued..." message after 3s wait

**API call types and frequency:**
| Call | Trigger | Estimated frequency |
|------|---------|-------------------|
| Intent extraction | Each voice capture | 5–20/day |
| Link summarization | Each shared link | 2–5/day |
| Briefing line | Once daily | 1/day |
| Workspace classifier | During intent extraction | Same as above |

Total: ~30–50 API calls/day — well within 15 req/min free tier.

---

## 10. Dependency Map (pubspec.yaml packages)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x

  # Navigation
  go_router: ^14.x

  # Local database
  drift: ^2.x
  sqlite3_flutter_libs: ^0.x
  path_provider: ^2.x
  path: ^1.x

  # Network / AI
  http: ^1.x                        # Gemini API calls
  connectivity_plus: ^6.x           # Network state monitoring

  # Notifications
  flutter_local_notifications: ^17.x
  workmanager: ^0.x                 # Background task scheduling

  # Platform
  permission_handler: ^11.x         # Runtime permissions
  flutter_secure_storage: ^9.x      # Secure key storage

  # Google ML Kit (OCR)
  google_mlkit_text_recognition: ^0.x

  # Google Fonts
  google_fonts: ^6.x                # Space Grotesk

  # Icons — ONLY icon set (ADR-012: no emojis, no Material Icons)
  lucide_icons: ^0.x                # 2px stroke, geometric, neubrutalist-aligned

  # Utilities
  uuid: ^4.x                        # UUID v4 generation
  freezed_annotation: ^2.x          # Immutable entities
  json_annotation: ^4.x             # JSON serialization

dev_dependencies:
  build_runner: ^2.x
  drift_dev: ^2.x
  riverpod_generator: ^2.x
  freezed: ^2.x
  json_serializable: ^6.x
  flutter_lints: ^4.x
```

---

## 11. Error Handling Strategy

All errors are represented as typed `Failure` subclasses:

```dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure { ... }      // No internet
class ApiFailure extends Failure { ... }           // Gemini error / timeout
class DatabaseFailure extends Failure { ... }      // Drift error
class PermissionFailure extends Failure { ... }    // Android permission denied
class ParseFailure extends Failure { ... }         // AI returned bad JSON
class RateLimitFailure extends Failure { ... }     // Gemini 429
```

**Result type pattern (no exceptions in domain layer):**
```dart
typedef Result<T> = Either<Failure, T>;
// Use: fpdart package Either or custom implementation
```

Every use case returns `Result<T>`. Presentation layer maps failures to UI states.

---

## 12. Privacy Architecture

Per ADR-002 and Principle 1:

```
What stays on device (always):
  - All task/event/reminder data (Drift DB)
  - Voice recordings (never stored — only transcript)
  - OCR results from screenshots
  - AI action logs
  - Notification logs

What leaves the device (and when):
  - Voice transcript → Gemini API (only when processing)
    Context sent: transcript + workspace names + current time
    Not sent: full task history, personal notes, raw audio
  - Link HTML content → Gemini API (only when shared link processed)
  - Briefing data → Gemini API (only task names + counts, no content)

What is NEVER sent externally:
  - Raw audio recordings
  - Full task descriptions/notes
  - File attachments
  - Location data
```

The `ai_actions_log` table stores every external AI call (input + output) so users can audit exactly what was sent. This is visible in Settings → Privacy.

---

## 13. Performance Targets

| Operation | Target | Approach |
|-----------|--------|---------|
| App cold start | < 2 seconds | Lazy initialization, no heavy sync on startup |
| Orb tap → listening active | < 500ms | SpeechRecognizer pre-initialized |
| Voice stop → confirmation visible | < 3 seconds | Gemini 2.0 Flash avg ~1.5s |
| Task list render | < 16ms/frame | Riverpod StreamProvider + ListView.builder |
| DB write (task + reminders) | < 100ms | Drift async + batch insert |
| Notification schedule | < 200ms | WorkManager enqueue is async |
| OCR on screenshot | < 2 seconds | ML Kit on-device, no network |

---

## 14. Next Phase Dependencies

Phase 5 (AI Design) will define:
- Gemini prompt templates for each agent
- Intent extraction JSON schema (full)
- Confidence scoring algorithm
- Workspace routing classifier logic

Phase 6 (Database Design) will define:
- Full Drift table definitions with all columns
- Migration strategy
- Index plan
- DAO method signatures

---

*Architecture v1.0 — 2026-07-24*
*Status: Final for MVP scope*
*Do not modify without a new ADR*
