package com.aura.aura

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private var registrar: AuraChannelRegistrar? = null

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.getBooleanExtra("trigger_capture", false)) {
            AuraOverlayService.methodChannel?.invokeMethod("onOrbTapped", null)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        registrar = AuraChannelRegistrar(
            activity = this,
            engine = flutterEngine,
            isPrimaryEngine = true,
        ).also { it.registerAll() }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        registrar?.handleActivityResult(requestCode, resultCode, data)
    }

    override fun onDestroy() {
        registrar?.dispose()
        registrar = null
        super.onDestroy()
    }
}
