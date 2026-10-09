# Runs the offline Lua test suite using the bundled 5.1.5 interpreter.
# Must be invoked from the repo root.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition

# A UNC root breaks the cmd.exe file walk in text_rule_test; rerun from a
# mapped drive letter (see tools/local-drive.ps1).
. (Join-Path $root "tools\local-drive.ps1")
if (Test-UncRoot $root) { exit (Invoke-FromMappedDrive $root "test.ps1") }

Set-Location $root

$lua = Join-Path $root "third_party\lua51\lua5.1.exe"
if (-not (Test-Path $lua)) {
    Write-Error "Missing interpreter: $lua"
    exit 2
}

& $lua "-e" "package.path='tests/?.lua;'..package.path" "tests/run.lua"
exit $LASTEXITCODE
