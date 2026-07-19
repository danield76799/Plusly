import java.util.Properties
import java.io.FileInputStream
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Fallback: parse versionCode/versionName straight from pubspec.yaml so a
// stale local.properties (common on reusable GHA runners) can never leak an
// old versionCode into the APK. Flutter's plugin normally writes these, but
// on some runners the file persists across jobs.
fun parsePubspecVersion(): Pair<Int, String> {
    val pubspec = rootProject.file("../pubspec.yaml")
    if (!pubspec.exists()) return Pair(flutter.versionCode, flutter.versionName)
    val versionLine = pubspec.readLines().firstOrNull { it.startsWith("version:") }
        ?: return Pair(flutter.versionCode, flutter.versionName)
    val version = versionLine.substringAfter("version:").trim()
    val parts = version.split("+")
    val versionName = parts[0]
    val versionCode = parts.getOrNull(1)?.toIntOrNull() ?: flutter.versionCode
    return Pair(versionCode, versionName)
}

val (pubspecVersionCode, pubspecVersionName) = parsePubspecVersion()

if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

configurations.all {
    // Use the latest version published: https://central.sonatype.com/artifact/com.google.crypto.tink/tink-android
    val tink = "com.google.crypto.tink:tink-android:1.17.0"
    // You can also use the library declaration catalog
    // val tink = libs.google.tink
    resolutionStrategy {
        force(tink)
        dependencySubstitution {
            substitute(module("com.google.crypto.tink:tink")).using(module(tink))
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Glance widget dependencies
    implementation("androidx.glance:glance-appwidget:1.1.1")
    implementation("androidx.glance:glance-material3:1.1.1")
}

android {
    namespace = "com.danield.plusly.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // NDK r27 — 16KB page size aligned

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        signingConfigs {
            create("release") {
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    // Support for 16KB page size on Android 15+ / Android 17
    // See: https://developer.android.com/guide/practices/page-sizes
    defaultConfig {
        applicationId = "com.danield.plusly.app"
        minSdk = 24  // Required for modern features
        targetSdk = flutter.targetSdkVersion
        versionCode = pubspecVersionCode
        versionName = pubspecVersionName
    }

    buildTypes {
        release {
            // Only use release signing if key.properties was found
            if (signingConfigs.findByName("release") != null) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            // Speed up R8: use compat mode (less aggressive, faster)
            // Configured via gradle.properties: android.enableR8.fullMode=false
        }
    }

    // 16KB page size support — extract native libs uncompressed
    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }

    // Play Store requires app bundles instead of APKs
    bundle {
        language {
            enableSplit = false
        }
        density {
            enableSplit = false
        }
        abi {
            enableSplit = false
        }
    }
}

flutter {
    source = "../.."
}


// Patch ELF alignment to 16KB for Android 15+/17 compatibility
// Run scripts/patch_elf_alignment.py after build to fix third-party .so files
// that were compiled with 4KB page size alignment
