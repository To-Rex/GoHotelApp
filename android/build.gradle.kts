allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// camera_android_camerax (CameraX 1.5.x) javac xatosi uchun tuzatish:
// camera-core annotatsiyalari CallbackToFutureAdapter sinfini compile
// classpath'da talab qiladi, plagin esa uni tranzitiv olmaydi.
subprojects {
    plugins.withId("com.android.library") {
        if (project.name == "camera_android_camerax") {
            project.dependencies.add(
                "implementation",
                "androidx.concurrent:concurrent-futures:1.2.0",
            )
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
