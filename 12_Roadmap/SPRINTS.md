# AURA — Development Roadmap (Sprints)

> **Version:** 1.0
> **Phase:** 7 — Development Roadmap
> **Status:** Ready for Phase 8 execution
> **Last Updated:** 2026-07-24

This is the sprint-by-sprint implementation plan for Phase 8 (AI Coding).
Each sprint is 1 week. Each sprint has a clear goal, deliverables, and definition of done.

---

## Phase 8 Entry Checklist

Before writing a single line of code, verify all of these are complete:

- [x] Phase 0 — Vision (VISION.md, PRINCIPLES.md)
- [x] Phase 1 — Product Discovery (01_Product/discovery.md)
- [x] Phase 2 — PRD (02_PRD/PRD.md v0.3)
- [x] Phase 3 — UX Design (03_UX/ — design system + 7 wireframes + 8 flows)
- [x] Phase 4 — System Architecture (04_Architecture/ARCHITECTURE.md)
- [x] Phase 5 — AI Architecture (05_AI/AI_ARCHITECTURE.md)
- [x] Phase 6 — Database Design (06_Database/SCHEMA.md)
- [x] Phase 7 — This document

**All checked. Phase 8 can begin.**

---

## Sprint Overview

| Sprint | Focus | Milestone |
|--------|-------|-----------|
| S1 | Flutter project setup + DB + core structure | App runs, DB initialized |
| S2 | Home screen + navigation + design system | Home screen matches wireframe |
| S3 | Voice capture pipeline (orb + STT + overlay) | Can speak and see transcript |
| S4 | Gemini integration + confirmation box | Full voice → task flow works |
| S5 | Workspace system (CRUD + sections) | Workspaces fully functional |
| S6 | Reminders + DND replay (F-07, F-08) | Reliable notifications firing |
| S7 | Task detail screen + search | Task management complete |
| S8 | Morning briefing (F-10) + proactive nudges (F-11) | Daily AI briefing working |
| S9 | Share-to-AURA: screenshot + link (F-09) | Share target functional |
| S10 | Onboarding (F-15) + settings (F-16) + recurring tasks (F-12) | App is feature-complete |
| S11 | Polish: animations, haptics, offline edge cases | Premium feel achieved |
| S12 | Real-world daily driver testing | Phase 9 begins |

---

## Sprint 1 — Foundation

**Goal:** Flutter project scaffolded with Clean Architecture, Drift DB initialized, CI running.

### Tasks

- [ ] `flutter create aura` with package name `com.aura.app`
- [ ] Add all dependencies from ARCHITECTURE.md pubspec.yaml section
- [ ] Scaffold folder structure (lib/core/, lib/features/, lib/database/, lib/platform/)
- [ ] Implement `core/constants/` — colors.dart, typography.dart, spacing.dart
- [ ] Implement `AppDatabase` with all 12 Drift tables (SCHEMA.md)
- [ ] Implement all DAOs: TaskDao, WorkspaceDao, ReminderDao, EventDao, NotificationDao
- [ ] Set up Riverpod: DatabaseProvider, DAO providers
- [ ] Set up go_router with all routes defined (empty screens as placeholders)
- [ ] Set up Flutter themes (dark + light) matching design system colors
- [ ] Set up Space Grotesk via google_fonts
- [ ] Write database smoke tests (insert → query → verify)
- [ ] Set up flutter_lints with project rules

**Definition of Done:**
- `flutter run` launches without crash
- DB initializes and all tables created
- Theme colors match design_system.md exactly
- Route `/` shows placeholder Home screen

---

## Sprint 2 — Home Screen

**Goal:** Home screen built to wireframe spec. Bento grid, all cells, navigation.

### Tasks

