package com.aura.aura

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AuraSpeechChannel(
    private val context: Context,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler, RecognitionListener {

    private val methodChannel = MethodChannel(messenger, "aura/speech")
    private val partialChannel = EventChannel(messenger, "aura/speech/partial")
    private val audioLevelChannel = EventChannel(messenger, "aura/speech/audioLevel")

    private var speechRecognizer: SpeechRecognizer? = null
    private var partialSink: EventChannel.EventSink? = null
    private var audioLevelSink: EventChannel.EventSink? = null

    private var isListening = false
    private val mainHandler = Handler(Looper.getMainLooper())

    init {
        methodChannel.setMethodCallHandler(this)

        partialChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                partialSink = events
            }

            override fun onCancel(arguments: Any?) {
                partialSink = null
            }
        })

        audioLevelChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                audioLevelSink = events
            }

            override fun onCancel(arguments: Any?) {
                audioLevelSink = null
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startListening" -> {
                val success = startListening()
                result.success(success)
            }
            "stopListening" -> {
                stopListening()
                result.success(true)
            }
            "cancelListening" -> {
                cancelListening()
                result.success(true)
            }
            "isAvailable" -> {
                result.success(SpeechRecognizer.isRecognitionAvailable(context))
            }
            else -> result.notImplemented()
        }
    }

    private fun startListening(): Boolean {
        if (!SpeechRecognizer.isRecognitionAvailable(context)) {
            return false
        }

        mainHandler.post {
            if (speechRecognizer == null) {
                speechRecognizer = SpeechRecognizer.createSpeechRecognizer(context).apply {
                    setRecognitionListener(this@AuraSpeechChannel)
                }
            }

            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-IN")
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, "en-IN")
                putExtra(RecognizerIntent.EXTRA_ONLY_RETURN_LANGUAGE_PREFERENCE, false)
                putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
                putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
                // Give the user more time between words — default ~1.5s is too aggressive.
                // Complete silence before stopping: 2.5 seconds
                putExtra("android.speech.extra.SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS", 2500L)
                // "Possibly done?" threshold: 1.5 seconds
                putExtra("android.speech.extra.SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS", 1500L)
                // Minimum session before auto-stop: 6 seconds
                putExtra("android.speech.extra.SPEECH_INPUT_MINIMUM_LENGTH_MILLIS", 6000L)
            }

            speechRecognizer?.startListening(intent)
            isListening = true
        }
        return true
    }

    private fun stopListening() {
        mainHandler.post {
            if (isListening) {
                speechRecognizer?.stopListening()
                isListening = false
            }
        }
    }

    private fun cancelListening() {
        mainHandler.post {
            if (isListening) {
                speechRecognizer?.cancel()
                isListening = false
            }
        }
    }

    // ── RecognitionListener Callbacks ──────────────────────────────────────

    override fun onReadyForSpeech(params: Bundle?) {
        mainHandler.post {
            methodChannel.invokeMethod("onSpeechStateChanged", "listening")
        }
    }

    override fun onBeginningOfSpeech() {}

    override fun onRmsChanged(rmsdB: Float) {
        // rmsdB ranges roughly from -2.0 to 10.0
        // Normalize to 0.0 .. 1.0 range for Flutter waveform
        val normalized = ((rmsdB + 2.0f) / 12.0f).coerceIn(0.0f, 1.0f).toDouble()
        mainHandler.post {
            audioLevelSink?.success(normalized)
        }
    }

    override fun onBufferReceived(buffer: ByteArray?) {}

    override fun onEndOfSpeech() {
        mainHandler.post {
            methodChannel.invokeMethod("onSpeechStateChanged", "autoStopped")
        }
    }

    override fun onError(error: Int) {
        mainHandler.post {
            isListening = false
            val errorMessage = when (error) {
                SpeechRecognizer.ERROR_AUDIO -> "Audio recording error"
                SpeechRecognizer.ERROR_CLIENT -> "Client side error"
                SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "Microphone permission required"
                SpeechRecognizer.ERROR_NETWORK -> "Network error"
                SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "Network timeout"
                SpeechRecognizer.ERROR_NO_MATCH -> "No speech detected"
                SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "Speech recognizer busy"
                SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "Speech timeout"
                else -> "Speech recognition error ($error)"
            }
            methodChannel.invokeMethod("onSpeechError", errorMessage)
        }
    }

    override fun onResults(results: Bundle?) {
        val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
        val text = matches?.firstOrNull() ?: ""
        mainHandler.post {
            isListening = false
            partialSink?.success(text)
            methodChannel.invokeMethod("onTranscriptReady", text)
        }
    }

    override fun onPartialResults(partialResults: Bundle?) {
        val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
        val text = matches?.firstOrNull() ?: ""
        mainHandler.post {
            partialSink?.success(text)
        }
    }

    override fun onEvent(eventType: Int, params: Bundle?) {}

    fun dispose() {
        speechRecognizer?.destroy()
        speechRecognizer = null
    }
}
