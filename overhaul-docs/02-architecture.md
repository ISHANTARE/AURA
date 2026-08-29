# System Architecture & Layering Specification

> **Forensic Rebuild Specification**  
> Complete architecture blueprint for AURA, covering dual-engine Flutter embedding, Kotlin native subsystems, Clean Architecture layering, Riverpod reactive dependency injection, and multi-activity Android lifecycle management.

---

## 1. High-Level Architecture Map

AURA uses a **Clean Architecture with Feature-Sliced vertical organization** coupled with a **Multi-Activity, Multi-Engine Android Native Foundation**:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            ANDROID NATIVE LAYER                             │
│                                                                             │
│  ┌──────────────────────┐  ┌──────────────────────┐  ┌───────────────────┐  │
│  │     MainActivity     │  │ AuraCaptureActivity  │  │ AuraShareActivity │  │
│  │ (Main FlutterEngine) │  │  (Cached Engine #1)  │  │(Cached Engine #2) │  │
│  └──────────┬───────────┘  └──────────┬───────────┘  └─────────┬─────────┘  │
│             │                         │                        │            │
│  ┌──────────▼─────────────────────────▼────────────────────────▼─────────┐  │
│  │             AuraChannelRegistrar (Unified Channel Binder)             │  │
│  └────────────────────────────────────┬──────────────────────────────────┘  │
│                                       │                                     │
│  ┌──────────────────────┐  ┌──────────▼───────────┐  ┌───────────────────┐  │
│  │  AuraOverlayService  │  │  AuraSpeechChannel   │  │  AuraTileService  │  │
│  │ (Canvas Floating Orb)│  │(SpeechRecognizer/RMS)│  │ (Quick Settings)  │  │
│  └──────────────────────┘  └──────────────────────┘  └───────────────────┘  │
└───────────────────────────────────────┬─────────────────────────────────────┘
                                        │ MethodChannels & EventChannels
┌───────────────────────────────────────▼─────────────────────────────────────┐
│                           FLUTTER APPLICATION LAYER                         │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ Presentation Layer: Screens, Widgets, Bento Cells, Riverpod Notifiers │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │ Domain Layer: Entities, Use Cases, Intent Resolvers, Schedulers       │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │ Data Layer: LLM Datasources, OCR Datasource, Link Scraper, DAOs       │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │ Core Infrastructure: Drift SQLite (WAL), SecureStore, AppRouter       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Directory Structure & Layering Rules

```
lib/
├── app.dart                   # AuraApp ConsumerStatefulWidget, lifecycle observer
├── main.dart                  # Bootstrap entry point, provider initialization
├── core/
│   ├── config/app_config.dart # Compile-time defaults and runtime fallback keys
│   ├── constants/             # Colors (OLED theme), Typography, Spacing
│   ├── errors/aura_failure.dart # Typed failure domain models
│   ├── providers/             # Global core providers, clock providers, DAO providers
│   ├── router/app_router.dart # GoRouter config, OnboardingGateNotifier
│   ├── security/secret_store.dart # Encrypted Keystore secret management
│   ├── services/              # ConnectivityMonitor, NotificationService export
│   ├── theme/theme_provider.dart  # ThemeMode and ThemeAccent state notifiers
│   └── utils/greeting.dart    # Time-aware personalized greeting generator
├── database/
│   ├── app_database.dart      # Drift schema v4, migrations v1->v2->v3->v4
│   ├── daos/                  # ItemDao, WorkspaceDao, NotificationDao, OfflineQueueDao, SharedContentDao
│   └── tables/                # 11 Drift table definitions
├── features/
│   ├── alarms/                # AlarmsScreen, AlarmCard, AlarmPicker
│   ├── capture/               # Voice capture, LLM API, LocalIntentParser, WorkspaceRouter
│   ├── home/                  # HomeScreen, BentoGrid, DayAgendaView, BriefingScheduler, NudgeEngine
│   ├── notes/                 # NotesScreen, NoteCard, NoteSortNotifier
│   ├── onboarding/            # OnboardingScreen 5-step wizard
│   ├── reminders/             # RemindersScreen, ReminderSchedulingService, DndService
│   ├── settings/              # SettingsScreen, sound pickers, data export/reset
│   └── workspaces/            # WorkspaceListScreen, WorkspaceDetailScreen, Kanban sections
└── platform/
    ├── channels.dart          # AuraChannels constants
    ├── overlay_channel.dart   # MethodChannel 'aura/overlay' client
    └── speech_channel.dart    # MethodChannel 'aura/speech' + 4 EventChannel clients
```

### Strict Architectural Boundaries

1. **Domain Isolation**: `domain/entities` and `domain/usecases` MUST NOT depend on presentation widgets or Flutter UI libraries.
2. **Database Access**: UI widgets never call Drift queries or raw SQL directly. All persistence passes through DAOs and UseCases.
3. **Hardware & Platform Access**: Native capabilities (Speech, Overlay, DND, Ringtones) are isolated behind platform wrappers (`platform/` or `features/*/data/services/`).
4. **Single-Path Scheduling**: `ReminderSchedulingService` is the ONLY class permitted to interact with `NotificationService` for item-derived alarms and reminders.

---

## 3. Multi-Activity & Dual-Engine Native System

### A. Engine Prewarming & Routing

To guarantee instantaneous voice capture response times when launching from outside the app (e.g. from the Floating Orb, Quick Settings Tile, or App Shortcut), AURA utilizes cached `FlutterEngine` instances:

1. **`MainActivity`**:
   - Primary FlutterActivity hosting the full application shell (`Routes.home`).
   - On launch, creates and caches secondary FlutterEngine instances (`capture_engine_id`, `share_engine_id`) via `FlutterEngineCache`.
   - Registers all platform channels on all engines via `AuraChannelRegistrar.registerWith(...)`.

2. **`AuraCaptureActivity`**:
   - Translucent activity (`@style/TranslucentTheme`) configured with `windowIsTranslucent = true`, `windowBackground = @android:color/transparent`.
   - Uses cached engine `capture_engine_id` pre-navigated to `/capture-overlay`.
   - Allows users to speak commands over any running Android app without losing background context.

3. **`AuraShareActivity`**:
   - Target activity for `ACTION_SEND` intents.
   - Extracts shared text, URIs, images, audio, video, or documents.
   - Caches payload into `aura_share_payload.json` inside Android cache directory.
   - Sweeps old shared media cached files older than 24 hours.
   - Launches `/share` route on the share engine.

4. **`OrbMenuActivity`**:
   - Transparent fullscreen activity launched when the user holds the Floating Orb for >600ms.
   - Displays a contextual quick-action card at the exact screen coordinates of the orb.

5. **`AuraTileService`**:
   - Android System Quick Settings Tile (`android.service.quicksettings.TileService`).
   - Clicking the tile executes `startActivityAndCollapse` to launch `AuraCaptureActivity`.

---

## 4. Reactive Dependency Injection Graph (Riverpod)

```
┌─────────────────────────────── databaseProvider (AppDatabase) ───────────────────────────────┐
│                                                                                               │
├── itemDaoProvider ─────────────► reminderSchedulingServiceProvider ──► executeAiActionUseCaseProvider
├── workspaceDaoProvider ───────┤                                       ▲
├── notificationDaoProvider ────┤                                       │
├── offlineQueueDaoProvider ────┤                                       │
└── sharedContentDaoProvider ───┘                                       │
                                                                        │
┌─────────────────────────────── captureProvider (CaptureNotifier) ─────┴──────────────────────┐
│  Dependencies:                                                                               │
│  - speechChannelProvider (SpeechChannel)                                                     │
│  - llmApiDataSourceProvider (LlmApiDataSource with RateLimiter)                              │
│  - workspaceRouterUseCaseProvider (WorkspaceRouterUseCase)                                   │
│  - executeAiActionUseCaseProvider (ExecuteAiActionUseCase)                                   │
│  - queueOfflineTranscriptUseCaseProvider (QueueOfflineTranscriptUseCase)                     │
│  - connectivityServiceProvider (ConnectivityService)                                         │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

### Core Provider Definitions

| Provider | Type | Lifecycle | Description |
|---|---|---|---|
| `databaseProvider` | `Provider<AppDatabase>` | App Lifetime | Singleton SQLite database connection. |
| `userNameProvider` | `StateNotifierProvider<UserNameNotifier, String>` | App Lifetime | Live user display name with `SharedPreferences` persistence. |
| `themeModeProvider` | `StateNotifierProvider<ThemeModeNotifier, ThemeMode>` | App Lifetime | Active theme mode (`ThemeMode.dark` / `ThemeMode.light`). |
| `themeAccentProvider` | `StateNotifierProvider<ThemeAccentNotifier, ThemeAccent>` | App Lifetime | Active theme accent color (Indigo, Cyan, Purple, Orange, Rose). |
| `onboardingGateProvider` | `StateNotifierProvider<OnboardingGateNotifier, bool>` | App Lifetime | Auth/Onboarding route guard state. |
| `allActiveItemsProvider` | `StreamProvider<List<Item>>` | Reactive | Live stream of all non-deleted, active items from `ItemDao`. |
| `todayFocusItemsProvider` | `StreamProvider<List<Item>>` | Reactive | Live stream of today's focus items (top priority). |
| `quickStatsProvider` | `StreamProvider<DashboardStats>` | Reactive | Live counts: Pending, Completed, Overdue. |
| `dayAgendaProvider` | `StreamProvider<DayAgendaModel>` | Reactive | Day agenda split into Timed Items and Anytime Checklist items. |
| `captureProvider` | `StateNotifierProvider<CaptureNotifier, CaptureState>` | Scoped | Complete voice capture state machine. |
| `offlineQueueProcessorProvider` | `Provider<OfflineQueueProcessor>` | App Lifetime | Auto-starting connectivity listener and offline queue processor. |

---

## 5. Declarative Navigation & Routing (`app_router.dart`)

```
/ (Root)
│
├── /onboarding           [Un-gated] First-run onboarding wizard
├── /capture-overlay      [Un-gated] Translucent voice capture overlay
├── /share                [Un-gated] Share-to-AURA receiver screen
│
└── ShellRoute (Persistent Bottom Navigation Shell)
    ├── / (Routes.home)   [Gated] Daily Cockpit Dashboard & Day Agenda
    ├── /alarms           [Gated] Alarms & Time-of-Day Alerts
    ├── /workspaces       [Gated] Workspace Management & Kanban
    ├── /notes            [Gated] Freeform Notes & Spoken Thoughts
    └── /settings         [Gated] App Settings, AI Engine, Sounds, Data
│
├── /workspace/:id        [Gated] Workspace Detail Screen & Sections
├── /task/:id             [Gated] Task / Reminder / Alarm Detail Editor
├── /briefing             [Gated] Fullscreen Morning Briefing
├── /search               [Gated] Global Search Screen
└── /reminders            [Gated] Dedicated Reminders List Screen
```

### Route Guard Contract (`OnboardingGateNotifier`)

- If `onboarding_complete` is `false`, any navigation attempt to a gated route is redirected to `/onboarding`.
- Un-gated whitelist: `/onboarding`, `/capture-overlay`, `/share`.
- Resetting app data calls `onboardingGateProvider.notifier.reset()`, immediately locking all routes without requiring an app restart.

---

## 6. App Lifecycle & Background Synchronization (`app.dart`)

`AuraApp` implements `WidgetsBindingObserver`. On every `AppLifecycleState.resumed` event, it executes the following synchronization tasks sequentially inside error-guarded blocks:

1. **`_processPendingBackgroundActions()`**:
   - Reads `pending_bg_action` from `SharedPreferences`.
   - Dispatches `MARK_DONE:<payload>` or `SNOOZE_30M:<payload>` triggered from background notification action buttons.
2. **`BriefingSchedulerService.onAppActive()`**:
   - Checks if today's morning briefing notification has been scheduled; schedules it if pending.
3. **`NudgeEngine.evaluateAndNudge()`**:
   - Evaluates quiet hours, 3-hour minimum spacing, and 3/day cap to fire a proactive focus nudge.
4. **`OverdueReminderUseCase.execute()`**:
   - Scans for overdue items and posts an overdue summary notification (max 1/day).
5. **`ReminderSchedulingService.resynchronizeAll()`**:
   - Self-healing sweep: reconciles OS alarms with SQLite database, advances recurring items, and schedules any missed slots.
