# Tech Stack & Dependency Specification

> **Forensic Rebuild Specification**  
> Every dependency, platform constraint, native SDK, and tool version in this document reflects the exact, verified configuration of the AURA production application.

---

## 1. Platform Targets & Runtime Constraints

| Dimension | Specification | Verification / Rationale |
|---|---|---|
| **Target OS** | Android 8.0+ (API Level 26+) | Required for `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`, `SYSTEM_ALERT_WINDOW`, `TYPE_APPLICATION_OVERLAY`, Notification Channels, and Quick Settings `TileService`. |
| **Android Namespace** | `com.aura.aura` | Configured in `android/app/build.gradle.kts` and `AndroidManifest.xml`. |
| **Min SDK** | `26` (Android 8.0 Oreo) | Hard minimum for overlay window types, foreground service notification channels, and modern alarm semantics. |
| **Compile SDK / Target SDK** | `flutter.compileSdkVersion` (API 34/35/36 compatible) / `flutter.targetSdkVersion` (API 34/35) | Supports Android 14+ predictive back, exact alarm policies, and photo picker. |
| **JVM Target / Java Version** | Java 11 (`JavaVersion.VERSION_11`) | Configured with `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")`. |
| **NDK Version** | `27.0.12077973` | Required for native C SQLite compilation via `sqlite3_flutter_libs`. |
| **Dart SDK** | `>=3.4.0 <4.0.0` | Enables records, pattern matching, switch expressions, and sealed classes. |
| **Flutter Version** | Flutter 3.22.x+ (Material 3 enabled) | Uses Flutter embedding v2 with dual `FlutterEngine` caching. |

---

## 2. Production Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # ── State Management ──────────────────────────────────────────────────────
  flutter_riverpod: ^2.5.1      # Declarative reactive DI graph and state notifiers

  # ── Navigation & Routing ──────────────────────────────────────────────────
  go_router: ^14.2.0             # URL-based declarative router with redirect guards

  # ── Local Database & Storage ──────────────────────────────────────────────
  drift: ^2.18.0                 # Type-safe SQLite ORM with reactive streams
  sqlite3_flutter_libs: ^0.5.24  # Bundled native SQLite C library with WAL support
  path_provider: ^2.1.3          # App sandbox directory resolution
  path: ^1.9.0                   # File path manipulation utilities

  # ── Environment & Security ────────────────────────────────────────────────
  flutter_dotenv: ^5.2.1         # Local development .env file loader
  flutter_secure_storage: ^9.2.2 # Android Keystore encrypted secret storage

  # ── Networking & AI ───────────────────────────────────────────────────────
  http: ^1.2.1                   # HTTP client for LLM API and web scraper
  connectivity_plus: ^6.0.3      # Live network status monitor (WiFi/Cellular/None)
  url_launcher: ^6.3.0           # External browser / intent launcher

  # ── Notifications & Timezones ─────────────────────────────────────────────
  flutter_local_notifications: ^17.2.2 # Local notifications & alarm channel
  timezone: ^0.9.2               # IANA timezone database
  flutter_timezone: ^3.0.1       # Native device timezone resolver

  # ── Android Platform & Hardware Permissions ───────────────────────────────
  permission_handler: ^11.3.1    # Exact alarms, mic, notifications, overlay

  # ── On-Device ML / OCR ────────────────────────────────────────────────────
  google_mlkit_text_recognition: ^0.13.0 # On-device Latin OCR for Share target

  # ── Design, Typography & Icons ────────────────────────────────────────────
  google_fonts: ^6.2.1           # Inter (UI/Body) & Outfit (Headers/Display)
  lucide_icons: ^0.257.0         # Pure Lucide icon set (Strict: No Material/Emoji)

  # ── Utilities ─────────────────────────────────────────────────────────────
  uuid: ^4.4.0                   # UUID v4 generator for all entity IDs
  shared_preferences: ^2.2.3     # Non-sensitive persistent settings
  intl: ^0.19.0                  # Date formatting, localization, relative time
  share_plus: ^10.1.4            # Data export file sharing

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.11          # Code generation orchestrator
  drift_dev: ^2.18.0             # Drift schema compiler and DAO generator
  flutter_lints: ^4.0.0          # Strict lint rules
