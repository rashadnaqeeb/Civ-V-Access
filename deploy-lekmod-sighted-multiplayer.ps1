<#
.SYNOPSIS
    Deploy the minimum bits a sighted multiplayer partner needs to play
    against a Civ-V-Access host on LekMod: our fork engine DLL into their
    LekMod DLC folder and the fake-DLC manifest. No accessibility code runs on
    this machine.

.DESCRIPTION
    The LekMod variant of deploy-sighted-multiplayer.ps1. The partner must have
    LekMod installed already (this script does not install LekMod). Two things
    must match between host and partner:

      - Engine DLL. The host runs our LekMod fork (the clone's civvaccess
        branch); the partner must run the same DLL for lockstep determinism.
        The fork inherits LekMod's GUID, so the DLC version check passes either
        way -- but the DLLs must be identical, so the partner installs ours. It
        lands where LekMod loads its DLL: the partner's LekMod DLC folder
        (Assets/DLC/LEKMOD*). LekMod's shipped DLL is backed up; -Uninstall
        restores it.

      - DLC presence and GUID. The host has DLC_CivVAccess active; the partner
        needs the same package GUID on the DLC list. CivVAccess_2.Civ5Pkg is
        deployed with empty UISkin directories, same as the other sighted
        deploys. Priority is left at the committed value -- the DLC-list match
        is by GUID, and the SteamApp + Key tags publish the sentinel
        assets_hash regardless of content, so host and partner line up.

.PARAMETER GameDir
    Override the auto-detected Civ V install path.

.PARAMETER SkipDlc
    Skip the DLC manifest copy.

.PARAMETER Uninstall
    Remove DLC_CivVAccess and (if a backup exists) restore LekMod's shipped
    engine DLL into the LekMod DLC folder.
#>
[CmdletBinding()]
param(
    [string]$GameDir,
    [switch]$SkipDlc,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

$repoRoot            = Split-Path -Parent $MyInvocation.MyCommand.Path
$engineLekmodDistDir = Join-Path $repoRoot 'dist\engine-lekmod'
$dlcSrcDir          = Join-Path $repoRoot 'src\dlc'
$dlcName            = 'DLC_CivVAccess'
$dlcBackupDirName   = "$dlcName.backup"
$installManifestName = 'CivVAccess.install.json'
$manifestFile       = 'CivVAccess_2.Civ5Pkg'
$engineDllName      = 'CvGameCore_Expansion2.dll'

$civ5DocsDir  = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5"

$versionsFile = Join-Path $repoRoot 'versions.json'
if (-not (Test-Path $versionsFile)) { throw "versions.json missing at $versionsFile" }
$versions            = Get-Content -LiteralPath $versionsFile -Raw | ConvertFrom-Json
$modVersion          = $versions.mod
$engineLekmodVersion = $versions.components.engine_lekmod
$coreVersion         = $versions.components.core

# Set in the driver after Resolve-CivVInstallDir, before any function uses them.
$dlcBackupDir       = $null
$engineLekmodBackup = $null

$dlcUiDirs = @(
    'UI\FrontEnd',
    'UI\Shared',
    'UI\InGame',
    'UI\TechTree'
)

function Add-CandidateGameDir {
    param([System.Collections.Generic.List[string]]$List, [string]$Path)
    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        $normalized = $Path.Trim().Trim('"')
        if (-not [string]::IsNullOrWhiteSpace($normalized) -and -not $List.Contains($normalized)) {
            $List.Add($normalized)
        }
    }
}

