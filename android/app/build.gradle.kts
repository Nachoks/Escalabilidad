import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// --- 1. CARGA DE PROPIEDADES (FUERA DEL BLOQUE ANDROID) ---
// Al ponerlo aquí arriba, evitamos el error "Unresolved reference"
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.somnolence_app"
    
    compileSdk = 35
    
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.somnolence_app"
        minSdk = flutter.minSdkVersion
        
        targetSdk = 35 
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: "androiddebugkey"
            keyPassword = keystoreProperties["keyPassword"] as String? ?: "android"
            
            val storeFileName = keystoreProperties["storeFile"] as String?
            storeFile = if (storeFileName != null) file(storeFileName) else null
            
            storePassword = keystoreProperties["storePassword"] as String? ?: "android"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}



flutter {
    source = "../.."
}

apply(plugin = "com.google.gms.google-services")

// 👇 AGREGA ESTO AL FINAL DEL ARCHIVO PARA ARREGLAR EL ERROR DE VERSIONES 👇
configurations.all {
    resolutionStrategy {
        eachDependency {
            // Forzamos versiones estables que no piden SDK 36
            if (requested.group == "androidx.activity") {
                useVersion("1.9.3")
            }
            if (requested.group == "androidx.core") {
                useVersion("1.15.0")
            }
        }
    }
}