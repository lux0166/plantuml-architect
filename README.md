# PlantUML Architect for Codex

PlantUML Architect is a local Codex plugin that makes Codex design web application architecture before coding. It creates PlantUML source files for use case, component, sequence, class, activity, and deployment diagrams, lets users review or edit the draft, then renders final SVG/PNG only after approval.

## What It Does

- Enforces a diagram-as-code workflow for web projects.
- Creates architecture files under `docs/architecture/`.
- Provides reusable PlantUML templates for common UML diagrams.
- Renders `.puml` or `.plantuml` files to `.svg` or `.png` only after explicit approval.
- Creates optional `.drawio` handoff files for manual drag-and-drop editing in diagrams.net/draw.io.
- Keeps PlantUML runtime separate from the repository so the plugin stays lightweight.

## Install In Codex

Open PowerShell, then clone this repository:

```powershell
git clone https://github.com/lux0166/plantuml-architect.git
cd plantuml-architect
```

Add this repository as a Codex plugin marketplace from inside the cloned folder:

```powershell
codex plugin marketplace add .
```

The `.` means "the current folder". If you are not inside the cloned folder, pass the full path instead:

```powershell
codex plugin marketplace add C:\path\to\plantuml-architect
```

Then open Codex and install the `plantuml-architect` plugin from the `PlantUML Architect` marketplace.

## How Codex Recognizes It

After the plugin is installed and enabled, Codex can pick up the skill from normal prompts that mention PlantUML, UML, use case, sequence diagram, class diagram, architecture diagram, or Vietnamese phrases such as `vẽ UML`, `vẽ use case`, `sơ đồ lớp`, `sơ đồ tuần tự`, and `thiết kế kiến trúc`.

Example prompts:

```text
Vẽ UML cho web quản lý thư viện.
Tạo use case diagram trước khi code.
Thiết kế kiến trúc PlantUML cho app bán hàng.
Generate sequence diagram for checkout flow.
Tạo bản draw.io để kéo thả chỉnh sơ đồ.
Duyệt rồi render final SVG.
```

## Runtime Requirements

Java/JDK 17 or newer is required. The renderer calls `java` locally, so Java must be available in PATH, `JAVA_HOME\bin\java.exe`, or a standard Windows install path such as `C:\Program Files\Java\...\bin\java.exe`.

This repository does not include `plantuml.jar`.

Recommended setup after cloning:

```powershell
powershell -ExecutionPolicy Bypass -File .\plugins\plantuml-architect\scripts\install-plantuml-runtime.ps1
```

That helper only downloads the official PlantUML JAR into `.\plugins\plantuml-architect\assets\plantuml.jar`. It does not install Java and it does not run automatically during Codex plugin install.

Manual setup:

- Save the downloaded JAR at `.\plugins\plantuml-architect\assets\plantuml.jar`.
- Or keep the JAR anywhere and set `PLANTUML_JAR`:

```powershell
$env:PLANTUML_JAR = "C:\path\to\plantuml.jar"
```

Test the renderer:

```powershell
powershell -ExecutionPolicy Bypass -File .\plugins\plantuml-architect\scripts\render-plantuml.ps1 `
  -InputPath .\plugins\plantuml-architect\templates `
  -OutputDir .\test-output
```

If PlantUML reports a Graphviz issue, install Graphviz or pass `-GraphvizDot <path-to-dot.exe>`.

## Usage

Ask Codex for architecture first:

```text
Design the architecture for a shopping web app with PlantUML before coding.
```

The skill guides Codex to create:

- `docs/architecture/requirements.md`
- `docs/architecture/use-case.puml`
- `docs/architecture/component.puml`
- `docs/architecture/sequence-<flow>.puml`
- `docs/architecture/class-domain.puml`
- `docs/architecture/activity-<flow>.puml`
- `docs/architecture/deployment.puml`

Default workflow:

1. Codex creates draft `.puml` files.
2. You review or edit the draft.
3. If manual layout editing is needed, create/edit a `.drawio` handoff.
4. After you approve the draft, render final SVG/PNG.

Approve and render PlantUML diagrams:

```powershell
powershell -ExecutionPolicy Bypass -File .\plugins\plantuml-architect\scripts\approve-render.ps1 `
  -Approved `
  -InputPath .\docs\architecture `
  -OutputDir .\docs\architecture\out
```

Create an editable draw.io handoff when you need manual drag-and-drop edits:

```powershell
powershell -ExecutionPolicy Bypass -File .\plugins\plantuml-architect\scripts\create-drawio-handoff.ps1 `
  -OutputPath .\docs\architecture\manual-edit.drawio
```

Open the `.drawio` file in diagrams.net/draw.io or draw.io Desktop. Export SVG/PNG from draw.io after approval. PlantUML remains the source of truth; the draw.io file is a presentation/manual-edit copy and can drift from the `.puml` source.

## Repository Layout

```text
marketplace.json
plugins/
  plantuml-architect/
    .codex-plugin/plugin.json
    skills/plantuml-architect/SKILL.md
    scripts/render-plantuml.ps1
    scripts/approve-render.ps1
    scripts/install-plantuml-runtime.ps1
    scripts/create-drawio-handoff.ps1
    templates/*.puml
    templates/manual-component.drawio
    assets/README.md
```

## Notes

This repository does not vendor `plantuml.jar`. Users must install Java/JDK 17+ themselves. The optional helper script downloads the official PlantUML JAR from the PlantUML GitHub release page. PlantUML itself is developed at https://github.com/plantuml/plantuml.
