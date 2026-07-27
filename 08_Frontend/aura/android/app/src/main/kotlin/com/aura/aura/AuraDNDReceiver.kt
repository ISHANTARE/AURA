package com.aura.aura

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class AuraDNDReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == NotificationManager.ACTION_INTERRUPTION_FILTER_CHANGED) {
            val nm = context?.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            val filter = nm?.currentInterruptionFilter ?: NotificationManager.INTERRUPTION_FILTER_UNKNOWN
            val isDnd = filter != NotificationManager.INTERRUPTION_FILTER_ALL

            // Pass DND state change to listeners if needed
            val dndIntent = Intent("com.aura.aura.DND_STATUS_CHANGED")
            dndIntent.putExtra("isDnd", isDnd)
            dndIntent.putExtra("filter", filter)
            context?.sendBroadcast(dndIntent)
        }
    }
}
