# ── Flutter / Dart ─────────────────────────────────────────────────────────────
# Keep Flutter engine & plugin registrant
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ── Google ML Kit Text Recognition ────────────────────────────────────────────
# The core latin recognizer is bundled; the optional language model classes
# (Chinese, Devanagari, Japanese, Korean) are not. Suppress R8 warnings for
# the unreferenced optional models that the plugin references via reflection.
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions

# Keep the Latin recognizer (the one AURA actually uses for share-to-AURA OCR)
-keep class com.google.mlkit.vision.text.latin.** { *; }
-keep class com.google.mlkit.vision.text.TextRecognizer { *; }
-keep class com.google_mlkit_text_recognition.** { *; }

# ── Permission Handler ─────────────────────────────────────────────────────────
-keep class com.baseflow.permissionhandler.** { *; }

# ── Kotlin Coroutines ──────────────────────────────────────────────────────────
-dontwarn kotlinx.coroutines.**
-keep class kotlinx.coroutines.** { *; }

# ── Drift / SQLite ─────────────────────────────────────────────────────────────
-keep class com.tekartik.sqflite.** { *; }

# ── Suppress obsolete Java 8 source/target warnings from Gradle plugins ────────
-dontwarn java.lang.invoke.**
