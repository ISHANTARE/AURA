package com.aura.aura

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PixelFormat
import android.graphics.RectF
import android.graphics.Typeface
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.PopupMenu
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
        const val KEY_ORB_DISMISSED = "orb_user_dismissed"

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
            .setContentText("Tap orb to capture · Long-press for options")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
    }

    private fun showFloatingOrb() {
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        val density = resources.displayMetrics.density
        val orbSizePx = (60 * density).toInt()

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
            x = if (savedX != -1) savedX else (resources.displayMetrics.widthPixels - orbSizePx - (16 * density).toInt())
            y = if (savedY != -1) savedY else (resources.displayMetrics.heightPixels - (220 * density).toInt())
        }

        // Premium dark orb drawn on a custom canvas view
        val orbView = object : View(this) {
            private val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.parseColor("#1A1A2E")
                style = Paint.Style.FILL
            }
            private val ringPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.parseColor("#7B6FF0")
                style = Paint.Style.STROKE
                strokeWidth = 3f * density
            }
            private val innerGlowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.parseColor("#3D35A0")
                style = Paint.Style.FILL
                alpha = 80
            }
            private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.WHITE
                textSize = 22f * density
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                textAlign = Paint.Align.CENTER
            }

            override fun onDraw(canvas: Canvas) {
                val cx = width / 2f
                val cy = height / 2f
                val r = width / 2f - 2 * density

                // Dark background circle
                canvas.drawCircle(cx, cy, r, bgPaint)

                // Inner glow
                canvas.drawCircle(cx, cy, r * 0.7f, innerGlowPaint)

                // Accent ring
                val inset = ringPaint.strokeWidth / 2f
                canvas.drawOval(RectF(inset, inset, width - inset, height - inset), ringPaint)

                // "A" text
                val textY = cy - (textPaint.descent() + textPaint.ascent()) / 2f
                canvas.drawText("A", cx, textY, textPaint)
            }
        }

        // Long-press detection via handler
        val longPressHandler = Handler(Looper.getMainLooper())
        var longPressRunnable: Runnable? = null
        val longPressMs = 600L

        orbView.setOnTouchListener(object : View.OnTouchListener {
            private var initialX = 0
            private var initialY = 0
            private var initialTouchX = 0f
            private var initialTouchY = 0f
            private var isDragging = false
            private var longPressTriggered = false

            override fun onTouch(v: View?, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = params!!.x
                        initialY = params!!.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        isDragging = false
                        longPressTriggered = false

                        // Schedule long-press
                        longPressRunnable = Runnable {
                            if (!isDragging) {
                                longPressTriggered = true
                                showLongPressMenu(v!!)
                            }
                        }
                        longPressHandler.postDelayed(longPressRunnable!!, longPressMs)
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val dx = (event.rawX - initialTouchX).toInt()
                        val dy = (event.rawY - initialTouchY).toInt()
                        if (Math.abs(dx) > 8 || Math.abs(dy) > 8) {
                            isDragging = true
                            longPressRunnable?.let { longPressHandler.removeCallbacks(it) }
                        }
                        if (isDragging) {
                            params!!.x = initialX + dx
                            params!!.y = initialY + dy
                            windowManager?.updateViewLayout(floatingView, params)
                        }
                        return true
                    }
                    MotionEvent.ACTION_UP -> {
                        longPressRunnable?.let { longPressHandler.removeCallbacks(it) }
                        if (!isDragging && !longPressTriggered) {
                            onOrbTapped()
                        } else if (isDragging) {
                            prefs.edit()
                                .putInt(KEY_ORB_X, params!!.x)
                                .putInt(KEY_ORB_Y, params!!.y)
                                .apply()
                        }
                        return true
                    }
                    MotionEvent.ACTION_CANCEL -> {
                        longPressRunnable?.let { longPressHandler.removeCallbacks(it) }
                        return true
                    }
                }
                return false
            }
        })

        floatingView = orbView
        windowManager?.addView(floatingView, params)
    }

    private fun showLongPressMenu(anchor: View) {
        // Use a PopupMenu anchored to the floating orb view position
        val intent = Intent(this, OrbMenuActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            putExtra("orb_x", params?.x ?: 0)
            putExtra("orb_y", params?.y ?: 0)
        }
        startActivity(intent)
    }

    private fun onOrbTapped() {
        val captureIntent = Intent(this, AuraCaptureActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        startActivity(captureIntent)
        methodChannel?.invokeMethod("onOrbTapped", null)
    }

    fun dismissAndStop() {
        prefs.edit().putBoolean(KEY_ORB_DISMISSED, true).apply()
        stopSelf()
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
