# Feature Specification: Voice Capture & AI Processing

> **Forensic Rebuild Specification**  
> Complete specification for AURA's voice capture state machine, speech recognition streams, waveform visualizer, intent confirmation cards, and offline queueing.

---

## 1. Voice Capture Entry Points

AURA provides 5 distinct, zero-friction entry points to initiate voice capture:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. Native Floating Orb Tap (AuraOverlayService → AuraCaptureActivity)       │
│ 2. In-App Floating Orb (HomeScreen FloatingOrb widget → GoRouter)           │
│ 3. Android Quick Settings Tile (AuraTileService → AuraCaptureActivity)      │
│ 4. App Shortcuts Launcher (shortcuts.xml: "Voice Capture" shortcut)         │
│ 5. In-App Mic Buttons & Bottom Navigation Bar Action                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

All entry points route to the translucent `/capture-overlay` screen (`FloatingCaptureOverlayScreen`), which attaches to `captureProvider`.

---

## 2. State Machine (`CaptureStatus`)

```
               ┌──────────┐
               │   idle   │
               └────┬─────┘
                    │ startCapture()
                    ▼
               ┌──────────┐
      ┌────────┤ starting │
      │        └────┬─────┘
      │ Mic Error   │ SpeechRecognizer initialized
      ▼             ▼
┌───────────┐  ┌───────────┐    2500ms silence / stopAndProcess()
│   error   │  │ listening ├─────────────────────────┐
└─────▲─────┘  └────┬──────┘                         │
      │             │ switchToTextInput()            │
      │             ▼                                ▼
      │        ┌───────────┐  submitTyped()    ┌────────────┐
      │        │ textInput ├──────────────────►│ processing │
      │        └───────────┘                   └─────┬──────┘
      │                                              │
      │ LLM Auth/Config Failure                      ├─ Offline? → Saved to DB queue
      └──────────────────────────────────────────────┤
                                                     │ LLM Success / Offline Parser
                                                     ▼
                                               ┌───────────┐
                                               │confirming │
                                               └─────┬─────┘
                                                     │ confirmAndSave()
                                                     ▼
                                               ┌────────────┐
                                               │savedSuccess│
                                               └────────────┘
```

### Complete State Definitions

| State Enum | UI Presentation | Actions & Behavior |
|---|---|---|
| `idle` | Inactive / Hidden | Baseline state. Subscriptions cancelled. |
| `starting` | Translucent blurred background, glowing mic orb | Subscribes to `SpeechChannel` streams; requests `VOICE_LOCALE` pref. |
| `listening` | Live waveform visualizer, audio ripple, real-time partial text | Streams audio levels `[0.0, 1.0]`; resets 2500ms silence timer on every speech event. |
| `textInput` | Keyboard open, text field with submit button | Manual typing mode when speech is noisy or unavailable. |
| `processing` | Circular spinner, glowing orb, `"Understanding your request..."` | Probes connectivity; dispatches to LLM API or queues offline. |
| `confirming` | Interactive Confirmation Card with editable fields | Human-in-the-loop review of extracted title, time, workspace, priority. |
| `savedSuccess` | Animated checkmark, haptic feedback, confirmation text | Automatically resets to `idle` and dismisses overlay after 1500ms. |
| `error` | Red alert card with actionable error text | Provides `"TRY AGAIN"` (restarts listening) and `"TYPE INSTEAD"` buttons. |

---

## 3. Audio Visualization & Silence Detection

1. **RMS Power Normalization**:
   - `AuraSpeechChannel.kt` intercepts `onRmsChanged(rmsdB)`.
   - Normalizes raw input: `level = ((rmsdB + 2.0) / 12.0).coerceIn(0.0, 1.0)`.
   - Streams via EventChannel `aura/speech/audioLevel` to drive dynamic scale and pulse effects on `WaveformWidget`.
2. **2500ms Silence Auto-Stop**:
   - Every `partialTranscript` and `finalTranscript` event cancels and restarts a `Timer(const Duration(milliseconds: 2500))`.
   - If no speech occurs for 2.5 seconds, `stopAndProcess()` is called automatically.
3. **500ms Final Result Grace Window**:
   - At `stopAndProcess()`, Flutter stops `SpeechRecognizer` and polls up to 500ms (5 x 100ms) for the definitive `finalTranscriptStream` token to arrive before falling back to the last partial.

---

## 4. Confirmation Card Architecture

The confirmation interface (`ConfirmationBox`) allows the user to correct AI parsing before anything is committed to SQLite:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ ✦ AURA INTELLIGENCE                                                         │
│ [ Task Title: "Submit semester project report"                            ] │
├─────────────────────────────────────────────────────────────────────────────┤
│ 📅 Target Deadline: [ Today, 05:00 PM  (Tap to change)                    ] │
│ 📁 Target Workspace: [ IIT Prep ▼ (Exact Match 90%)                       ] │
│ ⚡ Priority: [ Low ] [ Medium ] [ (•) HIGH ]                                │
│ 🔔 Reminders: [ 30 min before (x) ] [ + Add Reminder ]                      │
│ 📝 Notes: "portal closes strictly at 5pm no extensions"                     │
├─────────────────────────────────────────────────────────────────────────────┤
│ [ CANCEL ]                                               [ CONFIRM & SAVE →]│
└─────────────────────────────────────────────────────────────────────────────┘
```

- **Editable Title**: Text input pre-filled with `IntentResult.title`.
- **Date & Time Picker**: Bottom sheet date/time selector modifying `IntentResult.deadline`.
- **Workspace Selector**: Dropdown showing exact match, fuzzy suggestion, or `"Create '<workspace>'?"` option.
- **Priority Selector**: Segmented choice between `high`, `medium`, and `low`.
- **Reminders List**: Removable chips showing offsets (e.g. `30m before`, `1d before`).
- **AI Notice Badge**: If `usedLocalFallback` is true, displays informational banner: *"Parsed offline (No API key set)"*.

---

## 5. Offline Queueing Protocol

1. When `stopAndProcess()` detects `ConnectivityService.isOnline() == false`:
   - Calls `QueueOfflineTranscriptUseCase.execute(transcript)`.
   - Inserts row into `offline_queues` table with `status = 'pending'`, `attempts = 0`.
   - Sets state to `CaptureStatus.savedSuccess` with `isOfflineSaved = true`.
   - UI shows: *"Saved to offline queue. Will sync when online."*
2. Background processing handled automatically by `OfflineQueueProcessor`.
