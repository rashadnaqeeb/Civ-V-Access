<#
.SYNOPSIS
    Deploy staged proxy stack, DLC payload, and (optionally) the modded
    engine DLL into the Civilization V install.

.DESCRIPTION
    Three pieces, each independently skippable:
      - Proxy stack: dist/proxy/lua51_Win32.dll + the Tolk runtime DLLs from
        third_party/tolk/dist/x86/.
      - DLC: src/dlc/ (the fake-DLC payload) into Assets/DLC/DLC_CivVAccess/.
      - Engine DLL: dist/engine/CvGameCore_Expansion2.dll into
        Assets/DLC/Expansion2/, with the original vanilla DLL backed up to
        build/CvGameCore_Expansion2.vanilla.dll.bak on first install.

    The engine DLL is deployed by default; pass -SkipEngine for Lua-only
    iterations where the (~4 MB) DLL copy isn't worth it.

    -Uninstall reverses everything: restores the vanilla engine DLL from the
    backup, restores the original lua51_Win32.dll, removes the DLC and the
    proxy runtime DLLs.

.PARAMETER GameDir
    Override the auto-detected Civ V install path.

.PARAMETER SkipProxy
    Skip the proxy stack and the legacy lua51 rename. Useful when only the
    DLC payload changed.

.PARAMETER SkipDlc
    Skip the DLC payload copy. Useful for proxy-only iteration (rare).

.PARAMETER SkipEngine
    Skip copying dist/engine/CvGameCore_Expansion2.dll. Useful for fast
    Lua-only iterations.

.PARAMETER SkipCinematics
    Skip copying audio-described BNW opening cinematics. Files are large
    (~80 MB English, ~5 MB per non-English locale) and rarely change, so
    this is useful for fast Lua-only iterations.

.PARAMETER Uninstall
    Remove the proxy stack, restore the original lua51, remove the DLC,
    and (if a backup exists) restore the vanilla engine DLL and stock
    BNW cinematics.
