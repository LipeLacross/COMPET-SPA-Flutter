android {
    namespace = "com.example.competspa"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.competspa"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Habilita multidex
        multiDexEnabled = true
    }

    compileOptions {
        // Atualiza para Java 11
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11" // Altere para Java 11
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // ajuste para release real
        }
    }
}

dependencies {
    // Desugaring para APIs Java 8+
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Multidex runtime
    implementation("androidx.multidex:multidex:2.0.1")
}

// plugin Flutter ao final
flutter {
    source = "../.."
}
