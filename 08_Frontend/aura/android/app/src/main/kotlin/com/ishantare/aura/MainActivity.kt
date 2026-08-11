package com.ishantare.aura

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL_OVERLAY = "com.aura.aura/overlay"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_OVERLAY)

        AuraOverlayService.onOrbTapListener = {
            activity.runOnUiThread {
                channel.invokeMethod("onOrbTapped", null)
            }
        }

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startOverlay" -> {
                    if (isOverlayPermissionGranted()) {
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
                    result.success(isOverlayPermissionGranted())
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(null)
                }
                "isOverlayRunning" -> {
                    result.success(AuraOverlayService.isServiceRunning)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isOverlayPermissionGranted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivity(intent)
        }
    }
}
