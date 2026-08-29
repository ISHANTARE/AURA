# Feature Specification: Settings & Task Detail Editor

> **Forensic Rebuild Specification**  
> Complete specification for AURA's comprehensive Settings management, encrypted credential storage, full database export/reset, and Task Detail editor.

---

## 1. Settings Screen Specification (`SettingsScreen`)

The Settings Screen is divided into 10 structured management sections:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ SETTINGS                                                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ 1. USER PROFILE                                                             │
│    [Avatar 'I'] Display Name: [ Ishan T                                   ] │
├─────────────────────────────────────────────────────────────────────────────┤
│ 2. COLOR THEME ACCENT & MODE                                                │
│    Theme Mode: [ Moon (Dark) ] / [ Sun (Light) ]                            │
│    Accents: (•) Indigo  ( ) Cyan  ( ) Purple  ( ) Orange  ( ) Rose          │
├─────────────────────────────────────────────────────────────────────────────┤
│ 3. FLOATING ASSISTANT ORB                                                   │
│    System Floating Orb: Active on screen · [ HIDE ORB ]                     │
├─────────────────────────────────────────────────────────────────────────────┤
│ 4. SOUNDS & RINGTONES                                                       │
│    Alarm Audio: "Beep Ringtone" · [ PICK AUDIO ]                            │
│    Notification Audio: "Chime" · [ PICK AUDIO ]                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ 5. REMINDER DEFAULTS                                                        │
│    Default Reminder: [ 1 day & 6 hours before deadline ▼ ]                  │
├─────────────────────────────────────────────────────────────────────────────┤
│ 6. MORNING BRIEFING                                                         │
│    Briefing Hour: [ 7:00 AM ▼ ]                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ 7. VOICE INPUT LANGUAGE                                                     │
│    Speech Recognition: [ Device default ▼ ] (13 Locales Available)          │
├─────────────────────────────────────────────────────────────────────────────┤
│ 8. AI ENGINE & LLM API                                                      │
│    Provider Preset: [ Google Gemini (Recommended) ▼ ]                       │
│    Base URL: [ https://generativelanguage.googleapis.com/v1beta/openai/   ] │
│    Model Target: [ gemini-2.0-flash                                       ] │
│    Quick Chips: [ gemini-2.0-flash ] [ gemini-1.5-flash ] [ gemini-1.5-pro ]│
│    API Key: [ •••••••••••••••••••••••• ] [ 👁 ]                             │
│    [ Free Gemini Key Card: 100% Free at Google AI Studio ]                  │
│    [                        SAVE ALL SETTINGS                             ] │
├─────────────────────────────────────────────────────────────────────────────┤
│ 9. WORKSPACES & ARCHIVE                                                     │
│    Archived Workspaces: 2 · [ RESTORE ]                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│ 10. DATA MANAGEMENT                                                         │
│    • Export App Data (Generates JSON & shares via system sheet)             │
│    • Reset App Data (FK-safe wipe, cancels all alarms, resets gate)         │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.1 Complete Settings Storage Keys Table

| Setting Item | Storage Mechanism | Storage Key | Default Value |
|---|---|---|---|
| Display Name | `SharedPreferences` | `USER_NAME` | `''` (hydrates to `'Ishan T'`) |
| Theme Mode | `SharedPreferences` | `THEME_MODE` | `'dark'` |
| Theme Accent | `SharedPreferences` | `THEME_ACCENT` | `'Indigo'` |
| Alarm Sound Title / URI | `SharedPreferences` | `ALARM_SOUND_TITLE`, `ALARM_SOUND_URI` | System Default |
| Notif Sound Title / URI | `SharedPreferences` | `NOTIF_SOUND_TITLE`, `NOTIF_SOUND_URI` | System Default |
| Reminder Default | `SharedPreferences` | `REMINDER_DEFAULT` | `'1 day & 6 hours before'` |
| Briefing Hour | `SharedPreferences` | `BRIEFING_HOUR` | `7` |
| Voice Recognition Locale | `SharedPreferences` | `VOICE_LOCALE` | `''` (Device Default) |
| LLM Provider Preset | `SharedPreferences` | `LLM_PROVIDER_PRESET` | `'Google Gemini (Recommended)'` |
| LLM Base URL | `SharedPreferences` | `LLM_BASE_URL` | `https://generativelanguage.googleapis.com/v1beta/openai/` |
| LLM Model | `SharedPreferences` | `LLM_MODEL` | `gemini-2.0-flash` |
| LLM API Key | `FlutterSecureStorage` | `apiKey` | `''` (Encrypted in Android Keystore) |
| Onboarding Gate | `SharedPreferences` | `onboarding_complete` | `false` |

### 1.2 Data Export & Reset Specifications

#### Export App Data
- Fetches all active items (`itemDao.watchAllActive().first`) and workspaces (`workspaceDao.getAll()`).
- Constructs JSON payload with schema version `1` and export timestamp.
- Writes to `${applicationDocumentsDirectory}/aura_export_${timestamp}.json`.
- Shares file via `Share.shareXFiles(...)`.

#### Reset App Data Protocol
1. Cancels all active OS alarms and notifications: `NotificationService().cancelAll()`.
2. Wipes SQLite database tables in strict foreign-key safe order:
   `reminders_schedule` -> `notes` -> `shared_contents` -> `notification_logs` -> `ai_actions_logs` -> `offline_queues` -> `daily_logs` -> `sync_queues` -> `items` -> `workspace_sections` -> `workspaces`.
3. Clears native floating orb prefs: `OverlayChannel.clearNativePrefs()`.
4. Wipes `SharedPreferences.clear()` and `FlutterSecureStorage.deleteAll()`.
5. Resets Riverpod notifiers: `themeAccentProvider.resetToDefault()`, `themeModeProvider.resetToDefault()`, `userNameProvider.reset()`, `onboardingGateProvider.reset()`.
6. Navigates to `/onboarding`.

---

## 2. Task Detail Screen Specification (`TaskDetailScreen`)

Accessible via route `/task/:id`. Provides complete inspection and modification for any item:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ [← Back] TASK DETAILS                                         [Trash Delete]│
├─────────────────────────────────────────────────────────────────────────────┤
│ Title: [ Submit semester project report                                   ] │
│                                                                             │
│ 📁 Workspace: [ IIT Prep ▼ ]      📂 Section: [ Academics ▼ ]                │
│ 🏷 Category: [ Reminder ]          📌 Kind: [ Task ]                         │
│ ⚡ Priority: [ Low ] [ Medium ] [ (•) HIGH ]                                │
│ 📅 Target Deadline: [ 2026-08-29 17:00 ] [ Pick Date/Time ]                 │
│ ⏰ Alarm Time: [ None ]                   [ Set Alarm ]                     │
│ 🔔 Custom Ringtone: [ System Default ▼ ]                                    │
│ 🔁 Recurrence: [ None ▼ ]                                                   │
│                                                                             │
│ 📝 Notes & Details:                                                         │
│ ┌─────────────────────────────────────────────────────────────────────────┐ │
│ │ portal closes strictly at 5pm no extensions                             │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│ ── SUBTASKS (2 / 3 Completed) ───────────────────────────────────────────── │
│ [x] Write Introduction and Problem Statement                                │
│ [x] Export Architecture Diagrams to PDF                                     │
│ [ ] Upload ZIP to submission portal                                         │
│ [+ Add Subtask]                                                             │
│                                                                             │
│ 🎙 AI Spoken Transcript (Read-Only):                                        │
│ "Remind me to submit the semester project report today at 5pm urgent"       │
├─────────────────────────────────────────────────────────────────────────────┤
│ [                      SAVE CHANGES / COMPLETE TASK                       ] │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.1 Editing & Scheduling Synchronization
- Modifying any timing field (`deadline`, `fireAt`, `startTime`, `recurrenceRule`, `soundUri`) triggers an automatic call to `ReminderSchedulingService.syncForItem(item)`.
- Deleting an item triggers `ReminderSchedulingService.cancelForItem(item.id)` before setting `deleted_at = nowMs`.
- Subtasks are stored in the same `items` table with `parent_id = parentItem.id`.
