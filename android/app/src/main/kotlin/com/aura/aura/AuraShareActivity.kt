package com.aura.aura

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.webkit.MimeTypeMap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream

class AuraShareActivity : FlutterActivity() {

    companion object {
        const val TAG = "AuraShareActivity"
        const val CHANNEL_NAME = "aura/share"

        @Volatile
        var pendingPayloadJson: String? = null
    }

    override fun getCachedEngineId(): String? = null

    override fun shouldDestroyEngineWithHost(): Boolean = true

    override fun getBackgroundMode(): FlutterActivityLaunchConfigs.BackgroundMode {
        return FlutterActivityLaunchConfigs.BackgroundMode.transparent
    }

    override fun getRenderMode(): RenderMode {
        return RenderMode.texture
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine {
        return FlutterEngine(context.applicationContext).apply {
            navigationChannel.setInitialRoute("/share")
            dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // AuraChannelRegistrar registers aura/overlay + aura/share in one place.
        // The close() and getInitialSharePayload() methods in aura/share are handled there.
        AuraChannelRegistrar.registerWith(this, flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setBackgroundDrawableResource(android.R.color.transparent)
        handleShareIntent(intent)
        purgeOldSharedCache()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleShareIntent(intent)
    }

    private fun handleShareIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.action
        if (action != Intent.ACTION_SEND && action != Intent.ACTION_SEND_MULTIPLE) return

        val payload = JSONObject()
        val type = intent.type ?: "text/plain"

        try {
            if (action == Intent.ACTION_SEND) {
                if (type.startsWith("text/")) {
                    val text = intent.getStringExtra(Intent.EXTRA_TEXT) ?: ""
                    val subject = intent.getStringExtra(Intent.EXTRA_SUBJECT) ?: ""
                    payload.put("type", "text")
                    payload.put("content", text)
                    payload.put("text", text)
                    payload.put("subject", subject)
                    payload.put("mimeType", type)
                } else {
                    val streamUri = extractSingleUri(intent)
                    val localPath = streamUri?.let { copyUriToCache(it) } ?: ""
                    val itemType = when {
                        type.startsWith("image/") -> "image"
                        type.startsWith("video/") -> "video"
                        type.startsWith("audio/") -> "audio"
                        type == "application/pdf" -> "pdf"
                        else -> "file"
                    }
                    payload.put("type", itemType)
                    payload.put("mimeType", type)
                    payload.put("uri", streamUri?.toString() ?: "")
                    payload.put("filePath", localPath)
                    payload.put("localPath", localPath)
                    val extraText = intent.getStringExtra(Intent.EXTRA_TEXT)
                    if (!extraText.isNullOrEmpty()) {
                        payload.put("content", extraText)
                    }
                }
            } else if (action == Intent.ACTION_SEND_MULTIPLE) {
                val streamUris = extractMultipleUris(intent)
                val filesArray = JSONArray()
                var firstPath = ""
                streamUris.forEachIndexed { index, uri ->
                    val path = copyUriToCache(uri)
                    if (index == 0) firstPath = path
                    filesArray.put(JSONObject().apply {
                        put("uri", uri.toString())
                        put("filePath", path)
                        put("localPath", path)
                    })
                }
                val itemType = when {
                    type.startsWith("image/") -> "image"
                    type.startsWith("video/") -> "video"
                    type.startsWith("audio/") -> "audio"
                    type == "application/pdf" -> "pdf"
                    else -> "multiple_files"
                }
                payload.put("type", itemType)
                payload.put("mimeType", type)
                payload.put("filePath", firstPath)
                payload.put("localPath", firstPath)
                payload.put("files", filesArray)
            }

            val jsonStr = payload.toString()
            pendingPayloadJson = jsonStr

            // Save payload JSON to cache file as backup
            val payloadFile = File(cacheDir, "aura_share_payload.json")
            payloadFile.writeText(jsonStr)

            // Notify Flutter if engine is already mounted
            flutterEngine?.let { engine ->
                MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)
                    .invokeMethod("onShareReceived", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "handleShareIntent failed: ${e.message}", e)
        }
    }

    private fun extractSingleUri(intent: Intent): Uri? {
        val streamUri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            try {
                intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
            } catch (e: Exception) {
                null
            }
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
        }
        if (streamUri != null) return streamUri

        intent.clipData?.let { clip ->
            if (clip.itemCount > 0) {
                clip.getItemAt(0)?.uri?.let { return it }
            }
        }

        return intent.data
    }

    private fun extractMultipleUris(intent: Intent): List<Uri> {
        val list = mutableListOf<Uri>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            try {
                intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM, Uri::class.java)?.let {
                    list.addAll(it)
                }
            } catch (e: Exception) {
                // Ignore and fall through to clipData
            }
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)?.let {
                list.addAll(it)
            }
        }

        if (list.isEmpty()) {
            intent.clipData?.let { clip ->
                for (i in 0 until clip.itemCount) {
                    clip.getItemAt(i)?.uri?.let { list.add(it) }
                }
            }
        }
        return list
    }

    private fun copyUriToCache(uri: Uri): String {
        return try {
            val shareDir = File(cacheDir, "aura_shared").apply { if (!exists()) mkdirs() }
            val safeName = "aura_share_${System.currentTimeMillis()}_${System.nanoTime()}"
            var extension = contentResolver.getType(uri)?.let { mime ->
                MimeTypeMap.getSingleton().getExtensionFromMimeType(mime)
            }
            if (extension.isNullOrEmpty()) {
                val path = uri.path
                if (path != null && path.contains(".")) {
                    extension = path.substringAfterLast('.', "bin")
                } else {
                    extension = "bin"
                }
            }
            val destFile = File(shareDir, "$safeName.$extension")

            if (uri.scheme == "file") {
                val srcFile = File(uri.path ?: "")
                if (srcFile.exists()) {
                    srcFile.copyTo(destFile, overwrite = true)
                    return destFile.absolutePath
                }
            }

            contentResolver.openInputStream(uri)?.use { input ->
                FileOutputStream(destFile).use { output ->
                    input.copyTo(output)
                }
            }
            destFile.absolutePath
        } catch (e: Exception) {
            Log.e(TAG, "copyUriToCache failed for $uri: ${e.message}", e)
            ""
        }
    }

    private fun purgeOldSharedCache() {
        try {
            val cutoff = System.currentTimeMillis() - (24 * 60 * 60 * 1000L) // 24 hours
            val shareDir = File(cacheDir, "aura_shared")
            if (shareDir.exists() && shareDir.isDirectory) {
                shareDir.listFiles()?.forEach { file ->
                    if (file.lastModified() < cutoff) {
                        file.delete()
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "purgeOldSharedCache error: ${e.message}", e)
        }
    }
}
