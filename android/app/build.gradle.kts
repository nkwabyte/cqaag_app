import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties").takeIf { it.exists() }
    ?: rootProject.file("../secrets/key.properties").takeIf { it.exists() }

if (keystorePropertiesFile != null && keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "org.cqaaggh.cqaag_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "org.cqaaggh.cqaag_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyAliasProp = keystoreProperties.getProperty("keyAlias")
            val keyPasswordProp = keystoreProperties.getProperty("keyPassword")
            val storePasswordProp = keystoreProperties.getProperty("storePassword")
            val storeFileProp = keystoreProperties.getProperty("storeFile")

            if (!keyAliasProp.isNullOrEmpty() &&
                !keyPasswordProp.isNullOrEmpty() &&
                !storePasswordProp.isNullOrEmpty() &&
                !storeFileProp.isNullOrEmpty()) {
                keyAlias = keyAliasProp
                keyPassword = keyPasswordProp
                storePassword = storePasswordProp

                val candidateFiles = listOf(
                    file(storeFileProp),
                    rootProject.file(storeFileProp),
                    rootProject.file("../$storeFileProp"),
                    rootProject.file("../secrets/$storeFileProp"),
                    rootProject.file("../secrets/cqaag-keystore.jks")
                )
                val resolvedFile = candidateFiles.firstOrNull { it.exists() } ?: file(storeFileProp)
                storeFile = resolvedFile
            }
        }
    }

    buildTypes {
        release {
            val releaseConfig = signingConfigs.getByName("release")
            val isReleaseSigningReady = releaseConfig.storeFile != null && releaseConfig.storeFile!!.exists()

            signingConfig = if (isReleaseSigningReady) {
                releaseConfig
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
