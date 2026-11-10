# Skyfold Windows export.
# Usage:
#   .\tools\ci\export_windows.ps1
#
# Requires Godot 4.7.2 on PATH or GODOT set to the console executable, and the
# exact 4.7.2 Windows export templates installed under
# %APPDATA%\Godot\export_templates\4.7.2.stable.

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$godot = $env:GODOT
if ([string]::IsNullOrWhiteSpace($godot)) {
    $godot = "godot"
}

$outputDir = Join-Path $repoRoot "build\windows"
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
$output = Join-Path $outputDir "Skyfold.exe"

Write-Host "== Export Windows Desktop =="
& $godot --headless --path $repoRoot --export-release "Windows Desktop" $output
if ($LASTEXITCODE -ne 0) {
    throw "Windows export failed with exit code $LASTEXITCODE"
}

$exe = Get-Item $output
$pck = Get-Item (Join-Path $outputDir "Skyfold.pck")
Write-Host ("Skyfold.exe {0:N0} bytes" -f $exe.Length)
Write-Host ("Skyfold.pck {0:N0} bytes" -f $pck.Length)
Write-Host "Export complete."
