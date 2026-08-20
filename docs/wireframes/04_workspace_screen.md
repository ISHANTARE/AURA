# Wireframe: Workspace Screen

> **Feature:** F-06 — Workspace System, F-06a — Workspace Sections
> **Access:** Bottom nav "Workspaces" tab, or tapping workspace chip on home screen

---

## Screen Layout — Workspace List View

```
┌─────────────────────────────────────────────────────┐
│  STATUS BAR                                         │
├─────────────────────────────────────────────────────┤
│                                                     │
│  WORKSPACES                              [+  NEW]   │ ← Header (56dp)
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────────┬──────────────────────┐    │
│  │  📚 VIT              │  🎯 GATE Prep         │    │ ← Row 1
│  │  ────────────────    │  ──────────────────   │    │
│  │  TASKS: 8  EVENTS: 2 │  TASKS: 3  EVENTS: 0  │    │
│  │  ⚠ 2 overdue        │  Next: Algo PYQs      │    │
│  │                      │  in 2 days            │    │
│  └──────────────────────┴──────────────────────┘    │
│                                                     │
│  ┌──────────────────────┬──────────────────────┐    │
│  │  💼 Internship       │  👤 Personal          │    │ ← Row 2
│  │  ────────────────    │  ──────────────────   │    │
│  │  TASKS: 2  EVENTS: 1 │  TASKS: 5  EVENTS: 0  │    │
│  │  Standup Thu 10AM    │  ↻ 3 habits today     │    │
│  └──────────────────────┴──────────────────────┘    │
│                                                     │
│  ┌──────────────────────┬──────────────────────┐    │
│  │  ❤️ Health            │  [+  Add workspace]   │    │ ← Row 3
│  │  ────────────────    │                       │    │
│  │  TASKS: 2  EVENTS: 0 │  Tap to create        │    │
│  │  ↻ Exercise · DSA    │                       │    │
│  └──────────────────────┴──────────────────────┘    │
│                                                     │
│                                                     │
│  ─────────────────────────────────────────────────  │
│  ARCHIVED    >                                      │ ← Collapsed section
│                                                     │
├─────────────────────────────────────────────────────┤
│  [🏠 Home]  [📅 Calendar]  [🗂 Workspaces▶]  [⚙]   │ ← Bottom nav
└─────────────────────────────────────────────────────┘
```

---

## Workspace Card Specifications

```
Size:      ~168dp x 140dp (fills half screen width, minus margins)
Border:    2px solid #FFFFFF
Shadow:    4px 4px 0px #FFFFFF
Bg:        #141414
Radius:    0
Padding:   16dp

Layout:
  Top row:   [emoji 24sp] [workspace name 17sp SemiBold white]
  Divider:   1px rgba(255,255,255,0.15)
  Stats row: "TASKS: N  EVENTS: N" — 11sp ALL CAPS secondary
  Preview:   Next upcoming deadline or event (13sp secondary)
             OR recurring tasks today (13sp secondary)
             OR overdue warning (13sp red #FF3B3B)

Long press: Context menu (Edit / Archive / Delete)
Tap:        Opens workspace detail screen
```

---

## Screen Layout — Workspace Detail (after tapping a workspace)

```
┌─────────────────────────────────────────────────────┐
│  ← Back                                [⋮ options]  │ ← App bar (56dp)
│  📚 VIT                                             │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────┬──────────┬──────────┬──────────────┐  │ ← Stats bento row (80dp)
│  │ ACTIVE   │ OVERDUE  │ EVENTS   │  SECTIONS     │  │
│  │   8      │  2 🔴    │   2      │    3          │  │
│  └──────────┴──────────┴──────────┴──────────────┘  │
│                                                     │
│  [All] [Subjects] [Projects] [Fests & Events] [+]   │ ← Section tabs (48dp)
│  ─────────────────────────────────────────────────  │
│                                                     │
│  OVERDUE                                            │ ← Grouped list
│  ┌─────────────────────────────────────────────┐    │
│  │ ▌ DBMS Quiz              Today 2:00 PM  🔴  │    │ ← Task item (64dp min)
│  └─────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────┐    │
│  │ ▌ ML Assignment          Tonight 11:59 PM 🔴│    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  THIS WEEK                                          │
│  ┌─────────────────────────────────────────────┐    │
│  │ ▌ CN Lab Report          Fri Aug 2    🟡     │    │
│  └─────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────┐    │
│  │ ◆ Capstone Presentation  Sat Aug 3 2PM  🔵  │    │ ← Event (blue indicator)
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  UPCOMING                                           │
│  ┌─────────────────────────────────────────────┐    │
│  │ ▌ Patent Filing          4 days left   ⚪    │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
├─────────────────────────────────────────────────────┤
│  [🏠] [📅] [🗂▶] [⚙]                              │
│                     ◉ [floating orb]                │
└─────────────────────────────────────────────────────┘
```

