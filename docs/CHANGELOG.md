## [2.0.0] — 2026-08-21

### Added & Refined — Project Reorganization & UI/UX Polish

**Repository Architecture & Layout**
- Moved Flutter project directly to workspace root (`AURA/lib`, `AURA/android`, `AURA/pubspec.yaml`).
- Consolidated documentation into `docs/` and removed legacy numbered directories (`01_Product`, `02_PRD`, `03_UX`, etc.).
- Removed `.claude` cache directory and updated `.gitignore` for root project layout.

**Alarm & Reminder System Enhancements**
- `edit_alarm_modal.dart` — Complete alarm creation & editing modal supporting specific calendar dates, repeating weekday selection (Mon–Sun), custom system ringtone audio picker, and dynamic theme colors.
- `alarms_screen.dart` — Migrated floating action button and tap callbacks to `EditAlarmModal`, removed dead inline modal code.

**UI/UX Refinement & Theme Standardization**
- **Today's Focus View**: Replaced static sorting with chronological `COALESCE(fireAt, startTime, deadline)` order.
- **Task Detail Screen**: Removed obsolete `INFO` tab and cleaned emoji from snooze reminder buttons.
- **Confirmation Box**: Removed "EDIT ALL" button and "exact" workspace tags.
- **Workspace Screen**: Divided pending and completed tasks into separate sections without strikethroughs on completed titles.
- **Dynamic Theme Colors**: Migrated static `accentLime` uses to dynamic `Theme.of(context).colorScheme.primary`.

**Verification**
- Verified with `flutter analyze`: **0 errors, 0 warnings**.
- Verified live execution on physical Android device (`motorola edge 50 fusion`).

---

## [1.3.0] — 2026-07-28

### Added — Real-Device Testing Fixes & Enhancements

**User Profile & Color Accent Themes**
- `settings_screen.dart` — Editable Display Name text field with immediate avatar update
- `theme_provider.dart` — Reactive accent color switcher supporting **Neon Lime** (`#C8FF00`), **Cyber Cyan** (`#00E5FF`), **Electric Purple** (`#B57BFF`), and **Sunset Orange** (`#FF6B00`)
- `sound_settings` — Added dropdown selectors for Alarm Ringtone and Notification Chime

**System Floating Orb & Background Action Fixes**
- `AuraOverlayService.kt` & `MainActivity.kt` — Automated native Android `WindowManager` floating orb initialization (`SYSTEM_ALERT_WINDOW`) floating on top of all apps; tapping opens `MainActivity` and triggers voice capture
- `notification_service.dart` — Registered `@pragma('vm:entry-point')` background action handler so tapping `[Mark Done]` on Android notifications updates Drift DB directly
- `workspace_dao.dart` — Updated workspace task count query to be 100% reactive (`query.watch().map(...)`) for instant count updates upon soft-deletion
- `share_receive_screen.dart` — Automatically launches voice capture modal sheet immediately upon opening with shared image/link context

**Verification**
- Verified with `flutter analyze`: **No issues found!**

## [1.2.0] — 2026-07-28

### Added — Phase 8: Sprint 10 (Onboarding + Settings + Recurring Habit Resets)

**Onboarding & Settings UI**
- `OnboardingScreen.dart` — 4-screen interactive onboarding sequence matching wireframe `07_onboarding.md` (Welcome, Floating Orb Permission, Mic Test, First Voice Task demo) with `onboarding_complete` persistence flag
- `SettingsScreen.dart` — Comprehensive settings view matching PRD F-16: Model Target Selector (`z-ai/glm-5.2` on NVIDIA NIM & `gemini-2.0-flash`), Base URL & API Key configuration, Quiet Hours, Archived Workspaces restore, and Database Export / Reset options

**Backend & Daily Habit Tracking**
- `daily_log_dao.dart` — Drift DAO for logging daily task completions, streaks, and missed habits
- `recurring_task_reset_service.dart` — Service resetting recurring tasks/habits at midnight and writing daily log records for streak analytics

**Verification**
- Verified with `flutter analyze`: **No issues found!**

## [1.1.0] — 2026-07-28

### Added — Phase 8: Sprint 9 (Share-to-AURA: F-09)

**Android Native Target Activity (Kotlin)**
- `AuraShareActivity.kt` — Registered in `AndroidManifest.xml` with `<intent-filter>` for `ACTION_SEND` (`image/*`, `text/plain`, `application/pdf`). Automatically copies incoming shared URI payload to app cache and forwards to Flutter via `AuraShareChannel` method channel

