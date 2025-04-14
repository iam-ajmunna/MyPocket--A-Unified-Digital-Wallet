buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.0.0") // Adjust version if needed
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22") // Explicitly set Kotlin version here or define in gradle.properties
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
<<<<<<< HEAD
    repositories {
        google()
        mavenCentral()
    }
=======
        repositories {
                google()
                mavenCentral()
        }
>>>>>>> efbe7be226cb82988e230e435421310d584df00c
}
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
        val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
        project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
        delete(rootProject.layout.buildDirectory)
}

