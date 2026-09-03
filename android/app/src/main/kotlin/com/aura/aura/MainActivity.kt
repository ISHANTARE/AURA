package com.aura.aura

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    companion object {
        const val CAPTURE_ENGINE_ID = "capture_engine_id"
        const val SHARE_ENGINE_ID = "share_engine_id"
        const val REQUEST_ALARM_RINGTONE = 1001
        const val REQUEST_NOTIFICATION_RINGTONE = 1002
    }

    private var captureEngine: FlutterEngine? = null
    private var shareEngine: FlutterEngine? = null

    private var dndEventSink: EventChannel.EventSink? = null
    private var dndReceiver: BroadcastReceiver? = null

    private var pendingRingtoneResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Prewarm background capture engine
        if (FlutterEngineCache.getInstance().get(CAPTURE_ENGINE_ID) == null) {
            captureEngine = FlutterEngine(this).apply {
                navigationChannel.setInitialRoute("/capture-overlay")
                dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
                FlutterEngineCache.getInstance().put(CAPTURE_ENGINE_ID, this)
            }
        }

        // 2. Prewarm background share engine
        if (FlutterEngineCache.getInstance().get(SHARE_ENGINE_ID) == null) {
            shareEngine = FlutterEngine(this).apply {
                navigationChannel.setInitialRoute("/share")
                dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
                FlutterEngineCache.getInstance().put(SHARE_ENGINE_ID, this)
            }
        }

        // 3. Register speech channels on all engines
        AuraChannelRegistrar.registerWith(this, flutterEngine)
        captureEngine?.let { AuraChannelRegistrar.registerWith(this, it) }
        shareEngine?.let { AuraChannelRegistrar.registerWith(this, it) }

        // 4. Register overlay MethodChannel
        registerOverlayChannel(flutterEngine)

        // 5. Register share MethodChannel
        registerShareChannel(flutterEngine)
        shareEngine?.let { registerShareChannel(it) }

        // 6. Register DND channels
        registerDndChannels(flutterEngine)
    }

    private fun registerOverlayChannel(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, "aura/overlay")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startOverlay" -> {
                        val colorHex = call.argument<String>("colorHex")
                        val intent = Intent(this, AuraOverlayService::class.java).apply {
                            action = "START_ORB"
                            if (!colorHex.isNullOrEmpty()) {
                                putExtra("colorHex", colorHex)
                            }
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(true)
                    }
                    "stopOverlay" -> {
                        val intent = Intent(this, AuraOverlayService::class.java).apply {
                            action = "STOP_ORB"
                        }
                        startService(intent)
                        result.success(true)
                    }
                    "updateOverlayColor", "updateOrbColor" -> {
                        val colorHex = call.argument<String>("colorHex")
                        val intent = Intent(this, AuraOverlayService::class.java).apply {
                            action = "UPDATE_COLOR"
                            if (!colorHex.isNullOrEmpty()) {
                                putExtra("colorHex", colorHex)
                            }
                        }
                        startService(intent)
                        result.success(true)
                    }
                    "isOverlayRunning" -> {
                        result.success(AuraOverlayService.isRunning)
                    }
                    "checkOverlayPermission", "isOverlayPermissionGranted" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            result.success(Settings.canDrawOverlays(this))
                        } else {
                            result.success(true)
                        }
                    }
                    "requestOverlayPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val intent = Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")
                            )
                            startActivity(intent)
                        }
                        result.success(null)
                    }
                    "pickSound" -> {
                        pendingRingtoneResult = result
                        val type = call.argument<String>("type") ?: "alarm"
                        val currentUriStr = call.argument<String>("currentUri")
                        val currentUri = if (!currentUriStr.isNullOrEmpty()) Uri.parse(currentUriStr) else null
                        val isNotification = type == "notification"
                        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                            putExtra(
                                RingtoneManager.EXTRA_RINGTONE_TYPE,
                                if (isNotification) RingtoneManager.TYPE_NOTIFICATION else RingtoneManager.TYPE_ALARM
                            )
                            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, true)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, currentUri)
                        }
                        startActivityForResult(
                            intent,
                            if (isNotification) REQUEST_NOTIFICATION_RINGTONE else REQUEST_ALARM_RINGTONE
                        )
                    }
                    "pickAlarmSound" -> {
                        pendingRingtoneResult = result
                        val currentUriStr = call.argument<String>("currentUri")
                        val currentUri = if (!currentUriStr.isNullOrEmpty()) Uri.parse(currentUriStr) else null
                        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALARM)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, true)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, currentUri)
                        }
                        startActivityForResult(intent, REQUEST_ALARM_RINGTONE)
                    }
                    "pickNotificationSound" -> {
                        pendingRingtoneResult = result
                        val currentUriStr = call.argument<String>("currentUri")
                        val currentUri = if (!currentUriStr.isNullOrEmpty()) Uri.parse(currentUriStr) else null
                        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_NOTIFICATION)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, true)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, currentUri)
                        }
                        startActivityForResult(intent, REQUEST_NOTIFICATION_RINGTONE)
                    }
                    "clearNativePrefs" -> {
                        getSharedPreferences("aura_orb_prefs", Context.MODE_PRIVATE).edit().clear().apply()
                        result.success(null)
                    }
                    "ping" -> {
                        result.success("pong")
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun registerShareChannel(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, "aura/share")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialSharePayload" -> {
                        val cacheFile = File(cacheDir, "aura_share_payload.json")
                        if (cacheFile.exists()) {
                            try {
                                val content = cacheFile.readText()
                                cacheFile.delete()
                                val jsonObj = org.json.JSONObject(content)
                                val map = HashMap<String, Any?>()
                                val keys = jsonObj.keys()
                                while (keys.hasNext()) {
                                    val key = keys.next()
                                    map[key] = jsonObj.opt(key)
                                }
                                if (map.containsKey("text") && !map.containsKey("content")) {
                                    map["content"] = map["text"]
                                }
                                if (map.containsKey("localPath") && !map.containsKey("filePath")) {
                                    map["filePath"] = map["localPath"]
                                }
                                result.success(map)
                            } catch (e: Exception) {
                                result.error("SHARE_ERROR", e.message, null)
                            }
                        } else {
                            result.success(null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun registerDndChannels(engine: FlutterEngine) {
        // MethodChannel
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

        // EventChannel
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
                    dndReceiver?.let { unregisterReceiver(it) }
                    dndReceiver = null
                    dndEventSink = null
                }
            })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_ALARM_RINGTONE || requestCode == REQUEST_NOTIFICATION_RINGTONE) {
            if (resultCode == RESULT_OK && data != null) {
                val uri: Uri? = data.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
                if (uri != null) {
                    val ringtone = RingtoneManager.getRingtone(this, uri)
                    val title = ringtone.getTitle(this) ?: "Selected Sound"
                    pendingRingtoneResult?.success(mapOf("uri" to uri.toString(), "title" to title))
                } else {
                    pendingRingtoneResult?.success(mapOf("uri" to "", "title" to "Silent"))
                }
            } else {
                pendingRingtoneResult?.success(null)
            }
            pendingRingtoneResult = null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        dndReceiver?.let { unregisterReceiver(it) }
        dndReceiver = null
        dndEventSink = null
    }
}
