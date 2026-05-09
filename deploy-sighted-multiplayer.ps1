<#
.SYNOPSIS
    Deploy the minimum bits a sighted multiplayer partner needs to play
    against a Civ-V-Access host: the modded engine DLL and the fake-DLC
    manifest. No accessibility code runs on this machine.

.DESCRIPTION
    Multiplayer compatibility hinges on two things that must match between
    host and partner:
      - Engine DLL GUID (CvDllVersion.h). Hosts run our forked
        CvGameCore_Expansion2.dll; partners must too, or the version check
        rejects the join.
      - DLC presence and GUID. The host has DLC_CivVAccess enabled; the
        partner needs the same package GUID active so the DLC list lines up.

    Everything else in the full deploy is local-only: the lua51 proxy, the
    Tolk runtime, the UI/ payload (boot scripts, scanner, speech pipeline,
    string tables, sounds), and the WorldView/InGame/ToolTips overrides.
    A sighted user has no use for any of it, and the UI overrides would
    actively break their game by referencing the absent `tolk` global.

    What this script copies:
      - dist/engine/CvGameCore_Expansion2.dll into Assets/DLC/Expansion2/,
        backing up the vanilla DLL under Assets/DLC/DLC_CivVAccess.backup/
        (sibling of the deployed DLC dir) on first install.
      - src/dlc/CivVAccess_2.Civ5Pkg into Assets/DLC/DLC_CivVAccess/. The
        manifest's UISkin directives reference UI/FrontEnd, UI/Shared,
        UI/InGame, UI/TechTree; the script creates those as empty directories
        so the engine resolves the manifest without dragging in any mod code.
      - CivVAccess.install.json into the deployed DLC dir, recording profile
        as "sighted" so the external installer treats this machine as a
        sighted-MP install on subsequent updates.

    -Uninstall reverses both: removes DLC_CivVAccess and restores the vanilla
    engine DLL from the backup.

.PARAMETER GameDir
    Override the auto-detected Civ V install path.

.PARAMETER SkipEngine
    Skip the engine DLL copy. Rarely useful; the engine GUID is the main
    thing the partner needs to match.

.PARAMETER SkipDlc
    Skip the DLC manifest copy.

.PARAMETER Uninstall
    Remove DLC_CivVAccess and (if a backup exists) restore the vanilla
    engine DLL.
#>
[CmdletBinding()]
param(
    [string]$GameDir,
    [switch]$SkipEngine,
    [switch]$SkipDlc,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

$repoRoot       = Split-Path -Parent $MyInvocation.MyCommand.Path
$engineDistDir  = Join-Path $repoRoot 'dist\engine'
$dlcSrcDir      = Join-Path $repoRoot 'src\dlc'
$dlcName        = 'DLC_CivVAccess'
$dlcBackupDirName    = "$dlcName.backup"  # sibling to DLC dir; survives DLC dir nuke
$installManifestName = 'CivVAccess.install.json'
$manifestFile   = 'CivVAccess_2.Civ5Pkg'
$engineDllName  = 'CvGameCore_Expansion2.dll'

# Versions live in versions.json at repo root. Sighted-MP only needs the
# engine binding, so we read just the engine + mod fields here. The full
# component list is documented in deploy.ps1.
$versionsFile = Join-Path $repoRoot 'versions.json'
if (-not (Test-Path $versionsFile)) { throw "versions.json missing at $versionsFile" }
$versions      = Get-Content -LiteralPath $versionsFile -Raw | ConvertFrom-Json
$modVersion    = $versions.mod
$engineVersion = $versions.components.engine
$coreVersion   = $versions.components.core

# Set in the driver after Resolve-CivVInstallDir, before any function uses them.
$dlcBackupDir = $null
$engineBackup = $null

# Empty directories created under the deployed DLC so the manifest's
# <UISkin>/<Skin>/<GameplaySkin> directives resolve. The host's full deploy
# populates these; the sighted partner's stays empty, which is the point.
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

    $cacheDir = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5\cache"
    if (Test-Path $cacheDir) {
        Write-Host "Clearing DLC cache:"
        Write-Host "  $cacheDir"
        Get-ChildItem -LiteralPath $cacheDir -File | Remove-Item -Force
    }
}

function Deploy-EngineDll {
    param([string]$Game)

    $stagedDll = Join-Path $engineDistDir $engineDllName
    if (-not (Test-Path $stagedDll)) {
        throw "Built engine DLL missing: $stagedDll. Run build-engine.ps1 first (or commit the built DLL)."
    }

    $installedDll = Join-Path $Game "Assets\DLC\Expansion2\$engineDllName"
    if (-not (Test-Path $installedDll)) {
        throw "Vanilla engine DLL not found at $installedDll. Verify game files in Steam and retry."
    }

    if (-not (Test-Path $engineBackup)) {
        $backupDir = Split-Path -Parent $engineBackup
        if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }
        Write-Host "Backing up vanilla engine DLL:"
        Write-Host "  $installedDll -> $engineBackup"
        Copy-Item -LiteralPath $installedDll -Destination $engineBackup -Force
    } else {
        Write-Host "  Vanilla engine DLL backup already exists at $engineBackup."
    }

    Write-Host "Deploying modded engine DLL:"
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
        installed_at   = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        components     = [ordered]@{
            engine       = [ordered]@{ version = $engineVersion }
            core_sighted = [ordered]@{ version = $coreVersion }
        }
        backups        = [ordered]@{
            engine_dll = "$backupDirRel/CvGameCore_Expansion2.vanilla.dll"
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

    if (Test-Path $engineBackup) {
        $installedDll = Join-Path $Game "Assets\DLC\Expansion2\$engineDllName"
        Write-Host "  Restoring vanilla engine DLL from backup:"
        Write-Host "    $engineBackup -> $installedDll"
        Copy-Item -LiteralPath $engineBackup -Destination $installedDll -Force
    } else {
        Write-Host "  No engine DLL backup present; skipping engine restore."
    }

    if (Test-Path $dlcBackupDir) {
        Write-Host "  Removing backup dir: $dlcBackupDir"
        Remove-Item -LiteralPath $dlcBackupDir -Recurse -Force
    }

    $cacheDir = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5\cache"
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
$dlcBackupDir = Join-Path $gameDir "Assets\DLC\$dlcBackupDirName"
$engineBackup = Join-Path $dlcBackupDir 'CvGameCore_Expansion2.vanilla.dll'

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
Write-Host "Sighted multiplayer deploy complete."
Write-Host "  Game dir: $gameDir"
Write-Host "  Version : $modVersion"
Write-Host ""
Write-Host "This machine has the engine DLL fork and the DLC_CivVAccess manifest"
Write-Host "(empty UI/ subdirs). No proxy, no Tolk runtime, no mod UI code is"
Write-Host "installed - the game will run as vanilla BNW for this player while"
Write-Host "remaining multiplayer-compatible with a Civ-V-Access host."
