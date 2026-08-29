package com.aura.aura

import android.content.Intent
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

class AuraTileService : TileService() {

    override fun onClick() {
        val intent = Intent(this, AuraCaptureActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivityAndCollapse(intent)
    }

    override fun onStartListening() {
        qsTile?.apply {
            state = Tile.STATE_ACTIVE
            label = "AURA Capture"
            updateTile()
        }
    }
}