- [ ] Implement `BentoCard` widget (design system spec: border, shadow, 0 radius)
- [ ] Implement `TaskCard` widget (priority stripe, title, deadline chip, checkbox)
- [ ] Implement `DeadlineCountdownChip` widget (green/amber/red by time remaining)
- [ ] Implement `WorkspaceChip` widget (emoji + name + count)
- [ ] Implement `PriorityBadge` widget (HIGH/MEDIUM/LOW)
- [ ] Build `HomeScreen` with bento layout (URGENT + ORB + FOCUS + NEXT UP + HABITS + WORKSPACES)
- [ ] Connect URGENT cell to `watchOverdue()` DAO stream
- [ ] Connect HABITS cell to recurring tasks stream
- [ ] Connect WORKSPACES cell to workspace list stream
- [ ] Implement bottom navigation (4 tabs: Home, Calendar, Workspaces, Settings)
- [ ] Implement stagger animation on home screen load (cells slide up + fade in, 40ms delay)
- [ ] Implement cell tap animations (scale 0.97 + shadow shrink)
- [ ] Add empty state designs for each bento cell
- [ ] Add loading shimmer states

**Definition of Done:**
- Home screen matches wireframe `01_home_screen.md` exactly
- All bento cells animate on load
- Navigation between tabs works
- No hardcoded colors (all from constants)

---

## Sprint 3 — Floating Orb + Voice Overlay

**Goal:** Floating orb appears over all apps. Tapping it shows voice capture popup.

### Tasks

**Android (Kotlin):**
- [ ] Implement `AuraOverlayService.kt` — WindowManager overlay, foreground service
- [ ] Handle SYSTEM_ALERT_WINDOW permission request flow
- [ ] Save orb position to SharedPreferences on drag end
- [ ] Implement BOOT_COMPLETED receiver to restart service on reboot
- [ ] Implement `AuraSpeechChannel.kt` — SpeechRecognizer bridge
  - [ ] startListening() / stopListening() MethodChannel handlers
  - [ ] Partial results EventChannel (live transcript)
  - [ ] Audio level EventChannel (for waveform animation)
  - [ ] Error handling (permission denied, no speech input)

**Flutter (Dart):**
- [ ] Implement `OverlayChannel` Dart wrapper
- [ ] Implement `SpeechChannel` Dart wrapper
- [ ] Implement `VoiceCaptureOverlay` widget:
  - [ ] 35% height compact popup (slide up animation)
  - [ ] Semi-transparent scrim over background app
  - [ ] Mini orb with glow (exact spec from design system)
  - [ ] LISTENING label (lime, animated)
  - [ ] Waveform widget (lime bars, driven by audioLevel EventChannel)
  - [ ] Live transcript text (updates in real-time)
  - [ ] Context hint text (below transcript)
  - [ ] "Type instead" link (switches to text input mode)
  - [ ] "STOP & PROCESS →" button (lime CTA)
  - [ ] Cancel (✕) button
- [ ] Implement text fallback mode (keyboard input)
- [ ] Implement `CaptureProvider` state machine (IDLE → LISTENING → PROCESSING → CONFIRMING)

**Definition of Done:**
- Orb visible on home screen AND on top of other apps (overlay)
- Tapping orb shows voice popup with live waveform
- Transcript updates in real-time as user speaks
- Auto-stops after 1.5s silence

---

## Sprint 4 — Gemini Integration + Confirmation Box

**Goal:** Complete voice → AI → confirm → save to DB flow.

### Tasks

- [ ] Implement `GeminiApiDataSource` (HTTP client for Gemini 2.0 Flash)
  - [ ] System prompt from AI_ARCHITECTURE.md Agent 1
  - [ ] Request/response models (IntentResult)
  - [ ] 8-second timeout
  - [ ] 1 retry on failure
  - [ ] Rate limiter (12 req/min max)
