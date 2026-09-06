package com.aura.aura

import android.app.Activity
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File

object AuraChannelRegistrar {

    private val speechChannels = mutableMapOf<String, AuraSpeechChannel>()

    /**
     * Register all platform channels on the given engine.
     *
     * @param context     Application/Activity context; if it is an [Activity], Activity-only
     *                    methods (ringtone picker) are also registered.
     * @param engine      The Flutter engine to register on.
     * @param requestCode Base request code for ringtone picker results.  Only used when
     *                    [context] is an Activity.
     */
    fun registerWith(context: Context, engine: FlutterEngine) {
        val engineId = engine.hashCode().toString()
        val speech = speechChannels.getOrPut(engineId) { AuraSpeechChannel(context) }
        speech.registerOn(engine)

        val activity = context as? Activity
        registerOverlayChannel(context, engine, activity)
        registerShareChannel(context, engine)
        registerDndChannels(context, engine)
    }

    // ──────────────────────────────────────────────────────────────────────────
    // aura/overlay — single handler; includes ringtone picker when Activity
    // is available so MainActivity never double-registers this channel.
    // ──────────────────────────────────────────────────────────────────────────
    private fun registerOverlayChannel(
        context: Context,
        engine: FlutterEngine,
        activity: Activity?,
    ) {
        MethodChannel(engine.dartExecutor.binaryMessenger, "aura/overlay")
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    // ── Overlay service management ────────────────────────
                    "startOverlay" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                            !Settings.canDrawOverlays(context)
                        ) {
                            Log.w("AuraChannelRegistrar", "startOverlay: SYSTEM_ALERT_WINDOW not granted")
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        val colorHex = call.argument<String>("colorHex")
                        val intent = Intent(context, AuraOverlayService::class.java).apply {
                            action = "START_ORB"
                            if (!colorHex.isNullOrEmpty()) putExtra("colorHex", colorHex)
                        }
                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                context.startForegroundService(intent)
                            } else {
                                context.startService(intent)
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e("AuraChannelRegistrar", "startOverlay failed: ${e.message}", e)
                            result.success(false)
                        }
                    }

                    "stopOverlay" -> {
                        val intent = Intent(context, AuraOverlayService::class.java).apply {
                            action = "STOP_ORB"
                        }
                        try {
                            context.startService(intent)
                        } catch (e: Exception) {
                            Log.e("AuraChannelRegistrar", "stopOverlay failed: ${e.message}", e)
                        }
                        result.success(true)
                    }

                    "updateOverlayColor", "updateOrbColor" -> {
                        val colorHex = call.argument<String>("colorHex")
                        val intent = Intent(context, AuraOverlayService::class.java).apply {
                            action = "UPDATE_COLOR"
                            if (!colorHex.isNullOrEmpty()) putExtra("colorHex", colorHex)
                        }
                        try {
                            context.startService(intent)
                        } catch (e: Exception) {
                            Log.e("AuraChannelRegistrar", "updateOverlayColor failed: ${e.message}", e)
                        }
                        result.success(true)
                    }

                    "isOverlayRunning" -> result.success(AuraOverlayService.isRunning)

                    "checkOverlayPermission", "isOverlayPermissionGranted" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            result.success(Settings.canDrawOverlays(context))
                        } else {
                            result.success(true)
                        }
                    }

                    "requestOverlayPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val intent = Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:${context.packageName}")
                            ).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
                            context.startActivity(intent)
                        }
                        result.success(null)
                    }

                    "clearNativePrefs" -> {
                        context.getSharedPreferences("aura_orb_prefs", Context.MODE_PRIVATE)
                            .edit().clear().apply()
                        result.success(true)
                    }

                    "ping" -> result.success("pong")

                    // ── Ringtone picker — Activity required ───────────────
                    "pickSound" -> {
                        if (activity == null) { result.success(null); return@setMethodCallHandler }
                        val type = call.argument<String>("type") ?: "alarm"
                        val currentUri = call.argument<String>("currentUri")
                            ?.takeIf { it.isNotEmpty() }?.let { Uri.parse(it) }
                        val isNotification = type == "notification"
                        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                            putExtra(
                                RingtoneManager.EXTRA_RINGTONE_TYPE,
                                if (isNotification) RingtoneManager.TYPE_NOTIFICATION
                                else RingtoneManager.TYPE_ALARM
                            )
                            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, true)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, currentUri)
                        }
                        // Store result so onActivityResult can resolve it
                        if (activity is MainActivity) {
                            activity.pendingRingtoneResult = result
                            activity.startActivityForResult(
                                intent,
                                if (isNotification) MainActivity.REQUEST_NOTIFICATION_RINGTONE
                                else MainActivity.REQUEST_ALARM_RINGTONE
                            )
                        } else {
                            result.success(null)
                        }
                    }

                    "pickAlarmSound" -> {
                        if (activity == null) { result.success(null); return@setMethodCallHandler }
                        val currentUri = call.argument<String>("currentUri")
                            ?.takeIf { it.isNotEmpty() }?.let { Uri.parse(it) }
                        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALARM)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, true)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, currentUri)
                        }
                        if (activity is MainActivity) {
                            activity.pendingRingtoneResult = result
                            activity.startActivityForResult(intent, MainActivity.REQUEST_ALARM_RINGTONE)
                        } else {
                            result.success(null)
                        }
                    }

                    "pickNotificationSound" -> {
                        if (activity == null) { result.success(null); return@setMethodCallHandler }
                        val currentUri = call.argument<String>("currentUri")
                            ?.takeIf { it.isNotEmpty() }?.let { Uri.parse(it) }
                        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_NOTIFICATION)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, true)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, currentUri)
                        }
                        if (activity is MainActivity) {
                            activity.pendingRingtoneResult = result
                            activity.startActivityForResult(intent, MainActivity.REQUEST_NOTIFICATION_RINGTONE)
                        } else {
                            result.success(null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // ──────────────────────────────────────────────────────────────────────────
    // aura/share
    // ──────────────────────────────────────────────────────────────────────────
    private fun registerShareChannel(context: Context, engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, "aura/share")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialSharePayload" -> {
                        val payload = AuraShareActivity.pendingPayloadJson ?: run {
                            val cacheFile = File(context.cacheDir, "aura_share_payload.json")
                            if (cacheFile.exists()) {
                                try {
                                    val content = cacheFile.readText()
                                    cacheFile.delete()
                                    content
                                } catch (e: Exception) {
                                    null
                                }
                            } else null
                        }
                        result.success(payload)
                    }
                    "close" -> {
                        if (context is Activity) context.finish()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // ──────────────────────────────────────────────────────────────────────────
    // com.aura.aura/dnd & com.aura.aura/dnd_events
    // ──────────────────────────────────────────────────────────────────────────
    private fun registerDndChannels(context: Context, engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, "com.aura.aura/dnd")
            .setMethodCallHandler { call, result ->
                if (call.method == "isDndActive") {
                    val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    val filter = nm.currentInterruptionFilter
                    result.success(filter != NotificationManager.INTERRUPTION_FILTER_ALL)
                } else {
                    result.notImplemented()
                }
            }

        EventChannel(engine.dartExecutor.binaryMessenger, "com.aura.aura/dnd_events")
            .setStreamHandler(object : EventChannel.StreamHandler {
                private var dndReceiver: BroadcastReceiver? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    dndReceiver = object : BroadcastReceiver() {
                        override fun onReceive(receiverContext: Context, intent: Intent) {
                            if (intent.action == NotificationManager.ACTION_INTERRUPTION_FILTER_CHANGED) {
                                val nm = receiverContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                                val isDnd = nm.currentInterruptionFilter != NotificationManager.INTERRUPTION_FILTER_ALL
                                events?.success(isDnd)
                            }
                        }
                    }
                    try {
                        context.registerReceiver(
                            dndReceiver,
                            IntentFilter(NotificationManager.ACTION_INTERRUPTION_FILTER_CHANGED)
                        )
                    } catch (e: Exception) {
                        Log.e("AuraChannelRegistrar", "Failed to register DND receiver: ${e.message}")
                    }
                }

                override fun onCancel(arguments: Any?) {
                    dndReceiver?.let {
                        try { context.unregisterReceiver(it) } catch (_: Exception) {}
                    }
                    dndReceiver = null
                }
            })
    }
}
