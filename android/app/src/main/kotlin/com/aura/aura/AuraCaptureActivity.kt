package com.aura.aura

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class AuraCaptureActivity : FlutterActivity() {

    override fun getCachedEngineId(): String = MainActivity.CAPTURE_ENGINE_ID

    override fun shouldDestroyEngineWithHost(): Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setBackgroundDrawableResource(android.R.color.transparent)
    }
}
