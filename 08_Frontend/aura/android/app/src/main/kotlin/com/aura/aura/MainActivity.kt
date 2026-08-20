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
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var speechChannel: AuraSpeechChannel? = null
    private var dndEventSink: EventChannel.EventSink? = null
    private var dndReceiver: BroadcastReceiver? = null
    private var pendingRingtoneResult: MethodChannel.Result? = null

    companion object {
        private const val REQUEST_RINGTONE_PICKER = 9922
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.getBooleanExtra("trigger_capture", false)) {
            AuraOverlayService.methodChannel?.invokeMethod("onOrbTapped", null)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // Initialize Speech Bridge Channel
        speechChannel = AuraSpeechChannel(applicationContext, messenger)

        // Floating Orb Overlay Control Channel
        val overlayChannel = MethodChannel(messenger, "aura/overlay")
        AuraOverlayService.methodChannel = overlayChannel

        overlayChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startOverlay" -> {
                    if (Settings.canDrawOverlays(this)) {
                        val intent = Intent(this, AuraOverlayService::class.java)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "stopOverlay" -> {
                    val intent = Intent(this, AuraOverlayService::class.java)
                    stopService(intent)
                    result.success(true)
                }
                "isOverlayPermissionGranted" -> {
                    result.success(Settings.canDrawOverlays(this))
                }
                "requestOverlayPermission" -> {
                    if (!Settings.canDrawOverlays(this)) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                    }
                    result.success(true)
                }
                "isOverlayRunning" -> {
                    result.success(AuraOverlayService.isServiceRunning)
                }
                "updateOrbColor" -> {
                    val colorHex = call.argument<String>("colorHex") ?: "#7B6FF0"
                    getSharedPreferences(AuraOverlayService.PREFS_NAME, Context.MODE_PRIVATE)
                        .edit().putString(AuraOverlayService.KEY_ORB_COLOR_HEX, colorHex).apply()
                    AuraOverlayService.instance?.updateOrbColor(colorHex)
                    result.success(true)
                }
                "pickAlarmSound" -> {
                    pendingRingtoneResult = result
                    val currentUriStr = call.argument<String>("currentUri")
                    val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                        putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALARM or RingtoneManager.TYPE_RINGTONE)
                        putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, "Select Alarm Sound")
                        putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
                        putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                        if (!currentUriStr.isNullOrEmpty()) {
                            putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, Uri.parse(currentUriStr))
                        }
                    }
                    try {
                        startActivityForResult(intent, REQUEST_RINGTONE_PICKER)
                    } catch (e: Exception) {
                        pendingRingtoneResult?.error("ERROR", "Failed to launch ringtone picker: ${e.message}", null)
                        pendingRingtoneResult = null
                    }
                }
                else -> result.notImplemented()
            }
        }

        // ── DND (Do Not Disturb) Method Channel ──────────────────────────────
        val dndMethodChannel = MethodChannel(messenger, "com.aura.aura/dnd")
        dndMethodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isDndActive" -> {
                    val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    val filter = nm.currentInterruptionFilter
                    val isDnd = filter != NotificationManager.INTERRUPTION_FILTER_ALL
                    result.success(isDnd)
                }
                "getDndFilter" -> {
                    val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    result.success(nm.currentInterruptionFilter)
                }
                else -> result.notImplemented()
            }
        }

        // ── DND State Change Event Channel ────────────────────────────────────
        val dndEventChannel = EventChannel(messenger, "com.aura.aura/dnd_events")
        dndEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                dndEventSink = events
                dndReceiver = object : BroadcastReceiver() {
                    override fun onReceive(context: Context?, intent: Intent?) {
                        if (intent?.action == NotificationManager.ACTION_INTERRUPTION_FILTER_CHANGED) {
                            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                            val filter = nm.currentInterruptionFilter
                            val isDnd = filter != NotificationManager.INTERRUPTION_FILTER_ALL
                            dndEventSink?.success(isDnd)
                        }
                    }
                }
                val filter = IntentFilter(NotificationManager.ACTION_INTERRUPTION_FILTER_CHANGED)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    registerReceiver(dndReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
                } else {
                    registerReceiver(dndReceiver, filter)
                }
            }

            override fun onCancel(arguments: Any?) {
                dndEventSink = null
                dndReceiver?.let { unregisterReceiver(it) }
                dndReceiver = null
            }
        })
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_RINGTONE_PICKER) {
            if (resultCode == RESULT_OK) {
                val uri: Uri? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI, Uri::class.java)
                } else {
                    data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
                }

                val title = if (uri != null) {
                    try {
                        val ringtone = RingtoneManager.getRingtone(applicationContext, uri)
                        ringtone.getTitle(applicationContext) ?: "Custom Alarm"
                    } catch (e: Exception) {
                        "Custom Alarm"
                    }
                } else {
                    "Default Alarm"
                }

                val resultMap = mapOf(
                    "uri" to (uri?.toString() ?: ""),
                    "title" to title
                )
                pendingRingtoneResult?.success(resultMap)
            } else {
                pendingRingtoneResult?.success(null)
            }
            pendingRingtoneResult = null
        }
    }

    override fun onDestroy() {
        speechChannel?.dispose()
        speechChannel = null
        dndReceiver?.let { unregisterReceiver(it) }
        dndReceiver = null
        super.onDestroy()
    }
}
