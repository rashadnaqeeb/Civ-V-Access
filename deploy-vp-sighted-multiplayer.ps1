<#
.SYNOPSIS
    Deploy the minimum bits a sighted multiplayer partner needs to play
    against a Civ-V-Access host on Vox Populi: the fork engine DLL into the
    VP MODS folder and the fake-DLC manifest. No accessibility code runs on
    this machine.

.DESCRIPTION
    The VP variant of deploy-sighted-multiplayer.ps1. The partner must have
    Vox Populi installed already (this script does not install VP). Two
    things must match between host and partner:

      - Engine DLL. The host runs our civvaccess branch of the
        Community-Patch-DLL fork; the partner must run the same DLL. The
        fork inherits VP's GUID, so the version check passes either way --
        but the DLLs must be identical for lockstep determinism, so the
        partner installs ours. It lands where VP loads its DLL from:
        MODS\(1) Community Patch\ in the user's Documents. VP's shipped DLL
        is backed up; -Uninstall restores it.

      - DLC presence and GUID. The host has DLC_CivVAccess enabled; the
        partner needs the same package GUID active so the DLC list lines
        up. CivVAccess_2.Civ5Pkg is deployed with empty UISkin directories,
        same as the vanilla sighted deploy.

.PARAMETER GameDir
    Override the auto-detected Civ V install path.

.PARAMETER SkipEngine
    Skip the engine DLL copy.

.PARAMETER SkipDlc
    Skip the DLC manifest copy.

.PARAMETER Uninstall
    Remove DLC_CivVAccess and (if a backup exists) restore VP's shipped
    engine DLL into the MODS folder.
