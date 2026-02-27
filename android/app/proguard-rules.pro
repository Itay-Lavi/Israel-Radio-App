# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Play Core (referenced by Flutter but not used — suppress missing class warnings)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# just_audio / ExoPlayer (media3)
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.** { *; }
-keep class com.ryanheise.just_audio.** { *; }
-dontwarn com.google.android.exoplayer2.**
-dontwarn androidx.media3.**

# audio_service
-keep class com.ryanheise.audioservice.** { *; }
-dontwarn com.ryanheise.audioservice.**

# audio_session
-keep class com.ryanheise.audiosession.** { *; }
-dontwarn com.ryanheise.audiosession.**

# OkHttp / networking (used internally by ExoPlayer)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Prevent stripping of native methods
-keepclassmembers class * {
    native <methods>;
}

# Preserve Generic Signatures for Gson/TypeToken
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

# Keep models and plugin classes that might be serialized
-keep class com.itay.** { *; }
-keep class **.flutter_alarm_background_trigger.** { *; }
