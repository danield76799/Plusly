allprojects {
    repositories {
        google()
        mavenCentral()
    }
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
// AGP 9 dwingt in checkAarMetadata af dat elke library compileSdk >= de
// compileSdk die zijn dependencies vragen (bv. androidx.fragment 1.7 → 34).
// Oudere Flutter-plugins (flutter_ringtone_player e.a.) zijn tegen API 31/33
// gebouwd en falen daarop hard. Daarom: forceer compileSdk 37 voor alle
// library-modules. Dat is semantisch veilig — ze compileren dan alleen
// tegen een nieuwere SDK.
// ':app' is door evaluationDependsOn hierboven al geëvalueerd voordat de
// subprojects-block hier draait; gebruik daarom plugins.withId niet, maar
// afterEvaluate met een state-check (en sla :app sowieso over).
fun forceCompileSdk37(p: Project) {
    if (!p.plugins.hasPlugin("com.android.library")) return
    val android = p.extensions.findByName("android") ?: return
    val setter = android.javaClass.methods.firstOrNull {
        it.name == "setCompileSdk" && it.parameterCount == 1
    } ?: return
    try {
        setter.invoke(android, 37)
    } catch (e: Exception) {
        p.logger.warn("Kon compileSdk niet forceren voor ${p.name}: ${e.message}")
    }
}

subprojects {
    if (name == "app") return@subprojects
    if (state.executed) {
        forceCompileSdk37(this)
    } else {
        afterEvaluate { forceCompileSdk37(this) }
    }
}
