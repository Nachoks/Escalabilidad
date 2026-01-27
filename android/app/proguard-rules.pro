# Mantener OneSignal
-keep class com.onesignal.** { *; }
-dontwarn com.onesignal.**

# Mantener Firebase y Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Mantener notificaciones
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable