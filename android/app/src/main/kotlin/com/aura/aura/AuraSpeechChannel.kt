package com.aura.aura

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class AuraSpeechChannel(private val context: Context) : RecognitionListener {

    private var partialSink: EventChannel.EventSink? = null
    private var audioLevelSink: EventChannel.EventSink? = null
    private var stateSink: EventChannel.EventSink? = null
    private var errorSink: EventChannel.EventSink? = null

    private var recognizer: SpeechRecognizer? = null

    fun registerOn(engine: FlutterEngine) {
        val messenger = engine.dartExecutor.binaryMessenger

        // Control MethodChannel
        MethodChannel(messenger, "aura/speech").setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> {
                    val localeId = call.argument<String>("localeId")
                    startListening(localeId)
                    result.success(true)
                }
                "stopListening" -> {
                    recognizer?.stopListening()
                    result.success(true)
                }
                "cancelListening" -> {
                    recognizer?.cancel()
                    stateSink?.success("ready")
                    result.success(true)
                }
                "isAvailable" -> {
                    result.success(SpeechRecognizer.isRecognitionAvailable(context))
                }
                else -> result.notImplemented()
            }
        }

        // EventChannels
        EventChannel(messenger, "aura/speech/partial").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, sink: EventChannel.EventSink?) { partialSink = sink }
                override fun onCancel(args: Any?) { partialSink = null }
            }
        )

        EventChannel(messenger, "aura/speech/audioLevel").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, sink: EventChannel.EventSink?) { audioLevelSink = sink }
                override fun onCancel(args: Any?) { audioLevelSink = null }
            }
        )

        EventChannel(messenger, "aura/speech/speechState").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, sink: EventChannel.EventSink?) { stateSink = sink }
                override fun onCancel(args: Any?) { stateSink = null }
            }
        )

        EventChannel(messenger, "aura/speech/speechError").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, sink: EventChannel.EventSink?) { errorSink = sink }
                override fun onCancel(args: Any?) { errorSink = null }
            }
        )
    }

    private fun startListening(localeId: String?) {
        recognizer?.destroy()
        recognizer = SpeechRecognizer.createSpeechRecognizer(context).apply {
            setRecognitionListener(this@AuraSpeechChannel)
        }

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
            if (!localeId.isNullOrBlank()) {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, localeId)
            } else {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault().toLanguageTag())
            }
        }

        stateSink?.success("ready")
        recognizer?.startListening(intent)
        stateSink?.success("listening")
    }

    // --- RecognitionListener Implementation ---

    override fun onPartialResults(partialResults: Bundle) {
        val partial = partialResults
            .getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            ?.firstOrNull() ?: return
        partialSink?.success(partial)
    }

    override fun onResults(results: Bundle) {
        val transcript = results
            .getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            ?.firstOrNull() ?: ""
        stateSink?.success("processing")
        partialSink?.success(transcript)
    }

    override fun onRmsChanged(rmsdB: Float) {
        // Map dB (roughly -2.0 .. 10.0) to [0.0, 1.0]
        val normalized = ((rmsdB + 2.0f) / 12.0f).coerceIn(0.0f, 1.0f)
        audioLevelSink?.success(normalized.toDouble())
    }

    override fun onError(error: Int) {
        val errorName = when (error) {
            SpeechRecognizer.ERROR_NO_MATCH -> "ERROR_NO_MATCH"
            SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "ERROR_SPEECH_TIMEOUT"
            SpeechRecognizer.ERROR_NETWORK -> "ERROR_NETWORK"
            SpeechRecognizer.ERROR_AUDIO -> "ERROR_AUDIO"
            SpeechRecognizer.ERROR_CLIENT -> "ERROR_CLIENT"
            SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "ERROR_RECOGNIZER_BUSY"
            SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "ERROR_INSUFFICIENT_PERMISSIONS"
            else -> "ERROR_UNKNOWN_$error"
        }
        stateSink?.success("error")
        errorSink?.success(errorName)
    }

    override fun onEndOfSpeech() {
        stateSink?.success("autoStopped")
    }

    override fun onBeginningOfSpeech() {}
    override fun onBufferReceived(buffer: ByteArray?) {}
    override fun onEvent(eventType: Int, params: Bundle?) {}
    override fun onReadyForSpeech(params: Bundle?) {}
}
