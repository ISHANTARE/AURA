# AURA — Product Discovery

> Phase 1 output: mapping the real user's life, pain points, and requirements
> through direct Q&A. This is the raw material for the PRD.
>
> User: Ishant | Date: 2026-07-23

---

## 1. The Canonical Story — Why AURA Exists

> "I forgot to go for a physical interview during ongoing placements."

**What happened, step by step:**
1. Ishant learned about the interview → through some channel (likely WhatsApp/portal)
2. Captured it in 3 places: mental note + screenshot + told roommate
3. Roommate was in class and forgot to remind him
4. Ishant also forgot
5. Interview missed

**Root cause:** Information existed — but in 3 lossy, unreliable places simultaneously.
No single source was authoritative. None had a reliable reminder attached.

**What AURA would have done:**
- One tap → speak → "Interview [company] today at [time], physical, [location]"
- Confirmation box → confirm
- Reminder auto-fires: 1 day before, morning of, 1 hour before, 15 min before
- Even if DND was on → notification replays the moment DND is turned off

**This story is the north star of every design decision in AURA.**

---

## 2. The User's Life

### Contexts (Workspaces)
Ishant's life spans multiple parallel contexts. These are NOT predefined — AURA should
create and manage workspaces dynamically based on what Ishant tells it.

Known contexts (partial — more exist):
- VIT coursework (classes, assignments, quizzes, labs, attendance)
- IIT/GATE preparation
- Personal projects (AI, product building, etc.)
- Internship work
- Placements (interviews, assessments, coding rounds)
- Health / fitness
- Personal / social

Key insight: **The list is open-ended.** Workspaces are created on-the-fly.
If Ishant says "I'm preparing for GATE" → AURA creates a GATE workspace, no manual setup.

### Current Productivity System (Before AURA)
| Method | Usage | Reliability |
|--------|-------|-------------|
| Mental notes | Primary | Very low |
| Random paper | Occasional | Low (lost easily) |
| Setting an alarm | Rare | Medium (no context) |
| Screenshots | Common | Low (buried in gallery) |
| Telling friends/roommate | Common | Very low (they forget too) |

**Assessment:** No system. Completely reactive. AURA replaces all of this with one reliable pipeline.

---

## 3. Input Modes

### Primary: Voice
- One tap on floating button → speak → confirmation box
- Comfortable using voice in public
- Voice is always the fastest path

### Secondary: Typing
- Available but not the primary flow
- Used when voice isn't practical

### Third: Share-to-AURA
When Ishant sees something important in another app:
- Share button → AURA
- AURA receives: screenshot, link, document, media

**Behavior by type:**

| Shared content | AURA behavior |
|---------------|---------------|
| Screenshot (WhatsApp msg, college portal, etc.) | Shows the screenshot, asks "What do you want to do with this?" → Ishant responds by voice |
| Link (Google Form, article, portal) | AURA opens it, reads it, saves the full context. Searchable later by description |
| Document/PDF | Classify, extract key info, attach to relevant task/workspace |
| Media | Classify and store |

**Key requirement:** Everything shared to AURA is organized, classified, and searchable.
If Ishant says "find that Google Form about the sports fest", AURA finds it.

---

## 4. The Floating Button (Primary Entry Point)

| Property | Spec |
|----------|------|
| Always visible | Yes — on top of all apps, all times |
| Appearance | Small orb with AURA logo — aesthetically premium |
| Movable | Yes — drag to anywhere on screen |
| Position persistence | Persists across app switches AND phone restarts |
| Exceptions | User can toggle it off, but it auto-restores on restart |

Secondary entry points:
- **Home screen widget** — for quick glance at today's tasks (not primary capture)
- Long-press power is too slow — not a priority

---

## 5. After Voice Input — The Confirmation Flow

```
User taps orb → speaks command
        ↓
AURA processes (AI extracts intent)
        ↓
Floating confirmation box appears:
  ┌─────────────────────────────────────┐
  │ 📋 Task: ML Assignment              │
  │ 📅 Deadline: Friday, Aug 1, 11:59PM │
  │ 🔔 Reminders: 1 day before,         │
  │                6 hrs before          │
  │ 🗂️ Workspace: VIT [auto-detected]   │
  │                                      │
  │   [✓ Confirm]    [✏️ Edit]           │
  └─────────────────────────────────────┘
        ↓                    ↓
   Task created          Edit mode opens
```

**Rules:**
- AURA NEVER finalizes anything without this confirmation step
- Workspace is auto-detected and shown — user can change it
- Edit opens the task detail for modification
- Confirmation is one tap

---

## 6. Reminder System

### Default Reminder Templates (by task type)

| Task Type | Default Reminders |
|-----------|-------------------|
| Assignment / submission | 1 day before + 6-7 hours before deadline |
| Project milestone | Twice daily (morning + evening) starting 1 week before |
| Interview / meeting / event | 1 day before + morning of + 1 hour before + 15 min before |
| Recurring task | Daily at a set time (user specifies) |
| Custom | User specifies in voice input — overrides defaults |

