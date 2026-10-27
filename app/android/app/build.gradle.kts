import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firma di distribuzione (docs/release-engineering.md): android/key.properties,
// fuori da git, con storeFile, storePassword, keyAlias, keyPassword. Senza, una
// build release si ferma: niente APK o AAB di release firmati con la chiave di debug.
val releaseKey = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val hasReleaseKey = listOf("storeFile", "storePassword", "keyAlias", "keyPassword").all { releaseKey.getProperty(it) != null }

android {
    namespace = "com.markg981.mirabo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.markg981.mirabo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Android 8 (API 26) è il requisito del prodotto (README.md, docs/README.md);
        // flutter.minSdkVersion in Flutter 3.47.7 vale 24, quindi lo fissiamo noi.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = rootProject.file(releaseKey.getProperty("storeFile"))
                storePassword = releaseKey.getProperty("storePassword")
                keyAlias = releaseKey.getProperty("keyAlias")
                keyPassword = releaseKey.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) signingConfigs.getByName("release") else null
        }
    }

    // Librerie native non compresse e allineate a 16 KB nell'APK (Android 15+,
    // pagine da 16 KB): controllo in studio/check_native.py.
    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }
}

// La release si ferma subito, prima di compilare, se manca la chiave di distribuzione.
tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    val signed = hasReleaseKey
    doFirst {
        if (!signed) {
            throw GradleException(
                "Build release senza android/key.properties: una release non si firma con la chiave di debug " +
                    "(docs/release-engineering.md). Per provare l'app usa una build debug o profile."
            )
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
