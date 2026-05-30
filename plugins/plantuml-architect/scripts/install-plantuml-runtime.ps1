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

$outputDir = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

Write-Host "Downloading PlantUML from $PlantUmlUrl"
Invoke-WebRequest -Uri $PlantUmlUrl -OutFile $OutputPath

$item = Get-Item -LiteralPath $OutputPath
Write-Host "Installed PlantUML JAR: $($item.FullName) ($($item.Length) bytes)"
