package com.aura.aura

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Transparent Activity that hosts the voice capture overlay on top of any screen.
 * Critically, it must configure the SpeechChannel on its own FlutterEngine,
 * otherwise startListening() silently fails and the UI freezes at "STARTING...".
 */
class AuraCaptureActivity : FlutterActivity() {

    override fun getInitialRoute(): String {
        return "/capture-overlay"
    }

    override fun getBackgroundMode(): BackgroundMode {
        return BackgroundMode.transparent
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // CRITICAL: Initialize SpeechChannel on THIS engine.
        AuraSpeechChannel(applicationContext, messenger)

        // Register overlay channel on this engine
        val overlayChannel = MethodChannel(messenger, "aura/overlay")
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
                else -> result.notImplemented()
            }
        }

        // Register DND channel on this engine
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
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }
}
