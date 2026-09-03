package com.aura.aura

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class AuraBootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        if (action == Intent.ACTION_BOOT_COMPLETED || action == "android.intent.action.QUICKBOOT_POWERON") {
            val prefs = context.getSharedPreferences("aura_orb_prefs", Context.MODE_PRIVATE)
            val isOrbEnabled = prefs.getBoolean("orb_enabled", false)

            if (isOrbEnabled) {
                val serviceIntent = Intent(context, AuraOverlayService::class.java).apply {
                    this.action = "START_ORB"
                }
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        context.startForegroundService(serviceIntent)
                    } else {
                        context.startService(serviceIntent)
                    }
                } catch (e: Exception) {
                    android.util.Log.e("AuraBootReceiver", "Failed to auto-start AuraOverlayService on boot: ${e.message}", e)
                }
            }
        }
    }
}