- [ ] Implement `IntentExtractorUseCase`
- [ ] Implement `WorkspaceRouterUseCase` (local, no API call)
- [ ] Implement `OfflineQueue` — save transcript when offline, process on reconnect
- [ ] Implement `ConnectivityProvider` (connectivity_plus stream)
- [ ] Implement `ConfirmationBox` widget:
  - [ ] All field rows (title, deadline, reminders, workspace, priority, recurring)
  - [ ] Confidence indicators (amber dot + badges per AI_ARCHITECTURE.md)
  - [ ] Inline field editing (tap field → edit)
  - [ ] CONFIRM & SAVE button (lime CTA)
  - [ ] EDIT ALL button → full edit mode
  - [ ] Start over link
- [ ] Implement `CreateTaskUseCase` (inserts task + reminders in DB transaction)
- [ ] Implement `AiActionsLogDao.insert()` on every confirm
- [ ] Implement success feedback: orb green flash + haptic (HapticFeedback.mediumImpact)
- [ ] Handle offline: queue transcript → show "saved as draft" message
- [ ] Test with real voice input (Indian English accent)

**Definition of Done:**
- Full flow works: tap orb → speak → AI parses → confirm box shows → save to DB
- Confidence indicators display correctly
- Offline capture queued and processed when back online
- Success feedback feels satisfying (animation + haptic)

---

## Sprint 5 — Workspace System

**Goal:** Workspace list, detail, sections, CRUD all working.

### Tasks

- [ ] Implement `WorkspaceScreen` (grid of workspace cards)
- [ ] Implement `WorkspaceCard` widget (emoji, name, stats, border, shadow)
- [ ] Implement `WorkspaceDetailScreen` (stats bento + section tabs + task list)
- [ ] Implement section tabs (lime selected / muted unselected)
- [ ] Implement `CreateWorkspaceScreen` (name + emoji picker + color picker + preview)
- [ ] Implement `WorkspaceDao`: CRUD + archive + watch all
- [ ] Implement `WorkspaceSectionDao`: CRUD + archive + watch by workspace
- [ ] Implement auto-workspace-creation from confirmation box (create on confirm)
- [ ] Implement workspace filtering on home screen (WORKSPACES cell chips)
- [ ] Empty state per workspace
- [ ] Long-press → context menu (Edit / Archive)

**Definition of Done:**
- User can create, view, edit, and archive workspaces
- Section tabs work and filter task list
- Auto-created workspaces from AI appear correctly
- Bento card style exactly matches design system

---

## Sprint 6 — Reminders + DND Replay

**Goal:** Reliable notification delivery. DND replay working. (F-07, F-08)

### Tasks

- [ ] Implement `NotificationService` — flutter_local_notifications setup
  - [ ] 3 channels: AURA_REMINDERS, AURA_BRIEFING, AURA_NUDGES
  - [ ] Notification actions: "Mark Done", "Snooze"
  - [ ] Tapping notification → deep link to task detail
- [ ] Implement `ScheduleReminderUseCase` — WorkManager one-time tasks
- [ ] Implement `CancelReminderUseCase`
- [ ] Implement snooze behavior:
  - [ ] Snooze picker (30min / 1hr / Tonight 9PM / Tomorrow 8AM / Custom)
  - [ ] Reschedule reminder with new fire_at
- [ ] Implement "Mark Done" from notification (update task status via WorkManager task)
- [ ] Implement `AuraDNDReceiver.kt` (BroadcastReceiver for DND changes)
- [ ] Implement `ReplayDndNotificationsUseCase`:
  - [ ] Query missed DND reminders from notification_log
  - [ ] Reword time-sensitive items (">2 hrs ago" → contextual message)
  - [ ] Send batch summary notification
- [ ] Implement overdue notification (1/day max, task past deadline)
- [ ] Test: reminder fires at exact time
- [ ] Test: DND → reminder missed → DND off → replay fires

**Definition of Done:**
- Reminders fire at correct time even when app is killed
- DND replay fires correctly when DND lifts
- Mark Done from notification updates task in DB

---

## Sprint 7 — Task Detail + Search

**Goal:** Task detail screen fully functional. Search works across all content.

### Tasks

