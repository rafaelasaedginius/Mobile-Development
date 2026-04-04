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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    plugins.withId("com.android.library") {
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
            val getNamespace = androidExt.javaClass.methods.firstOrNull {
                it.name == "getNamespace" && it.parameterCount == 0
            }
            val setNamespace = androidExt.javaClass.methods.firstOrNull {
                it.name == "setNamespace" && it.parameterCount == 1 &&
                        it.parameterTypes[0] == String::class.java
            }

            if (getNamespace != null && setNamespace != null) {
                val currentNamespace = getNamespace.invoke(androidExt) as? String
                if (currentNamespace.isNullOrBlank()) {
                    val fallbackNamespace = project.group.toString()
                        .takeIf { it.isNotBlank() && it != "unspecified" }
                        ?: "com.example.${project.name.replace('-', '_')}"
                    setNamespace.invoke(androidExt, fallbackNamespace)
                }
            }
        }
    }
}
