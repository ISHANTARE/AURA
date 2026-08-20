# Wireframe: Confirmation Box

> **Feature:** F-03 — Confirmation Box
> **Trigger:** Shown after AI processes voice/text input
> **Design:** Bottom sheet, same position as voice popup (morphs in)

---

## Core Principle

AURA NEVER saves anything silently. Every AI action has a human review step.
This screen is the review step. It must be:
- Fast to approve (one tap)
- Easy to edit (tap any field)
- Clear about what AI understood vs. what it's uncertain about

---

## Screen Layout

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  [Background app — still partially visible]         │ ← Same as voice popup (65% visible)
│  [Dimmed with rgba(0,0,0,0.4) scrim]               │
│                                                     │
├─────────────────────────────────────────────────────┤ ← 2px solid white border (top+sides)
│                                                     │
│  ◉A  AURA understood:                               │ ← Header row
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │  📋  ML Assignment                      ✏️   │   │ ← Title row (editable)
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  📅  Deadline     Fri, Aug 1 · 11:59 PM    ✏️       │
│  🔔  Reminders    Thu Jul 31 · 11:59 PM            │
│                   Fri Aug 1 · 05:00 AM             │
│  🗂️  Workspace   [ VIT > Subjects  auto ]   ✏️      │
│  ⚡  Priority    [ MEDIUM ]                ✏️       │
│  🔁  Recurring   No                        ✏️       │
│                                                     │
│  ────────────────────────────────────────────────  │
│                                                     │
│  [     ✓  CONFIRM & SAVE     ]  [  ✏️  EDIT ALL  ] │
│                                                     │
│  Start over                                         │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Component Breakdown

### Header
```
Left:    Mini orb (32dp, lime, processing → idle animation completes)
Text:    "AURA understood:" — 14sp SemiBold, secondary
         Transitions from "Thinking..." state
```

### Title Row
```
Icon:    📋 16dp
Label:   "Task" or "Event" — 11sp ALL CAPS secondary
Title:   Extracted task name — 17sp SemiBold white, full width
Edit:    ✏️ icon right — tap to make inline editable
         When editing: text becomes editable, keyboard opens
Uncertain flag: if AI confidence on title < 0.7 → amber dot left of title
```

### Field Rows (consistent pattern)

Each row:
```
Icon:    emoji or icon, 16dp
Label:   field value — 15sp white (or secondary if not set)
Edit:    ✏️ icon (right) — tap to edit this field inline
Auto:    "[auto]" chip appears when AI detected (not user-stated)
Uncertain: amber dot when confidence < 0.7
Missing:   "Tap to add [field]" — secondary italic
```

**Deadline row:**
```
Set:     "Fri, Aug 1 · 11:59 PM" — white
Not set: "No deadline — tap to set" — secondary italic, slightly amber
Past:    Red text + ⚠️ icon "This date is in the past"
Edit:    Opens DateTime picker (Material date picker, styled to match design system)
```

**Reminders row:**
```
Shows:   Each reminder on its own line — "Thu Jul 31 · 11:59 PM"
           "Fri Aug 1 · 05:00 AM"
Source:  "(from your voice)" or "(AURA default)" in tiny secondary below list
Edit:    ✏️ → opens reminder editor (add/remove/change each reminder)
```

**Workspace row:**
```
Format:  "WorkspaceName > SectionName" (if section detected)
         "WorkspaceName" (if no section)
         "Select workspace" (if none detected) — amber, prompts user
Badges:
  [auto]     → AI detected, not user-stated. Amber chip.
  [new]      → Workspace doesn't exist yet, will be created on confirm
  [new section] → Section doesn't exist, will be created on confirm
Edit:    ✏️ → opens workspace picker (list of existing + "Create new")
```

**Priority row:**
```
Shows:   Colored chip: [HIGH 🔴] [MEDIUM 🟠] [LOW ⚫]
Edit:    Tap chip → cycles through HIGH / MEDIUM / LOW inline
```

**Recurring row:**
```
Default: "No"
Set:     "Daily" / "Weekly Mon, Wed, Fri" / custom
Edit:    ✏️ → opens recurrence picker
```

