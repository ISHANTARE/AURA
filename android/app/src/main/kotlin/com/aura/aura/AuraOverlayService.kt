package com.aura.aura

import android.animation.ValueAnimator
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PixelFormat
import android.graphics.RadialGradient
import android.graphics.Shader
import android.graphics.Typeface
import android.os.Build
import android.os.IBinder
import android.util.DisplayMetrics
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.abs

class AuraOverlayService : Service() {

    companion object {
        var isRunning = false
        private const val CHANNEL_ID = "aura_overlay_channel"
        private const val NOTIF_ID = 1001
        private const val PREFS_NAME = "aura_orb_prefs"
    }

    private lateinit var windowManager: WindowManager
    private lateinit var orbView: OrbCanvasView
    private lateinit var params: WindowManager.LayoutParams
    private var currentColorHex: String = "#7B6FF0"

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        currentColorHex = getSavedAccentColor()
        createNotificationChannel()
        startForeground(NOTIF_ID, buildNotification())
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        setupOrb()
    }

    private fun getSavedAccentColor(): String {
        return try {
            val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val accentName = flutterPrefs.getString("flutter.THEME_ACCENT", "Indigo") ?: "Indigo"
            when (accentName.lowercase()) {
                "cyan" -> "#22D3EE"
                "purple" -> "#C084FC"
                "orange" -> "#FF9966"
                "rose" -> "#F472B6"
                "lime" -> "#C8FF00"
                else -> "#7B6FF0" // Neon Indigo (Default)
            }
        } catch (e: Exception) {
            "#7B6FF0"
        }
    }

    private fun setupOrb() {
        val density = resources.displayMetrics.density
        val sizePx = (56 * density).toInt()

        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val savedX = prefs.getInt("orb_x", (16 * density).toInt())
        val savedY = prefs.getInt("orb_y", (200 * density).toInt())

        orbView = OrbCanvasView(this)
        orbView.updateColor(currentColorHex)

        val windowType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        params = WindowManager.LayoutParams(
            sizePx, sizePx,
            windowType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = savedX
            y = savedY
        }

        // Gesture mechanics: Drag + Tap + Long Press (600ms)
        var longPressJob: Job? = null
        var isDragging = false
        var startRawX = 0f
        var startRawY = 0f
        var startX = 0
        var startY = 0

        orbView.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    isDragging = false
                    startRawX = event.rawX
                    startRawY = event.rawY
                    startX = params.x
                    startY = params.y

                    longPressJob = CoroutineScope(Dispatchers.Main).launch {
                        delay(600)
                        if (!isDragging) {
                            launchOrbMenu(params.x, params.y)
                        }
                    }
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = (event.rawX - startRawX).toInt()
                    val dy = (event.rawY - startRawY).toInt()
                    if (abs(dx) > 10 || abs(dy) > 10) {
                        isDragging = true
                        longPressJob?.cancel()
                        params.x = startX + dx
                        params.y = startY + dy
                        windowManager.updateViewLayout(orbView, params)
                    }
                }
                MotionEvent.ACTION_UP -> {
                    longPressJob?.cancel()
                    if (!isDragging) {
                        launchCaptureActivity()
                    } else {
                        // Snap to nearest screen edge (left or right)
                        snapToEdge()
                    }
                }
            }
            true
        }

        windowManager.addView(orbView, params)
        orbView.startPulse()

        // Mark enabled in prefs
        prefs.edit().putBoolean("orb_enabled", true).apply()
    }

    private fun snapToEdge() {
        val metrics = DisplayMetrics()
        windowManager.defaultDisplay.getMetrics(metrics)
        val screenWidth = metrics.widthPixels
        val density = resources.displayMetrics.density
        val margin = (16 * density).toInt()

        params.x = if (params.x + (orbView.width / 2) < screenWidth / 2) {
            margin
        } else {
            screenWidth - orbView.width - margin
        }

        windowManager.updateViewLayout(orbView, params)

        // Save position
        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit()
            .putInt("orb_x", params.x)
            .putInt("orb_y", params.y)
            .apply()
    }

    private fun launchCaptureActivity() {
        val intent = Intent(this, AuraCaptureActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        startActivity(intent)
    }

    private fun launchOrbMenu(x: Int, y: Int) {
        val intent = Intent(this, OrbMenuActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            putExtra("orb_x", x)
            putExtra("orb_y", y)
            putExtra("colorHex", currentColorHex)
        }
        startActivity(intent)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "STOP_ORB" -> {
                stopSelf()
                isRunning = false
            }
            "UPDATE_COLOR" -> {
                val hex = intent.getStringExtra("colorHex") ?: getSavedAccentColor()
                currentColorHex = hex
                if (::orbView.isInitialized) {
                    orbView.updateColor(hex)
                }
            }
            else -> {
                val hex = intent?.getStringExtra("colorHex") ?: getSavedAccentColor()
                currentColorHex = hex
                if (::orbView.isInitialized) {
                    orbView.updateColor(hex)
                }
            }
        }
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        if (::orbView.isInitialized) {
            orbView.stopPulse()
            try {
                windowManager.removeView(orbView)
            } catch (e: Exception) {
                // Ignore view not attached
            }
        }
        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit()
            .putBoolean("orb_enabled", false)
            .apply()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "AURA Floating Assistant",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps the AURA floating assistant active"
            }
            (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("AURA Assistant Active")
            .setContentText("Tap orb to trigger voice capture")
            .setSmallIcon(R.drawable.ic_aura_orb)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
    }

    // ── Custom Canvas View with Pulse Animation & Theme Color Matching ──────────

    inner class OrbCanvasView(context: Context) : View(context) {
        private var pulseScale = 1.0f
        private var animator: ValueAnimator? = null
        private var parsedColor: Int = Color.parseColor("#7B6FF0")
        private var parsedColorHex: String = "#7B6FF0"

        private val glowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
        }

        private val corePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            color = parsedColor
        }

        private val ringPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = 1.5f * resources.displayMetrics.density
            color = Color.parseColor("#60FFFFFF")
        }

        private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textAlign = Paint.Align.CENTER
            textSize = 20f * resources.displayMetrics.density
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        }

        fun updateColor(hex: String) {
            try {
                parsedColorHex = if (hex.startsWith("#")) hex else "#$hex"
                parsedColor = Color.parseColor(parsedColorHex)
                corePaint.color = parsedColor
                invalidate()
            } catch (e: Exception) {
                // Ignore parse errors
            }
        }

        fun startPulse() {
            animator = ValueAnimator.ofFloat(1.0f, 1.08f, 1.0f).apply {
                duration = 2000
                repeatCount = ValueAnimator.INFINITE
                addUpdateListener {
                    pulseScale = it.animatedValue as Float
                    invalidate()
                }
                start()
            }
        }

        fun stopPulse() {
            animator?.cancel()
            animator = null
        }

        override fun onDraw(canvas: Canvas) {
            super.onDraw(canvas)
            val cx = width / 2f
            val cy = height / 2f
            val baseRadius = (width / 2f) * 0.72f
            val currentRadius = baseRadius * pulseScale

            // Draw radial glow matching theme color
            val glowColorHex = "#66" + parsedColorHex.removePrefix("#")
            try {
                glowPaint.shader = RadialGradient(
                    cx, cy, currentRadius * 1.35f,
                    intArrayOf(Color.parseColor(glowColorHex), Color.TRANSPARENT),
                    floatArrayOf(0.4f, 1.0f),
                    Shader.TileMode.CLAMP
                )
                canvas.drawCircle(cx, cy, currentRadius * 1.35f, glowPaint)
            } catch (e: Exception) {
                // Fallback if hex formatting had issues
            }

            // Draw Core Orb
            canvas.drawCircle(cx, cy, currentRadius, corePaint)

            // Draw Subtle Inner Ring
            canvas.drawCircle(cx, cy, currentRadius * 0.88f, ringPaint)

            // Draw AURA 'A' Label in the center
            val textY = cy - ((textPaint.descent() + textPaint.ascent()) / 2f)
            canvas.drawText("A", cx, textY, textPaint)
        }
    }
}
