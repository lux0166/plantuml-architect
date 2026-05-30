---
name: plantuml-architect
description: Use when the user asks for PlantUML, UML, use case diagrams, sequence diagrams, class diagrams, activity diagrams, component diagrams, deployment diagrams, architecture diagrams, diagram-as-code, draw.io/diagrams.net handoff, manual diagram editing, drag-and-drop editing, review-before-render, approve-render, or Vietnamese requests such as "ve UML", "vẽ UML", "vẽ use case", "sơ đồ use case", "sơ đồ tuần tự", "sơ đồ lớp", "sơ đồ hoạt động", "sơ đồ thành phần", "sơ đồ triển khai", "bản vẽ kiến trúc", "thiết kế kiến trúc", "kéo thả", "chỉnh tay sơ đồ", "duyệt rồi render", "bấm duyệt", or "thiet ke kien truc" before building a web app. Enforces a draft-review-approve-render workflow before implementation and can create editable draw.io handoff files when visual manual editing is needed.
---

# PlantUML Architect

Use this skill whenever architecture diagrams should be created before coding, especially for web applications.

## Invocation Examples

Users can trigger this skill naturally after installing the plugin:

- "Vẽ UML cho web quản lý thư viện."
- "Tạo use case diagram trước khi code."
- "Thiết kế kiến trúc PlantUML cho app bán hàng."
- "Generate sequence diagram for checkout flow."
- "Update architecture diagrams after code changes."
- "Tạo bản draw.io để kéo thả chỉnh sơ đồ."

## Core Workflow

1. Create or update `docs/architecture/requirements.md` with a short, concrete requirements summary.
2. Create PlantUML sources in `docs/architecture/`:
   - `use-case.puml`
   - `component.puml`
   - `sequence-<flow>.puml` for important flows such as login, checkout, order, payment, or admin approval.
   - `class-domain.puml` when domain models or database entities matter.
   - `activity-<flow>.puml` when business process steps matter.
   - `deployment.puml` when infrastructure or runtime boundaries matter.
3. Stop at draft files first. Do not render SVG/PNG yet.
4. Ask the user to review/edit the draft. If they need drag-and-drop/manual visual editing, create an editable draw.io handoff at `docs/architecture/manual-edit.drawio`.
5. Render final SVG/PNG only after the user explicitly approves with wording such as `duyệt`, `approved`, `approve`, `render final`, or `bấm duyệt`.
6. Use the approved rendered diagrams as the design contract for the implementation.

## Diagram Rules

- Prefer PlantUML source files over Mermaid for this skill.
- Keep every diagram focused on one decision or flow.
- Use stable names for actors, components, classes, and services so diagrams can be diffed.
- For existing repos, inspect routes, controllers, models, services, and API clients before generating diagrams.
- For new web apps, create the minimum useful architecture set first: requirements, use case, component, and one sequence diagram for the primary flow.
- Treat `.puml` files as the source of truth. Treat `.drawio` files as editable presentation copies for manual layout tweaks.
- Do not claim PlantUML output can be perfectly converted into editable draw.io shapes. Create a draw.io handoff template instead when manual editing is requested.
- Do not render drafts immediately. Rendering is the final approval step.
- Do not start implementation work until the architecture files exist, unless the user explicitly asks to skip diagrams.

## Approval Rendering

Use the approval-gated render script from the plugin root after the user approves:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/approve-render.ps1 -Approved -InputPath docs/architecture -OutputDir docs/architecture/out
```

The approval script calls `render-plantuml.ps1` after approval. PlantUML rendering requires Java and a PlantUML JAR. It looks for the JAR in this order:

1. `-PlantUmlJar <path>` argument.
2. `PLANTUML_JAR` environment variable.
3. `assets/plantuml.jar` inside this plugin.

If Graphviz is needed for a diagram and PlantUML cannot find it, test with:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/render-plantuml.ps1 -TestDot
```

## Manual Editing Handoff

PlantUML is not a drag-and-drop editor. When the user asks to manually move boxes, adjust connectors, or edit the diagram visually, create a draw.io handoff file before final rendering:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/create-drawio-handoff.ps1 -OutputPath docs/architecture/manual-edit.drawio
```

Open `docs/architecture/manual-edit.drawio` in diagrams.net/draw.io for manual edits. Keep the `.puml` files as the architecture source of truth, and note that manual draw.io edits can drift from the PlantUML source.

For draw.io diagrams, export SVG/PNG from diagrams.net/draw.io after user approval. For PlantUML diagrams, use `approve-render.ps1 -Approved`.

## Output Expectations

- Put source diagrams in `docs/architecture/*.puml`.
- Put rendered diagrams in `docs/architecture/out/*.svg` or `*.png` only after explicit approval.
- Put manual editable diagrams in `docs/architecture/*.drawio` when drag-and-drop editing is requested.
- If rendering fails because Java or PlantUML is missing, explain the missing dependency and leave the `.puml` files in place.
- When presenting results, mention both the `.puml` source files and rendered `.svg` files.
