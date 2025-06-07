// Add necessary imports at the top
import java.util.Properties 

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Read Flutter version properties (Keep this part, it's useful for other settings)
val flutterRoot = project.rootProject.projectDir.resolve("../..")
val localProperties = Properties() // Use the imported Properties class
val localPropertiesFile = flutterRoot.resolve("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode")?.toIntOrNull() ?: 1
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"
val flutterMinSdkVersion = localProperties.getProperty("flutter.minSdkVersion")?.toIntOrNull() ?: 21 // Provide a default minSdk
val flutterTargetSdkVersion = localProperties.getProperty("flutter.targetSdkVersion")?.toIntOrNull() ?: 34 // Provide a default targetSdk
// Keep reading compileSdk for potential future use, but we won't use flutterCompileSdkVersion directly below
val flutterCompileSdkVersion = localProperties.getProperty("flutter.compileSdkVersion")?.toIntOrNull() ?: 34 
val flutterNdkVersion = localProperties.getProperty("flutter.ndkVersion") ?: "27.0.12077973" // Provide a default ndkVersion


android {
    namespace = "com.example.masterevent" // تأكد من أن هذا هو namespace الصحيح لمشروعك
    
    // --- التغيير المطلوب ---
    compileSdk = 35 // <--- استخدام القيمة 35 بشكل مباشر هنا
    // -----------------------

    ndkVersion = flutterNdkVersion         // Use the value read from properties or the default

    compileOptions {
        isCoreLibraryDesugaringEnabled = true 
        sourceCompatibility = JavaVersion.VERSION_1_8 
        targetCompatibility = JavaVersion.VERSION_1_8 
    }

    kotlinOptions {
        jvmTarget = "1.8" 
    }

    defaultConfig {
        applicationId = "com.example.masterevent" // تأكد من أن هذا هو applicationId الصحيح
        minSdk = flutterMinSdkVersion          // Use the value read from properties or the default
        targetSdk = flutterTargetSdkVersion    // Use the value read from properties or the default
        versionCode = flutterVersionCode       // Use the value read from properties or the default
        versionName = flutterVersionName       // Use the value read from properties or the default
    }

    // Simplified buildTypes block (as we left it before)
    buildTypes {
        release {
            // Keep only the necessary signing config for now
            signingConfig = signingConfigs.getByName("debug") 
            // Removed isMinifyEnabled and shrinkResources for testing
        }
        debug {
            // Debug specific settings if needed
        }
    }
}

dependencies {
    // Kotlin standard library
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.22") // Match Kotlin version with top-level build.gradle.kts

    // Core library desugaring dependency
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // الإصدار المحدث
}

// Flutter plugin configuration block
flutter {
    source = "../.." // Path to the root of your Flutter project
} 