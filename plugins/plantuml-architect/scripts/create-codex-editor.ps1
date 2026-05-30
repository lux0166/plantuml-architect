[CmdletBinding()]
param(
  [string]$OutputPath = "docs/architecture/codex-diagram-editor.html",
  [switch]$Force
)

$ErrorActionPreference = "Stop"

function Fail($Message, $Code) {
  Write-Error $Message -ErrorAction Continue
  exit $Code
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$pluginRoot = Split-Path -Parent $scriptRoot
$templatePath = Join-Path $pluginRoot "tools\codex-diagram-editor.html"

if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
  Fail "Codex local editor template not found: $templatePath" 2
}

if (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
  $OutputPath = Join-Path (Get-Location) $OutputPath
}

if ((Test-Path -LiteralPath $OutputPath) -and -not $Force) {
  Fail "Output already exists: $OutputPath. Pass -Force to overwrite it." 3
}

$outputDir = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
Copy-Item -LiteralPath $templatePath -Destination $OutputPath -Force:$Force

Write-Host "Created local Codex diagram editor: $OutputPath"
Write-Host "Open this local HTML file in Codex/in-app browser or any local browser. It does not use remote services."
