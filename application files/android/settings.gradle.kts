pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
<<<<<<< HEAD
    id("com.android.application") version "8.9.1" apply false
=======
    id("com.android.application") version "8.7.0" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version "4.3.15" apply false
    id("com.google.firebase.firebase-perf") version "1.4.1" apply false
    // END: FlutterFire Configuration
>>>>>>> efbe7be226cb82988e230e435421310d584df00c
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "android"
include(":app")
// Correct way to set a custom property in settings.gradle.kts
extensions.extra["flutter"] = emptyMap<String, String>()
// find flutter root path
val flutterSdkRoot = System.getenv("FLUTTER_ROOT")
if (flutterSdkRoot == null || flutterSdkRoot.isEmpty()) {
    println("Flutter SDK root not found, please set the environment variable FLUTTER_ROOT")
} else {
    println("Flutter SDK root found: $flutterSdkRoot")
    // camera_android root path
    val cameraAndroidRoot = file("$flutterSdkRoot/packages/camera/camera_android/android")
    // include camera_android module
    include(":camera_android")
    //set camera_android path
    project(":camera_android").projectDir = cameraAndroidRoot
}