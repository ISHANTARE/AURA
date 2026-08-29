# Platform Channels & Native Android Subsystems

> **Forensic Rebuild Specification**  
> Complete specification for all native Kotlin services, activities, receivers, and MethodChannel/EventChannel protocols connecting Flutter with Android OS capabilities.

---

## 1. Complete Channel Registry

All channel constants are defined in `lib/platform/channels.dart`:

```dart
abstract final class AuraChannels {
  static const String overlayMethod = 'aura/overlay';
  static const String speechMethod  = 'aura/speech';
  static const String shareMethod   = 'aura/share';
  static const String dndMethod     = 'com.aura.aura/dnd';
  static const String dndEvents     = 'com.aura.aura/dnd_events';
}
```

---

## 2. Overlay Channel (`aura/overlay`)

- **Native Implementation**: `AuraOverlayService.kt` (Foreground Service), `AuraChannelRegistrar.kt`, `MainActivity.kt`.
- **Dart Client**: `OverlayChannel` (`lib/platform/overlay_channel.dart`).
- **Foreground Service Type**: `specialUse` (requires `SYSTEM_ALERT_WINDOW`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_SPECIAL_USE`).

### 2.1 MethodChannel RPC Specification

| Method Name | Arguments | Return Type | Description |
|---|---|---|---|
| `startOverlay` | none | `bool` | Starts `AuraOverlayService` as a foreground service with floating Canvas orb. |
| `stopOverlay` | none | `bool` | Stops `AuraOverlayService` and removes floating window. |
| `checkOverlayPermission` | none | `bool` | Checks `Settings.canDrawOverlays(context)`. |
| `requestOverlayPermission` | none | `void` | Launches `Settings.ACTION_MANAGE_OVERLAY_PERMISSION` intent. |
| `isOverlayRunning` | none | `bool` | Checks if `AuraOverlayService.isRunning` is true. |
| `pickAlarmSound` | `{"currentUri": String}` | `Map<String, String>?` | Launches `RingtoneManager.ACTION_RINGTONE_PICKER` (`TYPE_ALARM`). Returns `{"title": "...", "uri": "..."}`. |
| `pickNotificationSound` | `{"currentUri": String}` | `Map<String, String>?` | Launches `RingtoneManager.ACTION_RINGTONE_PICKER` (`TYPE_NOTIFICATION`). Returns `{"title": "...", "uri": "..."}`. |
| `clearNativePrefs` | none | `void` | Wipes `aura_orb_prefs` (clears saved X/Y screen coordinates, color, and dismissed state). |
| `ping` | none | `String` | Returns `"pong"` for connection diagnostic verification. |

### 2.2 Floating Orb UI & Gesture Mechanics (`AuraOverlayService.kt`)

1. **Custom Canvas Rendering**:
   - Orb is drawn programmatically on a custom Android `View`.
   - Core Circle (Radius 24dp): Accent color with radial glow.
   - Micro-pulse Animation: Infinite ValueAnimator scaling radius `[22dp .. 26dp]` every 1500ms.
2. **Touch & Drag Physics**:
   - `MotionEvent.ACTION_DOWN`: Records initial touch position.
   - `MotionEvent.ACTION_MOVE`: Updates `WindowManager.LayoutParams` `x` and `y`.
   - `MotionEvent.ACTION_UP`: If movement < 10px, triggers Single Tap -> Launches `AuraCaptureActivity`. If dragged, snaps orb to nearest left/right screen edge and saves coordinates to `aura_orb_prefs`.
3. **Long Press Detection (600ms)**:
   - Holding orb stationary for >600ms cancels tap and launches `OrbMenuActivity` with intent extras `EXTRA_ORB_X` and `EXTRA_ORB_Y`.

---

## 3. Speech Recognition Channels (`aura/speech`)

- **Native Implementation**: `AuraSpeechChannel.kt`.
- **Dart Client**: `SpeechChannel` (`lib/platform/speech_channel.dart`).
- **Underlying Engine**: `android.speech.SpeechRecognizer` with `RecognizerIntent.ACTION_RECOGNIZE_SPEECH`.

### 3.1 MethodChannel (`aura/speech`)

| Method Name | Arguments | Return Type | Description |
|---|---|---|---|
| `startListening` | `{"localeId": String?}` | `bool` | Initializes and starts `SpeechRecognizer` with `EXTRA_PARTIAL_RESULTS = true`. |
| `stopListening` | none | `bool` | Stops recording gracefully and delivers final `onResults` transcript. |
| `cancelListening` | none | `bool` | Immediately aborts recording without delivering results. |
| `isAvailable` | none | `bool` | Verifies `SpeechRecognizer.isRecognitionAvailable(context)`. |

### 3.2 EventChannels Specification

| Channel Name | Emitted Data Type | Stream Description |
|---|---|---|
| `aura/speech/partial` | `String` | Emits live partial transcript string as words are spoken. |
| `aura/speech/audioLevel` | `double` | Emits normalized RMS audio power level in range `[0.0, 1.0]`. Raw `onRmsChanged` dB `[-2.0 .. 10.0]` is mapped to `(rms + 2.0) / 12.0`. |
| `aura/speech/speechState` | `String` | Emits speech lifecycle states: `"ready"`, `"listening"`, `"processing"`, `"autoStopped"`, `"error"`. |
| `aura/speech/speechError` | `String` | Emits human-readable error descriptions on `onError(int error)`. |

### 3.3 Silence Auto-Stop & Final Result Reconciliation

1. **Native Auto-Stop**: When Android SpeechRecognizer detects end of speech, `onEndOfSpeech()` fires and emits `speechState: "autoStopped"`.
2. **Flutter 2500ms Inactivity Timer**: `CaptureNotifier` resets a 2500ms silence timer on every partial/final token. If no new words arrive for 2.5s, it triggers `stopAndProcess()`.
3. **Final Result Polling**: At `stopAndProcess()`, Flutter polls up to 500ms (5 x 100ms) for the definitive `finalTranscriptStream` token before falling back to the last partial transcript.

---

## 4. Share Intent Channel (`aura/share`)

- **Native Implementation**: `AuraShareActivity.kt`.
- **Target Route**: `/share` (`ShareReceiveScreen`).

### 4.1 Intent Ingestion & Caching Protocol

1. `AuraShareActivity` intercepts `ACTION_SEND` and `ACTION_SEND_MULTIPLE` intents with MIME types `text/*`, `image/*`, `video/*`, `audio/*`, `application/pdf`, and `application/vnd.openxmlformats-officedocument.wordprocessingml.document`.
2. Extracts plain text, subject, shared URIs, and copy streams files into `context.cacheDir/aura_shared/`.
3. Purges any cached media files older than **24 hours**.
4. Serializes payload into JSON file: `context.cacheDir/aura_share_payload.json`.
5. MethodChannel `aura/share`:
   - `getInitialSharePayload` -> Reads and returns `aura_share_payload.json` Map, then deletes the temporary JSON file.

---

## 5. Do Not Disturb (DND) Channels

- **Channel Names**: MethodChannel `com.aura.aura/dnd`, EventChannel `com.aura.aura/dnd_events`.
- **Native Implementation**: `MainActivity.kt` & `AuraChannelRegistrar.kt`.
- **Dart Client**: `DndService` (`lib/features/reminders/data/services/dnd_service.dart`).

### 5.1 Protocol

- `isDndActive` -> Queries `NotificationManager.currentInterruptionFilter != INTERRUPTION_FILTER_ALL`.
- `dnd_events` EventChannel -> Broadcasts boolean (`true` = DND active, `false` = DND off) whenever `NotificationManager.ACTION_INTERRUPTION_FILTER_CHANGED` fires.
- When DND transitions from `true` to `false`, `DndService` immediately triggers `ReplayDndNotificationsUseCase.execute()`.

---

## 6. Native Activities, Services & Receivers Table

| Component | Class Name | Manifest Attributes | Responsibility |
|---|---|---|---|
| **Main Activity** | `MainActivity` | `android:launchMode="singleTop"` | Main application entry point; initializes engine caches and DND listeners. |
| **Capture Overlay** | `AuraCaptureActivity` | `android:theme="@style/TranslucentTheme"` | Translucent overlay activity hosting `/capture-overlay`. |
| **Share Target** | `AuraShareActivity` | `android:theme="@style/TranslucentTheme"` | Receives external Android share intents and routes to `/share`. |
| **Orb Popup Menu** | `OrbMenuActivity` | `android:theme="@android:style/Theme.Translucent.NoTitleBar.Fullscreen"` | Popup card launched on 600ms orb hold with shortcuts: Add Reminder, Add Event, Add Note, Add Alarm, Close Orb. |
| **Floating Service** | `AuraOverlayService` | `android:foregroundServiceType="specialUse"` | Persistent foreground service rendering the floating Canvas Orb. |
| **Quick Settings** | `AuraTileService` | `android.permission.BIND_QUICK_SETTINGS_TILE` | Quick Settings tile launching `AuraCaptureActivity`. |
| **Boot Receiver** | `AuraBootReceiver` | `android.intent.action.BOOT_COMPLETED` | Restarts overlay service and resynchronizes alarms after reboot. |
