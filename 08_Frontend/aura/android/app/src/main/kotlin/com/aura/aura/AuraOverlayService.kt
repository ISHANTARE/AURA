package com.aura.aura

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.MethodChannel

class AuraOverlayService : Service() {

    private var windowManager: WindowManager? = null
    private var floatingView: View? = null
    private var params: WindowManager.LayoutParams? = null
    private lateinit var prefs: SharedPreferences

    companion object {
        const val CHANNEL_ID = "aura_overlay_service_channel"
        const val NOTIFICATION_ID = 1001
        const val PREFS_NAME = "aura_orb_prefs"
        const val KEY_ORB_X = "orb_x"
        const val KEY_ORB_Y = "orb_y"

        var methodChannel: MethodChannel? = null
        var isServiceRunning = false
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, buildNotification())
        isServiceRunning = true

        if (Settings.canDrawOverlays(this)) {
            showFloatingOrb()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "AURA Floating Orb Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps AURA floating orb active on screen"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("AURA Active")
            .setContentText("Tap floating orb to capture voice")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
    }

    private fun showFloatingOrb() {
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        val density = resources.displayMetrics.density
        val orbSizePx = (56 * density).toInt()

        val savedX = prefs.getInt(KEY_ORB_X, -1)
        val savedY = prefs.getInt(KEY_ORB_Y, -1)

        val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        params = WindowManager.LayoutParams(
            orbSizePx,
            orbSizePx,
            layoutType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = if (savedX != -1) savedX else (resources.displayMetrics.widthPixels / 2 - orbSizePx / 2)
            y = if (savedY != -1) savedY else (resources.displayMetrics.heightPixels - (200 * density).toInt())
        }

        // Create Neubrutalist Lime Orb view programmatically
        val container = FrameLayout(this)
        val drawable = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(Color.parseColor("#C8FF00")) // Lime accent
            setStroke((3 * density).toInt(), Color.BLACK)
        }
        container.background = drawable

        val textView = TextView(this).apply {
            text = "A"
            setTextColor(Color.BLACK)
            textSize = 22f
            setTypeface(null, Typeface.BOLD)
            gravity = Gravity.CENTER
        }
        container.addView(
            textView,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        // Drag and tap touch listener
        container.setOnTouchListener(object : View.OnTouchListener {
            private var initialX = 0
            private var initialY = 0
            private var initialTouchX = 0f
            private var initialTouchY = 0f
            private var isClick = false

            override fun onTouch(v: View?, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = params!!.x
                        initialY = params!!.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        isClick = true
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val dx = (event.rawX - initialTouchX).toInt()
                        val dy = (event.rawY - initialTouchY).toInt()
                        if (Math.abs(dx) > 10 || Math.abs(dy) > 10) {
                            isClick = false
                        }
                        params!!.x = initialX + dx
                        params!!.y = initialY + dy
                        windowManager?.updateViewLayout(floatingView, params)
                        return true
                    }
                    MotionEvent.ACTION_UP -> {
                        if (isClick) {
                            onOrbTapped()
                        } else {
                            // Save orb position on drag end
                            prefs.edit()
                                .putInt(KEY_ORB_X, params!!.x)
                                .putInt(KEY_ORB_Y, params!!.y)
                                .apply()
                        }
                        return true
                    }
                }
                return false
            }
        })

        floatingView = container
        windowManager?.addView(floatingView, params)
    }

    private fun onOrbTapped() {
        // Launch translucent floating capture window over current app
        val captureIntent = Intent(this, AuraCaptureActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        startActivity(captureIntent)

        // Send method channel callback to Flutter if connected
        methodChannel?.invokeMethod("onOrbTapped", null)
    }

    override fun onDestroy() {
        super.onDestroy()
        isServiceRunning = false
        if (floatingView != null) {
            windowManager?.removeView(floatingView)
            floatingView = null
        }
    }
}
