# Feature Specification: Daily Cockpit & Home Screen

> **Forensic Rebuild Specification**  
> Complete specification for the primary AURA home screen, Bento Grid dashboard, Date Navigator, Day Agenda timeline, and Overdue Triage system.

---

## 1. Screen Architecture & Visual Layout

The Home Screen (`HomeScreen`) serves as AURA's Daily Cockpit. It integrates live reactive database streams into a high-density, neo-brutalist Bento Box layout:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ [Avatar] Good morning, Ishan T          [Sync Badge] [Settings Cog]         │
│ Saturday, August 29, 2026                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│ ┌───────────────────────────────────────┐ ┌───────────────────────────────┐ │
│ │ TODAY'S FOCUS                         │ │ OVERDUE TASKS (If > 0)        │ │
│ │ 3 Pending · 2 Completed               │ │ 2 items past due              │ │
│ │ [ Progress Ring / Bar: 40% Complete ] │ │ [ TRIAGE NOW → ]              │ │
│ └───────────────────────────────────────┘ └───────────────────────────────┘ │
│ ┌───────────────────────────────────────┐ ┌───────────────────────────────┐ │
│ │ FLOATING ASSISTANT ORB                │ │ QUICK STATS ROW               │ │
│ │ Active on Screen · [ HIDE ORB ]       │ │ 3 Pending · 2 Done · 1 Overdue│ │
│ └───────────────────────────────────────┘ └───────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────────────────┤
│ ── AURA DATE NAVIGATOR (7-Day Strip with Activity Dots) ─────────────────── │
│   [Mon 24]  [Tue 25]  [Wed 26]  [Thu 27]  [Fri 28]  [SAT 29]★  [Sun 30]     │
├─────────────────────────────────────────────────────────────────────────────┤
│ ── DAY AGENDA VIEW ─────────────────────────────────────────────────────────│
│ Filter: [ (•) All ] [ Pending Only ] [ Completed Only ]                     │
│                                                                             │
│ TIMED ITEMS (Chronological Events & Alarms)                                 │
│ ┌─────────────────────────────────────────────────────────────────────────┐ │
│ │ 09:30 AM  • Team Standup & Sprint Planning (Work Workspace)            │ │
│ │ 02:00 PM  • Interview Prep Session (IIT Prep Workspace)                 │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│ ANYTIME CHECKLIST                                                           │
│ ┌─────────────────────────────────────────────────────────────────────────┐ │
│ │ [ ] Submit semester project report                                      │ │
│ │ [x] Review medical prescription notes                                   │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Header Components

1. **User Avatar & Greeting**:
   - Initial circle avatar styled with active `ThemeAccent` color.
   - Dynamic greeting generated via `timeAwareGreeting(now.hour, userName)`:
     - 05:00 - 11:59 -> *"Good morning, <name>"*
     - 12:00 - 16:59 -> *"Good afternoon, <name>"*
     - 17:00 - 21:59 -> *"Good evening, <name>"*
     - 22:00 - 04:59 -> *"Working late, <name>"*
   - Date String: Formatted as `EEEE, MMMM d` (e.g. *"Saturday, August 29"*).
2. **Sync Status Badge (`SyncStatusBadge`)**:
   - Online: Subtly displays green online indicator.
   - Offline: Displays amber/red `"Offline (Local Mode)"` badge.
3. **Settings Navigation**:
   - Tap gear icon -> `context.push(Routes.settings)`.

---

## 3. Bento Grid Modules (`home_bento_cells.dart`)

### 3.1 Focus Progress Card (`TodayStatsCard`)
- **Data Source**: `todayStatsProvider` (calculates `pending` and `completed` counts for `targetDate == Today`).
- **Visuals**: Displays ratio of completed tasks to total tasks, percentage progress bar colored with active `ThemeAccent`.

### 3.2 Overdue Alert Banner (`OverdueBentoCard`)
- **Visibility**: Only rendered if `overdueItemsProvider` contains > 0 items.
- **Visuals**: Neon red border and warning badge (`LucideIcons.alertTriangle`). Shows count of overdue tasks and oldest past-due title.
- **Action**: Tap opens `OverdueTriageSheet` modal.

### 3.3 Floating Orb Controller (`FloatingOrbCard`)
- **Data Source**: `OverlayChannel.isRunning()`.
- **Status Display**: Shows `"Active on screen"` (accent text) or `"Inactive / Dismissed"` (muted text).
- **Button**: Toggles between `"SHOW ORB"` and `"HIDE ORB"`. Requests `SYSTEM_ALERT_WINDOW` permission if missing.

### 3.4 Quick Stats Row (`QuickStatsRow`)
- **Data Source**: `quickStatsProvider`.
- Three tiles side-by-side:
  1. `Pending`: Lime accent (`AuraColors.accentLime`).
  2. `Completed`: Green accent (`AuraColors.accentGreen`).
  3. `Overdue`: Red accent (`AuraColors.accentRed`) if > 0, else muted.

---

## 4. Date Navigator Strip (`AuraDateNavigator.dart`)

- **State Provider**: `selectedDateProvider` (`StateProvider<DateTime>`).
- **Week Window**: Displays a 7-day strip (Monday to Sunday) containing the anchor week.
- **Activity Badges**: `weekActivityMapProvider` streams task counts per day (`yyyy-MM-dd`) to draw small activity dots beneath days with pending tasks.
- **Interaction**:
  - Tapping any date updates `selectedDateProvider`, immediately refreshing `dayAgendaProvider`.
  - Today is always outlined with a bold accent border and star icon.
  - Left / Right arrows navigate between prior and future weeks.

---

## 5. Day Agenda Timeline (`day_agenda_view.dart`)

- **Filter Bar**: `selectedDayFilterProvider` (`DayFilter.all`, `DayFilter.pendingOnly`, `DayFilter.completedOnly`).
- **Sections**:
  1. **Timed Items**:
     - Includes: `kind == 'event'`, `category == 'alarm'`, or tasks with explicit hours/minutes (not `00:00` or `23:59`).
     - Chronological sorting: earliest timestamp first.
     - Displays: Time pill (e.g. `09:30 AM`), category icon, workspace badge, title, location (for events), and ringtone icon (for alarms).
  2. **Anytime Checklist**:
     - Standard tasks and reminders due on the selected day without specific clock times.
     - Checkbox: Interactive toggle. Checking completes the item, sets `doneAt = nowMs`, and logs to `daily_logs`.
     - Swipe Actions:
       - Swipe Left -> Soft-delete item (cancels OS notifications).
       - Swipe Right -> Snooze item (+30m, +1h, Tomorrow).
  3. **Empty State**:
     - If no items exist for the date: displays `"Nothing scheduled for this day"` with an `"Add Task"` quick-entry button.

---

## 6. Overdue Triage Sheet (`overdue_triage_sheet.dart`)

A modal bottom sheet enabling rapid batch operations on overdue items:

1. **Item Inspection List**: Scrollable list of overdue items showing title, workspace, and exact time elapsed since deadline.
2. **Batch Action Buttons**:
   - **Reschedule to Today**: Updates `fireAt` and `deadline` to today at 09:00 AM, re-syncs notifications via `ReminderSchedulingService`.
   - **Reschedule to Tomorrow**: Updates timestamps to tomorrow at 09:00 AM, re-syncs notifications.
   - **Mark All Completed**: Sets `status = 'completed'` and `doneAt = nowMs` for all listed items.
   - **Dismiss / Delete All**: Soft-deletes all listed items and cancels their OS alarms.
