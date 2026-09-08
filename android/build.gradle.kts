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

// Some plugins (e.g. file_picker 8.x) hardcode an older compileSdk in their
// own Gradle files, while the lifecycle library they depend on now requires
// compileSdk 36+ — which fails checkReleaseAarMetadata late in the build.
// Bump any module that still compiles against an older SDK.
// (Must be registered BEFORE evaluationDependsOn(":app") below, otherwise
// Gradle evaluates :app early and afterEvaluate() throws.)
subprojects {
    afterEvaluate {
        try {
            val android = extensions.findByName("android") ?: return@afterEvaluate
            val cls = android.javaClass
            val getter =
                cls.methods.firstOrNull {
                    it.name == "getCompileSdk" && it.parameterTypes.isEmpty()
                }
            val setter =
                cls.methods.firstOrNull {
                    it.name == "setCompileSdk" && it.parameterTypes.size == 1
                }
            val current = getter?.invoke(android) as? Int
            if (setter != null && (current == null || current < 36)) {
                setter.invoke(android, 36)
                println("[tutorsdesk] ${project.name}: compileSdk ${current} -> 36")
            }
        } catch (t: Throwable) {
            println("[tutorsdesk] compileSdk bump skipped for ${project.name}: $t")
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
