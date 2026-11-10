# Skyfold canonical verification.
# Run from anywhere:
#   .\tools\ci\verify.ps1
#
# Requires Godot 4.7.2 on PATH, or set GODOT to the console executable.

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$godot = $env:GODOT
if ([string]::IsNullOrWhiteSpace($godot)) {
    $godot = "godot"
}

Write-Host "== Godot version =="
& $godot --version
if ($LASTEXITCODE -ne 0) {
    throw "Godot is not available. Set GODOT or put godot on PATH."
}

Write-Host "== Import =="
& $godot --headless --path $repoRoot --import
if ($LASTEXITCODE -ne 0) {
    throw "Godot import failed with exit code $LASTEXITCODE"
}

Write-Host "== Parse check =="
$scripts = Get-ChildItem -Path "$repoRoot\scripts", "$repoRoot\tests", "$repoRoot\tools" -Filter "*.gd" -Recurse -File
foreach ($script in $scripts) {
    $relative = $script.FullName.Substring($repoRoot.Length + 1).Replace("\", "/")
    Write-Host "  $relative"
    & $godot --headless --path $repoRoot --check-only --script "res://$relative"
    if ($LASTEXITCODE -ne 0) {
        throw "Parse check failed: $relative (exit $LASTEXITCODE)"
    }
}

Write-Host "== Headless tests =="
& $godot --headless --path $repoRoot --script res://tests/run_tests.gd
if ($LASTEXITCODE -ne 0) {
    throw "Headless tests failed with exit code $LASTEXITCODE"
}

Write-Host "== Project verification =="
& $godot --headless --path $repoRoot --script res://tools/verify_project.gd
if ($LASTEXITCODE -ne 0) {
    throw "Project verification failed with exit code $LASTEXITCODE"
}

Write-Host ""
Write-Host "PASS - Skyfold verification complete"

