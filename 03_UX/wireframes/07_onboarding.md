# Wireframe: Onboarding Flow

> **Feature:** F-15 — Onboarding
> **Trigger:** First app launch only
> **Design:** 4 screens. Short. Action-oriented. Skippable.

---

## Flow Overview

```
App install → launch
      ↓
Screen 1: Welcome
      ↓
Screen 2: Permissions (3 sequential)
      ↓
Screen 3: First Workspaces
      ↓
Screen 4: Try It Now (live demo)
      ↓
Home Screen
```

---

## Screen 1: Welcome

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│                                                     │
│                                                     │
│                    ◉ A                              │ ← AURA orb (80dp, centered)
│                                                     │   Lime, ExtraBold A, black border
│                                                     │   Ambient glow (only glow allowed)
│                                                     │
│                   AURA                              │ ← 40sp ExtraBold white
│                                                     │
│         AI-Unified Reality Assistant                │ ← 15sp secondary
│                                                     │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│     One tap. You speak. Life organizes itself.      │ ← 18sp SemiBold white (tagline)
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│                                                     │
│                                                     │
│                                                     │
│  [         GET STARTED →         ]                  │ ← Primary CTA (lime, full width)
│                                                     │
│                Skip →                               │ ← Skip link (secondary, skip all)
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Screen 1 Specs
```
Background:   #0D0D0D (base)
Orb:          80dp, ambient pulse animation running
Tagline:      Appears after 400ms delay (fade in) for theatrical effect
GET STARTED:  Standard lime CTA
Skip:         14sp secondary — skips to Home screen directly
Progress:     Dot indicators [● ○ ○ ○] — lime active dot, white inactive
```

---

## Screen 2: Permissions

**Shown one permission at a time** (3 sequential sub-screens).

### 2a — Overlay Permission

```
┌─────────────────────────────────────────────────────┐
│                              ● ○ ○ ○  [Skip]        │ ← Progress + skip
├─────────────────────────────────────────────────────┤
│                                                     │
│                                                     │
│              ┌─────────┐                            │
│              │         │                            │ ← Phone mockup illustration
│              │   ◉A    │  ← orb floating            │
│              │         │      on top of other app   │
│              │ [Gmail] │                            │
│              └─────────┘                            │
│                                                     │
│  The AURA orb lives on top of all your apps         │ ← 20sp SemiBold white
│                                                     │
│  Press one button from anywhere — Gmail,            │ ← 14sp secondary
│  WhatsApp, Chrome — AURA is always there.           │
│                                                     │
│  [ GRANT OVERLAY PERMISSION ]                       │ ← Lime CTA
│                                                     │
│  This opens Android settings. Tap AURA → Allow.    │ ← 12sp secondary instruction
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 2b — Microphone Permission

```
Icon:         🎤 illustration (64dp, white on black bento card)
Title:        "AURA listens when you tap"
Description:  "Your voice is processed locally when possible.
               It is never stored without your knowledge."
CTA:          [GRANT MICROPHONE ACCESS]
```

### 2c — Notification Permission

```
Icon:         🔔 illustration
Title:        "AURA reminds you. Always."
Description:  "This is the most important permission.
               Without it, AURA can't remind you of deadlines."
CTA:          [ALLOW NOTIFICATIONS]
After grant:  "✓ Done. AURA will never let you miss a deadline."
```

### Permission Handling
```
Granted:     Green ✓ animation → auto-advance to next permission (1 second)
Denied:      Show: "[permission name] is important for AURA to work well.
                    You can enable it later in Settings."
             Button changes to: [CONTINUE ANYWAY →]
All done:    Auto-advance to Screen 3
```

---

## Screen 3: First Workspaces

```
┌─────────────────────────────────────────────────────┐
│                              ○ ○ ● ○  [Skip]        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  What are you working on right now?                 │ ← 22sp Bold white
│                                                     │
│  Tap to create your first workspaces.               │ ← 14sp secondary
│  AURA will detect more as you use it.               │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐                 │
│  │  📚 VIT      │  │  🎯 GATE Prep │                │ ← Suggestion chips (tap to select)
│  └──────────────┘  └──────────────┘                 │
│  ┌──────────────┐  ┌──────────────┐                 │
│  │  💼 Internship│  │  👤 Personal  │                │
│  └──────────────┘  └──────────────┘                 │
│  ┌──────────────┐  ┌──────────────┐                 │
│  │  ❤️ Health   │  │  + Custom... │                 │
│  └──────────────┘  └──────────────┘                 │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  Selected: [📚 VIT ✓] [🎯 GATE Prep ✓]             │ ← Selected state chips (lime bg)
│                                                     │
│  [     CONTINUE →     ]                             │ ← CTA (active after ≥1 selected)
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Screen 3 Specs
```
Suggestion chips: 2px white border, #141414 bg, emoji + name inside
Selected chips:   lime bg, black text, 2px black border
Custom chip:      Opens text input field inline to type workspace name
Minimum:          1 workspace must be selected to continue
CTA:              Disabled (secondary style) until at least 1 selected
                  Activates (lime) once ≥ 1 selected
```

---

## Screen 4: Try It Now

```
┌─────────────────────────────────────────────────────┐
│                              ○ ○ ○ ●  [Skip]        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  You're almost set.                                 │ ← 22sp Bold white
│                                                     │
│  Try AURA now. Tap the orb and say                  │ ← 14sp secondary
│  something like:                                    │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │  "ML assignment due Friday,                 │    │ ← Example prompt (bento card,
│  │   remind me a day before."                  │    │   lime border instead of white)
│  └─────────────────────────────────────────────┘    │
│                                                     │
│                                                     │
│                    ◉ A                              │ ← Large orb (72dp, centered)
│                                                     │   Pulsing gently
│              Tap to try →                           │ ← 13sp secondary below orb
│                                                     │
│                                                     │
│                                                     │
│                                                     │
│  [        SKIP FOR NOW →       ]                    │ ← Secondary CTA to skip demo
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Screen 4 Behavior
```
Tap orb:     Activates voice capture (same as real experience)
             Voice popup appears normally
             User speaks → AI processes → confirmation appears
After confirm: 
  Confetti / success animation
  Message: "✓ Your first task is saved. You're all set."
  [  OPEN AURA  ] CTA → goes to Home screen
  
Skip:        Goes directly to Home screen
             First workspace(s) already created from Screen 3
```

---

## Progress Indicator (all screens)
```
4 dots, bottom-center:
  Active:   Lime (#C8FF00) filled circle, 8dp
  Inactive: White 2dp border circle, 8dp
  Spacing:  12dp between dots
```

---

## Transition Animations

| Transition | Animation |
|------------|-----------|
| Screen 1 → 2 | Slide left, 300ms ease-in-out |
| Screen 2a → 2b | Slide left (within permissions group) |
| Screen 2 → 3 | Slide left |
| Screen 3 → 4 | Slide left |
| Screen 4 → Home | Fade to Home (not slide — feels like "launching") |
| Permission granted | Green checkmark bounce → 800ms wait → auto-advance |
| Workspace chip select | Lime fill animation: expands from tap point (200ms) |