**Rule:** User's voice input always overrides defaults.
If Ishant says "remind me every 3 hours starting tomorrow" — that's what happens.

### Snooze Behavior
| User action | AURA behavior |
|-------------|--------------|
| Dismiss notification | Auto re-remind in 30 minutes |
| Stop notification | Cancelled — no further reminders for this instance |
| Voice snooze | Options: "1 hour" / "Tonight" / "Tomorrow morning" |

### DND Behavior
- AURA respects DND (does not break through)
- When DND is turned off → ALL missed AURA notifications replay immediately
- No notification is ever silently dropped

---

## 7. Recurring Tasks

**Definition:** A task that repeats daily for a minimum of 2 weeks.

Examples:
- Daily DSA practice
- Exercise / gym
- GATE PYQ review
- Medication / habit tracking

**Check-off behavior:**
- Notification fires at scheduled time
- Dismiss → re-remind later (same as regular notifications)
- Mark done → logged as completed for the day
- Auto-resets at midnight for the next day

**Missed day behavior (all three apply):**
1. Logged as "missed" in history
2. Ask: "You missed DSA yesterday. Add a makeup session today?"
3. Gentle roast (humor) — e.g., "Yesterday's DSA said it missed you. Did you miss it too?"

---

## 8. Morning Briefing

### Smart timing
| Condition | Briefing time |
|-----------|--------------|
| Slept before ~1 AM | 7:00 - 7:30 AM |
| Slept late | 8:30 - 9:00 AM |

Future: AURA could detect sleep pattern from phone usage data to auto-adjust briefing time.

### Format (v1 — evolves with use)
```
Good morning, Ishant. [Day, Date]

🔴 URGENT (due < 48 hours):
  → ML Assignment — due tomorrow 11:59 PM
  → DBMS Quiz — today 2 PM

🎯 TODAY'S FOCUS (AI suggested):
  → Complete feature engineering (~2 hrs)
  → Review GATE Algorithms PYQs (~1 hr)

📅 UPCOMING:
  → Internship standup — Thursday 10 AM
  → Patent submission — 4 days left

🔁 RECURRING:
  → Daily DSA — ✗ missed yesterday
  → Exercise — ✓ done

💬 AURA's note: You have 3 deadlines this week.
   Yesterday you completed 2/4 tasks. Keep going.
```

Delivery: Both notification AND in-app screen. User sees whichever they open first.

---

## 9. Proactive Nudges (Push-to-Work)

Ishant explicitly acknowledged he gets lazy/postpones.
AURA is given permission to be an aggressive (but kind) productivity coach.

All of these are approved:
- "You haven't logged progress on X in 2 days. Want to work on it now?"
- "Based on deadlines, start Y today or you'll rush by Friday"
- "You've been productive today! 3 done, 2 remaining."
- "It's 10 PM and you haven't done daily DSA. Start now?"
- "You have free time right now. Want a task suggestion?"

**Timing:** Varies by day since Ishant's schedule differs each day of the week.
Future: AURA learns the weekly pattern over time and sends nudges at optimal times.

---

## 10. Workspace System

### Dynamic Creation
- No predefined workspace list
- Workspaces are created on-the-fly from conversation
- Example: "I'm preparing for GATE" → AURA creates GATE workspace automatically

### Assignment Flow
1. Ishant mentions workspace in voice input → used directly
2. AURA auto-detects from keywords → shown in confirmation box
3. User confirms or corrects in the confirmation box
All three happen together — guess + show + confirm.

### Multi-workspace tasks
- A task CAN belong to multiple workspaces
- Ishant explicitly mentions it in the voice input
- Example: "This is for both VIT project and my internship"

---

## 11. Task vs Event (Open Question)

**Status:** Not fully resolved. Ishant wants to think about it.
Architecture must support both and the distinction between them.

**Working definition for now:**
- **Task** = something you DO (assignment, study session, coding practice)
- **Event** = something you ATTEND (interview, class, meeting, standup)

**Key difference in behavior:**
- Events block time on the calendar
- Tasks are deadline-bound but don't block specific time unless scheduled

**Future:** AURA may auto-classify based on keywords and context.

---

## 12. Privacy Model

- AURA only knows what Ishant explicitly shares with it
- No background data collection from other apps
- No scraping Gmail, WhatsApp, or any other source
- If AURA knows about something, Ishant chose to share it

---

## 13. Development Philosophy

> "There is no failing, only learning and improving."

- Build → use → feel friction → fix
- Requirements will evolve through actual usage
- No rigid feature set — AURA is a living product
- Desktop version is a future milestone; mobile architecture must be future-proof

---

*Phase 1 Status: COMPLETE*
*Next: Phase 2 — Product Requirements Document (PRD)*
*Created: 2026-07-23*
