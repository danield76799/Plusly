# ProGuard rules voor Plusly
# Wees conservatief: alleen keep wat nodig is voor runtime

# === SQLCipher (database encryptie) ===
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# === Matrix SDK (veel reflectie, JSON parsing) ===
-keep class org.matrix.** { *; }
-keep class org.matrix.androidsdk.** { *; }
-keep class org.matrix.rustcomponents.** { *; }
-keep class org.matrix.olm.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# === WebRTC (native calls via JNI) ===
-keep class org.webrtc.** { *; }
-keep class com.cloudwebrtc.webrtc.** { *; }
-keep class io.flutter.plugins.** { *; }

# === Flutter plugins met native code ===
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.** { *; }

# === FFI / Rust bridge (flutter_rust_bridge) ===
-keep class io.lndclient.** { *; }
-keep class com.benjaminabel.** { *; }
-keep class fr.baml.** { *; }
-keepclassmembers class * {
    @com.benjaminabel.* <methods>;
}

# === JSON serialisatie (reflectie) ===
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# === Google Crypto Tink ===
-keep class com.google.crypto.tink.** { *; }
-keepclassmembers class com.google.crypto.tink.** { *; }

# === UnifiedPush ===
-keep class org.unifiedpush.** { *; }

# === Image loading / compressie ===
-keep class com.bumptech.glide.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }

# === Video / Audio ===
-keep class com.google.android.exoplayer2.** { *; }
-keep class com.arthenica.ffmpegkit.** { *; }

# === QR / Barcode ===
-keep class com.google.zxing.** { *; }
-keep class com.google.mlkit.** { *; }

# === Locatie / Maps ===
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.maps.** { *; }
-keep class com.google.android.gms.location.** { *; }

# === AndroidX / Material ===
-keep class androidx.** { *; }
-keep class com.google.android.material.** { *; }
-keep interface androidx.** { *; }

# === Kotlin reflectie ===
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.reflect.** { *; }
-dontwarn kotlin.reflect.**

# === Geolocator / Location ===
-keep class com.baseflow.geolocator.** { *; }
-keep class com.baseflow.permissionhandler.** { *; }

# === File picker / Share ===
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class dev.fluttercommunity.plus.share.** { *; }

# === URL launcher / WebView ===
-keep class io.flutter.plugins.urllauncher.** { *; }
-keep class io.flutter.plugins.webviewflutter.** { *; }

# === Local notifications ===
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# === Wakelock ===
-keep class dev.fluttercommunity.plus.wakelock.** { *; }

# === Secure storage ===
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# === Package info ===
-keep class dev.fluttercommunity.plus.packageinfo.** { *; }

# === Device info ===
-keep class dev.fluttercommunity.plus.deviceinfo.** { *; }

# === DON'T remove essential Flutter/Dart classes ===
-dontwarn io.flutter.embedding.**
-dontwarn android.**
-dontwarn androidx.**
-dontwarn com.google.android.gms.**
-dontwarn org.webrtc.**
-dontwarn net.sqlcipher.**

# === Verminder logging (optioneel) ===
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
}
-assumenosideeffects class io.flutter.plugins.** {
    public static void d(...);
    public static void v(...);
}

# === Suppress missing XMLStreamException (gebruikt door Apache Tika) ===
-dontwarn javax.xml.stream.XMLStreamException