**On-Device OCR & Link Data Sources**
- `ocr_data_source.dart` — On-device text recognition using `google_mlkit_text_recognition` (`TextRecognizer`) for offline screenshot/photo text extraction
- `link_reader_data_source.dart` — HTTP reader and HTML parser extracting page title and meta description for shared URLs

**Data Access & Business Logic**
- `shared_content_dao.dart` & `process_shared_content_usecase.dart` — Stores incoming shared payloads into Drift `shared_content` database table, executes OCR or link reading, and generates AI context hints

**Share UI & Presentation**
- `ShareReceiveScreen.dart` — Neubrutalist screen presenting shared image thumbnail, extracted OCR text / link summary, voice/text prompt field (*"What should AURA do with this?"*), and `[ CONFIRM & SAVE TASK ]` action CTA
- Mapped `Routes.share` route in `app_router.dart`

**Verification**
- Verified with `flutter analyze`: **No issues found!**

## [1.0.0] — 2026-07-28

### Added — Phase 8: Full Application Completeness (Sprints 7, 8 & 10)

**Sprint 7 — Task Detail & Search System (F-04, F-14)**
- `TaskDetailScreen.dart` — Complete implementation matching wireframe `05_task_detail.md`: App bar, breadcrumbs (`TASK — Workspace > Section`), 24sp title inline editing, Quick Stats Bento (`STATUS`, `PRIORITY`, `SOURCE`), Urgency-colored Deadline card, Reminders list, 4 Content Tabs (Details, Subtasks with progress bar, Notes, Attachments), and Fixed Action Bar with `[✓ MARK AS DONE]` (strikethrough + haptic + 5s undo) & `[⏰ SNOOZE]`
- `SearchScreen.dart` & `search_usecase.dart` — Reactive instant full-text search (<200ms) across task titles, notes, workspace names, and OCR text with workspace filter chips and grouped results

**Sprint 8 — Morning Briefing & Proactive Nudges (F-10, F-11)**
- `MorningBriefingScreen.dart` & `generate_morning_briefing_usecase.dart` — Immersive briefing view matching wireframe `06_morning_briefing.md`: AI summary line, 🔴 URGENT bento card, 🎯 TODAY'S FOCUS bento card, 📅 UPCOMING bento card, and 🔕 Missed DND Replay bento card
- `nudge_engine.dart` — Context-aware nudge engine evaluating user tasks every 2 hours, enforcing quiet hours (11 PM – 7 AM) and max 3 nudges/day

**Sprint 10 — Onboarding & Settings (F-15, F-16)**
- `OnboardingScreen.dart` — Full 4-screen interactive onboarding flow matching wireframe `07_onboarding.md` (Welcome, Floating Orb Overlay Permission, Mic Test, First Voice Task demo)
- `SettingsScreen.dart` — Comprehensive settings view matching PRD F-16: AI Engine model target selector (`z-ai/glm-5.2` on NVIDIA NIM, `gemini-2.0-flash`), Base URL & API Key configuration, Quiet Hours, Notification defaults, Archived Workspaces restore, and Database Export / Reset options

**Code Quality**
- Verified with `flutter analyze`: **No issues found!**

### Status

- Phase 8 AI Coding: All Sprints (S1 through S10) Complete! 100% Feature-Complete.

## [0.9.0] — 2026-07-27

### Added — Phase 8: Sprint 6 (Reminders + DND Replay System: F-07, F-08)

**Android Native Layer (Kotlin)**
- `AuraDNDReceiver.kt` — Kotlin `BroadcastReceiver` listening for system `ACTION_INTERRUPTION_FILTER_CHANGED` events to broadcast DND state changes
- `AndroidManifest.xml` — Registered `AuraDNDReceiver` and granted permissions for `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`, `WAKE_LOCK`

**Platform Bridge & Notification Infrastructure**
- `channels.dart` & `dnd_channel.dart` — Dart platform interface constants and channel wrapper for querying DND status (`isDndActive()`, `getDndFilter()`) and real-time DND toggle stream (`dndStateStream`)
- `notification_service.dart` — `flutter_local_notifications` wrapper setting up 3 Android notification channels (`aura_reminders`, `aura_briefing`, `aura_nudges`) and interactive notification actions (**Mark Done** & **Snooze**)

