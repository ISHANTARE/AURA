# Wireframe: Morning Briefing Screen

> **Feature:** F-10 — Morning Briefing
> **Trigger:** Notification at briefing time (default 7:30 AM) → tapping opens this screen
> **Design:** Full screen, immersive. Replaces home screen temporarily.

---

## Screen Layout

```
┌─────────────────────────────────────────────────────┐
│  STATUS BAR                              [✕ Dismiss]│ ← Top bar (48dp) — minimal
├─────────────────────────────────────────────────────┤
│                                                     │
│  Good morning, Ishan T.                              │ ← 32sp ExtraBold white
│  Thursday, July 24                                  │ ← 16sp secondary
│                                                     │
│  ── 2 tasks due today. Yesterday: 3/5 done. ──      │ ← AI summary line (14sp secondary, italic)
│                                                     │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │  🔴 URGENT                                   │   │ ← Section 1 (bento card)
│  │  ─────────────────────────────────────────   │   │
│  │  ML Assignment        Due tonight 11:59 PM  →│   │
│  │  DBMS Quiz            Due today 2:00 PM     →│   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │  🎯 TODAY'S FOCUS         AI suggested  🤖   │   │ ← Section 2 (bento card)
│  │  ─────────────────────────────────────────   │   │
│  │  ① Complete feature engineering   ~2 hrs   →  │   │
│  │  ② Review GATE Algo PYQs          ~1 hr    →  │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │  📅 UPCOMING             Next 7 days         │   │ ← Section 3 (bento card)
│  │  ─────────────────────────────────────────   │   │
│  │  Internship standup      Thu · 10:00 AM     →│   │
│  │  Patent submission       4 days left        →│   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │  🔁 HABITS               Recurring today     │   │ ← Section 4 (bento card)
│  │  ─────────────────────────────────────────   │   │
│  │  Daily DSA    ✗ missed yesterday — do today? │   │
│  │  Exercise     ✓ done yesterday               │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  [  ▶  START MY DAY  ]                             │ ← Primary CTA (lime, full width)
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Component Breakdown

### Header

```
Greeting:  "Good morning, Ishan T." — 32sp ExtraBold, white
           Changes by time: "Good afternoon" / "Good evening"
Date:      "Thursday, July 24" — 16sp Regular, secondary
Spacing:   24dp below header before summary line
```

### AI Summary Line

```
Font:      14sp Regular, secondary, italic
Format:    "N tasks due today. Yesterday: X/Y done. [motivational note]."
AI-generated: personalized, not canned
Examples:
  "2 tasks due today. Yesterday: 3/5 done. Strong finish yesterday."
  "Clear day ahead. Yesterday: 5/5 done. Momentum is real."
  "3 deadlines this week. Yesterday: 1/4 done. Today's the day to catch up."
```

### Section Cards (all follow same bento card pattern)

**URGENT section**

```
Label:     "🔴 URGENT" — 11sp ALL CAPS, red (#FF3B3B)
Criteria:  Tasks/events due within 48 hours
Item row:  Task name (15sp SemiBold) + deadline chip (right) + → arrow
           Tap row: Opens task detail
Empty:     Hidden entirely (section not shown if nothing urgent)
```

**TODAY'S FOCUS section**

```
Label:     "🎯 TODAY'S FOCUS" — 11sp ALL CAPS, lime (#C8FF00)
Badge:     "AI suggested  🤖" — 11sp secondary, right-aligned in header
Criteria:  AI picks 2–3 tasks based on priority + deadline proximity + estimated time
Item row:  ① number (lime) + task name + "~N hrs" (secondary, right) + → arrow
Tap row:   Opens task detail
```

**UPCOMING section**

```
Label:     "📅 UPCOMING" — 11sp ALL CAPS, blue (#4DFFFF)
Subtitle:  "Next 7 days" — secondary
Item row:  Title + date/time or days remaining + → arrow
Events:    Blue left indicator
Tasks:     White left indicator
```

**HABITS section**

```
Label:     "🔁 HABITS" — 11sp ALL CAPS, purple (#B57BFF)
Item row:  Habit name + completion status indicator
Status:
  ✓ green: "done yesterday"
  ✗ red:   "missed yesterday — do today?" (prompts action)
  — gray:  "not yet today"
Tap ✗ row: Quick-marks habit done for today (green flash + haptic)
```

---

## "START MY DAY" Button

```
Style:     Full width lime CTA (standard primary button spec)
Label:     "▶  START MY DAY"
Tap:       Dismisses briefing → navigates to Home screen
           Briefing notification is cleared
```

## Dismiss [✕]

```
Position:  Top right
Style:     Small secondary button
Tap:       Dismisses full screen, goes to Home
           Same as "START MY DAY" functionally
```

---

## Notification Spec (precedes the screen)

```
Notification:
  Title:   "Good morning, Ishan T. ☀️"
  Body:    "2 urgent deadlines today. Daily DSA missed yesterday. Tap to see your plan."
  Action:  [Open Briefing] — opens this screen
  Style:   Expandable notification showing top 3 items inline
  Channel: AURA_BRIEFING (separate from reminder channel — user can mute independently)
```

---

## Edge Cases

| Situation | Behavior |
| ----------- | --------- |
| Nothing due, all done | Section: "✨ Clear Day — Nothing urgent today." Shows upcoming only |
| All tasks done | "All caught up! Here's what's coming next week." |
| First morning (no data) | Shows onboarding message instead of briefing |
| Offline | Still shows (data is local) — no AI content if never fetched |
| DND lifted items | Shows extra section: "WHILE YOU WERE IN DND" with missed reminders |

---

## DND Replay Section (conditional)

Shown only when DND was active and reminders fired during DND:

```
┌──────────────────────────────────────────────────┐
│  🔕 WHILE YOU WERE IN DND                        │
│  ────────────────────────────────────────────    │
│  ML Assignment reminder  (was 11:59 PM)  →       │
│  Team meeting at 10 AM   (in 45 minutes) →       │
└──────────────────────────────────────────────────┘
```

Time-sensitive items reworded:

- "Interview in 15 min" (fired 2 hrs ago) → "You had a reminder 2 hrs ago: Interview at VIT Placement Cell"

---

## Animations

| Event | Animation |
| ------- | ----------- |
| Screen enters | Slides up from bottom, full screen, 350ms ease-out |
| Section cards | Stagger in: slide up 8dp + fade, 50ms delay each |
| Summary line | Typewriter effect (optional — if feels premium, not gimmicky) |
| START MY DAY tap | Screen slides left → Home screen slides in from right |
| Dismiss tap | Screen slides down |
