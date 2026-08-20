package com.aura.aura

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView
import android.graphics.Typeface
import android.widget.FrameLayout
import android.view.ViewGroup

/**
 * Transparent activity that shows the orb long-press popup menu.
 * Appears above everything (system overlay style) without disrupting the user's current app.
 */
class OrbMenuActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Make activity transparent and frameless
        window.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        window.addFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL)
        window.addFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)

        val orbX = intent.getIntExtra("orb_x", 0)
        val orbY = intent.getIntExtra("orb_y", 0)

        // Full-screen dimmed background
        val rootFrame = FrameLayout(this)
        rootFrame.setBackgroundColor(Color.parseColor("#80000000"))
        rootFrame.setOnClickListener { finish() }

        // Popup card
        val menuCard = buildMenuCard()

        // Position popup near orb location
        val screenWidth = resources.displayMetrics.widthPixels
        val screenHeight = resources.displayMetrics.heightPixels
        val cardWidthDp = 220
        val density = resources.displayMetrics.density
        val cardWidthPx = (cardWidthDp * density).toInt()

        val layoutParams = FrameLayout.LayoutParams(cardWidthPx, ViewGroup.LayoutParams.WRAP_CONTENT)

        // Place popup: if orb is on right half → anchor left, else anchor right
        val targetX = if (orbX > screenWidth / 2) {
            orbX - cardWidthPx - (16 * density).toInt()
        } else {
            orbX + (70 * density).toInt()
        }
        val targetY = maxOf((60 * density).toInt(), minOf(orbY, screenHeight - (300 * density).toInt()))

        layoutParams.leftMargin = maxOf(8, targetX)
        layoutParams.topMargin = targetY
        layoutParams.gravity = Gravity.TOP or Gravity.START

        rootFrame.addView(menuCard, layoutParams)
        setContentView(rootFrame)
    }

    private fun buildMenuCard(): LinearLayout {
        val density = resources.displayMetrics.density
        val cardPadding = (12 * density).toInt()

        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#1E1E30"))
            val borderDrawable = android.graphics.drawable.GradientDrawable().apply {
                shape = android.graphics.drawable.GradientDrawable.RECTANGLE
                cornerRadius = 16 * density
                setColor(Color.parseColor("#1E1E30"))
                setStroke((1.5f * density).toInt(), Color.parseColor("#7B6FF0"))
            }
            background = borderDrawable
            setPadding(cardPadding, cardPadding, cardPadding, cardPadding)
            elevation = 16 * density
        }

        // Header
        val header = TextView(this).apply {
            text = "AURA"
            setTextColor(Color.parseColor("#7B6FF0"))
            textSize = 11f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            letterSpacing = 0.15f
            setPadding(
                (8 * density).toInt(),
                (4 * density).toInt(),
                (8 * density).toInt(),
                (12 * density).toInt()
            )
        }
        card.addView(header)

        // Divider
        val divider = View(this).apply {
            setBackgroundColor(Color.parseColor("#333355"))
            layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 1)
        }
        card.addView(divider)

        val itemsHeight = (10 * density).toInt()

        // Menu items
        val items = listOf(
            Triple("🔔", "Add Reminder", "reminder"),
            Triple("📅", "Add Event", "event"),
            Triple("📝", "Add Note", "note"),
            Triple("⏰", "Add Alarm", "alarm"),
        )

        for ((emoji, label, type) in items) {
            card.addView(buildMenuItem(emoji, label) {
                launchCapture(type)
                finish()
            })
        }

        // Separator before close
        val divider2 = View(this).apply {
            setBackgroundColor(Color.parseColor("#333355"))
            layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 1).apply {
                topMargin = itemsHeight
                bottomMargin = itemsHeight
            }
        }
        card.addView(divider2)

        // Close item
        card.addView(buildMenuItem("✕", "Close Floating Icon", color = "#FF6B6B") {
            val prefs = getSharedPreferences(AuraOverlayService.PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().putBoolean(AuraOverlayService.KEY_ORB_DISMISSED, true).apply()
            stopService(Intent(this, AuraOverlayService::class.java))
            finish()
        })

        return card
    }

    private fun buildMenuItem(
        emoji: String,
        label: String,
        color: String = "#E8E8FF",
        onClick: () -> Unit
    ): LinearLayout {
        val density = resources.displayMetrics.density
        val hPad = (8 * density).toInt()
        val vPad = (12 * density).toInt()

        val row = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(hPad, vPad, hPad, vPad)
            isClickable = true
            isFocusable = true

            val bg = android.graphics.drawable.GradientDrawable().apply {
                cornerRadius = 8 * density
                setColor(Color.TRANSPARENT)
            }
            background = bg
            setOnClickListener { onClick() }
        }

        val emojiView = TextView(this).apply {
            text = emoji
            textSize = 16f
            val lp = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            lp.marginEnd = (12 * density).toInt()
            layoutParams = lp
        }
        row.addView(emojiView)

        val labelView = TextView(this).apply {
            text = label
            setTextColor(Color.parseColor(color))
            textSize = 14f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
        }
        row.addView(labelView)

        return row
    }

    private fun launchCapture(type: String) {
        if (type == "alarm") {
            // Launch main app at alarms screen
            val intent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("navigate_to", "alarms")
            }
            intent?.let { startActivity(it) }
        } else {
            // Launch floating capture overlay with type hint
            val intent = Intent(this, AuraCaptureActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                putExtra("capture_type", type)
            }
            startActivity(intent)
        }
    }
}