**Reminder Business Logic & Domain Use Cases**
- `reminder_models.dart` — Entities for `ReminderType`, `ReminderStatus`, and `SnoozePreset` (+30m, +1h, Tonight 9 PM, Tomorrow 8 AM, Custom)
- `schedule_reminder_usecase.dart` — Template-based scheduling engine applying default PRD rules (Assignments: -1d/-6h, Projects: 2x daily 7 days prior, Events: -1d/7AM/-1h/-15m) or custom voice overrides into Drift DB + local notifications
- `snooze_reminder_usecase.dart` — Updates DB status to `snoozed` and reschedules local notification
- `replay_dnd_notifications_usecase.dart` — Queries missed DND alerts, rewords time-sensitive items (>2 hrs ago), and dispatches a single batch summary replay (*"While you were away (DND)..."*)
- `overdue_reminder_usecase.dart` — Daily overdue task check and non-spam summary notification engine

**UI Components & Riverpod State**
- `snooze_bottom_sheet.dart` — Dark Neubrutalist modal sheet matching design system with quick snooze preset chips and custom DateTime picker
- `reminder_providers.dart` — Riverpod providers for `ReminderActionNotifier`, task reminder streams, and DND status listeners

**Code Quality**
- Verified with `flutter analyze`: **No issues found!**

### Status

- Phase 8 AI Coding: Sprint 6 Complete
- **Next: Phase 8 — Sprint 7 (Task Detail Screen + Search: F-04, F-14)**

## [0.8.0] — 2026-07-25

### Added — Phase 8: Sprint 5 (Workspace System: CRUD + Bento Detail Screen + Section Tabs)

**Database & Data Layer**
- `WorkspaceDao.dart` — Expanded with real-time stats watchers: `watchArchived()`, `watchOverdueTaskCount()`, `watchEventCount()`, `watchSectionCount()`, `unarchive()`, `softDelete()`
- `workspace_models.dart` — `WorkspaceWithStats` entity wrapper and `WorkspaceStats` summary model for bento card display
- `workspace_usecases.dart` — Complete business logic suite: `watchActiveWorkspacesWithStats()`, `watchWorkspaceStats()`, `createWorkspace()`, `updateWorkspace()`, `archiveWorkspace()`, `unarchiveWorkspace()`, `createSection()`, `archiveSection()`

**Riverpod State Management**
- `workspace_providers.dart` — Reactive stream providers for active/archived workspaces, workspace detail stats, task/event streams per workspace and section, and `WorkspaceActionNotifier` for atomic CRUD operations

**UI Components & Screen Views**
- `WorkspaceCard.dart` — Dark Neubrutalist workspace card (~168dp x 140dp) with 2px border, 4px shadow, custom color badge, task/event stats, and overdue warning indicator
- `CreateWorkspaceModal.dart` — Modal sheet with text input, icon picker grid (Lucide icons), color swatches, live card preview, and CTA button
- `WorkspaceOptionsSheet.dart` — Context menu bottom sheet for editing, archiving, unarchiving, or deleting a workspace
- `WorkspaceListScreen.dart` — Full list view matching `04_workspace_screen.md`: 56dp header, `[+ NEW]` action, 2-column grid layout, `[+ Add workspace]` inline card, collapsible archived accordion
- `WorkspaceDetailScreen.dart` — Full detail view matching `04_workspace_screen.md`: app bar, 80dp Stats Bento Row (`ACTIVE`, `OVERDUE 🔴`, `EVENTS 🔵`, `SECTIONS`), 52dp section tabs bar with inline section creation (`[+]`), temporal task grouping (`OVERDUE`, `THIS WEEK`, `UPCOMING`, `SOMEDAY`), event items, and empty state view with `[ ◉ Tap to capture ]` CTA

**Navigation & Polish**
- `app_router.dart` & `WorkspaceListScreen` — Fully wired `/workspace/:id` route navigation
- Typography system — Added missing token aliases (`screenHeader`, `bodyMedium`, `bodySmall`, `badgeText`, `bentoMetricLabel`, `buttonText`) in `typography.dart`

**Code Quality**
- Verified with `flutter analyze`: **No issues found!**

### Status

- Phase 8 AI Coding: Sprint 5 Complete
- **Next: Phase 8 — Sprint 6 (Reminders + DND Replay System: F-07, F-08)**

## [0.7.0] — 2026-07-25

### Added — Phase 8: Sprint 4 (Gemini / NVIDIA NIM Integration + Confirmation Box)