function Resolve-CivVInstallDir {
    param([string]$ExplicitPath)
    $appName = "Sid Meier's Civilization V"
    $candidates = New-Object 'System.Collections.Generic.List[string]'
    Add-CandidateGameDir -List $candidates -Path $env:CIV5_DIR
    Add-CandidateGameDir -List $candidates -Path $ExplicitPath
    foreach ($key in @(
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 8930',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 8930')) {
        try { Add-CandidateGameDir -List $candidates -Path (Get-ItemProperty -Path $key -ErrorAction Stop).InstallLocation } catch { }
    }
    try {
        $steam = Get-ItemProperty -Path 'HKCU:\Software\Valve\Steam' -ErrorAction Stop
        if (-not [string]::IsNullOrWhiteSpace($steam.SteamPath)) {
            $steamPath = ($steam.SteamPath -replace '/', '\').TrimEnd('\')
            Add-CandidateGameDir -List $candidates -Path (Join-Path $steamPath "steamapps\common\$appName")
            $libraryVdf = Join-Path $steamPath 'steamapps\libraryfolders.vdf'
            if (Test-Path $libraryVdf) {
                foreach ($m in [regex]::Matches((Get-Content -Raw $libraryVdf), '"path"\s*"([^"]+)"')) {
                    Add-CandidateGameDir -List $candidates -Path (Join-Path ($m.Groups[1].Value -replace '\\\\', '\') "steamapps\common\$appName")
                }
            }
        }
    } catch { }
    Add-CandidateGameDir -List $candidates -Path (Join-Path ${env:ProgramFiles(x86)} "Steam\steamapps\common\$appName")
    foreach ($candidate in $candidates) {
        if (Test-Path (Join-Path $candidate 'CivilizationV.exe')) { return (Resolve-Path $candidate).Path }
    }
    $searched = if ($candidates.Count -gt 0) { $candidates -join '; ' } else { '<none>' }
    throw "Could not find Civilization V install directory. Pass -GameDir or set CIV5_DIR. Searched: $searched"
}

function Resolve-LekModDllPath {
    # The partner installed LekMod themselves; its DLC folder is named LEKMOD*
    # (LEKMODvXX_X by convention). Find the one shipping the gameplay DLL.
    param([string]$Game)
    $dlcRoot = Join-Path $Game 'Assets\DLC'
    $folders = Get-ChildItem -LiteralPath $dlcRoot -Directory -Filter 'LEKMOD*' -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName $engineDllName) }
    if (-not $folders) {
        throw "No LekMod DLC folder with $engineDllName found under $dlcRoot. This machine needs LekMod installed first."
    }
    if ($folders.Count -gt 1) {
        throw "Multiple LekMod DLC folders found under $dlcRoot ($($folders.Name -join ', ')). Remove the stale one and retry."
    }
    return (Join-Path $folders[0].FullName $engineDllName)
}

function Deploy-DlcManifestOnly {
    param([string]$Game)
    $manifestSrc = Join-Path $dlcSrcDir $manifestFile
    if (-not (Test-Path $manifestSrc)) { throw "DLC manifest missing: $manifestSrc" }
    $dlcDir = Join-Path $Game "Assets\DLC\$dlcName"
    if (Test-Path $dlcDir) {
        Write-Host "  Removing existing DLC directory: $dlcDir"
        Remove-Item -LiteralPath $dlcDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $dlcDir -Force | Out-Null
    Write-Host "Deploying DLC manifest to:"
    Write-Host "  $dlcDir\$manifestFile"
    Copy-Item -LiteralPath $manifestSrc -Destination (Join-Path $dlcDir $manifestFile) -Force
    foreach ($rel in $dlcUiDirs) { New-Item -ItemType Directory -Path (Join-Path $dlcDir $rel) -Force | Out-Null }
    Write-Host "  Created empty UISkin directories (no mod code shipped)."
    $cacheDir = Join-Path $civ5DocsDir 'cache'
    if (Test-Path $cacheDir) {
        Write-Host "Clearing DLC cache:"
        Write-Host "  $cacheDir"
        Get-ChildItem -LiteralPath $cacheDir -File | Remove-Item -Force
    }
}

function Deploy-EngineDll {
    param([string]$Game)
    $stagedDll = Join-Path $engineLekmodDistDir $engineDllName
    if (-not (Test-Path $stagedDll)) { throw "Built LekMod fork DLL missing: $stagedDll." }

    $installedDll = Resolve-LekModDllPath -Game $Game

    if (-not (Test-Path $engineLekmodBackup)) {
        $backupDir = Split-Path -Parent $engineLekmodBackup
        if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }
        Write-Host "Backing up LekMod's shipped engine DLL:"
        Write-Host "  $installedDll -> $engineLekmodBackup"
        Copy-Item -LiteralPath $installedDll -Destination $engineLekmodBackup -Force
    } else {
        Write-Host "  LekMod engine DLL backup already exists at $engineLekmodBackup."
    }

    Write-Host "Deploying LekMod fork engine DLL:"
    Write-Host "  $stagedDll -> $installedDll"
    Copy-Item -LiteralPath $stagedDll -Destination $installedDll -Force
}

function Write-InstallManifest {
    param([string]$Game)
    $dlcDir = Join-Path $Game "Assets\DLC\$dlcName"
    $manifestPath = Join-Path $dlcDir $installManifestName
    $backupDirRel = "Assets/DLC/$dlcBackupDirName"
    $manifest = [ordered]@{
        schema_version = 1
        mod_version    = $modVersion
        profile        = 'sighted'
        variant        = 'lekmod'
        installed_at   = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        components     = [ordered]@{
            engine_lekmod = [ordered]@{ version = $engineLekmodVersion }
            core_sighted  = [ordered]@{ version = $coreVersion }
        }
        backups        = [ordered]@{
            engine_dll_lekmod = "$backupDirRel/CvGameCore_Expansion2.lekmod-stock.dll"
        }
    }
    Set-Content -LiteralPath $manifestPath -Value ($manifest | ConvertTo-Json -Depth 5) -Encoding UTF8
    Write-Host "Wrote install manifest:"
    Write-Host "  $manifestPath"
}

function Invoke-Uninstall {
    param([string]$Game)
    $dlcDir = Join-Path $Game "Assets\DLC\$dlcName"
    if (Test-Path $dlcDir) {
        Write-Host "  Removing DLC: $dlcDir"
        Remove-Item -LiteralPath $dlcDir -Recurse -Force
    }
    if (Test-Path $engineLekmodBackup) {
        # Restore into whichever LekMod folder currently ships the DLL.
        $installedDll = Resolve-LekModDllPath -Game $Game
        Write-Host "  Restoring LekMod's shipped engine DLL from backup:"
        Write-Host "    $engineLekmodBackup -> $installedDll"
        Copy-Item -LiteralPath $engineLekmodBackup -Destination $installedDll -Force
        Remove-Item -LiteralPath $engineLekmodBackup -Force
    } else {
        Write-Host "  No LekMod engine DLL backup present; skipping engine restore."
    }
    if ((Test-Path $dlcBackupDir) -and ((Get-ChildItem -LiteralPath $dlcBackupDir -Recurse -File | Measure-Object).Count -eq 0)) {
        Write-Host "  Removing empty backup dir: $dlcBackupDir"
        Remove-Item -LiteralPath $dlcBackupDir -Recurse -Force
    }
    $cacheDir = Join-Path $civ5DocsDir 'cache'
    if (Test-Path $cacheDir) {
        Write-Host "Clearing DLC cache:"
        Write-Host "  $cacheDir"
        Get-ChildItem -LiteralPath $cacheDir -File | Remove-Item -Force
    }
}

# ---- Driver ----
Write-Host "Locating Civilization V install..."
$gameDir = Resolve-CivVInstallDir -ExplicitPath $GameDir
Write-Host "  Game dir: $gameDir"

$dlcBackupDir       = Join-Path $gameDir "Assets\DLC\$dlcBackupDirName"
$engineLekmodBackup = Join-Path $dlcBackupDir 'CvGameCore_Expansion2.lekmod-stock.dll'

if ($Uninstall) {
    Invoke-Uninstall -Game $gameDir
    Write-Host ""
    Write-Host "Uninstall complete."
    return
}

if (-not $SkipDlc) {
    Deploy-DlcManifestOnly -Game $gameDir
} else {
    Write-Host "Skipping DLC manifest (-SkipDlc)."
}

Deploy-EngineDll -Game $gameDir

if (-not $SkipDlc) {
    Write-InstallManifest -Game $gameDir
}

Write-Host ""
Write-Host "LekMod sighted multiplayer deploy complete."
Write-Host "  Game dir: $gameDir"
Write-Host "  Version : $modVersion (LekMod variant)"
Write-Host ""
Write-Host "This machine has the Civ-V-Access LekMod fork DLL and the"
Write-Host "DLC_CivVAccess manifest (empty UI/ subdirs). No proxy, no Tolk"
Write-Host "runtime, no mod UI code - the game runs as normal LekMod for this"
Write-Host "player while staying multiplayer-compatible with a Civ-V-Access host."
