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
import android.content.pm.ServiceInfo
import android.graphics.BlurMaskFilter
import android.graphics.Shader
import android.graphics.Typeface
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.util.DisplayMetrics
import android.util.Log
import android.view.Gravity
import android.view.HapticFeedbackConstants
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
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
        private const val TAG = "AuraOverlayService"
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
        try {
            if (Build.VERSION.SDK_INT >= 34) {
                startForeground(
                    NOTIF_ID,
                    buildNotification(),
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                )
            } else {
                startForeground(NOTIF_ID, buildNotification())
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start foreground service: ${e.message}", e)
            isRunning = false
            stopSelf()
            return
        }
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
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            Log.w(TAG, "Cannot setup orb: overlay permission not granted")
            stopSelf()
            return
        }

        val density = resources.displayMetrics.density
        val sizePx = (72 * density).toInt()

        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val savedX = prefs.getInt("orb_x", (4 * density).toInt())
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

        // Gesture mechanics: TouchSlop Drag + Tap + Long Press (600ms)
        val scaledTouchSlop = ViewConfiguration.get(this).scaledTouchSlop
        var longPressJob: Job? = null
        var isDragging = false
        var isLongPressed = false
        var startRawX = 0f
        var startRawY = 0f
        var startX = 0
        var startY = 0

        orbView.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    isDragging = false
                    isLongPressed = false
                    startRawX = event.rawX
                    startRawY = event.rawY
                    startX = params.x
                    startY = params.y

                    longPressJob = CoroutineScope(Dispatchers.Main).launch {
                        delay(600)
                        if (!isDragging) {
                            isLongPressed = true
                            orbView.performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)
                            launchOrbMenu(params.x, params.y)
                        }
                    }
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = (event.rawX - startRawX).toInt()
                    val dy = (event.rawY - startRawY).toInt()
                    if (abs(dx) > scaledTouchSlop || abs(dy) > scaledTouchSlop) {
                        isDragging = true
                        longPressJob?.cancel()
                        val metrics = resources.displayMetrics
                        val screenWidth = metrics.widthPixels
                        val screenHeight = metrics.heightPixels
                        // Allow dragging all the way to the screen edges
                        params.x = (startX + dx).coerceIn(-(10 * density).toInt(), screenWidth - sizePx + (10 * density).toInt())
                        params.y = (startY + dy).coerceIn(0, screenHeight - sizePx)
                        try {
                            windowManager.updateViewLayout(orbView, params)
                        } catch (e: Exception) {
                            Log.e(TAG, "updateViewLayout failed: ${e.message}")
                        }
                    }
                }
                MotionEvent.ACTION_UP -> {
                    longPressJob?.cancel()
                    if (isLongPressed) {
                        // Handled by long press menu
                    } else if (!isDragging) {
                        launchCaptureActivity()
                    } else {
                        // Snap to nearest screen edge (left or right)
                        snapToEdge()
                    }
                }
            }
            true
        }

        try {
            windowManager.addView(orbView, params)
            orbView.startPulse()
            // Mark enabled in prefs
            prefs.edit().putBoolean("orb_enabled", true).apply()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to add orb view: ${e.message}", e)
            stopSelf()
        }
    }

    private fun snapToEdge() {
        val metrics = DisplayMetrics()
        windowManager.defaultDisplay.getMetrics(metrics)
        val screenWidth = metrics.widthPixels
        val density = resources.displayMetrics.density
        // Align flush to edge (envelope has padding so core touches edge)
        val margin = -(6 * density).toInt()

        params.x = if (params.x + (orbView.width / 2) < screenWidth / 2) {
            margin
        } else {
            screenWidth - orbView.width - margin
        }

        try {
            windowManager.updateViewLayout(orbView, params)
        } catch (e: Exception) {
            Log.e(TAG, "snapToEdge updateViewLayout failed: ${e.message}")
        }

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

        private val shadowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            color = Color.argb(120, 0, 0, 0)
        }

        private val corePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            color = parsedColor
        }

        private val ringPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = 2f * resources.displayMetrics.density
            color = Color.argb(90, 255, 255, 255)
        }

        private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textAlign = Paint.Align.CENTER
            textSize = 20f * resources.displayMetrics.density
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        }

        init {
            setLayerType(LAYER_TYPE_SOFTWARE, null)
            shadowPaint.maskFilter = BlurMaskFilter(6f * resources.displayMetrics.density, BlurMaskFilter.Blur.NORMAL)
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
            animator = ValueAnimator.ofFloat(0.95f, 1.0f).apply {
                duration = 2200
                repeatMode = ValueAnimator.REVERSE
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
            val density = resources.displayMetrics.density
            val cx = width / 2f
            val cy = height / 2f
            val coreRadius = (25f * density) * pulseScale
            val glowRadius = 34f * density

            // 1. Atmospheric Glow (Multi-stop smooth radial bloom matching accent color)
            val r = Color.red(parsedColor)
            val g = Color.green(parsedColor)
            val b = Color.blue(parsedColor)
            val glowAlpha = (110 * pulseScale).toInt().coerceIn(0, 255)
            val glowMidAlpha = (45 * pulseScale).toInt().coerceIn(0, 255)

            glowPaint.shader = RadialGradient(
                cx, cy, glowRadius,
                intArrayOf(
                    Color.argb(glowAlpha, r, g, b),
                    Color.argb(glowMidAlpha, r, g, b),
                    Color.TRANSPARENT
                ),
                floatArrayOf(0.55f, 0.82f, 1.0f),
                Shader.TileMode.CLAMP
            )
            canvas.drawCircle(cx, cy, glowRadius, glowPaint)

            // 2. Soft Drop Shadow
            canvas.drawCircle(cx + (2f * density), cy + (3f * density), coreRadius, shadowPaint)

            // 3. Core Orb Body
            canvas.drawCircle(cx, cy, coreRadius, corePaint)

            // 4. Subtle Clean White Border Ring (matching Flutter FloatingOrb 2dp border)
            canvas.drawCircle(cx, cy, coreRadius - (1f * density), ringPaint)

            // 5. Centered AURA 'A' Glyph
            val textY = cy - ((textPaint.descent() + textPaint.ascent()) / 2f)
            canvas.drawText("A", cx, textY, textPaint)
        }
    }
}