```

---

## 3. Native Android Architecture & Services

AURA uses a hybrid Flutter + Android native architecture implemented in Kotlin (`android/app/src/main/kotlin/com/aura/aura/`):

```
android/app/src/main/kotlin/com/aura/aura/
├── MainActivity.kt            # Primary FlutterActivity (hosts full UI)
├── AuraCaptureActivity.kt     # Translucent Floating Activity (hosts /capture-overlay)
├── AuraShareActivity.kt       # Share Target Activity (handles ACTION_SEND intents)
├── OrbMenuActivity.kt         # Translucent popup menu on floating orb long-press
├── AuraOverlayService.kt      # Foreground Service drawing floating Canvas Orb
├── AuraTileService.kt         # Android Quick Settings Tile service
├── AuraBootReceiver.kt        # RECEIVE_BOOT_COMPLETED receiver (restarts overlay)
├── AuraChannelRegistrar.kt    # Unified Method/EventChannel binder across engines
└── AuraSpeechChannel.kt       # SpeechRecognizer wrapper with RMS audio streams
```

### Platform Channels Architecture

| Channel Identifier | Channel Type | Kotlin Handler | Dart Client | Functionality |
|---|---|---|---|---|
| `aura/overlay` | `MethodChannel` | `AuraOverlayService`, `MainActivity` | `OverlayChannel` | Starts/stops floating orb, checks overlay permission, picks system alarm/notification ringtones, clears native prefs. |
| `aura/speech` | `MethodChannel` | `AuraSpeechChannel` | `SpeechChannel` | Starts, stops, and cancels Android `SpeechRecognizer`. |
| `aura/speech/partial` | `EventChannel` | `AuraSpeechChannel` | `SpeechChannel` | Streams live partial voice transcripts. |
| `aura/speech/audioLevel` | `EventChannel` | `AuraSpeechChannel` | `SpeechChannel` | Streams normalized RMS audio level `[0.0, 1.0]` for visualizer. |
| `aura/speech/speechState` | `EventChannel` | `AuraSpeechChannel` | `SpeechChannel` | Streams speech lifecycle states (`ready`, `listening`, `processing`, `autoStopped`, `error`). |
| `aura/speech/speechError` | `EventChannel` | `AuraSpeechChannel` | `SpeechChannel` | Streams error codes (`ERROR_NO_MATCH`, `ERROR_SPEECH_TIMEOUT`, etc.). |
| `aura/share` | `MethodChannel` | `AuraShareActivity` | `channels.dart` | Fetches cached `aura_share_payload.json` on share target launch. |
| `com.aura.aura/dnd` | `MethodChannel` | `MainActivity` | `DndService` | Queries live Do-Not-Disturb status (`isDndActive`). |
| `com.aura.aura/dnd_events` | `EventChannel` | `MainActivity` | `DndService` | Streams live DND filter transitions (`ACTION_INTERRUPTION_FILTER_CHANGED`). |

---

## 4. Android Manifest Permissions & Capabilities

```xml
<!-- Overlay & Background Services -->
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />

<!-- Voice Input & Speech Recognition -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- Notifications & Time-Critical Alarms -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />

<!-- Network & Storage -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
```

---

## 5. Security & Configuration Precedence

AURA enforces a strict 4-tier configuration precedence for all AI parameters:

```
┌─────────────────────────────────────────────────────────────┐
│ 1. User Settings (Encrypted FlutterSecureStorage / Prefs)  │  HIGHEST
├─────────────────────────────────────────────────────────────┤
│ 2. Compile Flags (--dart-define LLM_API_KEY=... / BASE_URL) │
├─────────────────────────────────────────────────────────────┤
│ 3. Development .env (GEMINI_API_KEY / LLM_BASE_URL)         │
├─────────────────────────────────────────────────────────────┤
│ 4. Hardcoded Application Defaults (AppConfig constants)     │  LOWEST
└─────────────────────────────────────────────────────────────┘
```

- **API Keys**: Stored exclusively via `flutter_secure_storage` inside Android Keystore (`SecretStore`). Never written to plaintext `SharedPreferences` or database logs.
- **R8 Proguard Rules**: Configured in `android/app/proguard-rules.pro` with explicit keep rules for Latin ML Kit, Kotlin Coroutines, and SQLite embedding.