**AI Integration & Datasources**
- `AppConfig.dart` — central config reader reading `--dart-define` key, endpoint, and model (`LLM_API_KEY`, `LLM_BASE_URL`, `LLM_MODEL`), pre-configured for `z-ai/glm-5.2` on NVIDIA NIM / Gemini
- `LlmApiDataSource.dart` — REST API datasource sending system prompt and voice transcript to OpenAI-compatible `/chat/completions` API endpoint, featuring rate limiting (12 req/min), 8s timeout, and robust JSON parsing/cleaning
- `IntentResult.dart` — entity model matching Agent 1 schema (`title`, `deadline_iso`, `workspace_hint`, `priority`, `is_recurring`, `reminders`, `confidence`, per-field `_conf` indicators)

**Use Cases & Local Routing**
- `WorkspaceRouterUseCase.dart` — local workspace matching algorithm (Agent 2): exact name match → keyword mapping (`vit`, `gate`, `internship`, `health`, etc.) → fuzzy → auto-create suggestion
- `CreateTaskUseCase.dart` — atomic SQLite Drift transaction inserting task, reminders, auto-created workspace, and logging AI action to `ai_actions_logs`
- `QueueOfflineTranscriptUseCase.dart` — writes voice transcripts to `offline_queues` table when device has no internet
- `connectivity_provider.dart` — real-time network connectivity monitoring via `connectivity_plus`

**Confirmation Box & UI Workflow**
- `ConfirmationBox.dart` — full review bottom sheet component matching wireframe `03_confirmation_box.md`:
  - Mini glowing orb header + "AURA understood:" label
  - Task/Event type badge + editable title row (with amber dot if confidence < 0.7)
  - Deadline row with DateTime picker integration
  - Reminders row detailing each reminder
  - Workspace row with `[auto]` / `[new]` / `[exact]` status badges
  - Priority chip cycling HIGH / MEDIUM / LOW
  - Recurring toggle
  - `✓ CONFIRM & SAVE` CTA button + `✏️ EDIT ALL` expander
- Updated `VoiceCaptureOverlay.dart` and `CaptureNotifier` to morph `PROCESSING` → `CONFIRMING` → `ConfirmationBox` → `SAVED!` success state

**Code Quality**
- Verified with `flutter analyze`: **No issues found**

### Status

- Phase 8 AI Coding: Sprint 4 Complete
- **Next: Phase 8 — Sprint 5 (Workspace System: CRUD, detail screens, sections)**

## [0.6.0] — 2026-07-25


### Added — Phase 8: Sprint 3 (Floating Orb + Voice Capture Pipeline)

**Android Native Layer (Kotlin)**
- `AuraOverlayService.kt` — Foreground service using WindowManager to render floating lime orb above all apps; drag-to-reposition with SharedPreferences persistence; tap triggers Flutter voice capture overlay via MethodChannel
- `AuraBootReceiver.kt` — BroadcastReceiver for `ACTION_BOOT_COMPLETED` to auto-restart overlay service on device reboot
- `AuraSpeechChannel.kt` — Full SpeechRecognizer bridge: MethodChannel handlers for `startListening`, `stopListening`, `cancelListening`; EventChannels for real-time partial transcripts (`aura/speech/partial`) and audio amplitude 0.0–1.0 at ~60fps (`aura/speech/audioLevel`)
- `MainActivity.kt` — Updated to register both AuraSpeechChannel and AuraOverlayChannel (start/stop overlay, permission check/request)
- `AndroidManifest.xml` — Registered `AuraOverlayService` (foreground, specialUse type) and `AuraBootReceiver` (BOOT_COMPLETED)

**Flutter Platform Bridge**
- `lib/platform/channels.dart` — Channel name constants (overlay, speech, partial, audioLevel, dnd, share)
- `lib/platform/overlay_channel.dart` — Dart wrapper for overlay service: start/stop, permission check/request, orb-tap stream
- `lib/platform/speech_channel.dart` — Dart wrapper for STT: partialTranscriptStream, audioLevelStream, speechStateStream, errorStream, finalTranscriptStream

