# AURA — User Flow Diagrams

> **Phase:** 3 — UX Design
> **Purpose:** Map every critical user journey from trigger to resolution.
> **Format:** Text-based flow diagrams + step descriptions.

---

## Flow 1: Core Loop — Voice Capture to Task Saved

This is the most important flow in AURA. Every other flow is secondary to this.

```
User sees something important (email, WhatsApp, portal notification)
                         │
                         ▼
            Taps floating AURA orb
                         │
                         ▼
         Voice popup slides up (35% overlay)
         Background app remains visible
                         │
                         ▼
              Android SpeechRecognizer starts
              Live transcript appears
                         │
                    User speaks...
                    "ML assignment due Friday
                     at 11:59 PM, remind me
                     the day before"
                         │
                         ▼
            ┌────────────────────────┐
            │  Auto-stop (1.5s       │
            │  silence) OR user taps │
            │  "STOP & PROCESS"      │
            └────────────────────────┘
                         │
                         ▼
              Popup → "Thinking..." state
              Gemini API called with transcript
                         │
                 ┌───────┴────────┐
                 │                │
              Online          Offline
                 │                │
                 ▼                ▼
          AI parses        Saved to
          intent JSON      offline queue
                 │         "Saved as draft,
                 ▼         will process when
         Confirmation      connected"
            box appears         │
                 │              ▼
          User reviews    END (for now)
          parsed fields
                 │
        ┌────────┴────────┐
        │                 │
     Confirm            Edit
        │                 │
        ▼                 ▼
   Task saved       Edit mode
   to Drift DB      User modifies
   Reminders        fields
   scheduled             │
   Orb green flash       ▼
   + haptic         Save → same as Confirm
        │
        ▼
   User returned
   to background app
```

---

## Flow 2: Share-to-AURA (Screenshot)

```
User sees notification / assignment details in any app
                    │
                    ▼
         User takes screenshot
         OR shares from gallery
                    │
                    ▼
         Android Share Sheet appears
                    │
                    ▼
         User taps "AURA" from share targets
                    │
                    ▼
         AURA Share Activity opens
         Shows screenshot full-width
                    │
                    ▼
         Google ML Kit OCR runs (on-device)
         Extracts text from screenshot
                    │
                    ▼
         "What do you want to do with this?"
         AURA orb pulses (listening activates)
                    │
                    ▼
         User speaks: "This is the ML assignment
         deadline. Create a task."
                    │
                    ▼
         AI combines:
           - OCR text from screenshot
           - User's voice instruction
                    │
                    ▼
         Confirmation box (pre-filled
         with screenshot context)
                    │
                    ▼
         User confirms → task saved
         Screenshot attached to task
```

---

## Flow 3: Morning Briefing

```
AURA background service
monitors first-unlock time
over past 7 days
            │
            ▼
     Calculates optimal
     briefing time
     (avg first-unlock - 5 min)
            │
            ▼
     Briefing time arrives
            │
            ▼
     AI generates briefing:
     - URGENT tasks (< 48 hrs)
     - TODAY'S FOCUS (2-3 tasks)
     - UPCOMING (7 days)
     - HABITS status
     - Motivational line
            │
            ▼
     Push notification fires:
     "Good morning, Ishan T. ☀️
      2 urgent deadlines today..."
            │
     User taps notification
            │
            ▼
     Morning Briefing screen
     (full screen, immersive)
            │
    User taps any item → Task detail
    User marks habit done → Green flash
    User taps "START MY DAY"
            │
            ▼
     Home screen
```

---

## Flow 4: Reminder Fires During DND

