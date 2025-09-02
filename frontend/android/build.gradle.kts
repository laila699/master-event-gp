// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    // Define Kotlin version - Use a version compatible with AGP 8.3.x
    val kotlinVersion = "1.9.22" // أو استخدم "1.9.23" أو "1.9.24" إذا كانت متاحة ومتوافقة

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Use double quotes and the classpath function
        // Update AGP version to be compatible with Gradle 8.9 (e.g., 8.3.2 or newer if needed)
        classpath("com.android.tools.build:gradle:8.3.2") 
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

// Apply plugins if necessary at the top level (usually not needed here for Flutter)
// plugins {
// }

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = File("../build") // Use File object for path

subprojects {
    project.buildDir = File("${rootProject.buildDir}/${project.name}")
    project.evaluationDependsOn(":app") // Ensure app module is evaluated first
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}