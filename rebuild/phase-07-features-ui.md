# Phase 7: Presentation & Feature UI Screens

> **Authority Document:** [`overhaul-docs/06-features/`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/06-features/)  
> **Status:** Pending Execution  

---

## Phase Overview

Phase 7 builds all user-facing presentation layers in Flutter: the Daily Cockpit Bento Grid, Voice Capture Overlay with real-time audio waveform, Workspaces Kanban board, Alarms and Reminders screens, Morning Briefing digest, Settings, 5-step Onboarding wizard, and Share Target ingestion screen.

---

## Sprint Breakdown

### Sprint 7.1: UI Primitives & App Shell Navigation
**Objective:** Build reusable neo-brutalist widgets and bottom navigation shell.

#### Tasks:
- [ ] **Task 7.1.1: Core Primitives (`lib/core/widgets/`)**
  - `BentoCard`: Rounded 16dp container, `bgCard` fill, `border` outline, optional accent glow.
  - `GlassmorphicContainer`: `BackdropFilter(sigma: 12)`, semi-transparent surface.
  - `AuraButton`: Primary, secondary, outline, and destructive button states with haptic feedback.
  - `AuraChip`: Workspace tag and priority chip (`#FF6B6B`, `#FBBF24`, `#34D399`).
- [ ] **Task 7.1.2: App Shell & Bottom Navigation (`lib/app_shell.dart`)**
  - Persistent bottom navigation bar with Lucide icons: Home (`LayoutGrid`), Workspaces (`FolderTree`), Alarms (`AlarmClock`), Notes (`FileText`), Settings (`Settings`).
  - Floating center action button or orb integration.

---

### Sprint 7.2: Home Screen Bento Cockpit & Day Agenda
**Objective:** Implement `lib/features/home/` with Bento Grid and timeline agenda.

#### Tasks:
- [ ] **Task 7.2.1: Date Navigator & Greeting Header**
  - Dynamic time-aware greeting (`Good morning / afternoon / evening, Ishan`).
  - Horizontal date strip allowing past/future date switching with auto-center on "Today".
- [ ] **Task 7.2.2: Bento Grid Status Modules**
  - Quick Stats Bento: Completed vs pending count with progress ring.
  - Next Up Bento: Highest priority upcoming item countdown.
  - Proactive Nudge Bento: Contextual smart suggestion card.
- [ ] **Task 7.2.3: Overdue Triage Banner**
  - Appears when overdue tasks exist; 1-tap reschedule or bulk triage.
- [ ] **Task 7.2.4: Day Agenda Timeline View**
  - Chronological hourly timeline of timed events/reminders.
  - Separate "Anytime Today" checklist section.

---

### Sprint 7.3: Voice Capture Overlay & Confirmation Cards
**Objective:** Implement `lib/features/capture/` floating translucent activity and confirmation card.

#### Tasks:
- [ ] **Task 7.3.1: Voice Capture Screen (`/capture-overlay`)**
  - Translucent blurred backdrop (`AuraCaptureActivity`).
  - Animated pulsing microphone orb.
  - Real-time RMS audio waveform visualizer driven by `aura/speech/audioLevel`.
  - Live partial transcript streaming text.
- [ ] **Task 7.3.2: Editable Confirmation Card**
  - Rendered post-intent extraction before any DB write (Principle 4: Human-in-the-loop).
  - Editable fields: Title, Intent Type chip, Workspace selector, Date/Time picker, Priority toggle.
  - Action buttons: "Confirm & Schedule" and "Discard".

---

### Sprint 7.4: Workspaces & Kanban Management
**Objective:** Implement `lib/features/workspaces/` workspace browser and section columns.

#### Tasks:
- [ ] **Task 7.4.1: Workspace List Screen**
  - Grid of workspace cards displaying custom color hex, Lucide icon, active task count.
  - "New Workspace" modal with color picker and icon picker.
- [ ] **Task 7.4.2: Workspace Detail & Kanban Board**
  - Column sections (`Todo`, `In Progress`, `Done`, or custom).
  - Drag-and-drop or 1-tap section moving.
  - Cascading archive and soft-delete actions.

---

### Sprint 7.5: Alarms, Reminders & Snooze Sheets
**Objective:** Implement `lib/features/alarms/` and `lib/features/reminders/`.

#### Tasks:
- [ ] **Task 7.5.1: Alarms Screen & AlarmCard**
  - Alarm toggles, repeat day selectors (Mon-Sun chips), custom sound selector (`pickAlarmSound`).
  - Full-screen alarm ringing modal with large Dismiss and Snooze buttons.
- [ ] **Task 7.5.2: Reminders Screen**
  - Grouped by Today, Upcoming, Someday.
  - Relative time countdown badges.
- [ ] **Task 7.5.3: Snooze Bottom Sheet**
  - Quick presets: "+10 Min", "+30 Min", "+1 Hour", "Tonight (8 PM)", "Tomorrow Morning (9 AM)".

---

### Sprint 7.6: Morning Briefing, Settings, Onboarding & Share Target
**Objective:** Implement remaining utility and onboarding screens.

#### Tasks:
- [ ] **Task 7.6.1: Morning Briefing Screen (`/briefing`)**
  - Daily schedule digest, weather summary placeholder, high-priority alarm review, 1-tap "Start My Day".
- [ ] **Task 7.6.2: Settings Screen (`/settings`)**
  - BYOK API Key configuration (Gemini / Groq / OpenRouter / Ollama).
  - Theme mode (Dark / Light) and Accent selector (6 variants).
  - Floating orb overlay toggle with permission status.
  - Full Data Export (`.json`) & Cascading Factory Reset.
- [ ] **Task 7.6.3: 5-Step Onboarding Wizard (`/onboarding`)**
  - Welcome $\rightarrow$ Persona/Workspaces Setup $\rightarrow$ System Permissions $\rightarrow$ Voice Tutorial $\rightarrow$ Done.
- [ ] **Task 7.6.4: Share Target Screen (`/share`)**
  - Ingests shared text, URLs, and images.
  - On-device Latin OCR preview via Google ML Kit.
  - "Add voice note to share" record button.

---

## Phase 7 Acceptance Criteria & Verification

1. All screens render in dark theme without rendering overflow errors.
2. Voice capture overlay opens in under $100\text{ms}$ with smooth audio waveform.
3. Interactive widget tests pass for BentoCard, ConfirmationCard, and AlarmCard.
