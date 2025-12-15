import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase plugins
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("keystore.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.rotativo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Habilita core library desugaring para suportar flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.rotativo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "city"
    productFlavors {
        create("demo") {
            dimension = "city"
            applicationId = "com.rotativodigital"
            resValue("string", "app_name", "Rotativo")
        }
        create("ouroPreto") {
            dimension = "city"
            applicationId = "com.rotativodigitalouropretord"
            resValue("string", "app_name", "Rotativo Ouro Preto")
        }
        create("vicosa") {
            dimension = "city"
            applicationId = "com.rotativodigitalvicosa"
            resValue("string", "app_name", "Rotativo Viçosa")
        }
    }

     signingConfigs {
        create("release") {
            keyAlias = "my-key-alias"
            keyPassword = keystoreProperties["keyPassword"] as String? ?: "sua_senha_da_chave"
            storeFile = file("../keys/release-key.keystore")
            storePassword = keystoreProperties["storePassword"] as String? ?: "sua_senha_do_keystore"
        }
    }   

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")

            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
           // signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring para suportar flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