#>
[CmdletBinding()]
param(
    [string]$GameDir,
    [switch]$SkipEngine,
    [switch]$SkipDlc,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

$repoRoot        = Split-Path -Parent $MyInvocation.MyCommand.Path
$engineVpDistDir = Join-Path $repoRoot 'dist\engine-vp'
$dlcSrcDir       = Join-Path $repoRoot 'src\dlc'
$dlcName         = 'DLC_CivVAccess'
$dlcBackupDirName    = "$dlcName.backup"
$installManifestName = 'CivVAccess.install.json'
$manifestFile    = 'CivVAccess_2.Civ5Pkg'
$engineDllName   = 'CvGameCore_Expansion2.dll'

$civ5DocsDir  = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5"
$vpModsDllDir = Join-Path $civ5DocsDir 'MODS\(1) Community Patch'

$versionsFile = Join-Path $repoRoot 'versions.json'
if (-not (Test-Path $versionsFile)) { throw "versions.json missing at $versionsFile" }
$versions        = Get-Content -LiteralPath $versionsFile -Raw | ConvertFrom-Json
$modVersion      = $versions.mod
$engineVpVersion = $versions.components.engine_vp
$coreVersion     = $versions.components.core

# Set in the driver after Resolve-CivVInstallDir, before any function uses them.
$dlcBackupDir   = $null
$engineVpBackup = $null

# Empty directories created under the deployed DLC so the manifest's
# <UISkin>/<Skin>/<GameplaySkin> directives resolve without mod code.
$dlcUiDirs = @(
    'UI\FrontEnd',
    'UI\Shared',
    'UI\InGame',
    'UI\TechTree'
)

function Add-CandidateGameDir {
    param(
        [System.Collections.Generic.List[string]]$List,
        [string]$Path
    )
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

    $uninstallKeys = @(
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 8930',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 8930'
    )
    foreach ($key in $uninstallKeys) {
        try {
            $props = Get-ItemProperty -Path $key -ErrorAction Stop
            Add-CandidateGameDir -List $candidates -Path $props.InstallLocation
        } catch { }
    }

    try {
        $steam = Get-ItemProperty -Path 'HKCU:\Software\Valve\Steam' -ErrorAction Stop
        $steamPath = $steam.SteamPath
        if (-not [string]::IsNullOrWhiteSpace($steamPath)) {
            $steamPath = ($steamPath -replace '/', '\').TrimEnd('\')
            Add-CandidateGameDir -List $candidates -Path (Join-Path $steamPath "steamapps\common\$appName")

            $libraryVdf = Join-Path $steamPath 'steamapps\libraryfolders.vdf'
            if (Test-Path $libraryVdf) {
                $raw = Get-Content -Raw $libraryVdf
                $matches = [regex]::Matches($raw, '"path"\s*"([^"]+)"')
                foreach ($m in $matches) {
                    $libPath = $m.Groups[1].Value -replace '\\\\', '\'
                    Add-CandidateGameDir -List $candidates -Path (Join-Path $libPath "steamapps\common\$appName")
                }
            }
        }
    } catch { }

    try {
        $hklmSteam = Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam' -ErrorAction Stop
        if ($hklmSteam -and -not [string]::IsNullOrWhiteSpace($hklmSteam.InstallPath)) {
            $p = $hklmSteam.InstallPath.TrimEnd('\')
            Add-CandidateGameDir -List $candidates -Path (Join-Path $p "steamapps\common\$appName")
        }
    } catch { }

    Add-CandidateGameDir -List $candidates -Path (Join-Path ${env:ProgramFiles(x86)} "Steam\steamapps\common\$appName")

    foreach ($candidate in $candidates) {
        $exe = Join-Path $candidate 'CivilizationV.exe'
        if (Test-Path $exe) {
            return (Resolve-Path $candidate).Path
        }
    }

    $searched = if ($candidates.Count -gt 0) { $candidates -join '; ' } else { '<none>' }
    throw "Could not find Civilization V install directory. Pass -GameDir or set CIV5_DIR. Searched: $searched"
}

function Deploy-DlcManifestOnly {
    param([string]$Game)

    $manifestSrc = Join-Path $dlcSrcDir $manifestFile
    if (-not (Test-Path $manifestSrc)) {
        throw "DLC manifest missing: $manifestSrc"
    }

    $dlcDir = Join-Path $Game "Assets\DLC\$dlcName"
    if (Test-Path $dlcDir) {
        Write-Host "  Removing existing DLC directory: $dlcDir"
        Remove-Item -LiteralPath $dlcDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $dlcDir -Force | Out-Null

    Write-Host "Deploying DLC manifest to:"
    Write-Host "  $dlcDir\$manifestFile"
    Copy-Item -LiteralPath $manifestSrc -Destination (Join-Path $dlcDir $manifestFile) -Force

    foreach ($rel in $dlcUiDirs) {
        $p = Join-Path $dlcDir $rel
        New-Item -ItemType Directory -Path $p -Force | Out-Null
    }
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

    $stagedDll = Join-Path $engineVpDistDir $engineDllName
    if (-not (Test-Path $stagedDll)) {
        throw "Built VP fork DLL missing: $stagedDll."
    }

    $installedDll = Join-Path $vpModsDllDir $engineDllName
    if (-not (Test-Path $installedDll)) {
        throw "VP's engine DLL not found at $installedDll. This machine needs Vox Populi installed first."
    }

    if (-not (Test-Path $engineVpBackup)) {
        $backupDir = Split-Path -Parent $engineVpBackup
        if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }
        Write-Host "Backing up VP's shipped engine DLL:"
        Write-Host "  $installedDll -> $engineVpBackup"
        Copy-Item -LiteralPath $installedDll -Destination $engineVpBackup -Force
    } else {
        Write-Host "  VP engine DLL backup already exists at $engineVpBackup."
    }

    Write-Host "Deploying VP fork engine DLL:"
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
        variant        = 'vp'
        installed_at   = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        components     = [ordered]@{
            engine_vp    = [ordered]@{ version = $engineVpVersion }
            core_sighted = [ordered]@{ version = $coreVersion }
        }
        backups        = [ordered]@{
            engine_dll_vp = "$backupDirRel/CvGameCore_Expansion2.vp-stock.dll"
        }
    }

    $json = $manifest | ConvertTo-Json -Depth 5
    Set-Content -LiteralPath $manifestPath -Value $json -Encoding UTF8
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

    if (Test-Path $engineVpBackup) {
        $installedDll = Join-Path $vpModsDllDir $engineDllName
        Write-Host "  Restoring VP's shipped engine DLL from backup:"
        Write-Host "    $engineVpBackup -> $installedDll"
        Copy-Item -LiteralPath $engineVpBackup -Destination $installedDll -Force
        Remove-Item -LiteralPath $engineVpBackup -Force
    } else {
        Write-Host "  No VP engine DLL backup present; skipping engine restore."
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

# Backup paths derived from gameDir. Functions read these from script scope.
$dlcBackupDir   = Join-Path $gameDir "Assets\DLC\$dlcBackupDirName"
$engineVpBackup = Join-Path $dlcBackupDir 'CvGameCore_Expansion2.vp-stock.dll'

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

if (-not $SkipEngine) {
    Deploy-EngineDll -Game $gameDir
} else {
    Write-Host "Skipping engine DLL (-SkipEngine)."
}

if (-not $SkipDlc) {
    Write-InstallManifest -Game $gameDir
}

Write-Host ""
Write-Host "VP sighted multiplayer deploy complete."
Write-Host "  Game dir: $gameDir"
Write-Host "  Version : $modVersion (VP variant)"
Write-Host ""
Write-Host "This machine has the Civ-V-Access fork of the Community Patch DLL"
Write-Host "and the DLC_CivVAccess manifest (empty UI/ subdirs). No proxy, no"
Write-Host "Tolk runtime, no mod UI code - the game runs as normal Vox Populi"
Write-Host "for this player while staying multiplayer-compatible with a"
Write-Host "Civ-V-Access host."
