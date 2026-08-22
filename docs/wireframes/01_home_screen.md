# Wireframe: Home Screen (Today View)

> **Feature:** Main app screen — default view on launch
> **PRD Reference:** F-13 (Timeline & Calendar Views), F-17 (Design System)
> **Layout:** Pure Dark Neubrutalism + Bento Grid

---

## Screen Purpose

The home screen is the command center. It answers:
"What matters right now?"

It shows today's urgent tasks, AI-suggested focus, upcoming events, habits, and workspace access — all in a scannable bento grid.

---

## Full Screen Layout (Portrait, ~390 x 844dp)

```
┌─────────────────────────────────────────────────────┐
│  STATUS BAR (system)                                │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Good morning, Ishan T.            [🔍] [👤]         │ ← Header bar (56dp)
│  Thursday, July 24                                  │
│                                                     │
├──────────────────────────┬──────────────────────────┤
│                          │                          │
│  URGENT              🔴  │  ◉  A                   │ ← Row 1 (140dp)
│  ──────────────────────  │  ─────                  │
│  ML Assignment           │  Tap to                 │
│  · Due tonight 11:59 PM  │  capture                │
│                          │                          │
│  DBMS Quiz               │  [Orb - lime]           │
│  · Due today 2:00 PM     │                          │
│                          │                          │
├──────────────────────────┴──────────────────────────┤
│                                                     │
│  TODAY'S FOCUS                                      │ ← Row 2 (120dp, full width)
│  ──────────────────────────────────────────         │
│  ① Complete feature engineering    ~2 hrs →         │
│  ② Review GATE Algorithms PYQs     ~1 hr  →         │
│                                                     │
├──────────────────────────┬──────────────────────────┤
│                          │                          │
│  NEXT UP              3  │  HABITS                  │ ← Row 3 (120dp)
│  ──────────────────────  │  ──────────────────────  │
│  Internship standup      │  DSA Practice   ✗        │
│  Thu · 10:00 AM          │  Exercise       ✓        │
│                          │  Reading        —        │
│  Patent submission       │                          │
│  4 days left             │                          │
│                          │                          │
├──────────────────────────┴──────────────────────────┤
│                                                     │
│  WORKSPACES                                         │ ← Row 4 (80dp)
│  ──────────────────────────────────────────         │
│  [📚 VIT · 8]  [🎯 GATE · 3]  [💼 Intern · 2]  [+] │
│                                                     │
├─────────────────────────────────────────────────────┤
│  [🏠 Home]  [📅 Calendar]  [🗂 Workspaces]  [⚙ Settings]  │ ← Bottom Nav (56dp)
│                                                     │
│              ◉  [AURA orb — floating above nav]     │ ← Orb (56dp, floating)
└─────────────────────────────────────────────────────┘
```

---

## Component Breakdown

### Header Bar

```
Height: 56dp
Left:   "Good morning, Ishan T." — 22sp Bold white
        "Thursday, July 24"     — 13sp secondary
Right:  [🔍] Search icon  [👤] Profile icon  (each 24dp, 48dp tap target)
Background: transparent (shows base bg)
No border on header
```

### Bento Row 1 — URGENT + ORB (2 columns)

**Left cell — URGENT (60% width)**

```
Label:     "URGENT" — ALL CAPS, 11sp, secondary
Indicator: 🔴 dot (overdue/today count)
Content:   List of 1–3 urgent task chips
           Each chip: task name 15sp bold, deadline 12sp secondary below
           Priority stripe: red left border (4dp)
Empty:     "Nothing urgent. Good work." — secondary italic
Tap:       Opens All Tasks filtered to urgent
```

**Right cell — ORB CELL (40% width)**

```
Background: #141414 + 2px white border + 4px 4px white shadow
Content:    AURA orb centered
            "Tap to capture" — 11sp secondary below orb
The orb is NOT the floating orb here — this is a static call-to-action representation
Tap:        Activates voice capture (same as floating orb tap)
```

### Bento Row 2 — TODAY'S FOCUS (full width)

```
Label:   "TODAY'S FOCUS" — ALL CAPS, 11sp, secondary
Content: 2–3 AI-suggested tasks with:
         ① number indicator — 14sp, lime (#C8FF00)
         Task name — 15sp SemiBold white
         Estimated time — 12sp secondary
         → arrow right (indicates tappable)
Tap row: Opens task detail
AI note: Small "AI suggested" chip in top-right corner of cell (11sp, purple)
Empty:   "Add some tasks to get focus suggestions."
```

### Bento Row 3 — NEXT UP + HABITS (2 columns)

**Left cell — NEXT UP (50% width)**

```
Label:   "NEXT UP" — ALL CAPS, 11sp, secondary
Counter: count badge (white number on black, 2px white border)
Content: 2 items shown (events by time, tasks by deadline)
         Event: title, day + time — blue (4DFFFF) left indicator
         Task:  title, days remaining — white left indicator
Tap:     Opens calendar / upcoming view
```

**Right cell — HABITS (50% width)**

```
Label:   "HABITS" — ALL CAPS, 11sp, secondary
Content: Today's recurring tasks, each line:
         Task name — 14sp
         Status:  ✓ (green, done)  ✗ (red, not done)  — (gray, not yet)
Tap row: Marks habit done (with haptic + green flash)
Tap cell: Opens recurring tasks list
```

### Bento Row 4 — WORKSPACES (full width)

```
Label:   "WORKSPACES" — ALL CAPS, 11sp, secondary
Content: Horizontal scroll of workspace chips
         Each chip: emoji + name + active task count
         Chip style: 2px white border, 0 radius, #141414 bg, name in white
         [+] chip: creates new workspace
Tap chip: Navigates to workspace screen filtered to that workspace
```

### Floating Orb

```
Position: Floating, above bottom nav bar, default center-bottom
          Saved position persists across app restarts
Size:     56dp diameter
Style:    Lime fill, "A" ExtraBold black, 3px black border, 4px black shadow, lime glow
State:    Default → subtle pulse animation (ambient)
Tap:      Activates voice capture (F-02)
Long press: Quick action menu appears above orb
```

### Bottom Navigation

```
Height: 56dp + system nav bar height
Items:  Home | Calendar | Workspaces | Settings
        Icon 24dp + label 11sp below
Active: lime accent on icon, white label
Inactive: secondary color
```

---

## States

### Loading State

- Bento cells shimmer with `rgba(255,255,255,0.05)` animated highlight
- Cells load with stagger animation (40ms each) once data arrives

### Empty State (no tasks at all)

```
Shows only the orb cell (full width in that row) with:
"Nothing here yet. Tap the orb and tell me what's on your mind."
```

### Error State

```
Small snackbar at bottom: "Couldn't load some items. Tap to retry."
2px white border, black bg, white text
```

---

## Interactions & Animations

| Interaction | Animation |
| ------------- | ----------- |
| App launch | Bento cells slide up 8dp + fade in, 40ms stagger |
| Cell tap | Scale 0.97 + shadow shrinks, 100ms |
| Habit tap (mark done) | Green flash on row + checkmark bounce + haptic |
| Orb long press | Quick menu slides up above orb, 200ms |
| Workspace chip tap | Smooth navigate to workspace screen |
