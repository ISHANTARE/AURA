package com.aura.aura

import android.app.Activity
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Registers ALL platform channels identically for every Flutter engine.
 *
 * AURA runs two Flutter engines (MainActivity and the translucent
 * AuraCaptureActivity). Previously each engine registered its own ad-hoc
 * subset of channels — the capture engine was missing `pickAlarmSound` and
 * the `dnd_events` stream, so those features silently died depending on
 * which engine happened to be foreground.
 *
 * [isPrimaryEngine] must be true for the long-lived main engine only:
 * it owns the static [AuraOverlayService.methodChannel] reference the native
 * orb uses to notify Flutter about taps.
 */
class AuraChannelRegistrar(
    private val activity: Activity,
    engine: FlutterEngine,
    private val isPrimaryEngine: Boolean,
) {

    private val messenger: BinaryMessenger = engine.dartExecutor.binaryMessenger

    var speechChannel: AuraSpeechChannel? = null
        private set

    private var pendingRingtoneResult: MethodChannel.Result? = null
    private var dndEventSink: EventChannel.EventSink? = null
    private var dndReceiver: BroadcastReceiver? = null

    fun registerAll() {
        registerSpeech()
        registerOverlay()
        registerDnd()
    }

    // ── Speech ────────────────────────────────────────────────────────────────

    private fun registerSpeech() {
        speechChannel = AuraSpeechChannel(activity.applicationContext, messenger)
    }

    // ── Floating orb overlay control ─────────────────────────────────────────

    private fun registerOverlay() {
        val overlayChannel = MethodChannel(messenger, "aura/overlay")
        if (isPrimaryEngine) {
            AuraOverlayService.methodChannel = overlayChannel
        }
        overlayChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startOverlay" -> {
                    if (Settings.canDrawOverlays(activity)) {
                        val intent = Intent(activity, AuraOverlayService::class.java)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            activity.startForegroundService(intent)
                        } else {
                            activity.startService(intent)
                        }
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "stopOverlay" -> {
                    activity.stopService(Intent(activity, AuraOverlayService::class.java))
                    result.success(true)
                }
                "isOverlayPermissionGranted" -> {
                    result.success(Settings.canDrawOverlays(activity))
                }
                "requestOverlayPermission" -> {
                    if (!Settings.canDrawOverlays(activity)) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:${activity.packageName}")
                        )
                        activity.startActivity(intent)
                    }
                    result.success(true)
                }
                "isOverlayRunning" -> result.success(AuraOverlayService.isServiceRunning)
                "updateOrbColor" -> {
                    val colorHex = call.argument<String>("colorHex") ?: "#7B6FF0"
                    activity.getSharedPreferences(AuraOverlayService.PREFS_NAME, Context.MODE_PRIVATE)
                        .edit().putString(AuraOverlayService.KEY_ORB_COLOR_HEX, colorHex).apply()
                    AuraOverlayService.instance?.updateOrbColor(colorHex)
                    result.success(true)
                }
                "pickAlarmSound" -> launchRingtonePicker("alarm", call.argument<String>("currentUri"), "Select Default Alarm Sound", result)
                "pickNotificationSound" -> launchRingtonePicker("notification", call.argument<String>("currentUri"), "Select Default Notification Sound", result)
                "pickSound" -> launchRingtonePicker(
                    call.argument<String>("type") ?: "alarm",
                    call.argument<String>("currentUri"),
                    call.argument<String>("title"),
                    result
                )
                "clearNativePrefs" -> {
                    activity.getSharedPreferences(AuraOverlayService.PREFS_NAME, Context.MODE_PRIVATE)
                        .edit().clear().apply()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    // ── DND state ────────────────────────────────────────────────────────────

    private fun registerDnd() {
        val dndMethodChannel = MethodChannel(messenger, "com.aura.aura/dnd")
        dndMethodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isDndActive" -> result.success(isDndActive())
                "getDndFilter" -> {
                    val nm = activity.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    result.success(nm.currentInterruptionFilter)
                }
                else -> result.notImplemented()
            }
        }

        val dndEventChannel = EventChannel(messenger, "com.aura.aura/dnd_events")
        dndEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                dndEventSink = events
                dndReceiver = object : BroadcastReceiver() {
                    override fun onReceive(context: Context?, intent: Intent?) {
                        if (intent?.action == NotificationManager.ACTION_INTERRUPTION_FILTER_CHANGED) {
                            dndEventSink?.success(isDndActive())
                        }
                    }
                }
                val filter = IntentFilter(NotificationManager.ACTION_INTERRUPTION_FILTER_CHANGED)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    activity.registerReceiver(dndReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
                } else {
                    activity.registerReceiver(dndReceiver, filter)
                }
            }

            override fun onCancel(arguments: Any?) {
                dndEventSink = null
                dndReceiver?.let { activity.unregisterReceiver(it) }
                dndReceiver = null
            }
        })
    }

    private fun isDndActive(): Boolean {
        val nm = activity.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return nm.currentInterruptionFilter != NotificationManager.INTERRUPTION_FILTER_ALL
    }

    // ── Ringtone picker ──────────────────────────────────────────────────────

    /**
     * Uses the deprecated startActivityForResult API because FlutterActivity
     * does not extend ComponentActivity, so the Activity Result API contract
     * launcher is unavailable here. Isolated to this one method.
     */
    private fun launchRingtonePicker(
        type: String,
        currentUriStr: String?,
        title: String?,
        result: MethodChannel.Result
    ) {
        pendingRingtoneResult = result
        val ringtoneType = if (type == "notification") {
            RingtoneManager.TYPE_NOTIFICATION
        } else {
            RingtoneManager.TYPE_ALARM or RingtoneManager.TYPE_RINGTONE
        }
        val defaultTitle = if (type == "notification") "Select Notification Sound" else "Select Alarm Sound"
        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, ringtoneType)
            putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, title ?: defaultTitle)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
            if (!currentUriStr.isNullOrEmpty()) {
                putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, Uri.parse(currentUriStr))
            }
        }
        try {
            activity.startActivityForResult(intent, REQUEST_RINGTONE_PICKER)
        } catch (e: Exception) {
            pendingRingtoneResult?.error("ERROR", "Failed to launch ringtone picker: ${e.message}", null)
            pendingRingtoneResult = null
        }
    }

    /** Returns true when the result belonged to this registrar's request. */
    @Suppress("DEPRECATION")
    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_RINGTONE_PICKER) return false
        if (resultCode == Activity.RESULT_OK) {
            val uri: Uri? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI, Uri::class.java)
            } else {
                data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
            }

            val title = if (uri != null) {
                try {
                    val ringtone = RingtoneManager.getRingtone(activity.applicationContext, uri)
                    ringtone.getTitle(activity.applicationContext) ?: "Custom Alarm"
                } catch (e: Exception) {
                    "Custom Alarm"
                }
            } else {
                "Default Alarm"
            }

            pendingRingtoneResult?.success(
                mapOf(
                    "uri" to (uri?.toString() ?: ""),
                    "title" to title,
                )
            )
        } else {
            pendingRingtoneResult?.success(null)
        }
        pendingRingtoneResult = null
        return true
    }

    fun dispose() {
        speechChannel?.dispose()
        speechChannel = null
        dndReceiver?.let { activity.unregisterReceiver(it) }
        dndReceiver = null
    }

    companion object {
        private const val REQUEST_RINGTONE_PICKER = 9922
    }
}
