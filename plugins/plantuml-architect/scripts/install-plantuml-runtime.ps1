[CmdletBinding()]
param(
  [string]$PlantUmlUrl = "https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar",
  [string]$OutputPath
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$pluginRoot = Split-Path -Parent $scriptRoot

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
  $OutputPath = Join-Path $pluginRoot "assets\plantuml.jar"
}

$javaCommand = Get-Command java -ErrorAction SilentlyContinue
if (-not $javaCommand -and [string]::IsNullOrWhiteSpace($env:JAVA_HOME)) {
  Write-Warning "Java was not found in PATH or JAVA_HOME. Install Java/JDK 17+ before rendering diagrams."
}

$outputDir = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

Write-Host "Downloading PlantUML from $PlantUmlUrl"
Invoke-WebRequest -Uri $PlantUmlUrl -OutFile $OutputPath

$item = Get-Item -LiteralPath $OutputPath
Write-Host "Installed PlantUML JAR: $($item.FullName) ($($item.Length) bytes)"
Write-Host "Next: run scripts\render-plantuml.ps1 -TestDot from the plugin root to verify the runtime."
