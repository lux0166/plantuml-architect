[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [string]$InputPath = "docs/architecture",

  [string]$OutputDir = "docs/architecture/out",

  [ValidateSet("svg", "png")]
  [string]$Format = "svg",

  [switch]$Approved,

  [string]$PlantUmlJar = $env:PLANTUML_JAR,

  [string]$GraphvizDot = $env:GRAPHVIZ_DOT
)

$ErrorActionPreference = "Stop"

function Fail($Message, $Code) {
  Write-Error $Message -ErrorAction Continue
  exit $Code
}

if (-not $Approved) {
  Fail "Render blocked. Review/edit the diagram first, then run again with -Approved when the user has approved the draft." 10
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$renderScript = Join-Path $scriptRoot "render-plantuml.ps1"

if (-not (Test-Path -LiteralPath $renderScript -PathType Leaf)) {
  Fail "render-plantuml.ps1 not found next to approve-render.ps1" 2
}

$resolvedInput = Resolve-Path -LiteralPath $InputPath -ErrorAction SilentlyContinue
if (-not $resolvedInput) {
  Fail "Input path not found: $InputPath" 3
}

$inputItem = Get-Item -LiteralPath $resolvedInput.Path
if (-not $inputItem.PSIsContainer -and $inputItem.Extension -eq ".drawio") {
  Fail "Draw.io files are editable drafts. Open the .drawio file in diagrams.net/draw.io and export SVG/PNG after approval, or install draw.io Desktop and use its export command. PlantUML rendering only supports .puml/.plantuml input." 4
}

if ($inputItem.PSIsContainer) {
  $drawioFiles = Get-ChildItem -LiteralPath $inputItem.FullName -Recurse -File -Filter *.drawio
  $plantUmlFiles = Get-ChildItem -LiteralPath $inputItem.FullName -Recurse -File |
    Where-Object { $_.Extension -in @(".puml", ".plantuml") }
  if ($drawioFiles.Count -gt 0 -and $plantUmlFiles.Count -eq 0) {
    Fail "Only .drawio files were found. Export those from diagrams.net/draw.io after approval. No .puml/.plantuml files were found for PlantUML rendering." 5
  }
}

$renderParams = @{
  InputPath = $InputPath
  OutputDir = $OutputDir
  Format = $Format
}
if (-not [string]::IsNullOrWhiteSpace($PlantUmlJar)) {
  $renderParams.PlantUmlJar = $PlantUmlJar
}
if (-not [string]::IsNullOrWhiteSpace($GraphvizDot)) {
  $renderParams.GraphvizDot = $GraphvizDot
}

& $renderScript @renderParams
exit $LASTEXITCODE
