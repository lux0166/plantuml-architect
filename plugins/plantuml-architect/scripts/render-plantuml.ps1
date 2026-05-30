[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [string]$InputPath = "docs/architecture",

  [string]$OutputDir = "docs/architecture/out",

  [ValidateSet("svg", "png")]
  [string]$Format = "svg",

  [string]$PlantUmlJar = $env:PLANTUML_JAR,

  [string]$GraphvizDot = $env:GRAPHVIZ_DOT,

  [switch]$TestDot
)

$ErrorActionPreference = "Stop"

function Fail($Message, $Code) {
  Write-Error $Message
  exit $Code
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$pluginRoot = Split-Path -Parent $scriptRoot
$defaultJar = Join-Path $pluginRoot "assets\plantuml.jar"

$javaCommand = Get-Command java -ErrorAction SilentlyContinue
$javaExe = if ($javaCommand) { $javaCommand.Source } else { $null }
if (-not $javaExe -and -not [string]::IsNullOrWhiteSpace($env:JAVA_HOME)) {
  $candidate = Join-Path $env:JAVA_HOME "bin\java.exe"
  if (Test-Path -LiteralPath $candidate -PathType Leaf) {
    $javaExe = $candidate
  }
}
if (-not $javaExe) {
  $commonJava = Get-ChildItem -Path "C:\Program Files\Java" -Recurse -Filter java.exe -ErrorAction SilentlyContinue |
    Sort-Object FullName -Descending |
    Select-Object -First 1
  if ($commonJava) {
    $javaExe = $commonJava.FullName
  }
}
if (-not $javaExe) {
  Fail "Cài Java trước khi render PlantUML. Install Java/JDK 17+ and reopen the terminal so java is available in PATH." 2
}

if ([string]::IsNullOrWhiteSpace($PlantUmlJar)) {
  $PlantUmlJar = $defaultJar
}

if (-not (Test-Path -LiteralPath $PlantUmlJar -PathType Leaf)) {
  Fail "Missing plantuml.jar. Put the official PlantUML JAR at '$defaultJar', pass -PlantUmlJar <path>, or set PLANTUML_JAR." 3
}

$plantUmlArgs = @("-jar", $PlantUmlJar, "-charset", "UTF-8")
if (-not [string]::IsNullOrWhiteSpace($GraphvizDot)) {
  $plantUmlArgs += @("--dot-path", $GraphvizDot)
}

if ($TestDot) {
  & $javaExe @plantUmlArgs "-testdot"
  exit $LASTEXITCODE
}

$resolvedInput = Resolve-Path -LiteralPath $InputPath -ErrorAction SilentlyContinue
if (-not $resolvedInput) {
  Fail "Input path not found: $InputPath" 4
}

$inputItem = Get-Item -LiteralPath $resolvedInput.Path
if ($inputItem.PSIsContainer) {
  $diagramFiles = Get-ChildItem -LiteralPath $inputItem.FullName -Recurse -File |
    Where-Object { $_.Extension -in @(".puml", ".plantuml") }
} else {
  if ($inputItem.Extension -notin @(".puml", ".plantuml")) {
    Fail "Input file must use .puml or .plantuml extension: $($inputItem.FullName)" 5
  }
  $diagramFiles = @($inputItem)
}

if (-not $diagramFiles -or $diagramFiles.Count -eq 0) {
  Fail "No .puml or .plantuml files found under: $InputPath" 6
}

$resolvedOutputDir = $OutputDir
if (-not [System.IO.Path]::IsPathRooted($resolvedOutputDir)) {
  $resolvedOutputDir = Join-Path (Get-Location) $resolvedOutputDir
}
New-Item -ItemType Directory -Force -Path $resolvedOutputDir | Out-Null

$renderArgs = $plantUmlArgs + @("--format", $Format, "--output-dir", $resolvedOutputDir)
$renderArgs += $diagramFiles | ForEach-Object { $_.FullName }

& $javaExe @renderArgs
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
  Write-Error "PlantUML render failed with exit code $exitCode. If the error mentions Graphviz/dot, install Graphviz or pass -GraphvizDot <path>, then test with -TestDot."
  exit $exitCode
}

Write-Host "Rendered $($diagramFiles.Count) PlantUML file(s) to $resolvedOutputDir as .$Format"
