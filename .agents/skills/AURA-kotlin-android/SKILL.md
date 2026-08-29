---
name: AURA-kotlin-android
description: >
  Kotlin/Android native layer developer for AURA. Use this skill when: writing or fixing any Kotlin
  file under android/, implementing platform channels (MethodChannel/EventChannel), building the
  floating Canvas orb (AuraOverlayService), wiring the SpeechRecognizer (AuraSpeechChannel),
  implementing the boot receiver, Quick Settings tile, share target activity, translucent capture
  activity, or when the user says "write the Kotlin for X", "implement the platform channel for X",
  "fix the Android side of X", "the orb isn't showing", "speech isn't working", "DND channel broken",
  "share target not launching", or "boot receiver not firing". This skill is the authoritative
  reference for all android/ directory work.
---

# AURA Kotlin Android Developer

You are implementing the **native Android layer** of AURA. This layer is a hybrid
Flutter + Kotlin architecture. Your job is to write correct, production-quality Kotlin
that backs the platform channels consumed by the Dart/Flutter layer.

> **Source of truth for all behavioral specs**: `overhaul-docs/01-tech-stack.md`,
> `overhaul-docs/02-architecture.md`, and `overhaul-docs/05-platform-channels.md`.
> Read those before writing any Kotlin.

---

## 1. Android Project Identity

| Key | Value |
|-----|-------|
| Application ID / Namespace | `com.aura.aura` |
| Min SDK | 26 (Android 8.0 Oreo) |
| Compile SDK | `flutter.compileSdkVersion` (34/35/36 compatible) |
| Target SDK | `flutter.targetSdkVersion` (34/35) |
| JVM Target | Java 11 (`JavaVersion.VERSION_11`) |
| NDK Version | `27.0.12077973` |
| Core Library Desugaring | `com.android.tools:desugar_jdk_libs:2.0.4` |
| Kotlin source root | `android/app/src/main/kotlin/com/aura/aura/` |

---

## 2. Full Kotlin File Tree

```
android/app/src/main/kotlin/com/aura/aura/
├── MainActivity.kt            # Primary FlutterActivity — hosts full UI, prewarmsengines
├── AuraCaptureActivity.kt     # Translucent overlay activity → /capture-overlay route
├── AuraShareActivity.kt       # Android Share Target (ACTION_SEND intents)
├── OrbMenuActivity.kt         # Transparent popup on orb long-press (>600ms)
├── AuraOverlayService.kt      # Foreground Service — draws Canvas floating orb
├── AuraTileService.kt         # Quick Settings TileService
├── AuraBootReceiver.kt        # RECEIVE_BOOT_COMPLETED BroadcastReceiver
├── AuraChannelRegistrar.kt    # Registers all Method/EventChannels across all engines
└── AuraSpeechChannel.kt       # SpeechRecognizer wrapper + RMS audio streams
```

---

## 3. Platform Channels — Complete Reference

All channel names and types to implement:

| Channel Name | Type | Handler Class | Dart Client Class |
|---|---|---|---|
| `aura/overlay` | MethodChannel | `AuraOverlayService` + `MainActivity` | `OverlayChannel` |
| `aura/speech` | MethodChannel | `AuraSpeechChannel` | `SpeechChannel` |
| `aura/speech/partial` | EventChannel | `AuraSpeechChannel` | `SpeechChannel` |
| `aura/speech/audioLevel` | EventChannel | `AuraSpeechChannel` | `SpeechChannel` |
| `aura/speech/speechState` | EventChannel | `AuraSpeechChannel` | `SpeechChannel` |
| `aura/speech/speechError` | EventChannel | `AuraSpeechChannel` | `SpeechChannel` |
| `aura/share` | MethodChannel | `AuraShareActivity` | `channels.dart` |
| `com.aura.aura/dnd` | MethodChannel | `MainActivity` | `DndService` |
| `com.aura.aura/dnd_events` | EventChannel | `MainActivity` | `DndService` |

---

## 4. MainActivity.kt — Engine Prewarming & Channel Registration

