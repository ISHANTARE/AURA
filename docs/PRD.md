# AURA — Product Requirements Document (PRD)

> **Version:** 0.1 (MVP)
> **Author:** Ishan T (Product Owner) + Antigravity (Documentation)
> **Last Updated:** 2026-07-23
> **Status:** In Progress — Stage 2

---

## How to Use This Document

This PRD is the single source of truth for what AURA builds.

- Every feature in here gets built. Nothing outside of here gets built without updating this first.
- When starting a coding session in Antigravity: reference the feature section number.
- When a feature's behavior is unclear during coding: the answer is in this doc.
- When you want to add something new mid-build: add it here first, then code it.

---

## Product Summary

AURA is a voice-first, AI-native personal productivity assistant for Android.

**One sentence:** Press one button, speak your thought, AURA organizes your life.

**Core loop:**

```
User sees/hears something important
           ↓
Taps floating AURA orb
           ↓
Speaks naturally
           ↓
AURA extracts intent (AI)
           ↓
Shows confirmation box
           ↓
User confirms with one tap
           ↓
Task / Event / Reminder created
           ↓
AURA proactively reminds and nudges
```

---

## Feature Index

| # | Feature | Priority |
| --- | --------- | --------- |
| F-01 | Floating Orb Button | P0 — Core |
| F-02 | Voice Capture Flow | P0 — Core |
| F-03 | Confirmation Box | P0 — Core |
| F-04 | Task Creation & Metadata | P0 — Core |
| F-05 | Event Creation & Metadata | P0 — Core |
| F-06 | Workspace System | P0 — Core |
| F-06a | Workspace Sections (Sub-directories) | P0 — Core |
| F-07 | Reminder System | P0 — Core |
| F-08 | DND-Aware Notifications | P0 — Core |
| F-09 | Share-to-AURA | P1 — Important |
| F-10 | Morning Briefing | P1 — Important |
| F-11 | Proactive Nudges | P1 — Important |
| F-12 | Recurring Tasks | P1 — Important |
| F-13 | Timeline & Calendar Views | P1 — Important |
| F-14 | Search | P1 — Important |
| F-15 | Onboarding | P1 — Important |
| F-16 | Settings | P2 — Later |
| F-17 | Design System & Visual Language | P0 — Core |

**Priority:**

- P0: Must exist before the app is usable at all
- P1: Must exist before daily driver phase
- P2: Can be added during or after daily driver

---

---

# F-01 — Floating Orb Button

## What It Is

A persistent, always-visible floating button that overlays every app on the phone.
It is the primary entry point for all AURA interactions.

## Appearance

- Shape: Circle (orb)
- Content: AURA logo / icon — premium, glowing, aesthetically designed
- Size: ~56dp diameter (comfortable thumb tap, not intrusive)
- Style: Semi-transparent glass/glow effect. Dark by default.
- State indicators:
  - Default: subtle ambient glow / pulse animation
  - Listening: active glow, pulsing rings (like sound waves)
  - Processing: spinner or thinking animation
  - Success: brief green flash, then returns to default

## Behavior

- Appears on top of all apps (Android overlay permission)
- Fully draggable — user can move it anywhere on screen
- Position persists across:
  - App switches
  - Phone restarts
  - AURA app restarts
- Position is saved to local storage immediately on drag end

## Visibility Control

- Always visible by default
- User can temporarily hide it from within AURA settings
- On phone restart: always reappears at last saved position
- Not visible on: lock screen, always-on display

## Tap Behavior

- Single tap → opens voice capture (F-02)
- Long press → opens quick action menu:
  - "Add task" (goes to voice capture, task mode)
  - "Add event" (goes to voice capture, event mode)
  - "Open AURA" (opens main app)
  - "Hide button" (dismisses orb until next restart or manual re-enable)

## Technical Notes

- Requires `SYSTEM_ALERT_WINDOW` permission (Android overlay)
- Implemented as a persistent Foreground Service to survive app backgrounding
- Position stored in SharedPreferences as x,y floats
- Must survive: phone restart, RAM clearing, battery optimization kill

## Edge Cases

- If overlay permission is revoked: show notification "AURA orb disabled — tap to re-enable"
- If phone is rotated: recalculate position so orb stays in same relative position
- If orb is dragged off-screen: snap it back to nearest edge

---

---

# F-02 — Voice Capture Flow

## What It Is

The core input mechanism. After tapping the orb, user speaks naturally.
AURA transcribes and sends the text to the AI for intent extraction.

## Design Principle — Compact, Non-Intrusive Popup

**Voice capture is NOT a full-screen takeover.**
The orb is a floating overlay tool — the user is always in another app (Gmail, WhatsApp, Chrome, etc.).
The voice capture appears as a **compact bottom popup (~35% screen height)**, leaving the background app fully visible.

**Why:** The most common use case is the user reading something (an email, a WhatsApp message, a job listing) and wanting to capture it. They need to SEE what they're reading while speaking about it.

```
┌─────────────────────────────────────────┐
│  📧 Gmail — Prof. Sharma                │  ← Background app FULLY visible
│                                         │
│  ML Assignment deadline is Friday,      │
│  August 1st at 11:59 PM...              │
│                                         │
├─────────────────────────────────────────┤
│  🟡 LISTENING...     ▁▃▅▃▁▄▆▃    ✕    │  ← AURA compact popup (35% height)
│                                         │
│  "...deadline is Friday August 1st..."  │  ← Live transcript
│  Context: ML Assignment · VIT           │  ← AI context hint
│                                         │
│  [Type instead]  [STOP & PROCESS →]    │
└─────────────────────────────────────────┘
```

## Flow

```
User taps orb (floating, in any app)
      ↓
Compact bottom popup slides up (~35% screen height)
Background app stays visible above popup
      ↓
Recording starts immediately (no extra tap needed)
      ↓
User speaks (about what they're reading OR a new thought)
      ↓
Live transcript updates in real-time inside popup
AI context hint appears ("Speaking about: ML Assignment · VIT")
      ↓
Silence detected (1.5s) OR user taps "STOP & PROCESS →"
      ↓
Popup transitions to "Thinking..." state (orb animates)
      ↓
Confirmation box appears (F-03) — replaces popup at same bottom position
```

