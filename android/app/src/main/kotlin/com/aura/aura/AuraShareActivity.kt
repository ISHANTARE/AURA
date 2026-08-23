package com.aura.aura

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import org.json.JSONObject

/**
 * Share Target Activity (Sprint 9 / PRD F-09).
 *
 * Hardened against the failure modes found in audit follow-up review:
 *  - Config-change re-delivery no longer duplicates payloads (intent-identity
 *    guard).
 *  - The payload is persisted to cacheDir JSON instead of living only in an
 *    Activity field, so it survives engine restarts and is consumed exactly
 *    once (file deleted on read).
 *  - Media copies run off the main thread and older than 24h are swept.
 *  - Warm shares arriving via onNewIntent push `onShareReceived` to Dart.
 */
class AuraShareActivity : FlutterActivity() {

    companion object {
        const val CHANNEL_SHARE = "aura/share"
        private const val PAYLOAD_FILE = "aura_share_payload.json"
        private const val CACHE_MAX_AGE_MS = 24L * 60 * 60 * 1000
    }

    private var methodChannel: MethodChannel? = null

    /** Identity of the intent currently materialized on disk — prevents the
     *  same share from being re-written after rotation/config change. */
    private var lastHandledIntentId: Int = Int.MIN_VALUE

    override fun getInitialRoute(): String {
        val isShare = intent?.action == Intent.ACTION_SEND
        return if (isShare) "/share" else (super.getInitialRoute() ?: "/")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIncomingIntent(intent)
        sweepStaleCache()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIncomingIntent(intent)
        // A warm share landed while this activity was alive — tell Dart.
        methodChannel?.invokeMethod("onShareReceived", null)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        methodChannel = MethodChannel(messenger, CHANNEL_SHARE)

        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialSharePayload" -> {
                    result.success(consumePayloadFile())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun handleIncomingIntent(intent: Intent?) {
        if (intent == null || intent.action != Intent.ACTION_SEND) return

        // Dedupe re-delivered intents (rotation, process restore).
        if (intent.identityHash() == lastHandledIntentId) return
        lastHandledIntentId = intent.identityHash()

        val type = intent.type ?: return
        if (type.startsWith("text/")) {
            val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
            if (sharedText != null) {
                writePayload(
                    JSONObject().apply {
                        put("type", "text")
                        put("content", sharedText)
                        put("mimeType", type)
                    }
                )
            }
            return
        }

        val fileUri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(Intent.EXTRA_STREAM)
        } ?: return

        val mediaCategory = when {
            type.startsWith("image/") -> "image"
            type.startsWith("video/") -> "video"
            type.startsWith("audio/") -> "audio"
            type == "application/pdf" -> "pdf"
            else -> "document"
        }
        val ext = when {
            type.startsWith("image/") -> "jpg"
            type.startsWith("video/") -> "mp4"
            type.startsWith("audio/") -> "mp3"
            type == "application/pdf" -> "pdf"
            type.contains("word") || type.contains("document") -> "docx"
            else -> "bin"
        }

        // Copy off the main thread — large media stalled startup before.
        Thread {
            val localPath = copyUriToCache(fileUri, "shared_media.$ext")
            if (localPath != null) {
                writePayload(
                    JSONObject().apply {
                        put("type", mediaCategory)
                        put("filePath", localPath)
                        put("mimeType", type)
                    }
                )
                runOnUiThread {
                    methodChannel?.invokeMethod("onShareReceived", null)
                }
            }
        }.start()
    }

    private fun Intent.identityHash(): Int {
        var hash = action?.hashCode() ?: 0
        hash = 31 * hash + (type?.hashCode() ?: 0)
        hash = 31 * hash + (getStringExtra(Intent.EXTRA_TEXT)?.hashCode() ?: 0)
        val stream = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            getParcelableExtra(Intent.EXTRA_STREAM)
        }
        return 31 * hash + (stream?.hashCode() ?: 0)
    }

    // ── Payload persistence ──────────────────────────────────────────────────

    private fun payloadFile(): File = File(cacheDir, PAYLOAD_FILE)

    private fun writePayload(json: JSONObject) {
        try {
            payloadFile().writeText(json.toString())
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /** Single-consume read: returns the payload and deletes it. */
    private fun consumePayloadFile(): Map<String, Any?>? {
        val file = payloadFile()
        if (!file.exists()) return null
        return try {
            val json = JSONObject(file.readText())
            file.delete()
            json.toMap()
        } catch (e: Exception) {
            e.printStackTrace()
            file.delete()
            null
        }
    }

    private fun JSONObject.toMap(): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>()
        for (key in keys()) {
            map[key] = when (val v = get(key)) {
                is JSONObject -> v.toMap()
                else -> v
            }
        }
        return map
    }

    // ── Cache hygiene ────────────────────────────────────────────────────────

    private fun sweepStaleCache() {
        Thread {
            try {
                val cutoff = System.currentTimeMillis() - CACHE_MAX_AGE_MS
                cacheDir.listFiles()?.forEach { f ->
                    if (f.name != PAYLOAD_FILE && f.lastModified() < cutoff) {
                        f.delete()
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }.start()
    }

    private fun copyUriToCache(uri: Uri, filename: String): String? {
        return try {
            val inputStream = contentResolver.openInputStream(uri) ?: return null
            val file = File(cacheDir, "${System.currentTimeMillis()}_$filename")
            val outputStream = FileOutputStream(file)
            inputStream.use { input ->
                outputStream.use { output ->
                    input.copyTo(output)
                }
            }
            file.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}
