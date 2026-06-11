<#
.SYNOPSIS
    Interim VP testing overlay: copy the VP-generated vendor overrides
    over the installed DLC payload.

.DESCRIPTION
    Regenerates build/vendor/vp via tools/vendoring/vendor.py, then copies
    the staged UI tree over Assets/DLC/DLC_CivVAccess/UI in the game
    install. Run AFTER deploy.ps1 (this overlays the payload deploy ships).

    While the overlay is applied, VANILLA SESSIONS ARE BROKEN: the
    VP-flavored overrides reference Community Patch controls and text keys
    that vanilla doesn't ship. Re-run deploy.ps1 to restore the vanilla
    payload.

    Interim tool for the phase 1 stock-VP smoke test; graduates into
    deploy-vp.ps1 with phase 3 of the VP port.

.PARAMETER GameDir
    Override the Civ V install path.
#>
[CmdletBinding()]
param(
    [string]$GameDir = "C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V"
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$dlcUi = Join-Path $GameDir 'Assets\DLC\DLC_CivVAccess\UI'
if (-not (Test-Path $dlcUi)) {
    throw "Installed DLC UI dir not found at $dlcUi -- run deploy.ps1 first."
}

Write-Host '--- regenerating VP staging'
& py (Join-Path $repoRoot 'tools\vendoring\vendor.py') generate --engine vp
if ($LASTEXITCODE -ne 0) { throw "vendor.py generate failed (exit $LASTEXITCODE)" }

$staged = Join-Path $repoRoot 'build\vendor\vp\UI'
if (-not (Test-Path $staged)) { throw "Staging dir missing: $staged" }

Write-Host '--- overlaying VP overrides onto the installed DLC'
Copy-Item -Recurse -Force (Join-Path $staged '*') $dlcUi

$count = (Get-ChildItem -Recurse -File $staged).Count
Write-Host "Overlay applied: $count VP-generated files copied over"
Write-Host "  $dlcUi"
Write-Host 'VANILLA SESSIONS ARE NOW BROKEN until you re-run deploy.ps1.'
