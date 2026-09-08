# ─────────────────────────────────────────────────────────────────────────────
# AURA Android Proguard & R8 Keep Rules
# ─────────────────────────────────────────────────────────────────────────────

# ML Kit Text Recognition — suppress unused Asian scripts while keeping Latin
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-keep class com.google.mlkit.vision.text.** { *; }

# SQLite3 / Drift Native Bindings
-keep class org.sqlite.** { *; }

# Kotlin Coroutines
-keep class kotlinx.coroutines.** { *; }