```kotlin
class MainActivity : FlutterActivity() {

    companion object {
        const val CAPTURE_ENGINE_ID = "capture_engine_id"
        const val SHARE_ENGINE_ID = "share_engine_id"
    }

    private lateinit var captureEngine: FlutterEngine
    private lateinit var shareEngine: FlutterEngine

    // DND EventChannel sink — kept alive for streaming
    private var dndEventSink: EventChannel.EventSink? = null
    private lateinit var dndReceiver: BroadcastReceiver

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Prewarm capture engine → navigates to /capture-overlay
        captureEngine = FlutterEngine(this).apply {
            dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
            navigationChannel.setInitialRoute("/capture-overlay")
            FlutterEngineCache.getInstance().put(CAPTURE_ENGINE_ID, this)
        }

        // 2. Prewarm share engine → navigates to /share
        shareEngine = FlutterEngine(this).apply {
            dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
            navigationChannel.setInitialRoute("/share")
            FlutterEngineCache.getInstance().put(SHARE_ENGINE_ID, this)
        }

        // 3. Register channels on all three engines
        AuraChannelRegistrar.registerWith(this, flutterEngine)
        AuraChannelRegistrar.registerWith(this, captureEngine)
        AuraChannelRegistrar.registerWith(this, shareEngine)

        // 4. Register overlay MethodChannel on main engine
        registerOverlayChannel(flutterEngine)

        // 5. Register DND channels on main engine
        registerDndChannels(flutterEngine)
    }

    private fun registerOverlayChannel(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, "aura/overlay")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startOverlay" -> {
                        startForegroundService(
                            Intent(this, AuraOverlayService::class.java).apply {
                                action = "START_ORB"
                            }
                        )
                        result.success(null)
                    }
                    "stopOverlay" -> {
                        startService(
                            Intent(this, AuraOverlayService::class.java).apply {
                                action = "STOP_ORB"
                            }
                        )
                        result.success(null)
                    }
                    "isOverlayRunning" -> {
                        result.success(AuraOverlayService.isRunning)
                    }
                    "checkOverlayPermission" -> {
                        result.success(Settings.canDrawOverlays(this))
                    }
                    "requestOverlayPermission" -> {
                        startActivity(
                            Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")
                            )
                        )
                        result.success(null)
                    }
                    "pickAlarmRingtone" -> {
                        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALARM)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, true)
                        }
                        startActivityForResult(intent, REQUEST_ALARM_RINGTONE)
                        result.success(null)
                    }
                    "clearNativePrefs" -> {
                        getSharedPreferences("aura_prefs", Context.MODE_PRIVATE).edit().clear().apply()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun registerDndChannels(engine: FlutterEngine) {
        // MethodChannel — query live DND state
        MethodChannel(engine.dartExecutor.binaryMessenger, "com.aura.aura/dnd")
            .setMethodCallHandler { call, result ->
                if (call.method == "isDndActive") {
                    val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    val filter = nm.currentInterruptionFilter
                    result.success(filter != NotificationManager.INTERRUPTION_FILTER_ALL)
                } else {
                    result.notImplemented()
                }
            }

        // EventChannel — stream DND filter changes
        EventChannel(engine.dartExecutor.binaryMessenger, "com.aura.aura/dnd_events")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    dndEventSink = events
                    dndReceiver = object : BroadcastReceiver() {
                        override fun onReceive(context: Context, intent: Intent) {
                            if (intent.action == NotificationManager.ACTION_INTERRUPTION_FILTER_CHANGED) {
                                val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                                val isDnd = nm.currentInterruptionFilter != NotificationManager.INTERRUPTION_FILTER_ALL
                                dndEventSink?.success(isDnd)
                            }
                        }
                    }
                    registerReceiver(
                        dndReceiver,
                        IntentFilter(NotificationManager.ACTION_INTERRUPTION_FILTER_CHANGED)
                    )
                }

                override fun onCancel(arguments: Any?) {
                    unregisterReceiver(dndReceiver)
                    dndEventSink = null
                }
            })
    }

    companion object {
        const val REQUEST_ALARM_RINGTONE = 1001
    }
}
```

---

## 5. AuraOverlayService.kt — Floating Canvas Orb

The orb is a `Canvas`-drawn circle rendered on a `SYSTEM_ALERT_WINDOW` overlay. It must:
- Be draggable anywhere on screen
- Pulse at idle (scale 1.0 → 1.08 → 1.0, 1200ms cycle)
- Respond to tap: launch `AuraCaptureActivity`
- Respond to long-press (>600ms): launch `OrbMenuActivity` at orb coordinates