---

## Section Tabs

```
Style (see design_system.md — Section Tab component):
Selected:   lime bg, black text, 2px black border
Unselected: transparent, secondary text, muted border

[All]:      Always first tab — shows everything in workspace
[+ Add]:    Always last tab — tap to create new section
            → Shows text input inline: "Section name..." + ✓ confirm

On tab switch:
  Content slides horizontally (200ms ease-in-out)
  Active tab animates to lime style
```

---

## Task / Event List Items

**Task item:**
```
Height:    min 64dp
Layout:
  Left:    4dp wide priority color stripe (flush to card left)
           ▌ = task indicator
  Content:
    Row 1: Task name — 16sp SemiBold white
           Priority badge (right) — chip style
    Row 2: Deadline chip — countdown style (see design_system)
           Section label (if viewing "All" tab) — secondary
  Right:   Checkbox — 24dp, 2px white border, 0 radius
           Tap: completes task with animation
```

**Event item:**
```
Height:    min 64dp
Left:      4dp blue (#4DFFFF) stripe + ◆ diamond indicator
Content:
  Row 1:   Event title — 16sp SemiBold white
  Row 2:   Date + time — 13sp secondary blue
Right:     Calendar icon (not checkbox — events aren't "completed")
```

---

## Workspace Options Menu (⋮)

```
Tap ⋮ in detail view:
  ┌──────────────────────────────┐
  │  ✏️  Edit workspace           │
  │  🎨  Change color / icon      │
  │  📦  Archive workspace        │
  │  ⬇️  Export tasks (JSON)      │
  └──────────────────────────────┘

All menu items: 16sp white, 2px white border on container, #1C1C1C bg
```

---

## Create New Workspace Flow

Triggered by [+ NEW] on workspace list OR [+ Add workspace] card:

```
┌─────────────────────────────────────────────────────┐
│  ← Cancel    New Workspace              [Create]    │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Name                                               │
│  ┌──────────────────────────────────────────────┐   │
│  │ GATE Prep                                    │   │ ← Text field (2px white border)
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  Icon (tap to pick emoji)                           │
│  [ 🎯 ]  [ 📚 ]  [ 💼 ]  [ 👤 ]  [ ❤️ ]  [ + ]     │ ← Emoji grid
│                                                     │
│  Color                                              │
│  [■] [■] [■] [■] [■] [■] [■]                       │ ← Color swatches (24dp circles)
│                                                     │
│  Preview:                                           │
│  ┌─────────────────────────────────────────────┐    │ ← Live preview card
│  │  🎯 GATE Prep                               │    │
│  │  TASKS: 0  EVENTS: 0                        │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Empty State (workspace has no tasks)

```
┌─────────────────────────────────────────────────────┐
│  (stats bento row — all zeros)                      │
├─────────────────────────────────────────────────────┤
│                                                     │
│            📭                                       │
│                                                     │
│      Nothing in GATE Prep yet.                      │ ← 17sp SemiBold
│                                                     │
│      Tap the orb and say something like:            │ ← 14sp secondary
│      "Add GATE algebra practice                     │
│       to GATE Prep workspace"                       │ ← Example in lime
│                                                     │
│      [  ◉  Tap to capture  ]                        │ ← CTA button (lime)
│                                                     │
└─────────────────────────────────────────────────────┘
```