```
Reminder scheduled to fire at 11:59 PM
                  │
                  ▼
       DND is active at 11:59 PM
                  │
                  ▼
       Android blocks notification
                  │
                  ▼
       AURA logs in notification_log:
       status = FIRED_DURING_DND
                  │
                  ▼
       BroadcastReceiver monitors
       DND state changes
                  │
                  ▼
       DND turns off (midnight / morning)
                  │
                  ▼
       AURA queries notification_log
       for FIRED_DURING_DND items
                  │
                  ▼
       Time-sensitive check:
       ┌──────────────────────────────┐
       │ Fired < 2 hours ago:         │
       │ → Fire original reminder     │
       │                              │
       │ Fired > 2 hours ago:         │
       │ → Reword: "You had a         │
       │   reminder 3 hrs ago: ..."   │
       └──────────────────────────────┘
                  │
                  ▼
       Batch summary notification:
       "While you were in DND:
        · ML Assignment reminder
        · Team meeting in 45 min"
                  │
                  ▼
       User taps → AURA home
       DND items shown in briefing
       if morning briefing hasn't fired yet
```

---

## Flow 5: New Workspace Auto-Creation via Voice

```
User speaks: "I'm preparing for GATE.
              Add a new task: solve 5 PYQs today."
                    │
                    ▼
         AI processes transcript
                    │
         Workspace detection:
         "GATE" keyword detected
                    │
         Check: Does "GATE Prep"
         workspace exist?
                    │
                ┌───┴───┐
               Yes      No
                │        │
                ▼        ▼
         Assign to   Show in confirmation box:
         existing    Workspace: [New: GATE Prep] ✨
         GATE Prep
                         │
                         ▼
                  User confirms
                         │
                         ▼
                  AURA creates workspace:
                  - name: "GATE Prep"
                  - color: auto-assigned
                  - created_by: AI_DETECTED
                         │
                         ▼
                  Task assigned to
                  new workspace
                         │
                         ▼
                  User can rename/recolor
                  workspace later in settings
```

---

## Flow 6: Onboarding → First Task

```
App first launch
       │
       ▼
Splash screen (AURA orb + name)
       │
       ▼
Screen 1: Welcome
"One tap. You speak. Life organizes itself."
       │ GET STARTED
       ▼
Screen 2a: Overlay permission
       │ Grant / Deny + Continue
       ▼
Screen 2b: Microphone permission
       │ Grant / Deny + Continue
       ▼
Screen 2c: Notification permission
       │ Grant / Deny + Continue
       ▼
Screen 3: Workspace selection
User taps [📚 VIT] [🎯 GATE Prep]
       │ CONTINUE
       ▼
Workspaces created in DB
       │
       ▼
Screen 4: Try It Now
User taps orb → speaks → confirms first task
       │ Task created
       ▼
"✓ Your first task is saved. You're all set."
       │ OPEN AURA
       ▼
Home screen (with first task visible)
```

---

## Flow 7: Task Completion

```
User sees task in any list view
            │
            ▼
       Tap checkbox on task
       OR tap "MARK AS DONE" in task detail
            │
            ▼
    Task strike-through animation
    Green flash (#39FF88)
    Haptic: medium impact
            │
            ▼
    Snackbar: "Done! Undo?" (5 seconds)
            │
      ┌─────┴──────┐
      │             │
   Undo (tap)    No action
      │             │
      ▼             ▼
  Task restored   Status = DONE
  to TODO         Task moves to completed section
                  All pending reminders cancelled
                  Completion logged with timestamp
```

---

## Flow 8: Recurring Task Daily Cycle

```
Midnight reset (AURA background service)
            │
            ▼
    All recurring tasks
    reset to PENDING for new day
            │
            ▼
    Morning briefing includes
    today's recurring tasks
            │
            ▼
    Reminder fires at
    user-set time (e.g., 9 PM)
    "Daily DSA — not done yet"
            │
    ┌───────┴───────┐
    │               │
  Done          Dismissed
    │               │
    ▼               ▼
  Mark done     Re-remind in
  Green flash   30 minutes
  Logged for    (snooze behavior)
  today
    │
    ▼
Next midnight: check yesterday's status
If missed:
  → Log "missed" in daily_log
  → Morning briefing next day:
    "Missed DSA yesterday.
     Add a makeup session today?"
  → Gentle roast notification
    "The algorithm you skipped
     yesterday is still waiting."
```