```kotlin
class AuraOverlayService : Service() {

    companion object {
        var isRunning = false
        private const val CHANNEL_ID = "aura_overlay_channel"
        private const val NOTIF_ID = 1
    }

    private lateinit var windowManager: WindowManager
    private lateinit var orbView: OrbCanvasView
    private lateinit var params: WindowManager.LayoutParams

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        createNotificationChannel()
        startForeground(NOTIF_ID, buildNotification())
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        setupOrb()
    }

    private fun setupOrb() {
        orbView = OrbCanvasView(this)
        params = WindowManager.LayoutParams(
            56.dp, 56.dp,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 16.dp
            y = 200.dp
        }

        // Drag + tap + long-press gesture
        var longPressJob: Job? = null
        var isDragging = false
        var startRawX = 0f; var startRawY = 0f
        var startX = 0; var startY = 0

        orbView.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    isDragging = false
                    startRawX = event.rawX; startRawY = event.rawY
                    startX = params.x; startY = params.y
                    longPressJob = CoroutineScope(Dispatchers.Main).launch {
                        delay(600)
                        if (!isDragging) launchOrbMenu(params.x, params.y)
                    }
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = (event.rawX - startRawX).toInt()
                    val dy = (event.rawY - startRawY).toInt()
                    if (abs(dx) > 5 || abs(dy) > 5) {
                        isDragging = true
                        longPressJob?.cancel()
                        params.x = startX + dx
                        params.y = startY + dy
                        windowManager.updateViewLayout(orbView, params)
                    }
                }
                MotionEvent.ACTION_UP -> {
                    longPressJob?.cancel()
                    if (!isDragging) launchCaptureActivity()
                }
            }
            true
        }

        windowManager.addView(orbView, params)
        orbView.startPulse()
    }

    private fun launchCaptureActivity() {
        startActivity(
            Intent(this, AuraCaptureActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        )
    }

    private fun launchOrbMenu(x: Int, y: Int) {
        startActivity(
            Intent(this, OrbMenuActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                putExtra("orb_x", x)
                putExtra("orb_y", y)
            }
        )
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "STOP_ORB" -> {
                stopSelf()
                isRunning = false
            }
        }
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        if (::orbView.isInitialized) windowManager.removeView(orbView)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID, "AURA Floating Orb",
            NotificationManager.IMPORTANCE_LOW
        ).apply { description = "Keeps the AURA floating assistant visible" }
        (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(channel)
    }

    private fun buildNotification() = NotificationCompat.Builder(this, CHANNEL_ID)
        .setContentTitle("AURA Assistant Active")
        .setContentText("Tap to open AURA")
        .setSmallIcon(R.drawable.ic_aura_orb) // must exist in drawable
        .setPriority(NotificationCompat.PRIORITY_LOW)
        .build()
}
```

---

## 6. AuraSpeechChannel.kt — SpeechRecognizer + EventChannels

