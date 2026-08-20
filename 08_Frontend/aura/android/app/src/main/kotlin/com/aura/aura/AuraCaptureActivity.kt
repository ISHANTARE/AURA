package com.aura.aura

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine

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
        // AuraCaptureActivity has its own FlutterEngine (separate from MainActivity).
        // Without this, aura/speech MethodChannel has no handler → startListening returns false
        // → CaptureStatus stays at 'starting' forever.
        AuraSpeechChannel(applicationContext, messenger)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }
}
