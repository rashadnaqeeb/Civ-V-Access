# Lints and format-checks the mod's Lua source.
# Runs luacheck (semantic) and stylua (formatting) back to back. Both are
# read-only by default; pass -Fix to let stylua rewrite files in place.
# Expects tools/bin/luacheck.exe and tools/bin/stylua.exe (both gitignored).
# Must be invoked from the repo root.
#
# Usage:
#   ./lint.ps1                lint + format-check (read-only)
#   ./lint.ps1 -Fix           lint + format rewrite
#   ./lint.ps1 <path> ...     restrict to specific files / dirs
#
# Exit code is nonzero if either tool reports a problem (or, with -Fix,
# if either tool fails to run); a single combined exit keeps CI wiring
# straightforward.

[CmdletBinding()]
param(
    [switch]$Fix,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Paths
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $root

$luacheck = Join-Path $root "tools\bin\luacheck.exe"
$stylua   = Join-Path $root "tools\bin\stylua.exe"

if (-not (Test-Path $luacheck)) {
    Write-Error @"
Missing linter: $luacheck

Install with:
    gh release download v1.2.0 --repo lunarmodules/luacheck --pattern luacheck.exe --dir tools\bin\
"@
    exit 2
}

if (-not (Test-Path $stylua)) {
    Write-Error @"
Missing formatter: $stylua

Install with:
    gh release download v2.4.1 --repo JohnnyMorganz/StyLua --pattern stylua-windows-x86_64.zip --dir tools\bin\
    Expand-Archive tools\bin\stylua-windows-x86_64.zip -DestinationPath tools\bin\
    Remove-Item tools\bin\stylua-windows-x86_64.zip
"@
    exit 2
}

$targets = if ($Paths -and $Paths.Count -gt 0) { $Paths } else { @("src", "tests") }

Write-Host "--- luacheck" -ForegroundColor Cyan
# -q: print only files that have warnings, plus the final summary. Without
# it luacheck emits a "Checking ... OK" line per file (~300 lines), which
# buries the stylua output below it.
& $luacheck -q @targets
$luacheckExit = $LASTEXITCODE

if ($Fix) {
    Write-Host "--- stylua (rewrite)" -ForegroundColor Cyan
    & $stylua @targets
} else {
    Write-Host "--- stylua --check" -ForegroundColor Cyan
    & $stylua --check @targets
}
$styluaExit = $LASTEXITCODE

# Report in a way the user can act on: tell them which stage failed.
if ($luacheckExit -ne 0 -and $styluaExit -ne 0) {
    Write-Host "lint + format-check both failed" -ForegroundColor Red
} elseif ($luacheckExit -ne 0) {
    Write-Host "lint failed" -ForegroundColor Red
} elseif ($styluaExit -ne 0) {
    if ($Fix) {
        Write-Host "format rewrite failed" -ForegroundColor Red
    } else {
        Write-Host "format-check failed (run ./lint.ps1 -Fix to rewrite)" -ForegroundColor Yellow
    }
}

# Combined exit: nonzero if either failed. Luacheck's exit beats stylua's
# when both fail so the numeric code still pins one specific tool.
if ($luacheckExit -ne 0) { exit $luacheckExit }
exit $styluaExit
