package com.aura.aura

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine

/**
 * Transparent Activity that hosts the voice capture overlay on top of any screen.
 * Critically, it must configure the SpeechChannel on its own FlutterEngine,
 * otherwise startListening() silently fails and the UI freezes at "STARTING...".
 */
class AuraCaptureActivity : FlutterActivity() {

    private var registrar: AuraChannelRegistrar? = null

    override fun getInitialRoute(): String {
        return "/capture-overlay"
    }

    override fun getBackgroundMode(): BackgroundMode {
        return BackgroundMode.transparent
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Full channel parity with the main engine — previously this engine was
        // missing pickAlarmSound and dnd_events.
        registrar = AuraChannelRegistrar(
            activity = this,
            engine = flutterEngine,
            isPrimaryEngine = false,
        ).also { it.registerAll() }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        registrar?.handleActivityResult(requestCode, resultCode, data)
    }

    override fun onDestroy() {
        // Previously each capture session leaked a recognizer-backed channel.
        registrar?.dispose()
        registrar = null
        super.onDestroy()
    }
}