## Compact Popup UI Spec

- **Size:** Full screen width, ~35% height (≈260dp). Slides up from bottom edge.
- **Background:** `#141414` flat dark fill — no blur, no glassmorphism
- **Border:** `2px solid white` on top, left, right edges (Neubrutalist)
- **Background scrim:** `rgba(0,0,0,0.4)` applied over the non-popup area only — dims but does NOT hide the background app

### Inside the popup (top row)

- Mini AURA orb (32dp): lime `#C8FF00`, "A" black, black border, lime glow
- "LISTENING..." label in lime
- Compact waveform visualization (lime bars, horizontal, right-aligned)
- ✕ cancel button (white outlined small square, far right)

### Inside the popup (middle)

- Live transcript text: white italic, left-aligned, updates as user speaks
- Context hint: gray small text — AI's best guess at topic/workspace: "Speaking about: ML Assignment · VIT"

### Inside the popup (bottom row)

- "Type instead" — gray text link (opens keyboard input)
- "STOP & PROCESS →" — lime `#C8FF00` bg, black bold text, black 2px border, black 3px hard shadow

## Common Use Cases This Enables

| Scenario | Flow |
| ---------- | ------ |
| Reading email about deadline | Tap orb → email stays visible → read it out loud → AURA captures |
| WhatsApp message with important date | Tap orb → stay in WhatsApp → speak about it → captured |
| Browsing a job listing | Tap orb → say "save this for placements" → AURA adds context |
| In class, sudden thought | Tap orb → speak → popup dismisses → back to notes app |
| Any app, anything | Orb always available → never loses context of what you were doing |

## Speech-to-Text

- Provider: Android SpeechRecognizer API (built-in, free, no API key)
- Language: English (Indian English accent supported natively)
- Auto-stop: after ~1.5 seconds of silence
- Manual stop: user taps a stop/send button
- Offline: Android STT works partially offline via Gboard offline model

## Fallback — Text Input

- Below the waveform: a small "Type instead" link
- Opens a text field in the same overlay
- User types their input, taps send
- Same AI processing flow applies

## What the AI Receives

The raw transcript text, plus:

- Current time and date
- List of existing workspaces (for auto-detection)
- List of recent tasks (for context — "that thing I mentioned earlier")
- User's reminder defaults (for applying defaults)

## Example Inputs the AI Must Handle

- "ML assignment due Friday at 11:59 PM, remind me the day before and 6 hours before"
- "Interview at 3 PM tomorrow at the VIT placement cell"
- "Add daily DSA practice, recurring, starting today"
- "Note: Rahul said the project deadline is August 15th"
- "Remind me about that internship task"
- "Submit the patent form by next Monday, this is for the VIT project workspace"
- "Team meeting at 5, remind me 30 minutes before" (today assumed if no date given)

## AI Processing (Intent Extraction)

The AI must extract from the transcript:

- **Type:** task, event, note, or recurring task
- **Title:** clean, concise task/event name
- **Deadline / datetime:** parsed from natural language
- **Workspace:** detected from keywords or stated explicitly
- **Reminders:** from voice input or defaults if not specified
- **Priority:** high/medium/low — inferred or default medium
- **Recurrence:** if mentioned (daily, weekly, etc.)
- **Notes:** any extra context that doesn't fit above fields

## Error Handling

- STT fails: show "Couldn't hear clearly — try again or type"
- AI fails: show "Couldn't understand — try rephrasing or type manually"
- No internet (AI call fails): show "Offline — task saved as draft, AI will process when connected"

---

---

# F-03 — Confirmation Box

## What It Is

After voice capture and AI processing, a floating box appears showing what AURA understood.
User must confirm before anything is saved. AURA never saves silently.

## UI Layout

```
┌──────────────────────────────────────────────┐
│  📋  ML Assignment                           │
│                                              │
│  📅  Deadline    Fri, Aug 1 · 11:59 PM      │
│  🔔  Reminders   Thu Jul 31 · 11:59 PM      │
│                  Fri Aug 1 · 5:00 AM        │
│  🗂️  Workspace   VIT  [auto]                │
│  ⚡  Priority    Medium                      │
│  🔁  Recurring   No                          │
│                                              │
│  ────────────────────────────────────────── │
│  [     ✓ Confirm     ]  [  ✏️ Edit  ]       │
└──────────────────────────────────────────────┘
```

## Field Behavior

