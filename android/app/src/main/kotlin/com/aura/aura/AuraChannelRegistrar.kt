package com.aura.aura

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine

object AuraChannelRegistrar {

    private val speechChannels = mutableMapOf<String, AuraSpeechChannel>()

    fun registerWith(context: Context, engine: FlutterEngine) {
        val engineId = engine.hashCode().toString()
        val speech = speechChannels.getOrPut(engineId) { AuraSpeechChannel(context) }
        speech.registerOn(engine)
    }
}
