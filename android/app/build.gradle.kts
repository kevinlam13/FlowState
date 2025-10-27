plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flowstate"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ✅ Required for flutter_local_notifications on older Android APIs
        isCoreLibraryDesugaringEnabled = true
        // ✅ Use Java 17 toolchain
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // ✅ Match Java 17
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.flowstate"
        // These come from Flutter's versions; minSdk is typically 21+ by default.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // For now sign with debug so `flutter run --release` works
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}


dependencies {
    // Required for core library desugaring (Java 8+/17 APIs on older Android)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    // (Optional) Kotlin stdlib — usually provided via the plugin, safe to include:
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
}