- Every extracted field is shown
- Fields AURA is uncertain about are highlighted (different color/icon)
- Workspace shows "[auto]" badge if auto-detected — prompts user to verify
- If workspace is new (doesn't exist yet): shows "[New workspace]" badge

## Confirm Button

- Creates the task/event/reminder in the local database
- Shows brief success animation (green flash on orb + haptic feedback)
- Overlay dismisses
- User is returned to whatever app they were in

## Edit Button

- Expands the confirmation box into a full edit view
- All fields become editable inline
- User can:
  - Edit title (text field)
  - Change deadline (date/time picker)
  - Add/remove/edit reminders
  - Change workspace (dropdown of existing + "Create new")
  - Change priority (low / medium / high selector)
  - Toggle recurring (with recurrence pattern selector)
  - Add notes (text field)
- After editing: shows "Save" button which confirms and saves

## Workspace Handling in Confirmation Box

1. AURA auto-detects workspace from keywords → shows it with "[auto]" tag
2. If user stated workspace explicitly → shows it with no tag
3. If no workspace detected → shows "Select workspace" prompt
4. User can tap workspace field to change it at any time

## New Workspace Creation

- If workspace doesn't exist: confirmation box shows "[New: GATE Prep]"
- On confirm: workspace is created automatically — no separate setup needed

## Cancellation

- Tapping outside the box: asks "Discard this?" → Yes / No
- Tapping X: same behavior

## Edge Cases

- If AI couldn't extract a deadline: deadline field shows "No deadline — tap to add"
- If AI extracted a past date: highlight in red with warning "This date is in the past"
- If duplicate task detected: show warning "Similar task exists: [task name]. Add anyway?"

---

---

# F-04 — Task Creation & Metadata

## What Is a Task

A task is something the user needs to DO.
It has a deadline but does not inherently block a specific time slot.

Examples: assignment submission, completing a project section, practicing DSA, reading chapters

## Task Data Model (fields)

| Field | Type | Required | Notes |
| ------- | ------ | ---------- | ------- |
| id | UUID | Yes | Auto-generated |
| title | String | Yes | Max 200 chars |
| description / notes | String | No | Free text, any length |
| workspace_id | FK | Yes | Must belong to a workspace |
| deadline | DateTime | No | Null = no deadline |
| priority | Enum | Yes | LOW / MEDIUM / HIGH, default MEDIUM |
| status | Enum | Yes | TODO / IN_PROGRESS / DONE / CANCELLED |
| is_recurring | Boolean | Yes | Default false |
| recurrence_pattern | String | No | Only if is_recurring = true |
| created_at | DateTime | Yes | Auto |
| updated_at | DateTime | Yes | Auto |
| completed_at | DateTime | No | Set when status → DONE |
| source | Enum | Yes | VOICE / TEXT / SHARE — how it was created |
| ai_raw_transcript | String | No | Original voice transcript, stored for context |
| attachments | Array | No | Linked attachment records |
| reminders | Array | No | Linked reminder records |

## Task Status Flow

```
TODO → IN_PROGRESS → DONE
  ↓                    ↑
CANCELLED         (can undo within 10 seconds)
```

## Priority Display

- HIGH: red indicator
- MEDIUM: yellow indicator
- LOW: grey indicator

## Multi-Workspace Assignment

- A task can belong to multiple workspaces (stated explicitly in voice input)
- Stored as many-to-many relationship
- Displayed in all assigned workspace views

## Task Detail View (when user opens a task)

Shows all fields above, plus:

- Progress notes (user can add updates)
- Attached files, screenshots, links
- Reminder list with status
- Related tasks (if any — future feature)
- Activity log (created, modified, completed)

---

---

# F-05 — Event Creation & Metadata

## What Is an Event

An event is something the user needs to ATTEND or BE PRESENT FOR.
It has a specific date AND time. It blocks that time slot on the calendar.

Examples: placement interview, class, team meeting, internship standup, exam

## How Events Differ From Tasks

| Property | Task | Event |
| ---------- | ------ | ------- |
| Has deadline | Yes | Yes (start time) |
| Has specific time | Usually no | Always yes |
| Blocks calendar slot | No | Yes |
| Duration | N/A | Yes (has end time) |
| Reminder pattern | Before deadline | Before start time |
| Default reminders | 1 day + 6 hrs before deadline | 1 day + morning of + 1 hr + 15 min |

## Event Data Model (fields)

| Field | Type | Required | Notes |
| ------- | ------ | ---------- | ------- |
| id | UUID | Yes | Auto-generated |
| title | String | Yes | Max 200 chars |
| description | String | No | Free text |
| workspace_id | FK | Yes | |
| start_datetime | DateTime | Yes | |
| end_datetime | DateTime | No | If not given, assume 1 hour duration |
| location | String | No | Physical or virtual (link) |
| priority | Enum | Yes | Default HIGH for interviews, MEDIUM otherwise |
| status | Enum | Yes | UPCOMING / DONE / MISSED / CANCELLED |
| created_at | DateTime | Yes | |
| source | Enum | Yes | VOICE / TEXT / SHARE |
| ai_raw_transcript | String | No | |
| attachments | Array | No | |
| reminders | Array | No | |

## AI Classification (Task vs Event)

When AI processes voice input, it classifies the item:

- Contains time + attendance language ("meeting", "interview", "class", "standup") → Event
- Contains completion language ("submit", "finish", "complete", "practice") → Task
- Ambiguous → default to Task, show type selector in confirmation box

User can override the classification in the confirmation box.

## Event Default Reminders

| Timing | Reminder |
| -------- | ---------- |
| 1 day before | "Interview tomorrow at [time] — [location]" |
| Morning of (7 AM) | "Today: [event] at [time]" |
| 1 hour before | "In 1 hour: [event]" |
| 15 minutes before | "[Event] starts in 15 minutes" |

These are defaults — user can override in voice input or confirmation box.

---

---

# F-06 — Workspace System

## What Is a Workspace

A workspace is a named container (directory/folder) for tasks and events.
It groups items by life context.

Examples: VIT, GATE Prep, Internship, Placements, Personal, Health

## Key Properties

- **Dynamic:** created on-the-fly from voice input or manually
- **No predefined list:** AURA does not ship with fixed workspaces
- **Simple container:** no complex logic — just a named folder with a color
- **Multi-assign:** tasks can belong to multiple workspaces
- **Sections-supported:** a workspace can contain named sections (sub-directories) to further organize tasks and events within it

## Workspace Data Model

| Field | Type | Notes |
| ------- | ------ | ------- |
| id | UUID | |
| name | String | User-facing name |
| color | HexColor | Auto-assigned, user can change |
| icon | String | Emoji or icon identifier |
| created_at | DateTime | |
| created_by | Enum | USER_EXPLICIT / AI_DETECTED |
| is_archived | Boolean | Archive instead of delete |

## Creation Flow

### Auto-creation (AI-detected)

1. User says "I'm preparing for GATE"
2. AI detects no GATE workspace exists
3. Confirmation box shows "[New workspace: GATE Prep]"
4. User confirms → workspace created automatically

### Explicit creation in voice

1. User says "Add this to my internship workspace"
2. If workspace doesn't exist → same as above
3. If workspace exists → task assigned to it

### Manual creation (in-app)

- From workspace list screen: tap "+ New Workspace"
- Enter name, pick color, pick icon
- Done

## Auto-Detection Logic

AI checks the transcript for keywords that map to existing workspaces:

- "VIT", "assignment", "professor", "class", "VTOP" → VIT workspace
- "GATE", "IIT", "PYQ", "aptitude" → GATE workspace
- "internship", "standup", "sprint", "[company name]" → Internship workspace
- "placement", "interview", "resume", "OA", "coding round" → Placements workspace

If no match found → AI leaves workspace undetected → user prompted in confirmation box.

## Workspace View

Each workspace shows:

- Name + color + icon
- Count of active tasks and events
- Upcoming deadline preview
- Filter by: All / Active / Done / Overdue
- Section list (if any sections exist inside the workspace)

## Archiving

- Workspaces are never deleted (to preserve task history)
- Archived workspaces hidden from main view
- Accessible from "Archived" section in settings

---

---

# F-06a — Workspace Sections (Sub-directories)

## What Are Sections

Sections are named sub-directories inside a workspace.
They allow the user to organize tasks and events within a workspace by topic, subject, project, or event.

A workspace is a **life context** (e.g., VIT).
A section is a **sub-context within that life context** (e.g., Subjects, Events, Projects, Internship Apps).

## Real-World Example

```
📁 VIT  (workspace)
   ├── 📂 Subjects
   │     ├── ML Assignment  (task)
   │     ├── DBMS Quiz      (task)
   │     └── CN Lab Report  (task)
   ├── 📂 Projects
   │     ├── Patent Filing  (task)
   │     └── Capstone Presentation  (event)
   └── 📂 Fests & Events
         ├── Gravitas 2026 Registration  (task)
         └── Technitians Hackathon       (event)

📁 Personal  (workspace)
   ├── 📂 Health
   │     └── Daily Exercise (recurring task)
   └── 📂 Finance
         └── Pay rent — Aug 1 (task)
```

## Key Properties

- Sections live **inside** a workspace — they are not top-level
- Tasks and events belong to a section OR directly to the workspace (unsectioned)
- A section has a name only — inherits color and icon from its parent workspace
- Sections can be created manually or via voice
- No depth limit is enforced in MVP, but the recommended mental model is **2 levels max** (workspace → section)

## Section Data Model

| Field | Type | Notes |
| ------- | ------ | ------- |
| id | UUID | |
| workspace_id | FK | Parent workspace |
| name | String | User-facing name (e.g., "Subjects", "Projects") |
| created_at | DateTime | |
| created_by | Enum | USER_EXPLICIT / AI_DETECTED |
| sort_order | Int | User can reorder sections |
| is_archived | Boolean | Archive instead of delete |

## Task & Event Model Update

Add `section_id` field to both task and event models:

| Field | Type | Notes |
|-------|------|-------|
| section_id | FK (nullable) | Null = belongs directly to workspace root |

## Creation Flow

### Via voice input

1. User says: "Add ML assignment to VIT workspace, Subjects section"
2. AI extracts: workspace = VIT, section = Subjects
3. If Subjects doesn't exist in VIT → Confirmation box shows "[New section: Subjects in VIT]"
4. User confirms → section created + task assigned to it

### Manual creation (in-app)

1. Open a workspace
2. Tap "+ Add Section"
3. Enter section name → confirm
4. Section appears in workspace view
5. Drag tasks into sections OR assign section when creating a task

### AI Auto-Detection

AI attempts to detect sections from voice keywords:

- "For my [subject] class" → may detect or suggest a Subjects section
- "For the [event name] fest" → may detect or suggest a Fests & Events section
- Explicit mentions always take priority
- If AI is uncertain → leaves section undetected → user prompted in confirmation box

## Section View (inside a workspace)

```
[ VIT ] ─────────────────────────────────────────
  [Subjects]  [Projects]  [Fests & Events]  [+ Add]
─────────────────────────────────────────────────
  Showing: Subjects
  ● ML Assignment       Due: Tonight 11:59 PM  🔴
  ● DBMS Quiz           Due: Today 2:00 PM     🔴
  ● CN Lab Report       Due: Fri Aug 2         🟡
```

- Sections displayed as horizontal tabs or chips at the top of the workspace view
- "All" tab always available (shows everything in workspace regardless of section)
- Unsectioned tasks appear under a default "General" group (not a section — just a visual grouping)

## Moving Items Between Sections

- Long press on task/event → "Move to section" option
- Drag and drop within workspace view (if supported by Android version)
- Voice: "Move ML assignment to Projects section" → AURA confirms the move

## Section in Confirmation Box

When creating a task, confirmation box shows:

```
│  🗂️  Workspace   VIT > Subjects  [auto]        │
```

- Format: `WorkspaceName > SectionName`
- If no section detected: shows just `WorkspaceName` + "+ Add to section" prompt

## Archiving Sections

- Sections are never deleted (to preserve task history)
- Archive a section → hidden from main view, items still accessible via search
- Archiving a workspace archives all its sections too

## Edge Cases

- Task created with section in voice but workspace not yet created → create workspace + section together on confirm
- User assigns task to workspace that has sections → prompt: "Add to a specific section or keep in General?"
- Section renamed → all tasks remain linked (FK is by ID not name)

---

---

# F-07 — Reminder System

## What It Is

The engine that fires notifications at the right time to ensure nothing is missed.
The most critical feature — a reminder that doesn't fire is worse than no reminder.

## Reminder Types

| Type | Description |
| ------ | ------------- |
| DEADLINE_REMINDER | Fires X time before a task's deadline |
| EVENT_REMINDER | Fires X time before an event's start time |
| RECURRING_REMINDER | Fires daily for recurring tasks |
| MORNING_BRIEFING | Daily briefing notification |
| NUDGE | Proactive AI-generated push notification |
| SNOOZE_REPLAY | Re-fires after user snooze |
| DND_REPLAY | Re-fires when DND is lifted |

## Default Reminder Templates (Applied when user doesn't specify)

### For Assignments / Submissions (Task with deadline)

- 1 day before deadline
- 6–7 hours before deadline

### For Projects (Task tagged as project)

- Twice daily (9 AM + 7 PM) starting 7 days before deadline

### For Interviews / Meetings (Events)

- 1 day before (start time)
- Morning of at 7 AM
- 1 hour before
- 15 minutes before

### User override

If user specifies reminders in voice input → those override all defaults.
Example: "remind me every 3 hours starting tomorrow" → that happens exactly.

## Reminder Notification Content

```
[AURA icon]  ML Assignment
             Due in 6 hours · 11:59 PM tonight
             [Mark Done]  [Snooze]
```

- Tapping notification: opens task detail
- "Mark Done" action: marks task complete from notification
- "Snooze" action: opens snooze picker

## Snooze Behavior

| User action | Result |
| ------------- | -------- |
| Swipe to dismiss | Re-remind in 30 minutes automatically |
| Tap "Stop" / clear | No further reminders for this instance |
| Tap "Snooze" | Shows options: 30 min / 1 hour / Tonight 9PM / Tomorrow morning 8AM |
| Voice snooze | "Remind me in 2 hours" → parsed and scheduled |

## Reminder Storage

Each reminder is a record in the database:

- task_id / event_id it belongs to
- scheduled fire time
- type
- status: PENDING / FIRED / SNOOZED / DISMISSED / CANCELLED
- snoozed_until (if snoozed)

## Missed Reminders (Task overdue)

When a task's deadline passes without it being marked done:

- Show a "OVERDUE" badge on the task
- Send a notification: "ML Assignment is overdue. Mark done or update deadline?"
- Once per day maximum (don't spam)

---

---

# F-08 — DND-Aware Notifications

## What It Is

AURA respects Android's Do Not Disturb mode but never silently drops a notification.
When DND lifts, all missed notifications are replayed.

## Behavior During DND

- AURA notifications are blocked by DND (respects system setting)
- Notification is logged in database as FIRED_DURING_DND status
- No silent delivery — user should never think a reminder fired when it didn't

## Behavior When DND Lifts

- AURA monitors DND state via Android BroadcastReceiver
- When DND turns off: check notification log for FIRED_DURING_DND entries
- Batch replay: send ONE summary notification listing all missed items

```
[AURA icon]  While you were away (DND):
             · ML Assignment reminder (was due 11:59 PM)
             · Team meeting in 45 minutes
             · Daily DSA not yet done
             [Open AURA]
```

- If a time-sensitive reminder fired hours ago (e.g., "interview in 15 min" but 2 hours have passed):
  Reword it: "You had a reminder 2 hours ago: Interview at VIT Placement Cell"

## Implementation Notes

- `NotificationInterruptionFilter.INTERRUPTION_FILTER_NONE` detection via BroadcastReceiver
- Log table: `notification_log` with fields: reminder_id, scheduled_at, fired_at, status, dnd_was_active
- On DND lift: query all logs with status = FIRED_DURING_DND, group by time proximity, send batch

---

---

# F-09 — Share-to-AURA

## What It Is

AURA registers as an Android share target. Any content from any app can be sent to AURA.
AURA reads, classifies, and stores it — making everything searchable.

## Supported Content Types

| Type | Source Example | AURA Behavior |
| ------ | --------------- | --------------- |
| Screenshot / Image | WhatsApp, gallery, camera | OCR → "What to do with this?" → voice response |
| URL / Link | Chrome, WhatsApp, any browser | Open + read + extract key info |
| Document / PDF | Files app, email | Extract text + classify |
| Text snippet | WhatsApp copy, notes | Show text + "What to do with this?" |
| Audio / Video | (future) | Store with description |

## Screenshot Flow

```
User shares screenshot → AURA share target selected
            ↓
AURA opens, shows the screenshot in a share view
            ↓
"What do you want to do with this?" appears
            ↓
AURA orb pulses (listening mode activates)
            ↓
User speaks: "This is the deadline for the ML assignment. Create a task."
            ↓
AI combines: OCR text from screenshot + user voice instruction
            ↓
Confirmation box appears (pre-filled from combined context)
            ↓
User confirms → task saved with screenshot attached
```

## Link Flow

```
User shares a URL → AURA opens share view
            ↓
AURA fetches the page content
            ↓
Size check:
  Short (<2000 words) → read full content
  Long (>2000 words)  → extract: title, dates, deadlines, action items
            ↓
Summary shown + "What do you want to do with this?" 
            ↓
User responds by voice
            ↓
Confirmation box (pre-filled) → confirm → saved with link attached
```

## OCR (Screenshot Text Extraction)

- Provider: Google ML Kit Text Recognition (on-device, free, offline)
- Language: English (auto-detect)
- Handles: printed text, screenshots of apps, portal notifications
- Does not handle: complex tables, handwriting (for now)

## Storage & Search

All shared content is stored as an attachment record:

- Original content (image, link, PDF path)
- Extracted text / summary
- AI-generated description
- Linked task/event (if confirmed)
- Workspace (inherited from linked task)

Search must find shared items by:

- Description ("find that sports fest Google Form")
- Content keywords ("find something about August 15")
- Workspace filter

---

---

# F-10 — Morning Briefing

## What It Is

Every morning, AURA sends a notification + in-app briefing summarizing the day.
It is personalized, actionable, and generated fresh each morning.

## Timing

- Default: 7:30 AM
- Smart adjustment: AURA monitors phone unlock times over 7 days
  → calculates average first-unlock time → adjusts briefing to fire 5 minutes after
- Manual override: user sets a specific time in settings
- Late-wake detection: if phone not unlocked by 9 AM, fire briefing anyway

## Content Format

```
Good morning, Ishan T.  —  Tuesday, July 23

🔴 URGENT  (due within 48 hours)
   → ML Assignment   due tonight 11:59 PM
   → DBMS Quiz       today at 2:00 PM

🎯 TODAY'S FOCUS  (AI suggested)
   → Complete feature engineering   (~2 hrs)
   → Review GATE Algorithms PYQs   (~1 hr)

📅 UPCOMING  (next 7 days)
   → Internship standup   Thursday 10 AM
   → Patent submission    4 days left

🔁 RECURRING  (today's habits)
   → Daily DSA     ✗ missed yesterday — do it today?
   → Exercise      ✓ done yesterday

💬  You have 3 deadlines this week. Yesterday: 2/4 tasks done. Keep going.
```

## Delivery

- Notification: fires at briefing time, expandable to show summary
- In-app: tapping notification opens the full briefing screen inside AURA
- Both always — never just one

## AI Generation Rules

- URGENT: anything due within 48 hours
- TODAY'S FOCUS: AI picks 2–3 tasks based on deadline proximity + estimated time
- UPCOMING: next 7 days, sorted by date
- RECURRING: all recurring tasks, show yesterday's completion status
- Motivational line: generated by AI — short, relevant, not generic

## Edge Cases

- Nothing due today: still send briefing with upcoming items + recurring tasks
- All tasks done: "Clear day! Here's what's coming up..."
- First morning (no data): brief onboarding message instead

---

---

# F-11 — Proactive Nudges

## What It Is

AURA proactively sends motivational / accountability push notifications throughout the day.
User has given permission for aggressive nudging. AURA acts as a productivity coach.

## Nudge Types

| Trigger | Nudge Message |
| --------- | -------------- |
| Task not started, 48 hrs to deadline | "You haven't started [task] yet. Deadline: Friday. Start today?" |
| No progress logged in 2 days | "Haven't touched [project] in 2 days. 5 minutes now?" |
| Free time detected (no events for 2+ hrs) | "Free window right now. Best task to tackle: [top priority task]" |
| 3+ tasks done today | "Productive day! 3 done. 2 remaining. Keep it up." |
| Evening, recurring task not done | "10 PM — Daily DSA not done yet. Quick 30 min session?" |
| Task deadline approaching, no progress | "ML Assignment due in 6 hours and not marked started. Need to hustle." |

## Timing Rules

- Max 3 nudges per day (to avoid notification fatigue)
- Never send between 11 PM – 7 AM
- Respect DND (apply DND replay logic from F-08)
- Space nudges at least 2 hours apart

## Tone

- Honest, direct, slightly humorous
- Never preachy or guilt-heavy
- Short — max 2 sentences

## User Control

- Nudges can be turned off in settings (but on by default)
- User can set "focus hours" when nudges are silenced

---

---

# F-12 — Recurring Tasks

## What It Is

A task that repeats daily (or on a set schedule) for a sustained period (minimum 2 weeks).
Used for habits, practice routines, and ongoing work.

## Recurring Task Examples

- Daily DSA practice
- GATE PYQ solving (1 chapter/day)
- Exercise / gym
- Journaling
- Medicine reminders

## Data Model Additions

| Field | Notes |
| ------- | ------- |
| is_recurring | Boolean |
| recurrence_type | DAILY / WEEKLY / CUSTOM |
| recurrence_days | e.g., ["MON","WED","FRI"] for weekly |
| recurrence_start | First occurrence date |
| recurrence_end | Optional end date |
| reminder_time | What time to fire the daily reminder |

## Daily Reset

- At midnight: all recurring tasks reset to PENDING for the new day
- Yesterday's completion is logged in `daily_log` table

## Completion Flow

- User gets reminder at set time
- Taps "Mark Done" on notification OR checks it off in app
- Logged as DONE for today's date
- Tomorrow it resets automatically

## Dismiss Behavior (didn't do it yet)

- User dismisses reminder → AURA re-reminds in 30–60 minutes (same as F-07 snooze)

## Missed Day Behavior (all three happen)

1. **History log:** "You missed DSA on July 22" — visible in task history
2. **Makeup prompt:** Next morning briefing includes "Missed DSA yesterday. Add a makeup session today?"
3. **Gentle roast:** Random from a curated set of humorous messages:
   - "Yesterday's DSA session said it missed you. Did you miss it back?"
   - "The algorithm you skipped yesterday is still waiting."
   - "Consistency is a habit. Missing it is also a habit. Choose wisely."

## Ending a Recurring Task

- User says "Stop daily DSA reminders" → AURA asks "Pause or end permanently?"
- Pause: stops reminders for X days
- End: sets recurrence_end to today, no more instances

---

---

# F-13 — Timeline & Calendar Views

## What It Is

Multiple visual representations of the same underlying task + event data.
Different views for different moods and needs.

## Views Available (MVP)

### Today View (Home screen)

- Default when AURA opens
- Shows: today's events (time-blocked), today's tasks, recurring tasks for today
- Sorted: events by start time, tasks by priority + deadline proximity

### Upcoming View

- All tasks and events in the next 7 days
- Sorted chronologically
- Grouped by day

### Workspace View

- Filtered view showing only one workspace's items
- Accessed from workspace switcher

### All Tasks View

- Flat list of all tasks (no events)
- Filters: Status (active / done / overdue), Priority, Workspace
- Sort: Deadline / Priority / Created date

## Planned for Later (Post-MVP)

- Weekly calendar view (7-day time grid)
- Monthly calendar view
- Kanban view (Todo / In Progress / Done columns)
- Deadline urgency view (sorted by time remaining)

## Calendar-Specific Behavior

- Events always show as time-blocked slots
- Tasks show as chips/cards below the time grid
- Tapping any item opens its detail view

---

---

# F-14 — Search

## What It Is

Find anything in AURA by describing it in natural language.
Not just title search — searches across all fields and attachments.

## Search Scope

- Task titles and notes
- Event titles and locations
- Workspace names
- Attachment content (OCR text from screenshots, link summaries, document text)
- AI-generated descriptions of shared content

## Search Behavior

- Instant search as user types (no submit button needed)
- Fuzzy matching: "ML assign" finds "ML Assignment"
- Semantic search (future): "that thing Rahul told me about" → finds related task

## Search Results Display

- Grouped by type: Tasks / Events / Attachments
- Each result shows: title, workspace, deadline/date, status
- Tapping result: opens detail view

## Filters in Search

- Workspace filter
- Status filter (active / done / all)
- Date range filter

---

---

# F-15 — Onboarding

## What It Is

The first-launch experience. Guides new user through setup without overwhelming them.

## Principles

- Short: 3–4 screens maximum
- Action-oriented: user does something, not just reads
- Skippable: experienced users can skip

## Onboarding Flow

### Screen 1: Welcome

- AURA logo + tagline: "One tap. You speak. Life organizes itself."
- "Get Started" button

### Screen 2: Permissions

Request (one at a time, with explanation):

1. **Overlay permission** (floating orb): "AURA needs to show the orb on top of all apps"
2. **Microphone permission**: "To capture your voice"
3. **Notification permission**: "To remind you at the right time"

### Screen 3: First Workspace

- "What are you working on right now?"
- Shows 4-5 suggestion chips: VIT / IIT Prep / Internship / Personal / Other
- User taps one or more to create their first workspaces
- Or types a custom one
- "AURA will detect and create more as you use it"

### Screen 4: Try It Now

- "Let's try AURA. Tap the orb and say something."
- Shows the floating orb as a demo
- User taps → speaks → sees confirmation box
- After first task created: "You're all set. AURA will remember this."

---

---

# F-16 — Settings

## Settings Available (MVP)

### Notifications

- Morning briefing: on/off, time override
- Proactive nudges: on/off
- Focus hours: time window when nudges are silenced
- DND replay: on/off (default on)

### Voice

- Default language (English, auto-detect)
- Auto-stop sensitivity (short pause / long pause)

### Workspaces

- View all workspaces
- Edit name/color/icon
- Archive workspace

### Reminder Defaults

- Task default: edit the default reminder times
- Event default: edit the default reminder times

### Appearance

- Theme: dark / light / system default (default: dark)
- Orb size: small / medium / large
- Orb position: reset to center

### Privacy & Data

- View what data AURA has stored
- Export all data (JSON)
- Clear all data
- App version + licenses

---

---

# F-17 — Design System & Visual Language

## Philosophy

AURA's design language is **Pure Dark Neubrutalism with Bento Grid layouts**.

This is a deliberate, opinionated aesthetic choice — not a default.
AURA should feel like a tool built by someone who cares deeply about craft.
It should look unmistakable. Sharp. Uncompromising.

**Confirmed on 2026-07-24:** After visual exploration of Neubrutalism, Matiks-style glassmorphism, and Terminal Brutalism, Pure Neubrutalism won. The hybrid variant (with atmospheric glow) was selected, then refined: all glow effects removed except one — the orb. Everything else is flat.

## Why This Style

| Neubrutalism gives us... | Bento Grid gives us... |
| -------------------------- | ------------------------ |
| Raw, honest, confident personality | Dense information in scannable blocks |
| Bold borders that create clear boundaries | Modular, resizable card layouts |
| High contrast that aids readability | Natural grouping of related data |
| Anti-generic feel — stands out immediately | Familiar grid rhythm — feels organized |
| Matches AURA's "direct & unfiltered" tone | Adapts to phone screens naturally |

## Color System

### Base Palette (Dark)

| Token | Value | Usage |
| ------- | ------- | ------- |
| `color-bg-base` | `#0D0D0D` | Main app background |
| `color-bg-card` | `#141414` | Card/bento cell background |
| `color-bg-elevated` | `#1C1C1C` | Modals, overlays, sheets |
| `color-border` | `#FFFFFF` | All card borders (pure white, full opacity) |
| `color-border-muted` | `rgba(255,255,255,0.15)` | Subtle dividers |
| `color-shadow` | `#FFFFFF` | Neubrutalist box-shadow (offset, white) |

### Accent Palette

| Token | Value | Usage |
| ------- | ------- | ------- |
| `color-accent-primary` | `#C8FF00` | Primary CTAs, active states, AURA orb glow |
| `color-accent-blue` | `#4DFFFF` | Events, calendar items |
| `color-accent-orange` | `#FF7A29` | Warnings, medium priority |
| `color-accent-red` | `#FF3B3B` | Overdue, high priority, urgent |
| `color-accent-green` | `#39FF88` | Success states, completed tasks |
| `color-accent-purple` | `#B57BFF` | Recurring tasks, habits |

### Text

| Token | Value | Usage |
| ------- | ------- | ------- |
| `color-text-primary` | `#FFFFFF` | Headlines, primary content |
| `color-text-secondary` | `rgba(255,255,255,0.6)` | Subtext, metadata |
| `color-text-disabled` | `rgba(255,255,255,0.3)` | Placeholder, disabled states |

## Typography

- **Typeface:** `Space Grotesk` (Google Fonts) — geometric, modern, slightly weird in the best way
- **Fallback:** `Inter`, `system-ui`
- **Scale:**

  | Role | Size | Weight |
  | ------ | ------ | -------- |
  | Display / Hero | 32–40sp | 800 (ExtraBold) |
  | Section Headers | 20–24sp | 700 (Bold) |
  | Card Titles | 16–18sp | 600 (SemiBold) |
  | Body / Metadata | 13–15sp | 400 (Regular) |
  | Labels / Tags | 11–12sp | 500 (Medium), ALL CAPS |

## Neubrutalism Rules

Every card, button, and interactive element must follow these rules:

1. **Hard border:** `2px solid #FFFFFF` — no subtle, ghostly borders
2. **Offset shadow:** `4px 4px 0px #FFFFFF` — the neubrutalist "drop" effect
3. **No border-radius:** `0px` on all cards and interactive elements
4. **No blur/glassmorphism:** Neubrutalism is anti-frosted-glass
5. **Bold text over decorative text:** hierarchy through weight, not effects
6. **Active/pressed state:** shift the shadow to `2px 2px 0px #FFFFFF` (pushes in)
7. **Accent backgrounds on key CTAs:** Confirm button = `bg: #C8FF00`, `text: #000000`, bold

## The Glow Rule (Binding — Do Not Break)

This is the final confirmed rule from the design review session.

| Element | Glow allowed? | Spec if yes |
| --------- | -------------- | ------------- |
| Cards | ❌ Never | — |
| Text / labels | ❌ Never | — |
| Numbers / stat values | ❌ Never | — |
| Buttons | ❌ Never | — |
| Priority stripes | ❌ Never | — |
| Background | ❌ Never | — |
| **Floating Orb** | ✅ Yes — only element | `radial-gradient` lime, 8% opacity, 28px spread |
| **Mini Orb (in popup)** | ✅ Yes — scaled | Same rule: 6% opacity, 16px spread |

> The orb glow is the ONLY atmospheric element in AURA's entire UI.
> It provides warmth and life without decorating the information.

## Bento Grid Layout System

### Grid Concept

The app's main screens are composed of a grid of **bento cells** — rectangular cards of varying sizes that each show one piece of information cleanly.

### Home Screen Bento Layout (Today View)

```
┌────────────────┬────────┐
│  URGENT        │  ORB   │  Row 1
│  2 items due   │        │
│  today         │        │
├────────────────┴────────┤
│  TODAY'S FOCUS (wide)   │  Row 2
│  2 tasks suggested      │
├───────────┬─────────────┤
│ NEXT UP   │  HABIT      │  Row 3
│ 3 items   │  DSA ✓      │
│           │  Exercise ✗ │
├───────────┴─────────────┤
│  WORKSPACE QUICK ACCESS │  Row 4
│  [VIT] [GATE] [+]       │
└─────────────────────────┘
```

- Each cell has a **bold label** (ALL CAPS, small) and its **content** below
- Cells can be **tapped** to open the full view
- Cells **animate in** on load (staggered slide-up, 40ms delay between cells)

### Workspace Screen Bento Layout

```
┌──────────┬──────────────┐
│ ACTIVE   │ OVERDUE      │
│   7      │    2  🔴     │
├──────────┴──────────────┤
│  SECTION TABS           │
│  [Subjects] [Projects]  │
├─────────────────────────┤
│  TASK LIST (full width) │
│  (standard list below)  │
└─────────────────────────┘
```

## Orb Design (binding spec)

- **Default state:** Lime `#C8FF00` solid fill. "A" ExtraBold black. `3px solid black` border. `4px 4px 0px black` hard offset shadow.
- **Orb glow:** faint lime radial blur behind orb only — `box-shadow: 0 0 28px 8px rgba(200,255,0,0.08)`. Barely visible. The ONLY glow in the system.
- **Listening state:** orb pulses with expanding concentric rings — rings are flat lime, no additional glow
- **Border rule:** `3px solid #000000` — black, not white (orb sits on dark bg, black border gives crispness)
- **Shadow rule:** `4px 4px 0px #000000` — black hard shadow, not white

## Motion & Animation

| Interaction | Animation |
| ------------- | ---------- |
| Screen load | Bento cells stagger in, slide up 8dp, fade in — 40ms delay each |
| Card tap | Scales to `0.97`, shadow shrinks (press feedback) |
| Task completion | Strike-through animation + green flash + haptic |
| Confirmation box appear | Slides up from bottom, 300ms ease-out |
| Orb listening | Pulse rings expand outward, loop |
| Section tab switch | Horizontal slide of content, 200ms |

## Component Library (Key UI Elements)

### Bento Card

- Background: `color-bg-card`
- Border: `2px solid color-border`
- Shadow: `4px 4px 0px color-shadow`
- Padding: `16dp`
- Label: `11sp, ALL CAPS, color-text-secondary`
- Value: `20–24sp, Bold, color-text-primary`

### Task Chip / List Item

- Left: priority indicator dot (colored)
- Title: `16sp, SemiBold`
- Deadline: `13sp, color-text-secondary`
- Right: status icon / checkbox
- Completed: `opacity 0.5` + strike-through

### Section Tab (inside workspace)

- Selected: `bg: color-accent-primary, text: #000000, border: 2px solid #000000`
- Unselected: `bg: transparent, text: color-text-secondary, border: 2px solid color-border-muted`

### CTA Button (Primary)

- Background: `color-accent-primary` (#C8FF00)
- Text: `#000000`, Bold
- Border: `2px solid #000000`
- Shadow: `4px 4px 0px #000000`
- Pressed: shadow shrinks to `2px 2px 0px #000000`

### CTA Button (Secondary)

- Background: `transparent`
- Text: `color-text-primary`
- Border: `2px solid color-border`
- Shadow: `4px 4px 0px rgba(255,255,255,0.3)`

## Dark Neubrutalism — What to Avoid

- ❌ Gradients on backgrounds (use flat fills only)
- ❌ Rounded corners on cards (0px strictly)
- ❌ Glassmorphism / frosted blur effects
- ❌ Drop shadows that blur (use hard offsets only)
- ❌ Thin, light borders (always 2px minimum)
- ❌ Generic sans-serif at regular weight — everything should feel intentional and bold
- ❌ Muted, earthy color palettes — this is a dark + neon flat system
- ❌ **Glow on anything except the orb** — this is the most important rule

---

---

## Appendix A — What AURA Does NOT Do (v1)

These are explicitly out of scope for the MVP:

- ❌ Read Gmail, WhatsApp, or any other app automatically
- ❌ Send messages on behalf of user
- ❌ Rearrange schedule without user approval
- ❌ Sync to Google Calendar (planned for later)
- ❌ Multi-user / shared tasks
- ❌ Desktop / web version
- ❌ Cloud backup (planned for later)
- ❌ Time-blocking (schedule tasks into specific time slots automatically)

---

## Appendix B — AI Behavior Summary

| Situation | AURA behavior |
| ----------- | -------------- |
| Extracts information from voice | Fills confirmation box — always waits for user confirm |
| Detects a workspace | Shows "[auto]" tag — user can change before confirming |
| Unsure about a field | Highlights it — user prompted to fill |
| Creates a new workspace | Shows "[New workspace]" in confirmation — auto-creates on confirm |
| Misunderstands input | User edits in confirmation box — no re-recording needed |
| Offline | Saves draft — AI processes when connected |
| Proactive nudge | Sends notification — no task modified without user action |

---

*PRD Version 0.3 — Design system finalized (F-17 updated with confirmed glow rule + orb spec)*
*Previous: Version 0.2 — Workspace Sections (F-06a) + initial Design System (F-17)*
*Next: Stage 3 — design_system.md + full wireframes for all 7 screens*
*Created: 2026-07-23 | Updated: 2026-07-24*
