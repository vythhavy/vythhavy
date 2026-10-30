import com.android.build.api.variant.LibraryAndroidComponentsExtension

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
    val sameDriveRoot = project.projectDir.toPath().root == rootProject.projectDir.toPath().root
    val hasKotlinSources =
        project.projectDir
            .resolve("src")
            .walkTopDown()
            .any { it.isFile && it.extension == "kt" }
    if (sameDriveRoot || !hasKotlinSources) {
        val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }

    plugins.withId("com.android.library") {
        extensions.configure<LibraryAndroidComponentsExtension> {
            finalizeDsl { libraryExtension ->
                if (libraryExtension.externalNativeBuild.cmake.path != null) {
                    if (libraryExtension.externalNativeBuild.cmake.buildStagingDirectory == null) {
                        libraryExtension.externalNativeBuild.cmake.buildStagingDirectory =
                            newBuildDir.dir(".cxx/${project.name}").asFile
                    }
                    if (libraryExtension.defaultConfig.ndk.abiFilters.isEmpty() &&
                        !project.hasProperty("disable-abi-filtering")
                    ) {
                        libraryExtension.defaultConfig.ndk.abiFilters.addAll(
                            listOf("armeabi-v7a", "arm64-v8a", "x86_64")
                        )
                    }
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
