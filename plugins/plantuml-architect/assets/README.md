# PlantUML Runtime Assets

This plugin renders diagrams through the local PlantUML CLI.

Required runtime:

- Java/JDK 17 or newer available as `java` in PATH.
- An official `plantuml.jar`.

JAR lookup order used by `scripts/render-plantuml.ps1`:

1. `-PlantUmlJar <path>` argument.
2. `PLANTUML_JAR` environment variable.
3. `assets/plantuml.jar` in this plugin directory.

Recommended local setup:

1. Install Java/JDK 17 or newer.
2. Run `scripts/install-plantuml-runtime.ps1` from the plugin root to download the official PlantUML JAR, or download it manually from https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar.
3. Save it as `assets/plantuml.jar`, or set `PLANTUML_JAR` to its absolute path.
4. Test the runtime:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/render-plantuml.ps1 -TestDot
```

Graphviz is not bundled by this plugin. Some diagrams may need it. If PlantUML reports a `dot` issue, install Graphviz or pass `-GraphvizDot <path-to-dot.exe>`.