```kotlin
class AuraSpeechChannel(private val context: Context) : RecognitionListener {

    // EventChannel sinks — held while streams are active
    private var partialSink: EventChannel.EventSink? = null
    private var audioLevelSink: EventChannel.EventSink? = null
    private var stateSink: EventChannel.EventSink? = null
    private var errorSink: EventChannel.EventSink? = null

    private var recognizer: SpeechRecognizer? = null

    fun registerOn(engine: FlutterEngine) {
        val messenger = engine.dartExecutor.binaryMessenger

        // Control MethodChannel
        MethodChannel(messenger, "aura/speech").setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> { startListening(); result.success(null) }
                "stop"  -> { recognizer?.stopListening(); result.success(null) }
                "cancel"-> { recognizer?.cancel(); result.success(null) }
                else    -> result.notImplemented()
            }
        }

        // Partial transcript stream
        EventChannel(messenger, "aura/speech/partial").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, sink: EventChannel.EventSink?) { partialSink = sink }
                override fun onCancel(args: Any?) { partialSink = null }
            }
        )

        // Audio level [0.0, 1.0] stream
        EventChannel(messenger, "aura/speech/audioLevel").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, sink: EventChannel.EventSink?) { audioLevelSink = sink }
                override fun onCancel(args: Any?) { audioLevelSink = null }
            }
        )

        // State stream: ready|listening|processing|autoStopped|error
        EventChannel(messenger, "aura/speech/speechState").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, sink: EventChannel.EventSink?) { stateSink = sink }
                override fun onCancel(args: Any?) { stateSink = null }
            }
        )

        // Error code stream: ERROR_NO_MATCH|ERROR_SPEECH_TIMEOUT|...
        EventChannel(messenger, "aura/speech/speechError").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, sink: EventChannel.EventSink?) { errorSink = sink }
                override fun onCancel(args: Any?) { errorSink = null }
            }
        )
    }

    private fun startListening() {
        recognizer?.destroy()
        recognizer = SpeechRecognizer.createSpeechRecognizer(context).apply {
            setRecognitionListener(this@AuraSpeechChannel)
        }
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
        }
        stateSink?.success("ready")
        recognizer?.startListening(intent)
        stateSink?.success("listening")
    }

    // --- RecognitionListener ---

    override fun onPartialResults(partialResults: Bundle) {
        val partial = partialResults
            .getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            ?.firstOrNull() ?: return
        partialSink?.success(partial)
    }

    override fun onResults(results: Bundle) {
        val transcript = results
            .getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            ?.firstOrNull() ?: ""
        stateSink?.success("processing")
        partialSink?.success(transcript) // Final result also sent as partial for Dart side
    }

    override fun onRmsChanged(rmsdB: Float) {
        // Normalize RMS from roughly -2..10 dB to [0.0, 1.0]
        val normalized = ((rmsdB + 2f) / 12f).coerceIn(0f, 1f)
        audioLevelSink?.success(normalized.toDouble())
    }

    override fun onError(error: Int) {
        val errorName = when (error) {
            SpeechRecognizer.ERROR_NO_MATCH        -> "ERROR_NO_MATCH"
            SpeechRecognizer.ERROR_SPEECH_TIMEOUT  -> "ERROR_SPEECH_TIMEOUT"
            SpeechRecognizer.ERROR_NETWORK         -> "ERROR_NETWORK"
            SpeechRecognizer.ERROR_AUDIO           -> "ERROR_AUDIO"
            SpeechRecognizer.ERROR_CLIENT          -> "ERROR_CLIENT"
            SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "ERROR_RECOGNIZER_BUSY"
            else -> "ERROR_UNKNOWN_$error"
        }
        stateSink?.success("error")
        errorSink?.success(errorName)
    }

    override fun onEndOfSpeech()         { stateSink?.success("autoStopped") }
    override fun onBeginningOfSpeech()   {}
    override fun onBufferReceived(b: ByteArray?) {}
    override fun onEvent(type: Int, params: Bundle?) {}
    override fun onReadyForSpeech(params: Bundle?) {}
}
```

---

## 7. AuraChannelRegistrar.kt — Unified Multi-Engine Channel Binder

```kotlin
object AuraChannelRegistrar {

    private val speechChannel = mutableMapOf<String, AuraSpeechChannel>()

    fun registerWith(context: Context, engine: FlutterEngine) {
        val engineId = engine.hashCode().toString()
        val sc = speechChannel.getOrPut(engineId) { AuraSpeechChannel(context) }
        sc.registerOn(engine)
    }
}
```

---

## 8. AuraCaptureActivity.kt — Translucent Voice Overlay

```kotlin
class AuraCaptureActivity : FlutterActivity() {

    override fun getCachedEngineId() = MainActivity.CAPTURE_ENGINE_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Dismiss on outside click (the underlying app is still visible through transparency)
        window.setBackgroundDrawableResource(android.R.color.transparent)
    }

    // CRITICAL: Use translucent theme in AndroidManifest.xml
    // android:theme="@style/TranslucentTheme"
    // TranslucentTheme: windowIsTranslucent=true, windowBackground=@android:color/transparent
}
```

---

## 9. AuraShareActivity.kt — Share Intent Handler

```kotlin
class AuraShareActivity : FlutterActivity() {

    override fun getCachedEngineId() = MainActivity.SHARE_ENGINE_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleShareIntent(intent)
        purgeOldSharedCache()
    }

    private fun handleShareIntent(intent: Intent) {
        if (intent.action != Intent.ACTION_SEND) return

        val payload = mutableMapOf<String, Any?>()

        when {
            intent.type?.startsWith("text/") == true -> {
                payload["type"] = "text"
                payload["text"] = intent.getStringExtra(Intent.EXTRA_TEXT)
                payload["subject"] = intent.getStringExtra(Intent.EXTRA_SUBJECT)
            }
            intent.type?.startsWith("image/") == true -> {
                payload["type"] = "image"
                payload["uri"] = (intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM))?.toString()
            }
            else -> {
                payload["type"] = "file"
                payload["uri"] = (intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM))?.toString()
            }
        }

        // Write payload to cache file for Dart to read via aura/share channel
        val cacheFile = File(cacheDir, "aura_share_payload.json")
        cacheFile.writeText(JSONObject(payload).toString())
    }

    private fun purgeOldSharedCache() {
        val cutoff = System.currentTimeMillis() - (24 * 60 * 60 * 1000L)
        cacheDir.listFiles()
            ?.filter { it.name.startsWith("aura_share_") && it.lastModified() < cutoff }
            ?.forEach { it.delete() }
    }
}

// Register MethodChannel in AuraChannelRegistrar for "aura/share":
// call.method == "getSharePayload" → read aura_share_payload.json → result.success(jsonString)
```

