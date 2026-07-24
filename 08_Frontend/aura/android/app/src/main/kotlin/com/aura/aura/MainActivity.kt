package com.aura.aura

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var speechChannel: AuraSpeechChannel? = null

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
    }

    override fun onDestroy() {
        speechChannel?.dispose()
        speechChannel = null
        super.onDestroy()
    }
}