---

## Action Buttons

### Primary — CONFIRM & SAVE
```
Style:    Full width, lime #C8FF00 bg, black text, 2px black border, 4px black shadow
Label:    "✓  CONFIRM & SAVE" — 16sp Bold
Tap:      1. Write to Drift DB (task + reminders + workspace)
          2. Schedule Android notifications
          3. Orb flashes green → haptic (medium)
          4. Sheet slides down (dismiss)
          5. User returned to their background app
```

### Secondary — EDIT ALL
```
Style:    Right of confirm, secondary button style (transparent, white border)
Label:    "✏️  EDIT ALL" — 15sp SemiBold
Width:    ~120dp
Tap:      Expands confirmation box to full edit mode (all fields become input)
```

### Tertiary — Start over
```
Style:    Text link, small, center-aligned below buttons
Label:    "Start over" — 13sp secondary
Tap:      Shows "Discard and re-record?" → Yes/No
          Yes: goes back to voice capture state
```

---

## Confidence Indicators

| AI confidence | Visual treatment |
|--------------|-----------------|
| ≥ 0.85 (high) | No indicator — field shown as-is |
| 0.5–0.84 (medium) | Amber dot (4dp) left of value + "[auto]" chip |
| < 0.5 (low) | Amber dot + value shown in amber color + "?" suffix |
| Missing entirely | "Tap to add [field]" — secondary italic |

Example uncertain workspace:
```
🗂️  Workspace   [ VIT > Subjects ? ]  [auto]   ✏️
```

---

## Edit Mode (when user taps "EDIT ALL")

The sheet expands upward to full-screen height (or 90% height):

```
┌─────────────────────────────────────────────────────┐
│  ← Back    Edit Task              [Save]             │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Task name                                          │
│  ┌──────────────────────────────────────────────┐   │
│  │ ML Assignment                                │   │ ← Text field
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  Deadline                                           │
│  [  Fri, Aug 1  ]  [  11:59 PM  ]                  │ ← Date + Time pickers
│                                                     │
│  Reminders  [+ Add reminder]                        │
│  ┌──────────────────────────────────┐               │
│  │ 1 day before deadline    [✕]    │               │
│  │ 6 hours before deadline  [✕]    │               │
│  └──────────────────────────────────┘               │
│                                                     │
│  Workspace                                          │
│  [VIT ▾]  Section: [Subjects ▾]                     │ ← Dropdowns
│                                                     │
│  Priority                                           │
│  [ HIGH ]  [ MEDIUM ▶ ]  [ LOW ]                   │ ← Selector (active = lime)
│                                                     │
│  Recurring                                          │
│  [ OFF ▶ ]  [ DAILY ]  [ WEEKLY ]  [ CUSTOM ]      │
│                                                     │
│  Notes                                              │
│  ┌──────────────────────────────────────────────┐   │
│  │ (optional free text)                         │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  [         SAVE CHANGES          ]                  │
└─────────────────────────────────────────────────────┘
```

---

## Edge Cases

| Situation | Behavior |
|-----------|---------|
| AI extracted past deadline | Red warning: "This date is in the past" — user must acknowledge before save |
| Duplicate task exists | Warning chip: "Similar: [task name]. Add anyway?" with [Add Anyway] [View Existing] |
| Workspace doesn't exist | "[New: GATE Prep]" badge — auto-created on confirm |
| No workspace detected | Workspace field shows in amber — mandatory before save |
| AI failed to parse | All fields empty/secondary — "AURA couldn't understand. Fill manually." |
| Network offline at confirm | Saves fully locally — no network needed for DB write |
| User dismisses by tapping outside | "Discard this?" → Yes / No |

---

## Animations

| Event | Animation |
|-------|-----------|
| Sheet appears | Morph from voice popup (content cross-fades, sheet stays) 300ms |
| Field edited | Inline text appears, keyboard slides up |
| Confirm tapped | Orb flashes #39FF88 → sheet slides down 300ms |
| Error (missing field) | Field row shakes 3x horizontally (200ms) |
