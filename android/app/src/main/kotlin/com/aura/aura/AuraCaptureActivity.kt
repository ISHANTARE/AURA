package com.aura.aura

import android.content.Context
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class AuraCaptureActivity : FlutterActivity() {

    companion object {
        const val CHANNEL_NAME = "aura/capture_activity"
    }

    private var captureChannel: MethodChannel? = null

    override fun getCachedEngineId(): String? = null

    override fun shouldDestroyEngineWithHost(): Boolean = false

    override fun getBackgroundMode(): FlutterActivityLaunchConfigs.BackgroundMode {
        return FlutterActivityLaunchConfigs.BackgroundMode.transparent
    }

    override fun getRenderMode(): RenderMode {
        return RenderMode.texture
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine {
        val cached = FlutterEngineCache.getInstance().get(MainActivity.CAPTURE_ENGINE_ID)
        if (cached != null) {
            return cached
        }
        val engine = FlutterEngine(context.applicationContext).apply {
            navigationChannel.setInitialRoute("/capture-overlay")
            dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
            FlutterEngineCache.getInstance().put(MainActivity.CAPTURE_ENGINE_ID, this)
        }
        AuraChannelRegistrar.registerWith(this, engine)
        return engine
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setBackgroundDrawableResource(android.R.color.transparent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Ensure speech recognition has this foreground Activity context
        AuraChannelRegistrar.registerWith(this, flutterEngine)

        captureChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "close" -> {
                        finish()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        // Signal Flutter engine to reset and immediately arm voice capture
        flutterEngine?.let { engine ->
            val channel = captureChannel ?: MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            channel.invokeMethod("restartCapture", null)
        }
    }
}
