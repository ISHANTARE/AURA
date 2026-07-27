package com.aura.aura

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
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

    override fun onDestroy() {
        speechChannel?.dispose()
        speechChannel = null
        dndReceiver?.let { unregisterReceiver(it) }
        dndReceiver = null
        super.onDestroy()
    }
}
