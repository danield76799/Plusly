# ProGuard rules for Flutter
# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class com.danield.extrachat.** { *; }

# Keep Matrix SDK classes
-keep class org.matrix.** { *; }
-keep class net.famedly.** { *; }

# Keep Google Play Core classes (voor deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Flutter plugins
-keep class com.dexterous.** { *; }
-keep class com.llfbandit.** { *; }

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}
