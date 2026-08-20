# Wireframe: Task Detail Screen

> **Feature:** F-04 — Task Creation & Metadata (Detail View)
> **Access:** Tap any task from home screen, workspace view, or search results

---

## Screen Layout

```
┌─────────────────────────────────────────────────────┐
│  ← Back                             [✏️ Edit]  [⋮]  │ ← App bar (56dp)
├─────────────────────────────────────────────────────┤
│                                                     │
│  ▌ TASK — VIT > Subjects                            │ ← Breadcrumb (priority color left bar)
│                                                     │
│  ML Assignment                                      │ ← Task name (24sp Bold white)
│                                                     │
│  ┌──────────────┬──────────────┬──────────────┐     │
│  │  STATUS      │  PRIORITY    │  SOURCE      │     │ ← Quick stats bento (80dp)
│  │  TODO        │  HIGH 🔴     │  VOICE 🎤    │     │
│  └──────────────┴──────────────┴──────────────┘     │
│                                                     │
│  DEADLINE                                           │ ← Section (11sp ALL CAPS secondary)
│  ┌─────────────────────────────────────────────┐    │
│  │  📅  Fri, Aug 1 · 11:59 PM                  │    │
│  │      🔴 Due in 6 hours                      │    │ ← Countdown chip
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  REMINDERS  [+ Add]                                 │
│  ┌─────────────────────────────────────────────┐    │
│  │  🔔 Thu Jul 31 · 11:59 PM   PENDING   [✕]  │    │
│  │  🔔 Fri Aug 1  · 05:00 AM   PENDING   [✕]  │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  [Details] [Subtasks] [Notes] [Attachments]         │ ← Content tabs (48dp)
│  ─────────────────────────────────────────────────  │
│                                                     │
│  [ Details tab content — see below ]                │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  [  ✓  MARK AS DONE  ]   [  ⏰  SNOOZE REMINDER  ] │ ← Fixed action bar (64dp)
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Header Area

### App Bar
```
Left:    ← back arrow (24dp, white)
Right:   ✏️ Edit button (opens full edit mode) | ⋮ more options
Title:   None (task name shown in body)
```

### Breadcrumb
```
Style:   4dp left colored bar (workspace color) + "TASK — WorkspaceName > SectionName"
Font:    12sp ALL CAPS, secondary
The colored bar gives instant workspace context
```

### Task Name
```
Font:    24sp ExtraBold, white
Editable: tap → inline edit (keyboard opens, field becomes editable)
Max:     200 chars
```

### Quick Stats Bento (3 cells)
```
STATUS chip:   [TODO] [IN PROGRESS] [DONE] [CANCELLED]
               Tap to cycle status with animation
PRIORITY chip: [HIGH 🔴] [MEDIUM 🟠] [LOW ⚫]
               Tap to cycle priority
SOURCE chip:   [VOICE 🎤] [TEXT ⌨️] [SHARE 📤] — non-interactive (info only)
```

---

## Deadline Section
```
Container: bento card (2px white border, 4px white shadow, #141414 bg)
Row 1:     📅 icon + formatted date/time (16sp SemiBold white)
Row 2:     Countdown chip — styled per deadline urgency
           Green (>3d): "3 days 4 hours left"
           Amber (1-3d): "1 day 6 hours left"
           Red (<24h):  "6 hours left" + subtle pulse on chip
           Overdue:     🔴 "Overdue by 2 hours" + continuous pulse

Tap:       Opens date/time picker to change deadline
No deadline: Shows "No deadline set — tap to add" (secondary, italic)
```

---

## Reminders Section
```
Header:    "REMINDERS" label + [+ Add] link (lime, right)

Each reminder row:
  Left:    🔔 icon
  Content: "Fri Aug 1 · 05:00 AM" — 15sp white
  Status:  "PENDING" (secondary) / "FIRED" (green) / "SNOOZED" (orange) / "MISSED" (red)
  Right:   [✕] delete this reminder

[+ Add]: Opens quick reminder picker:
         [30 min before] [1 hr before] [1 day before] [custom...]
```

---

## Content Tabs

### Tab 1: Details
```
Field rows (same style as confirmation box):
  Description / Notes:  Free text field (multiline, editable)
  Workspace:            WorkspaceName > Section (tappable to change)
  Estimated Hours:      Number input (e.g., "2 hrs")
  Recurring:            OFF / type of recurrence
  Created at:           Date (non-editable, secondary)
  AI transcript:        Collapsible — "Original voice: '...' [show]"
                        Shows raw transcript the user spoke
```

### Tab 2: Subtasks
```
Each subtask:
  ○ Subtask name — 15sp white
  Tap circle: marks subtask done (strikethrough + green flash)

Footer: [+ Add subtask] — text input appears inline
        2px white border input field, confirm on enter/tap ✓

Progress bar:
  Shows "2 / 5 subtasks done" — lime bar (neubrutalist: 2px white border, flat fill)
```

### Tab 3: Notes
```
Free text area:
  Background: #1C1C1C (elevated)
  Border: 2px white
  Font: 15sp Regular white
  Placeholder: "Add notes, context, or anything else..."
  Auto-saves on focus loss

Voice note (if captured):
  ▶ play button + waveform visualization + duration
  e.g., "Voice note · 0:32" with lime play button
```

### Tab 4: Attachments
```
Grid of attached items:
  Screenshot: thumbnail (tappable for full view)
              OCR text preview below thumbnail
  Link:       favicon + title + domain
  Document:   file icon + filename + size

[+ Attach]: Options — Camera / Gallery / Files / Link
```

---

## Fixed Action Bar

### MARK AS DONE (primary)
```
Style:   Lime CTA, half width
Tap:     Shows brief animation: strike-through on task name + green fill → status changes to DONE
         Haptic: medium impact
         Snackbar: "Done! Undo?" (5 second window)
If already done: shows "MARK AS TODO" (secondary style)
```

### SNOOZE REMINDER (secondary)
```
Style:   Secondary button, half width
Visible: Only when there's a PENDING reminder due within 24 hours
Tap:     Bottom sheet with options:
         [30 minutes] [1 hour] [Tonight 9 PM] [Tomorrow 8 AM] [Custom]
Hidden:  If no pending reminders
```

---

## Options Menu (⋮)

```
┌──────────────────────────────┐
│  ↗  Share task               │
│  📋  Duplicate task          │
│  🗂  Move to workspace       │
│  🗑  Delete task             │
└──────────────────────────────┘
Delete: Shows "Delete permanently?" confirm dialog (not reversible after 10s)
```

---

## States

### Loading
```
Task name: shimmer placeholder (2 lines)
Bento stats: shimmer cells
```

### Completed Task
```
Task name: strikethrough (but still readable)
Status cell: "DONE" — green #39FF88
Deadline cell: "Completed [date]"
Action bar: "MARK AS TODO" | (snooze hidden)
Overall: opacity slightly reduced (0.85) to feel "archived"
```

### Overdue Task
```
Deadline cell: red, pulsing
Status: "OVERDUE" badge at top of screen (2px red border, red bg at 10% opacity)
Action bar: "MARK AS DONE" still primary — easy resolution
```