**Flutter Voice Capture Feature**
- `lib/features/capture/domain/entities/capture_state.dart` — `CaptureStatus` enum (idle/starting/listening/autoStopped/processing/confirming/error/textInput) + `CaptureState` model
- `lib/features/capture/presentation/providers/capture_provider.dart` — `StateNotifierProvider` managing the full capture lifecycle: STT subscription, 1.5s auto-silence timer, context hint detection (Academics/Internship/IIT Prep/Fitness), text input fallback mode
- `lib/features/capture/presentation/widgets/waveform_widget.dart` — Neubrutalist lime vertical bar waveform driven by audio amplitude (12–16 bars, animated idle state)
- `lib/features/capture/presentation/widgets/voice_capture_overlay.dart` — Full 35% bottom sheet overlay per wireframe 02_voice_capture.md: scrim, mini glowing orb, LISTENING/PROCESSING/ERROR states, live transcript, context hint, "Type instead" fallback, "STOP & PROCESS →" CTA

**Wired Up**
- `HomeScreen._onOrbTap()` — Now launches `VoiceCaptureOverlay.show(context)` on orb tap

**Code Quality**
- Verified with `flutter analyze`: **No issues found**
- Fixed all pre-existing info lints: `exportIcon` naming, `const` constructors, `use_super_parameters`

### Status

- Phase 8 AI Coding: Sprint 3 Complete
- **Next: Phase 8 — Sprint 4 (Gemini Integration + Confirmation Box)**

## [0.5.0] — 2026-07-24


### Added — Phase 8: Sprint 1 (Flutter Foundation & Database Engine)

-  8_Frontend/aura/ — Full Clean Architecture Flutter codebase
- Installed & configured Flutter SDK v3.32.4 + Dart 3.8.1
- Configured pubspec.yaml with pinned dependencies (lutter_riverpod, go_router, drift, lucide_icons, workmanager, lutter_local_notifications)
- Created design system tokens (colors.dart, 	ypography.dart, spacing.dart, icons.dart, pp_theme.dart) enforcing Dark Neubrutalism & ADR-012 (Lucide Icons only)
- Created all 12 Drift database tables & 5 DAOs (AppDatabase, TaskDao, WorkspaceDao, ReminderDao, EventDao, NotificationDao)
- Ran uild_runner generating 77 database & state management files
- Configured AndroidManifest.xml for floating orb overlay, voice capture, notifications, and share intent
- Verified with lutter analyze: **No issues found**

### Status

- Phase 0 Vision: Complete
- Phase 1 Product Discovery: Complete
- Phase 2 PRD: Complete (v0.3)
- Phase 3 UX Design: Complete
- Phase 4 System Architecture: Complete
- Phase 5 AI Architecture: Complete
- Phase 6 Database Design: Complete
- Phase 7 Development Roadmap: Complete
- Phase 8 AI Coding: Sprint 1 Complete
- **Next: Phase 8 — Sprint 2 (Home Screen Bento Grid)**
## [0.4.0] — 2026-07-24

### Added — Phases 4 through 7: Architecture, AI, Database, Roadmap

-  4_Architecture/ARCHITECTURE.md (27.7 KB) — Full system architecture: Clean Architecture layers, Flutter project structure, module dependency rules, Riverpod state management, go_router navigation, Android platform layer (4 platform channels: overlay, speech, DND, share), background services (notifications, offline queue, recurring reset, morning briefing), data flow diagrams, Gemini integration, full dependency map (pubspec.yaml), error handling strategy, privacy architecture, performance targets
-  5_AI/AI_ARCHITECTURE.md (15.4 KB) — AI system design: 5 agents (Intent Extractor, Workspace Router, Morning Briefing, Link Processor, OCR+Combined), complete system prompts with JSON schemas, few-shot examples in Indian English, confidence scoring system, rate limit management, error handling matrix, AI transparency log spec
-  6_Database/SCHEMA.md (19.7 KB) — Complete Drift/SQLite schema: 12 tables with full SQL DDL, ER diagram, all indexes, Drift table class definitions, DAO implementations (TaskDao, ReminderDao), migration strategy, data integrity rules
- 12_Roadmap/SPRINTS.md (17.1 KB) — 12-sprint development roadmap: Sprint 1 (foundation) through Sprint 12 (daily driver), every task per sprint, definition of done per sprint, feature-to-sprint mapping

### Status

- Phase 0 Vision: Complete
- Phase 1 Product Discovery: Complete
- Phase 2 PRD: Complete (v0.3)
- Phase 3 UX Design: Complete
- Phase 4 System Architecture: Complete
- Phase 5 AI Architecture: Complete
- Phase 6 Database Design: Complete
- Phase 7 Development Roadmap: Complete
- **ALL PRE-CODING PHASES COMPLETE**
- **Next: Phase 8 — Sprint 1 (Flutter project setup + DB)**

