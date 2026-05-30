[CmdletBinding()]
param(
  [string]$TemplatePath,
  [string]$OutputPath = "docs/architecture/manual-edit.drawio",
  [switch]$Force
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$pluginRoot = Split-Path -Parent $scriptRoot

if ([string]::IsNullOrWhiteSpace($TemplatePath)) {
  $TemplatePath = Join-Path $pluginRoot "templates\manual-component.drawio"
}

if (-not (Test-Path -LiteralPath $TemplatePath -PathType Leaf)) {
  Write-Error "Draw.io template not found: $TemplatePath"
  exit 2
}

if (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
  $OutputPath = Join-Path (Get-Location) $OutputPath
}

if ((Test-Path -LiteralPath $OutputPath) -and -not $Force) {
  Write-Error "Output already exists: $OutputPath. Pass -Force to overwrite it."
  exit 3
}

$outputDir = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
Copy-Item -LiteralPath $TemplatePath -Destination $OutputPath -Force:$Force

Write-Host "Created editable draw.io handoff: $OutputPath"
Write-Host "Open it in diagrams.net/draw.io for drag-and-drop edits. Keep .puml files as the source of truth."
