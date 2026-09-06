package com.aura.aura

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        const val CAPTURE_ENGINE_ID = "capture_engine_id"
        const val SHARE_ENGINE_ID   = "share_engine_id"
        const val REQUEST_ALARM_RINGTONE        = 1001
        const val REQUEST_NOTIFICATION_RINGTONE = 1002
    }

    private var captureEngine: FlutterEngine? = null

    /** Exposed so AuraChannelRegistrar can resolve ringtone-picker results. */
    var pendingRingtoneResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Pre-warm background capture engine.
        if (FlutterEngineCache.getInstance().get(CAPTURE_ENGINE_ID) == null) {
            captureEngine = FlutterEngine(this).apply {
                navigationChannel.setInitialRoute("/capture-overlay")
                dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
                FlutterEngineCache.getInstance().put(CAPTURE_ENGINE_ID, this)
            }
        }

        // 2. Register all platform channels via the single registrar.
        //    AuraChannelRegistrar is the sole source of truth for all channels (overlay, share, dnd, speech)
        AuraChannelRegistrar.registerWith(this, flutterEngine)
        captureEngine?.let { AuraChannelRegistrar.registerWith(this, it) }
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Ringtone picker result callback
    // ──────────────────────────────────────────────────────────────────────────

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
}
