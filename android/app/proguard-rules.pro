# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# ===============================================
# FLUTTER LOCAL NOTIFICATIONS - CRITICAL RULES
# ===============================================

# Keep all flutter_local_notifications classes
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep notification-related Android classes
-keep class android.app.Notification { *; }
-keep class android.app.NotificationManager { *; }
-keep class android.app.NotificationChannel { *; }
-keep class android.app.PendingIntent { *; }
-keep class android.content.BroadcastReceiver { *; }
-keep class android.app.AlarmManager { *; }

# Keep notification receivers and services
-keep class * extends android.content.BroadcastReceiver
-keep class * extends android.app.Service
-keep class * extends android.app.IntentService

# Keep notification action classes
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class androidx.core.app.NotificationManagerCompat { *; }

# ===============================================
# TIMEZONE DATA - REQUIRED FOR SCHEDULED NOTIFICATIONS
# ===============================================

# Keep timezone classes
-keep class org.threeten.bp.** { *; }
-keep class com.jakewharton.threetenabp.** { *; }

# Keep timezone data
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ===============================================
# PERMISSION HANDLER
# ===============================================

# Keep permission handler classes
-keep class com.baseflow.permissionhandler.** { *; }

# ===============================================
# FLUTTER PLUGIN REGISTRANT
# ===============================================

# Keep Flutter plugin registrant
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# ===============================================
# GSON (if used for JSON serialization)
# ===============================================

# Keep Gson classes
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# ===============================================
# GENERAL ANDROID SYSTEM CLASSES
# ===============================================

# Keep system services
-keep class android.content.Context { *; }
-keep class android.content.Intent { *; }
-keep class android.os.Bundle { *; }
-keep class android.app.Activity { *; }

# Keep reflection-based classes
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# ===============================================
# SPECIFIC FLUTTER LOCAL NOTIFICATIONS FIXES
# ===============================================

# Prevent obfuscation of notification callback methods
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep native method names
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# ===============================================
# GOOGLE PLAY CORE (FLUTTER DEFERRED COMPONENTS)
# ===============================================

# Keep Google Play Core classes to prevent R8 errors
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep Flutter deferred components classes
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# ===============================================
# FLUTTER ENGINE CLASSES
# ===============================================

# Keep Flutter engine classes that might be referenced
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }

# ===============================================
# DEBUGGING (OPTIONAL - REMOVE IN PRODUCTION)
# ===============================================

# Uncomment to keep line numbers for better crash reports
# -keepattributes SourceFile,LineNumberTable
# -renamesourcefileattribute SourceFile
