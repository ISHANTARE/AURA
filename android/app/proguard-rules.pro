# ─────────────────────────────────────────────────────────────────────────────
# AURA Android Proguard & R8 Keep Rules
# ─────────────────────────────────────────────────────────────────────────────

# Generic Signatures & Annotations (Essential for Gson & TypeToken in release builds)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Gson & FlutterLocalNotificationsPlugin
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepclassmembers class * extends com.google.crypto.tink.shaded.protobuf.GeneratedMessageLite {
  <fields>;
}
-dontwarn sun.misc.**
-keep class com.google.crypto.tink.** { *; }

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