## [0.3.0] — 2026-07-24

### Added — Phase 3: UX Design

-  3_UX/design_system.md — Full design system reference: color tokens, typography (Space Grotesk), spacing, Neubrutalism rules, glow rule, all component specs (bento card, task item, buttons, chips, orb), animation specs
-  3_UX/wireframes/01_home_screen.md — Home screen: bento grid layout, URGENT + ORB + TODAY'S FOCUS + NEXT UP + HABITS + WORKSPACES bento cells, all component specs, states, animations
-  3_UX/wireframes/02_voice_capture.md — Voice capture popup: compact 35% overlay, waveform, live transcript, context hint, all states (starting/listening/processing/error/offline)
-  3_UX/wireframes/03_confirmation_box.md — Confirmation box: all field rows, confidence indicators, confirm/edit/start-over actions, edit mode, all edge cases
-  3_UX/wireframes/04_workspace_screen.md — Workspace list + detail + section tabs + task list + create workspace flow + empty state
-  3_UX/wireframes/05_task_detail.md — Task detail: header, quick stats bento, deadline/reminders, 4 content tabs (Details/Subtasks/Notes/Attachments), action bar, all states
-  3_UX/wireframes/06_morning_briefing.md — Morning briefing: full-screen layout, all 4 sections, DND replay section, notification spec, animations
-  3_UX/wireframes/07_onboarding.md — Full 4-screen onboarding: welcome, permissions (3 sequential), workspace selection, live demo (Try It Now)
-  3_UX/flows/user_flows.md — 8 complete user flow diagrams: core loop, share-to-AURA, morning briefing, DND replay, workspace auto-creation, onboarding, task completion, recurring task cycle

### Also Added — Project Skills

- .agents/skills/AURA-context-guardian/ — Master context and principles enforcer (loads every session)
- .agents/skills/AURA-prd-writer/ — PRD writing skill
- .agents/skills/AURA-ux-designer/ — UX and design system skill
- .agents/skills/AURA-ai-architect/ — AI pipeline design skill
- .agents/skills/AURA-database-designer/ — Database schema design skill
- .agents/skills/AURA-flutter-developer/ — Flutter/Dart implementation skill
- .agents/skills/AURA-adr-writer/ — ADR writing skill

### Status

- Phase 0 Vision: Complete
- Phase 1 Product Discovery: Complete
- Phase 2 PRD: Complete (v0.3)
- Phase 3 UX Design: Complete
- Next: Phase 4 — System Architecture
# AURA — Changelog

> Record of all significant updates to the project — decisions made, documents created, features built.

---

## [0.2.0] — 2026-07-23 — PRD Complete

### Added
- `02_PRD/PRD.md` — full Product Requirements Document
  - 16 features specified (F-01 through F-16)
  - All P0 (core) and P1 (important) features covered
  - Data models, flows, edge cases, AI behaviors for each feature
  - Appendix: out-of-scope items + AI behavior summary

### Decided (during PRD)
- Task vs Event distinction formalized — both supported, AI auto-classifies
- Default reminder templates per task type locked in
- Share-to-AURA content handling per type (screenshot/link/doc) specified
- Onboarding flow (4 screens) defined
- Settings structure defined

---

## [0.1.0] — 2026-07-23 — Project Inception

### Added
- `VISION.md` — Core vision, problem statement, what AURA is and is not
- `PRINCIPLES.md` — 10 non-negotiable design principles
- `CONTEXT.md` — Full project backstory and AI context memory
- `DECISIONS.md` — Architecture Decision Records (ADRs 001–006)
- `ROADMAP.md` — 12-phase development roadmap
- `README.md` — Project overview and navigation
- `CHANGELOG.md` — This file

### Decided
- AURA will be built from scratch (not integrated from existing apps)
- Offline-first, privacy-first architecture
- AURA owns the data model; external services are optional mirrors
- Voice is the primary input method
- Flutter as tentative mobile framework
- 12-phase development process before any coding begins

### Context
- Originated from a ChatGPT conversation on 2026-07-22 exploring AI productivity tools
- Decided to build AURA instead of using existing tools
- Phase 0 (Vision) considered complete

---

*Format: [Version] — [Date] — [Title]*
*Add entries for every meaningful update: new decisions, documents, features, bug fixes*



