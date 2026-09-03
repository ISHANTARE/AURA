package com.aura.aura

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView

class OrbMenuActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val density = resources.displayMetrics.density

        val colorHex = intent.getStringExtra("colorHex") ?: getSavedAccentColor()
        val parsedAccentColor = try {
            Color.parseColor(colorHex)
        } catch (e: Exception) {
            Color.parseColor("#7B6FF0")
        }

        val isLightMode = (resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK) == android.content.res.Configuration.UI_MODE_NIGHT_NO
        val cardBgColor = if (isLightMode) Color.parseColor("#FFFFFF") else Color.parseColor("#1C1C24")
        val cardBorderColor = if (isLightMode) Color.parseColor("#CBD5E1") else Color.parseColor("#33FFFFFF")
        val textColor = if (isLightMode) Color.parseColor("#0F172A") else Color.WHITE

        val root = FrameLayout(this).apply {
            setBackgroundColor(Color.parseColor("#99000000"))
            setOnClickListener { finish() }
        }

        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            val pad = (20 * density).toInt()
            setPadding(pad, pad, pad, pad)
            background = GradientDrawable().apply {
                setColor(cardBgColor)
                cornerRadius = 16 * density
                setStroke((1 * density).toInt(), cardBorderColor)
            }
        }

        val title = TextView(this).apply {
            text = "AURA Quick Actions"
            textSize = 16f
            setTextColor(parsedAccentColor)
            setTypeface(null, android.graphics.Typeface.BOLD)
            val mb = (16 * density).toInt()
            setPadding(0, 0, 0, mb)
        }
        card.addView(title)

        fun createMenuItem(label: String, onClick: () -> Unit): View {
            return TextView(this).apply {
                text = label
                textSize = 15f
                setTextColor(textColor)
                val padY = (12 * density).toInt()
                val padX = (8 * density).toInt()
                setPadding(padX, padY, padX, padY)
                setOnClickListener {
                    onClick()
                    finish()
                }
            }
        }

        card.addView(createMenuItem("Voice Capture") {
            startActivity(Intent(this, AuraCaptureActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            })
        })

        card.addView(createMenuItem("Open Alarms") {
            startActivity(Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("route", "/alarms")
            })
        })

        card.addView(createMenuItem("Quick Notes") {
            startActivity(Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("route", "/notes")
            })
        })

        card.addView(createMenuItem("Dismiss Orb") {
            stopService(Intent(this, AuraOverlayService::class.java))
        })

        val cardParams = FrameLayout.LayoutParams(
            (260 * density).toInt(),
            ViewGroup.LayoutParams.WRAP_CONTENT
        ).apply {
            gravity = Gravity.CENTER
        }

        root.addView(card, cardParams)
        setContentView(root)
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
                else -> "#7B6FF0"
            }
        } catch (e: Exception) {
            "#7B6FF0"
        }
    }
}
