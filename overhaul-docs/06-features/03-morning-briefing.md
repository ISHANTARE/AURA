# Feature Specification: Morning Briefing & Proactive Nudge Engine

> **Forensic Rebuild Specification**  
> Complete specification for AURA's daily morning briefing scheduler, briefing UI presentation, and proactive AI nudge engine.

---

## 1. Daily Morning Briefing Architecture

AURA automates the start-of-day planning ritual through a scheduled morning summary notification paired with a full-screen dashboard:

```
[ App Launch / Unlock Event ] ──► BriefingSchedulerService.onAppActive()
                                         │
                                         ├─ Already scheduled today? → No-op
                                         └─ Schedule for target hour (default 7:00 AM)
                                                │
                                                ▼
                                   NotificationIds.briefing (10001)
                                   Payload: "route:/briefing"
                                                │
                                                ▼ User taps notification
                                   MorningBriefingScreen (/briefing)
```

---

## 2. Scheduling Intelligence (`BriefingSchedulerService`)

`BriefingSchedulerService` runs on every app resume / active lifecycle transition:

1. **First-Unlock Time Tracking**:
   - Records device first-unlock epoch milliseconds into `SharedPreferences` key `briefing_first_unlock_ms`.
   - Guarded per calendar day (`_isSameDay(existingUnlock, now)`).
2. **Scheduling Decision Tree**:
   - Reads `BRIEFING_HOUR` from `SharedPreferences` (Default: `7`, range `5` to `10`).
   - `target = DateTime(year, month, day, BRIEFING_HOUR, 0)`.
   - **Case A: `now < target`**: Schedules today's briefing at `target` (e.g. 7:00 AM).
   - **Case B: `now >= target` AND `now < 9:00 AM`**: Late-wake fallback -> schedules for today at `09:00 AM`.
   - **Case C: `now >= 9:00 AM`**: User unlocked late or briefing window has passed -> schedules tomorrow at `BRIEFING_HOUR`.
3. **Dynamic Notification Body Composition**:
   - Live query: `ItemDao(db).watchTodayFocus().first`.
   - If empty -> `"Nothing due today — enjoy the calm start."`
   - If 1 item -> `"1 item today · Top: <title>"`
   - If N items -> `"<N> items today · Top: <title>"`
4. **Idempotency Guard**:
   - Stores `briefing_scheduled_date = 'briefing_yyyy_M_d'`.
   - Ensures the briefing notification is scheduled exactly once per calendar day.

---

## 3. Morning Briefing Screen (`MorningBriefingScreen`)

Accessible via deep-link `route:/briefing` or in-app navigation:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ [X] MORNING BRIEFING                                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│ Good morning, Ishan T                                                       │
│ Saturday, August 29                                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│ ── TODAY AT A GLANCE ────────────────────────────────────────────────────── │
│ ┌───────────────────┐ ┌───────────────────┐ ┌───────────────────┐           │
│ │ 3 Pending (Lime)  │ │ 2 Completed(Green)│ │ 1 Overdue (Red)   │           │
│ └───────────────────┘ └───────────────────┘ └───────────────────┘           │
├─────────────────────────────────────────────────────────────────────────────┤
│ ── TODAY'S FOCUS ────────────────────────────────────────────────────────── │
│ 1. [HIGH] Submit semester project report (05:00 PM)                         │
│ 2. [MED]  Team Standup & Sprint Planning (09:30 AM)                         │
│ 3. [LOW]  Review medical prescription notes                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│ ── URGENT ALARMS & DEADLINES ────────────────────────────────────────────── │
│ ⏰ 07:00 AM · Morning Wake-up Alarm                                         │
│ ⚠️ 05:00 PM · Project Submission Portal Close                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│ [                          START THE DAY →                                ] │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Screen Visual & Data Specifications

1. **Header & Greeting**:
   - Generates greeting from `timeAwareGreeting(now.hour, userName)` using live `userNameProvider`.
   - Displays sub-header date: `DateFormat('EEEE, MMMM d').format(now)`.
2. **Today at a Glance**:
   - Three neo-brutalist metric cards: Pending, Completed, Overdue (`quickStatsProvider`).
3. **Today's Focus List**:
   - Streams `todayFocusItemsProvider` (top 5 priority tasks due today).
   - Shows index number, priority pill, task title, and formatted deadline time.
   - Tapping any item pushes `Routes.taskRoute(item.id)`.
4. **Urgent Alarms & Deadlines**:
   - Streams `urgentItemsProvider` (top 3 critical alarms or high-priority deadlines).
5. **Primary CTA**:
   - High-contrast `"START THE DAY →"` button navigates directly to `Routes.home`.

---

## 4. Proactive AI Nudge Engine (`NudgeEngine`)

`NudgeEngine` evaluates ambient context on app foregrounding to fire gentle focus prompts:

### Nudge Firing Rules

1. **Quiet Hours Guard**: Never fires between **11:00 PM and 07:00 AM** (`now.hour >= 23 || now.hour < 7`).
2. **Spacing Guard**: Enforces a minimum interval of **3 hours** between consecutive nudges (`last_nudge_ms` in `SharedPreferences`).
3. **Daily Cap Guard**: Maximum of **3 nudges per calendar day** (`nudge_count_yyyy_M_d`).
4. **Target Selection & Rotation**:
   - Scans active items for `status != 'completed' && priority == 'high'`.
   - Rotates through targets using `nudge_rotate_idx` to prevent repeatedly nagging the user about the same task.
5. **Notification Dispatch**:
   - ID: `NotificationIds.nudge` (`10003`).
   - Title: `"Proactive Nudge"`
   - Body: `"Focus time: Ready to complete \"<title>\"?"`
   - Payload: `"item:<targetItemId>"`
