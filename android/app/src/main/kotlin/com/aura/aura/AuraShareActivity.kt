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

class AuraShareActivity : FlutterActivity() {

    companion object {
        const val CHANNEL_SHARE = "aura/share"
    }

    private var sharedPayload: Map<String, Any?>? = null
    private var methodChannel: MethodChannel? = null

    override fun getInitialRoute(): String {
        return "/share"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIncomingIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIncomingIntent(intent)
    }

    private fun handleIncomingIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.action
        val type = intent.type ?: ""

        if (Intent.ACTION_SEND == action && type.isNotEmpty()) {
            if (type.startsWith("text/")) {
                val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
                if (sharedText != null) {
                    sharedPayload = mapOf(
                        "type" to "text",
                        "content" to sharedText,
                        "mimeType" to type
                    )
                }
            } else {
                val fileUri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
                } else {
                    @Suppress("DEPRECATION")
                    intent.getParcelableExtra(Intent.EXTRA_STREAM)
                }
                if (fileUri != null) {
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
                    val localPath = copyUriToCache(fileUri, "shared_media.$ext")
                    sharedPayload = mapOf(
                        "type" to mediaCategory,
                        "filePath" to localPath,
                        "mimeType" to type
                    )
                }
            }
        }
    }

    private fun copyUriToCache(uri: Uri, filename: String): String? {
        return try {
            val inputStream = contentResolver.openInputStream(uri) ?: return null
            val file = File(cacheDir, "${System.currentTimeMillis()}_$filename")
            val outputStream = FileOutputStream(file)
            inputStream.copyTo(outputStream)
            inputStream.close()
            outputStream.close()
            file.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        methodChannel = MethodChannel(messenger, CHANNEL_SHARE)

        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialSharePayload" -> {
                    result.success(sharedPayload)
                    sharedPayload = null
                }
                else -> result.notImplemented()
            }
        }
    }
}
