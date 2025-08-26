plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
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
        create("patosDeMinas") {
            dimension = "city"
            applicationId = "com.rotativodigitalpatos"
            resValue("string", "app_name", "Rotativo Patos")
        }
        create("janauba") {
            dimension = "city"
            applicationId = "com.rotativodigitaljanauba"
            resValue("string", "app_name", "Rotativo Janauba")
        }
        create("conselheiroLafaiete") {
            dimension = "city"
            applicationId = "com.rotativodigitallafaiete"
            resValue("string", "app_name", "Rotativo Lafaiete")
        }
        create("capaoBonito") {
            dimension = "city"
            applicationId = "com.rotativodigitalcapao"
            resValue("string", "app_name", "Rotativo Capão")
        }
        create("joaoMonlevade") {
            dimension = "city"
            applicationId = "com.rotativodigitalmonlevade"
            resValue("string", "app_name", "Rotativo Monlevade")
        }
        create("itarare") {
            dimension = "city"
            applicationId = "com.rotativodigitalitarare"
            resValue("string", "app_name", "Rotativo Itararé")
        }
        create("passos") {
            dimension = "city"
            applicationId = "com.rotativodigitalpassos"
            resValue("string", "app_name", "Rotativo Passos")
        }
        create("ribeiraoDasNeves") {
            dimension = "city"
            applicationId = "com.rotativodigitalneves"
            resValue("string", "app_name", "Rotativo Neves")
        }
        create("igarape") {
            dimension = "city"
            applicationId = "com.rotativodigitaligarape"
            resValue("string", "app_name", "Rotativo Igarape")
        }
        create("ouroPreto") {
            dimension = "city"
            applicationId = "com.rotativodigitalouropreto"
            resValue("string", "app_name", "Rotativo Ouro Preto")
        }
    }

     signingConfigs {
        create("release") {
            keyAlias = "release-key"
            keyPassword = "sua_senha_da_chave"
            storeFile = file("../keys/release-key.keystore")
            storePassword = "sua_senha_do_keystore"
        }
    }   

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            minifyEnabled = true
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
