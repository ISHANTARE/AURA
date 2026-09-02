package com.aura.aura

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream

class AuraShareActivity : FlutterActivity() {

    override fun getCachedEngineId(): String = MainActivity.SHARE_ENGINE_ID

    override fun shouldDestroyEngineWithHost(): Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setBackgroundDrawableResource(android.R.color.transparent)
        handleShareIntent(intent)
        purgeOldSharedCache()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
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
                    val streamUri = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
                    val localPath = streamUri?.let { copyUriToCache(it) }
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
                    payload.put("filePath", localPath ?: "")
                    payload.put("localPath", localPath ?: "")
                    val extraText = intent.getStringExtra(Intent.EXTRA_TEXT)
                    if (!extraText.isNullOrEmpty()) {
                        payload.put("content", extraText)
                    }
                }
            } else if (action == Intent.ACTION_SEND_MULTIPLE) {
                val streamUris = intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
                val filesArray = JSONArray()
                var firstPath = ""
                streamUris?.forEachIndexed { index, uri ->
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

            // Save payload JSON to cache file
            val payloadFile = File(cacheDir, "aura_share_payload.json")
            payloadFile.writeText(payload.toString())

            // Notify Flutter share engine if cached
            FlutterEngineCache.getInstance().get(MainActivity.SHARE_ENGINE_ID)?.let { engine ->
                MethodChannel(engine.dartExecutor.binaryMessenger, "aura/share")
                    .invokeMethod("onShareReceived", null)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun copyUriToCache(uri: Uri): String {
        return try {
            val shareDir = File(cacheDir, "aura_shared").apply { if (!exists()) mkdirs() }
            val fileName = "aura_share_${System.currentTimeMillis()}_${uri.lastPathSegment ?: "file"}"
            val destFile = File(shareDir, fileName)

            contentResolver.openInputStream(uri)?.use { input ->
                FileOutputStream(destFile).use { output ->
                    input.copyTo(output)
                }
            }
            destFile.absolutePath
        } catch (e: Exception) {
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
            e.printStackTrace()
        }
    }
}
