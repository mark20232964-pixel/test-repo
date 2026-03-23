plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.roadresq"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    // 🔥 THIS IS THE REAL FIX (FOR KTS)
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
    applicationId = "com.example.roadresq"
    minSdk = flutter.minSdkVersion
    targetSdk = 36

    // 🔥 FIX
    versionCode = 1
    versionName = "1.0"

    multiDexEnabled = true
}

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")

    // 🔥 UPDATED Google Maps (stable)
    implementation("com.google.android.gms:play-services-maps:18.2.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