---

## 10. AuraBootReceiver.kt — Restart Orb After Device Boot

```kotlin
class AuraBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val prefs = context.getSharedPreferences("aura_prefs", Context.MODE_PRIVATE)
            if (prefs.getBoolean("orb_enabled", false)) {
                context.startForegroundService(
                    Intent(context, AuraOverlayService::class.java).apply {
                        action = "START_ORB"
                    }
                )
            }
        }
    }
}
```

---

## 11. AuraTileService.kt — Quick Settings Tile

```kotlin
class AuraTileService : TileService() {
    override fun onClick() {
        startActivityAndCollapse(
            Intent(this, AuraCaptureActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        )
    }

    override fun onStartListening() {
        qsTile?.apply {
            state = Tile.STATE_ACTIVE
            label = "AURA Capture"
            updateTile()
        }
    }
}
```

---

## 12. AndroidManifest.xml — Required Declarations

Every Kotlin component MUST be declared in `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Activities -->
<activity android:name=".AuraCaptureActivity"
    android:theme="@style/TranslucentTheme"
    android:exported="false" />

<activity android:name=".AuraShareActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.SEND" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="text/*" />
        <data android:mimeType="image/*" />
        <data android:mimeType="audio/*" />
        <data android:mimeType="video/*" />
        <data android:mimeType="application/*" />
    </intent-filter>
</activity>

<activity android:name=".OrbMenuActivity"
    android:theme="@style/TranslucentTheme"
    android:exported="false" />

<!-- Services -->
<service android:name=".AuraOverlayService"
    android:foregroundServiceType="specialUse"
    android:exported="false">
    <property android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
        android:value="assistantOverlay" />
</service>

<service android:name=".AuraTileService"
    android:exported="true"
    android:icon="@drawable/ic_aura_orb"
    android:label="AURA Capture"
    android:permission="android.permission.BIND_QUICK_SETTINGS_TILE">
    <intent-filter>
        <action android:name="android.service.quicksettings.action.QS_TILE" />
    </intent-filter>
</service>

<!-- Receivers -->
<receiver android:name=".AuraBootReceiver"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
    </intent-filter>
</receiver>
```

---

## 13. TranslucentTheme — `res/values/styles.xml`

```xml
<style name="TranslucentTheme" parent="@android:style/Theme.Translucent.NoTitleBar">
    <item name="android:windowIsTranslucent">true</item>
    <item name="android:windowBackground">@android:color/transparent</item>
    <item name="android:windowNoTitle">true</item>
    <item name="android:windowFullscreen">true</item>
</style>
```

---

## 14. build.gradle.kts — Key Configuration

```kotlin
android {
    namespace = "com.aura.aura"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.aura.aura"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    ndkVersion = "27.0.12077973"
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}
```

---

## 15. R8 Proguard Rules — `proguard-rules.pro`

```
# Flutter + Kotlin
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Kotlin Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** { volatile <fields>; }

# SQLite (sqlite3_flutter_libs)
-keep class org.sqlite.** { *; }
-dontwarn org.sqlite.**

# Google ML Kit
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
```

---

## 16. Common Mistakes to Avoid

| Mistake | Correct Approach |
|---|---|
| Declaring `FloatingOrbService` separately | Use only `AuraOverlayService` with `foregroundServiceType="specialUse"` |
| Registering channels only on main engine | Always use `AuraChannelRegistrar.registerWith()` on ALL three engines |
| Using `startActivity` in Service without `FLAG_ACTIVITY_NEW_TASK` | Always add the flag when starting activity from a Service |
| Forgetting to destroy `SpeechRecognizer` before re-creating | Always call `recognizer?.destroy()` before `createSpeechRecognizer()` |
| Writing shared payload to `filesDir` | Write to `cacheDir` — it's auto-purge eligible and accessible without permissions |
| Using `TYPE_SYSTEM_OVERLAY` | Use `TYPE_APPLICATION_OVERLAY` (API 26+ replacement) |
| `foregroundServiceType="dataSync"` for the orb | Must use `foregroundServiceType="specialUse"` |
