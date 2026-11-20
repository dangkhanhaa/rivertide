import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing (P2-60). The upload key lives OUTSIDE the repo; its path and
// passwords come from app/android/key.properties (git-ignored), written by
// tools/release/make_upload_key.ps1. Without that file, release builds fall
// back to the debug key so local `flutter build apk --release` still works —
// such a build can NOT be uploaded to Google Play.
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
val hasUploadKey = keyPropertiesFile.exists()
if (hasUploadKey) {
    keyPropertiesFile.inputStream().use { keyProperties.load(it) }
    for (name in listOf("storeFile", "storePassword", "keyAlias", "keyPassword")) {
        if (keyProperties.getProperty(name).isNullOrBlank()) {
            throw GradleException("key.properties: '$name' is missing (see docs/release/google-play.md)")
        }
    }
    if (!file(keyProperties.getProperty("storeFile")).exists()) {
        throw GradleException(
            "key.properties: keystore not found at ${keyProperties.getProperty("storeFile")}",
        )
    }
} else {
    logger.warn(
        "WARNING: app/android/key.properties not found - release build is signed with the " +
            "DEBUG key. Fine for local testing, NOT accepted by Google Play. " +
            "Run tools/release/make_upload_key.ps1 once (docs/release/google-play.md).",
    )
}

android {
    namespace = "vn.rivertide.rivertide"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Needed by flutter_local_notifications (java.time on older Android).
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Store identity: never change after the first upload to Google Play.
        applicationId = "vn.rivertide.rivertide"
        minSdk = flutter.minSdkVersion
        // Flutter 3.47 defaults: compileSdk 36, targetSdk 36 (Android 16),
        // minSdk 24. Google Play's target API rule rises every August; 36 is
        // the newest stable level (docs/release/google-play.md, check before upload).
        targetSdk = flutter.targetSdkVersion
        // From pubspec.yaml `version: name+code`; bump the +code for every upload.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasUploadKey) {
            create("release") {
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (hasUploadKey) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