#>
[CmdletBinding()]
param(
    [string]$GameDir,
    [switch]$SkipProxy,
    [switch]$SkipDlc,
    [switch]$SkipEngine,
    [switch]$SkipCinematics,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

$repoRoot         = Split-Path -Parent $MyInvocation.MyCommand.Path
$proxyDistDir     = Join-Path $repoRoot 'dist\proxy'
$engineDistDir    = Join-Path $repoRoot 'dist\engine'
$tolkDistDir      = Join-Path $repoRoot 'third_party\tolk\dist\x86'
$engineBackup     = Join-Path $repoRoot 'build\CvGameCore_Expansion2.vanilla.dll.bak'
$cinematicSrcDir  = Join-Path $repoRoot 'audio described intros'
$cinematicBackup  = Join-Path $repoRoot 'build\cinematics-vanilla'
$dlcSrcDir        = Join-Path $repoRoot 'src\dlc'
$soundsSrcDir     = Join-Path $repoRoot 'sounds'
$dlcName          = 'DLC_CivVAccess'
$legacyDlcDirs    = @('CivVAccess')
$legacyModDir     = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5\MODS\Civ-V-Access (v 1)"

# BNW opening cinematic filenames the engine expects under
# Assets/DLC/Expansion2/. Only en_US is a full .wmv video; non-English locales
# are .wma audio dubs the engine layers over the en_US.wmv visual track. Source
# files in $cinematicSrcDir are pre-named to match these exactly.
$cinematicFiles = @(
    'Civ5XP2_Opening_Movie_en_US.wmv',
    'Civ5XP2_Opening_Movie_de_DE.wma',
    'Civ5XP2_Opening_Movie_es_ES.wma',
    'Civ5XP2_Opening_Movie_fr_FR.wma',
    'Civ5XP2_Opening_Movie_it_IT.wma',
    'Civ5XP2_Opening_Movie_pl_PL.wma',
    'Civ5XP2_Opening_Movie_ru_RU.wma'
)

# Files to copy into the game directory alongside the proxy. lua51_Win32.dll
# is our build (dist/proxy/); the rest are third-party screen-reader bridges
# shipped from third_party/tolk/dist/x86/. Both are committed to the repo so
# contributors can deploy without rebuilding.
$ourProxyFiles = @('lua51_Win32.dll')
$tolkFiles     = @(
    'Tolk.dll',
    'SAAPI32.dll',
    'dolapi32.dll',
    'nvdaControllerClient32.dll',
    'BoyCtrl.dll',
    'boyctrl.ini',
    'ZDSRAPI.dll',
    'ZDSRAPI.ini'
)

$engineDllName = 'CvGameCore_Expansion2.dll'

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

function Deploy-ProxyStack {
    param([string]$Game)

    # Verify all expected source files before touching anything.
    foreach ($f in $ourProxyFiles) {
        $p = Join-Path $proxyDistDir $f
        if (-not (Test-Path $p)) { throw "Missing built proxy file: $p. Run build-proxy.ps1 first." }
    }
    foreach ($f in $tolkFiles) {
        $p = Join-Path $tolkDistDir $f
        if (-not (Test-Path $p)) { throw "Missing Tolk runtime file: $p" }
    }

    $stockDll    = Join-Path $Game 'lua51_Win32.dll'
    $originalDll = Join-Path $Game 'lua51_original.dll'
    if (Test-Path $originalDll) {
        Write-Host "  lua51_original.dll already present - proxy previously deployed."
    } elseif (Test-Path $stockDll) {
        Write-Host "  Renaming stock lua51_Win32.dll -> lua51_original.dll"
        Rename-Item -LiteralPath $stockDll -NewName 'lua51_original.dll'
    } else {
        throw "Neither lua51_Win32.dll nor lua51_original.dll found in $Game. Run 'Verify integrity of game files' in Steam and retry."
    }

    Write-Host "Copying proxy + Tolk runtime to game directory:"
    foreach ($f in $ourProxyFiles) {
        $src = Join-Path $proxyDistDir $f
        $dst = Join-Path $Game $f
        Copy-Item -LiteralPath $src -Destination $dst -Force
        Write-Host "  $dst"
    }
    foreach ($f in $tolkFiles) {
        $src = Join-Path $tolkDistDir $f
        $dst = Join-Path $Game $f
        Copy-Item -LiteralPath $src -Destination $dst -Force
        Write-Host "  $dst"
    }
}

function Deploy-Dlc {
    param([string]$Game)

    $dlcDir = Join-Path $Game "Assets\DLC\$dlcName"
    if (Test-Path $dlcDir) {
        Write-Host "  Removing existing DLC directory: $dlcDir"
        Remove-Item -LiteralPath $dlcDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $dlcDir -Force | Out-Null
    Write-Host "Deploying DLC payload to:"
    Write-Host "  $dlcDir"
    Copy-Item -Path (Join-Path $dlcSrcDir '*') -Destination $dlcDir -Recurse -Force

    if (Test-Path $soundsSrcDir) {
        $soundsDst = Join-Path $dlcDir 'Sounds'
        New-Item -ItemType Directory -Path $soundsDst -Force | Out-Null
        Write-Host "Deploying sound assets to:"
        Write-Host "  $soundsDst"
        Copy-Item -Path (Join-Path $soundsSrcDir '*.wav') -Destination $soundsDst -Force
    }

    if (Test-Path $legacyModDir) {
        Write-Host "Removing legacy mod directory:"
        Write-Host "  $legacyModDir"
        Remove-Item -LiteralPath $legacyModDir -Recurse -Force
    }
    $legacyBootstrap = Join-Path $Game 'CivVAccess'
    if ((Test-Path $legacyBootstrap) -and ($legacyBootstrap -ne $dlcDir)) {
        Write-Host "Removing legacy bootstrap directory:"
        Write-Host "  $legacyBootstrap"
        Remove-Item -LiteralPath $legacyBootstrap -Recurse -Force
    }
    foreach ($legacy in $legacyDlcDirs) {
        $p = Join-Path $Game "Assets\DLC\$legacy"
        if ((Test-Path $p) -and ($p -ne $dlcDir)) {
            Write-Host "Removing legacy DLC directory:"
            Write-Host "  $p"
            Remove-Item -LiteralPath $p -Recurse -Force
        }
    }

    # Engine re-enumerates DLC list at startup from this cache. Without
    # clearing, newly-added or renamed DLCs may not appear until the user
    # forces a refresh.
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

    # First-run backup. Only ever backs up if no backup exists; never
    # overwrites the backup with a modded DLL.
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

function Deploy-Cinematics {
    param([string]$Game)

    if (-not (Test-Path $cinematicSrcDir)) {
        throw "Cinematics source directory missing: $cinematicSrcDir"
    }

    $expansion2Dir = Join-Path $Game 'Assets\DLC\Expansion2'
    if (-not (Test-Path $expansion2Dir)) {
        throw "BNW (Expansion2) directory not found at $expansion2Dir. The mod requires BNW; verify the game install."
    }

    foreach ($f in $cinematicFiles) {
        $src = Join-Path $cinematicSrcDir $f
        if (-not (Test-Path $src)) { throw "Missing cinematic source file: $src" }
    }

    # First-run backup. Copy each stock cinematic into the backup directory
    # only if no backup file already exists for it - never overwrite a backup
    # with a modded file.
    if (-not (Test-Path $cinematicBackup)) {
        New-Item -ItemType Directory -Path $cinematicBackup -Force | Out-Null
    }
    foreach ($f in $cinematicFiles) {
        $installed = Join-Path $expansion2Dir $f
        $backup    = Join-Path $cinematicBackup $f
        if ((Test-Path $installed) -and -not (Test-Path $backup)) {
            Write-Host "Backing up vanilla cinematic:"
            Write-Host "  $installed -> $backup"
            Copy-Item -LiteralPath $installed -Destination $backup -Force
        }
    }

    Write-Host "Deploying audio-described BNW cinematics:"
    foreach ($f in $cinematicFiles) {
        $src = Join-Path $cinematicSrcDir $f
        $dst = Join-Path $expansion2Dir $f
        Write-Host "  $src -> $dst"
        Copy-Item -LiteralPath $src -Destination $dst -Force
    }
}

function Invoke-Uninstall {
    param([string]$Game)

    $stockDll    = Join-Path $Game 'lua51_Win32.dll'
    $originalDll = Join-Path $Game 'lua51_original.dll'
    if (Test-Path $originalDll) {
        if (Test-Path $stockDll) {
            Write-Host "  Removing proxy lua51_Win32.dll"
            Remove-Item -LiteralPath $stockDll -Force
        }
        Write-Host "  Restoring lua51_original.dll -> lua51_Win32.dll"
        Rename-Item -LiteralPath $originalDll -NewName 'lua51_Win32.dll'
    } else {
        Write-Host "  No lua51_original.dll found; skipping proxy restore."
    }

    foreach ($f in @('Tolk.dll','SAAPI32.dll','dolapi32.dll','nvdaControllerClient32.dll','BoyCtrl.dll','boyctrl.ini','ZDSRAPI.dll','ZDSRAPI.ini')) {
        $p = Join-Path $Game $f
        if (Test-Path $p) {
            Write-Host "  Removing $p"
            Remove-Item -LiteralPath $p -Force
        }
    }

    foreach ($name in @($dlcName) + $legacyDlcDirs) {
        $p = Join-Path $Game "Assets\DLC\$name"
        if (Test-Path $p) {
            Write-Host "  Removing DLC: $p"
            Remove-Item -LiteralPath $p -Recurse -Force
        }
    }

    $legacyBootstrap = Join-Path $Game 'CivVAccess'
    if (Test-Path $legacyBootstrap) {
        Write-Host "  Removing legacy bootstrap: $legacyBootstrap"
        Remove-Item -LiteralPath $legacyBootstrap -Recurse -Force
    }

    if (Test-Path $legacyModDir) {
        Write-Host "  Removing legacy mod directory: $legacyModDir"
        Remove-Item -LiteralPath $legacyModDir -Recurse -Force
    }

    $proxyLog = Join-Path $Game 'proxy_debug.log'
    if (Test-Path $proxyLog) {
        Remove-Item -LiteralPath $proxyLog -Force
    }

    # Restore vanilla engine DLL if we ever swapped it. Backup is the source
    # of truth; if missing, the user never deployed the modded engine in the
    # first place, so nothing to restore.
    if (Test-Path $engineBackup) {
        $installedDll = Join-Path $Game "Assets\DLC\Expansion2\$engineDllName"
        Write-Host "  Restoring vanilla engine DLL from backup:"
        Write-Host "    $engineBackup -> $installedDll"
        Copy-Item -LiteralPath $engineBackup -Destination $installedDll -Force
    } else {
        Write-Host "  No engine DLL backup present; skipping engine restore."
    }

    # Restore stock BNW cinematics from backup. Same logic as engine DLL: backup
    # is the source of truth, missing backup means we never deployed cinematics.
    if (Test-Path $cinematicBackup) {
        $expansion2Dir = Join-Path $Game 'Assets\DLC\Expansion2'
        foreach ($f in $cinematicFiles) {
            $backup    = Join-Path $cinematicBackup $f
            $installed = Join-Path $expansion2Dir $f
            if (Test-Path $backup) {
                Write-Host "  Restoring vanilla cinematic:"
                Write-Host "    $backup -> $installed"
                Copy-Item -LiteralPath $backup -Destination $installed -Force
            }
        }
    } else {
        Write-Host "  No cinematics backup present; skipping cinematics restore."
    }
}

# ---- Driver ----
Write-Host "Locating Civilization V install..."
$gameDir = Resolve-CivVInstallDir -ExplicitPath $GameDir
Write-Host "  Game dir: $gameDir"

if ($Uninstall) {
    Invoke-Uninstall -Game $gameDir
    Write-Host ""
    Write-Host "Uninstall complete."
    return
}

if (-not $SkipProxy) {
    Deploy-ProxyStack -Game $gameDir
} else {
    Write-Host "Skipping proxy stack (-SkipProxy)."
}

if (-not $SkipDlc) {
    Deploy-Dlc -Game $gameDir
} else {
    Write-Host "Skipping DLC payload (-SkipDlc)."
}

if (-not $SkipEngine) {
    Deploy-EngineDll -Game $gameDir
} else {
    Write-Host "Skipping engine DLL (-SkipEngine)."
}

if (-not $SkipCinematics) {
    Deploy-Cinematics -Game $gameDir
} else {
    Write-Host "Skipping cinematics (-SkipCinematics)."
}

Write-Host ""
Write-Host "Deploy complete."
Write-Host "  Game dir: $gameDir"
Write-Host ""
Write-Host "Reminder: for Lua.log output, set LoggingEnabled=1 in:"
Write-Host "  $env:USERPROFILE\Documents\My Games\Sid Meier's Civilization 5\config.ini"