- [ ] Implement `TaskDetailScreen` (header, quick stats, deadline, reminders, tabs)
- [ ] Implement 4 detail tabs: Details, Subtasks, Notes, Attachments
- [ ] Implement subtask list + completion
- [ ] Implement inline field editing (tap any field to edit)
- [ ] Implement `MARK AS DONE` with animation (strikethrough + green flash + haptic)
- [ ] Implement `SNOOZE REMINDER` action bar button
- [ ] Implement 10-second undo after mark done
- [ ] Implement task options menu (Share / Duplicate / Move / Delete)
- [ ] Implement soft delete (deleted_at) + confirmation dialog
- [ ] Implement `SearchScreen`:
  - [ ] Instant search (Drift FTS or LIKE query)
  - [ ] Search across: task titles, notes, workspace names, shared_content OCR text
  - [ ] Filter chips: workspace, status, date range
  - [ ] Grouped results: Tasks / Events / Attachments

**Definition of Done:**
- Task detail screen matches wireframe `05_task_detail.md`
- All 4 tabs functional
- Mark done animation matches design system motion spec
- Search returns results within 200ms

---

## Sprint 8 — Morning Briefing + Proactive Nudges

**Goal:** Daily briefing works. Proactive nudges fire intelligently.

### Tasks

- [ ] Implement `GenerateMorningBriefingUseCase`
  - [ ] Query urgent tasks, today's events, habits, upcoming items
  - [ ] Call Gemini for motivational line (Agent 3 prompt from AI_ARCHITECTURE.md)
  - [ ] Fallback to static template if API fails
- [ ] Implement `MorningBriefingScreen` (full screen, all 4 sections)
- [ ] Schedule briefing via WorkManager (periodic, recalculate time weekly)
- [ ] Implement phone unlock time tracking (save to SharedPreferences)
- [ ] Implement late-wake detection (fire at 9 AM if phone not unlocked)
- [ ] Implement DND replay section in briefing (if DND overnight)
- [ ] Implement deep link: notification → `/briefing` route
- [ ] Implement proactive nudge engine (F-11):
  - [ ] Max 3/day
  - [ ] No nudges 11PM–7AM
  - [ ] Nudge types from PRD F-11
  - [ ] WorkManager periodic check every 2 hours

**Definition of Done:**
- Briefing notification fires at correct time
- Briefing screen matches wireframe `06_morning_briefing.md`
- Motivational line is AI-generated (or static fallback)
- Nudges fire correctly (max 3/day, quiet hours respected)

---

## Sprint 9 — Share-to-AURA

**Goal:** AURA appears in Android share sheet. Screenshots and links processed.

### Tasks

