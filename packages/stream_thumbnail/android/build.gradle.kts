buildscript {
    val kotlinVersion = "2.2.20"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.11.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

plugins {
    id("com.android.library")
}

group = "io.getstream.stream_thumbnail"
version = "1.0-SNAPSHOT"

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

android {
    namespace = "io.getstream.stream_thumbnail"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }

    lint {
        disable.add("InvalidPackage")
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
    }
}
