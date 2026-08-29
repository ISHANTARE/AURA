# Phase 6: Native Android Subsystem (Kotlin)

> **Authority Document:** [`overhaul-docs/05-platform-channels.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/05-platform-channels.md)  
> **Status:** Complete (Verified)  

---

## Phase Overview

Phase 6 implements AURA's native Kotlin layer on Android: dual `FlutterEngine` caching for sub-second overlay launches, the persistent `AuraOverlayService` with custom Canvas orb rendering, `android.speech.SpeechRecognizer` with live RMS audio power streams, Share Target intake, Quick Settings tile, and boot auto-start.

---

## Sprint Breakdown

### Sprint 6.1: Manifest Permissions, Gradle & Kotlin Setup
**Objective:** Configure Android manifest permissions, service types, and Kotlin registrar.

#### Tasks:
- [x] **Task 6.1.1: AndroidManifest.xml Configuration**
  - Declare permissions:
    - `SYSTEM_ALERT_WINDOW` (Floating Orb Overlay)
    - `FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_SPECIAL_USE`
    - `RECORD_AUDIO` (Speech Recognition)
    - `SCHEDULE_EXACT_ALARM` & `USE_EXACT_ALARM`
    - `POST_NOTIFICATIONS`
    - `RECEIVE_BOOT_COMPLETED`
  - Declare activities with transparent themes:
    - `AuraCaptureActivity` (translucent theme, launch mode `singleTask`).
    - `AuraShareActivity` with intent filters for `ACTION_SEND` (text, image, pdf).
    - `OrbMenuActivity` (translucent popup).
  - Declare `AuraOverlayService`, `AuraTileService`, `AuraBootReceiver`.
- [x] **Task 6.1.2: AuraChannelRegistrar (`AuraChannelRegistrar.kt`)**
  - Centralized binder wiring all MethodChannels and EventChannels across both FlutterEngines.
- [x] **Task 6.1.3: Dart Channel Constants (`lib/platform/channels.dart`)**
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

### Sprint 6.2: Dual FlutterEngine & Floating Canvas Orb Service
**Objective:** Implement `MainActivity.kt`, `AuraCaptureActivity.kt`, and `AuraOverlayService.kt`.

#### Tasks:
- [x] **Task 6.2.1: Dual FlutterEngine Prewarming (`MainActivity.kt`)**
  - Prewarm background `FlutterEngine` cached as `"aura_capture_engine"` pre-routed to `/capture-overlay`.
  - Ensures $\le 100\text{ms}$ cold launch when tapping the floating orb.
- [x] **Task 6.2.2: AuraOverlayService Canvas Drawing & Touch Physics**
  - Programmatic Canvas drawing: 24dp radius orb, accent radial glow, pulsing `ValueAnimator` (22dp to 26dp over 1500ms).
  - Touch mechanics: Single tap ($<10\text{px}$ delta) launches `AuraCaptureActivity`.
  - Drag physics: Snaps to nearest left/right screen edge on release; saves coordinates to `aura_orb_prefs`.
  - Long press ($>600\text{ms}$): Launches `OrbMenuActivity`.
- [x] **Task 6.2.3: Overlay MethodChannel Handlers**
  - Implement `startOverlay`, `stopOverlay`, `checkOverlayPermission`, `requestOverlayPermission`, `pickAlarmSound`, `pickNotificationSound`, `clearNativePrefs`, `ping`.
- [x] **Task 6.2.4: Dart OverlayChannel Client (`lib/platform/overlay_channel.dart`)**
  - Typed Dart RPC wrapper matching all Kotlin channel methods.

---

### Sprint 6.3: AuraSpeechChannel (Android SpeechRecognizer & RMS Stream)
**Objective:** Implement real-time speech-to-text and audio waveform streaming in `AuraSpeechChannel.kt`.

#### Tasks:
- [x] **Task 6.3.1: SpeechRecognizer MethodChannel & Recognition Lifecycle**
  - `startListening(localeId)`: Initializes `SpeechRecognizer` with `EXTRA_PARTIAL_RESULTS = true`.
  - `stopListening()`: Completes capture and triggers final token resolution.
  - `cancelListening()`: Aborts recording immediately.
- [x] **Task 6.3.2: 4 EventChannels Implementation**
  - `aura/speech/partial`: Emits live partial transcript string.
  - `aura/speech/audioLevel`: Emits normalized RMS power in `[0.0, 1.0]` (`(rms + 2.0) / 12.0`).
  - `aura/speech/speechState`: Emits `"ready"`, `"listening"`, `"processing"`, `"autoStopped"`, `"error"`.
  - `aura/speech/speechError`: Emits error description string on failure.
- [x] **Task 6.3.3: Dart SpeechChannel Client (`lib/platform/speech_channel.dart`)**
  - Exposes typed streams for partial transcripts, RMS audio level, and speech states.

---

### Sprint 6.4: Share Target, Quick Settings Tile & Boot Receiver
**Objective:** Implement `AuraShareActivity.kt`, `AuraTileService.kt`, and `AuraBootReceiver.kt`.

#### Tasks:
- [x] **Task 6.4.1: AuraShareActivity Implementation**
  - Intercepts shared plain text, web URLs, and images.
  - Copies shared files to sandbox cache `context.cacheDir/aura_shared/`.
  - Purges any cache files older than 24 hours.
  - Launches Flutter `/share` route.
- [x] **Task 6.4.2: AuraTileService Implementation**
  - Android Quick Settings Tile: Tap toggles the floating orb overlay on/off and updates tile state.
- [x] **Task 6.4.3: AuraBootReceiver Implementation**
  - Listens for `Intent.ACTION_BOOT_COMPLETED`.
  - Reads `aura_orb_prefs` and auto-restarts `AuraOverlayService` if it was active before reboot.

---

## Phase 6 Acceptance Criteria & Verification

1. Kotlin code compiles without warnings (`./gradlew assembleDebug`).
2. Native MethodChannel ping returns `"pong"`.
3. EventChannel audioLevel stream emits normalized double values during speech.
4. `test/platform/platform_channel_test.dart` passes using mocked binary messenger.
