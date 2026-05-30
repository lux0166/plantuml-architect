---
name: plantuml-architect
description: Use when the user asks for PlantUML, UML, use case diagrams, sequence diagrams, class diagrams, activity diagrams, component diagrams, deployment diagrams, architecture diagrams, diagram-as-code, or Vietnamese requests such as "ve UML", "vẽ UML", "vẽ use case", "sơ đồ use case", "sơ đồ tuần tự", "sơ đồ lớp", "sơ đồ hoạt động", "sơ đồ thành phần", "sơ đồ triển khai", "bản vẽ kiến trúc", "thiết kế kiến trúc", or "thiet ke kien truc" before building a web app. Enforces a PlantUML diagram-as-code architecture workflow before implementation.
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

## Core Workflow

1. Create or update `docs/architecture/requirements.md` with a short, concrete requirements summary.
2. Create PlantUML sources in `docs/architecture/`:
   - `use-case.puml`
   - `component.puml`
   - `sequence-<flow>.puml` for important flows such as login, checkout, order, payment, or admin approval.
   - `class-domain.puml` when domain models or database entities matter.
   - `activity-<flow>.puml` when business process steps matter.
   - `deployment.puml` when infrastructure or runtime boundaries matter.
3. Render diagrams to `docs/architecture/out/` when local runtime is available.
4. Use the generated diagrams as the design contract for the implementation.

## Diagram Rules

- Prefer PlantUML source files over Mermaid for this skill.
- Keep every diagram focused on one decision or flow.
- Use stable names for actors, components, classes, and services so diagrams can be diffed.
- For existing repos, inspect routes, controllers, models, services, and API clients before generating diagrams.
- For new web apps, create the minimum useful architecture set first: requirements, use case, component, and one sequence diagram for the primary flow.
- Treat `.puml` files as the source of truth.
- Do not start implementation work until the architecture files exist, unless the user explicitly asks to skip diagrams.

## Rendering

Use the plugin render script from the plugin root:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/render-plantuml.ps1 -InputPath docs/architecture -OutputDir docs/architecture/out
```

PlantUML rendering requires Java and a PlantUML JAR. It looks for the JAR in this order:

1. `-PlantUmlJar <path>` argument.
2. `PLANTUML_JAR` environment variable.
3. `assets/plantuml.jar` inside this plugin.

If Graphviz is needed for a diagram and PlantUML cannot find it, test with:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/render-plantuml.ps1 -TestDot
```

## Output Expectations

- Put source diagrams in `docs/architecture/*.puml`.
- Put rendered diagrams in `docs/architecture/out/*.svg`.
- If rendering fails because Java or PlantUML is missing, explain the missing dependency and leave the `.puml` files in place.
- When presenting results, mention both the `.puml` source files and rendered `.svg` files.
