<#
.SYNOPSIS
    Prepare an installed Vox Populi for a modpack-bake merged-DB session, then
    tear that prep down. Mode-agnostic: it does NOT change the install state.

.DESCRIPTION
    The VP modpack bake (build-modpack.ps1) reads the engine-merged cache DB that
    a normal CP+VP session writes. To produce that DB, a session must run the
    Community-Patch-DLL fork (so the bake's DLL matches what players run) with
    database validation on (so the merged DB persists). This script lays down
    exactly those two things and nothing else:

      1. Completes a partial plain-VP install from -ClonePath / build/vp-runtime
         (idempotent; the substrate's audio data is part of what the bake expects).
      2. Places dist/engine-vp's fork DLL over VP's shipped DLL in
         MODS\(1) Community Patch\, backing up VP's DLL on first run.
      3. Sets ValidateGameDatabase=1 in config.ini so Civ5DebugDatabase.db persists.
      4. Removes any active ZCivVAccessVP / ZCivVAccessCP package and LekMod DLC,
         so the merged DB from the CP+VP session is not polluted by a second copy.

    It deliberately does NOT touch the accessibility DLC payload, the proxy / Tolk
    stack, the vendor overlay, the MODS accessibility overlay, or the cinematics --
    whatever install state was there stays in place (that is the mode-agnostic,
    don't-clobber win over the retired deploy-vp.ps1 mod-overlay).

    After running, start a game with (1) Community Patch and (2) Vox Populi
    enabled (Squads off), load to the map, and quit. That writes the merged DB
    the bake reads. Then run build-modpack.ps1 and deploy.ps1 -State vp.

    -Restore puts VP's shipped DLL back into MODS from the backup and removes the
    backup. The packages this script removed are re-laid by the subsequent
    deploy.ps1 -State vp / -State cp, so restore does not re-add them.

.PARAMETER GameDir
    Override the auto-detected Civ V install path.

.PARAMETER ClonePath
    Community-Patch-DLL clone, used to complete a partial plain-VP install and as
    the fork DLL source's sibling. Defaults to the sibling directory next to this
    repo. Ignored for any asset already staged under build/vp-runtime.

.PARAMETER Restore
    Reverse step 2: restore VP's shipped DLL into MODS from the backup.
#>
[CmdletBinding()]
param(
    [string]$GameDir,
    [string]$ClonePath,
    [switch]$Restore
)

$ErrorActionPreference = 'Stop'

$repoRoot        = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $repoRoot 'tools\dlc-assembly.ps1')

$engineVpDistDir = Join-Path $repoRoot 'dist\engine-vp'
$vpRuntimeDir    = Join-Path $repoRoot 'build\vp-runtime'
$dlcName         = 'DLC_CivVAccess'
$dlcBackupDirName = "$dlcName.backup"
$modpackNames    = @('ZCivVAccessVP', 'ZCivVAccessCP')
$engineDllName   = 'CvGameCore_Expansion2.dll'

if ([string]::IsNullOrWhiteSpace($ClonePath)) {
    $ClonePath = Join-Path (Split-Path -Parent $repoRoot) 'Community-Patch-DLL'
}

$civ5DocsDir  = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5"
$vpModsDllDir = Join-Path $civ5DocsDir 'MODS\(1) Community Patch'

# Set in the driver after Resolve-CivVInstallDir, before any helper uses them.
$dlcBackupDir       = $null
$engineVpBackup     = $null
$expansionPkgBackup = $null

function Remove-ActivePackages {
    param([string]$Game)
    $dlcRoot = Join-Path $Game 'Assets\DLC'
    foreach ($name in $modpackNames) {
        $d = Join-Path $dlcRoot $name
        if (Test-Path $d) {
            Write-Host "Removing active modpack package (would pollute the merged DB):"
            Write-Host "  $d"
            Remove-Item -LiteralPath $d -Recurse -Force
        }
    }
    Get-ChildItem -LiteralPath $dlcRoot -Directory -Filter 'LEKMOD*' -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "Removing LekMod DLC (would pollute the merged DB):"
        Write-Host "  $($_.FullName)"
        Remove-Item -LiteralPath $_.FullName -Recurse -Force
    }
}

# ---- Driver ----
Write-Host "Locating Civilization V install..."
$gameDir = Resolve-CivVInstallDir -ExplicitPath $GameDir
Write-Host "  Game dir: $gameDir"

$dlcBackupDir       = Join-Path $gameDir "Assets\DLC\$dlcBackupDirName"
$engineVpBackup     = Join-Path $dlcBackupDir 'CvGameCore_Expansion2.vp-stock.dll'
$expansionPkgBackup = Join-Path $dlcBackupDir 'Expansion2.Civ5Pkg.stock'

if ($Restore) {
    Restore-VpForkDll
    Write-Host ""
    Write-Host "Restore complete. VP's shipped DLL is back in MODS. The removed packages"
    Write-Host "are re-laid by deploy.ps1 -State vp / -State cp; this does not re-add them."
    return
}

Complete-VPInstall -Game $gameDir
Install-VpForkDll
Enable-DatabaseValidation -DocsDir $civ5DocsDir
Remove-ActivePackages -Game $gameDir

Write-Host ""
Write-Host "Bake prep complete. The install state is otherwise untouched."
Write-Host ""
Write-Host "Now generate the merged database:"
Write-Host "  - Start a game with (1) Community Patch and (2) Vox Populi enabled"
Write-Host "    (do NOT enable (4a) Squads)."
Write-Host "  - Let it load to the map, then quit."
Write-Host "This deploy set ValidateGameDatabase=1 so Civ5DebugDatabase.db persists."
Write-Host ""
Write-Host "Then bake and deploy the modpack:"
Write-Host "  ./build-modpack.ps1"
Write-Host "  ./deploy.ps1 -State vp"
Write-Host ""
Write-Host "When done, ./stage-vp-modpack-bake.ps1 -Restore puts VP's shipped DLL back."