- [ ] Register `AuraShareActivity.kt` as Android share target (AndroidManifest.xml)
  - [ ] Handle: image/*, text/plain, text/uri-list, application/pdf
  - [ ] Copy shared file to AURA private storage
- [ ] Implement `ShareReceiveScreen`:
  - [ ] Screenshot: show image + OCR preview + voice capture
  - [ ] Link: show URL + fetch + summary + voice capture
  - [ ] Text: show text + voice capture
- [ ] Implement `OcrDataSource` (ML Kit Text Recognition)
- [ ] Implement `LinkReaderDataSource` (HTML fetch + text extraction)
- [ ] Implement link summarization (Gemini Agent 4)
- [ ] Integrate shared content with confirmation box (pre-fill from OCR + voice)
- [ ] Store result in `shared_content` table + link to created task
- [ ] Implement search on shared_content OCR text

**Definition of Done:**
- AURA appears in Android share sheet
- Sharing a screenshot: OCR runs, AURA asks "what to do", task created with screenshot attached
- Sharing a link: page is read, summary shown, task created with link attached

---

## Sprint 10 — Onboarding + Settings + Recurring Tasks

**Goal:** App is feature-complete. Can be given to a new user.

### Tasks

- [ ] Implement `OnboardingFlow` (4 screens from wireframe `07_onboarding.md`)
  - [ ] Screen 1: Welcome
  - [ ] Screen 2: 3 permissions (sequential, with explanations)
  - [ ] Screen 3: Workspace selection (suggestion chips)
  - [ ] Screen 4: Try It Now (live demo with orb)
- [ ] Show onboarding only on first launch (SharedPreferences flag)
- [ ] Implement `SettingsScreen` (all settings from PRD F-16)
  - [ ] Notifications: briefing time, nudges, DND replay
  - [ ] Workspace management
  - [ ] Reminder defaults
  - [ ] Appearance: dark/light/system
  - [ ] Privacy: view AI log, export data, clear data
- [ ] Implement recurring task midnight reset (WorkManager)
- [ ] Implement `DailyLog` write on recurring task completion/miss
- [ ] Implement makeup prompt in morning briefing for missed recurring tasks
- [ ] Implement gentle roast notification for missed recurring tasks

**Definition of Done:**
- First-time launch shows onboarding
- All settings save and persist
- Recurring tasks reset at midnight
- App is usable end-to-end by a new user

---

## Sprint 11 — Polish

**Goal:** AURA feels premium. Every interaction is satisfying.

### Tasks

- [ ] Audit ALL animations against motion spec in design_system.md
- [ ] Add haptic feedback to every primary action
- [ ] Fix any missing empty states or loading states
- [ ] Fix all edge cases identified during Sprints 1–10
- [ ] Performance audit:
  - [ ] App cold start < 2 seconds
  - [ ] Voice → confirmation < 3 seconds
  - [ ] Task list scrolls at 60fps (no jank)
- [ ] Memory leak audit (dispose controllers, cancel streams)
- [ ] Offline edge case testing:
  - [ ] Voice capture offline → queued → processed when online
  - [ ] All screens usable offline
- [ ] Review PRD appendix A (out of scope list) — confirm nothing was accidentally built
- [ ] Review PRINCIPLES.md — confirm no principle was violated

**Definition of Done:**
- No animation is missing or stuttering
- All haptics fire correctly
- Cold start < 2 seconds
- No crashes in 30 minutes of daily use

---

## Sprint 12 — Daily Driver (Phase 9 begins)

**Goal:** Ishant uses AURA as his primary productivity tool for real tasks.

### Tasks

- [ ] Ishant installs APK on personal device
- [ ] Uses AURA daily for 2 weeks minimum
- [ ] Logs every friction point in `10_Testing/daily_driver_log.md`
- [ ] Captures: "this didn't work", "this is confusing", "this felt great"
- [ ] Prioritizes friction log into a v1.1 backlog
- [ ] No new features until daily driver phase is complete

**Definition of Done:**
- 14 consecutive days using AURA as primary productivity tool
- Friction log has ≥ 20 entries
- v1.1 backlog prioritized and ready

---

## Feature → Sprint Mapping

| PRD Feature | Sprint |
|-------------|--------|
| F-01 Floating Orb | S3 |
| F-02 Voice Capture | S3, S4 |
| F-03 Confirmation Box | S4 |
| F-04 Task Creation & Metadata | S4, S7 |
| F-05 Event Creation & Metadata | S4, S7 |
| F-06 Workspace System | S5 |
| F-06a Workspace Sections | S5 |
| F-07 Reminder System | S6 |
| F-08 DND-Aware Notifications | S6 |
| F-09 Share-to-AURA | S9 |
| F-10 Morning Briefing | S8 |
| F-11 Proactive Nudges | S8 |
| F-12 Recurring Tasks | S10 |
| F-13 Timeline & Calendar Views | S2 (basic), S10 (full) |
| F-14 Search | S7 |
| F-15 Onboarding | S10 |
| F-16 Settings | S10 |
| F-17 Design System | S1, S2 |

---

*Roadmap v1.0 — 2026-07-24*
*Phase 7 complete. ALL pre-coding phases done.*
*Phase 8 (AI Coding) begins with Sprint 1.*
