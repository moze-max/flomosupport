plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flomosupport"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion
    ndkVersion = "27.1.12297006"

    compileOptions {
        // Correct syntax for Kotlin DSL
        isCoreLibraryDesugaringEnabled = true // Use 'is' prefix and '=' for assignment
        sourceCompatibility = JavaVersion.VERSION_1_8 // Use '=' for assignment
        targetCompatibility = JavaVersion.VERSION_1_8 // Use '=' for assignment
    }

    kotlinOptions {
        jvmTarget = "1.8" // Use double quotes for String literals
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flomosupport"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// === ADD THIS ENTIRE BLOCK HERE, WITH KOTLIN DSL SYNTAX ===
dependencies {
    // Correct syntax for Kotlin DSL
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // Use parentheses for method calls
}
// ==========================================================