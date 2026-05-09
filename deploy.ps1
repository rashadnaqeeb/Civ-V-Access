<#
.SYNOPSIS
    Deploy staged proxy stack, DLC payload, and (optionally) the modded
    engine DLL into the Civilization V install.

.DESCRIPTION
    Three pieces, each independently skippable:
      - Proxy stack: dist/proxy/lua51_Win32.dll + the Tolk runtime DLLs from
        third_party/tolk/dist/x86/.
      - DLC: src/dlc/ (the fake-DLC payload) into Assets/DLC/DLC_CivVAccess/.
        Also writes CivVAccess.install.json into the deployed DLC dir, the
        single source of truth on installed version + profile that the
        external installer reads on subsequent runs.
      - Engine DLL: dist/engine/CvGameCore_Expansion2.dll into
        Assets/DLC/Expansion2/, with the vanilla DLL and the stock BNW
        cinematics backed up under Assets/DLC/DLC_CivVAccess.backup/ (a
        sibling of the DLC dir, so it survives the redeploy nuke-and-recreate
        of the DLC dir itself).

    The engine DLL is deployed by default; pass -SkipEngine for Lua-only
    iterations where the (~4 MB) DLL copy isn't worth it.

    -Uninstall reverses everything: restores the vanilla engine DLL from the
    backup, restores the original lua51_Win32.dll, removes the DLC and the
    proxy runtime DLLs, and clears the engine's DLC cache so the next launch
    forgets DLC_CivVAccess immediately.

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
$cinematicSrcDir  = Join-Path $repoRoot 'audio described intros'
$dlcSrcDir        = Join-Path $repoRoot 'src\dlc'
$soundsSrcDir     = Join-Path $repoRoot 'sounds'
$dlcName          = 'DLC_CivVAccess'
$dlcBackupDirName = "$dlcName.backup"  # sibling to DLC dir; holds vanilla file backups so they survive the dir nuke on redeploy
$installManifestName = 'CivVAccess.install.json'
$legacyDlcDirs    = @('CivVAccess')
$legacyModDir     = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5\MODS\Civ-V-Access (v 1)"

# Versions live in versions.json at repo root. The mod's own version is the
# release tag (and the changelog key); each component (core, engine, runtime,
# cinematics) carries its own version that bumps only when its source tree
# changed. The install manifest stamps each separately so the external
# installer can render per-component diffs and the digest skip can short-
# circuit unchanged components on update.
$versionsFile = Join-Path $repoRoot 'versions.json'
if (-not (Test-Path $versionsFile)) { throw "versions.json missing at $versionsFile" }
$versions    = Get-Content -LiteralPath $versionsFile -Raw | ConvertFrom-Json
$modVersion  = $versions.mod
$coreVersion       = $versions.components.core
$engineVersion     = $versions.components.engine
$runtimeVersion    = $versions.components.runtime
$cinematicsVersion = $versions.components.cinematics

# Set in the driver after Resolve-CivVInstallDir, before any function uses them.
$dlcBackupDir    = $null
$engineBackup    = $null
$cinematicBackup = $null

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

# Generated Lua module that exposes the mod version to the in-game Boot
# announcement (Text.format key TXT_KEY_CIVVACCESS_BOOT_INGAME). Written here
# rather than committed under src/dlc/ so versions.json stays the single
# source of truth -- bumping the mod version in versions.json is the only
# thing the spoken version reflects. package-release.ps1 writes the same
# file into the staged core-blind tree before zipping.
function Write-VersionLua {
    param([string]$DlcRoot)
    $dst = Join-Path $DlcRoot 'UI\InGame\CivVAccess_Version.lua'
    $body = @"
-- Generated by deploy.ps1 / package-release.ps1 from versions.json. Do not
-- edit by hand; edits will be overwritten on the next deploy or package run.
civvaccess_shared = civvaccess_shared or {}
civvaccess_shared.version = "$modVersion"
"@
    Set-Content -LiteralPath $dst -Value $body -Encoding UTF8
}

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

    Write-VersionLua -DlcRoot $dlcDir

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

function Write-InstallManifest {
    param(
        [string]$Game,
        [ValidateSet('blind','sighted')]
        [string]$Profile
    )

    $dlcDir = Join-Path $Game "Assets\DLC\$dlcName"
    $manifestPath = Join-Path $dlcDir $installManifestName

    $backupDirRel = "Assets/DLC/$dlcBackupDirName"

    if ($Profile -eq 'blind') {
        $components = [ordered]@{
            core       = [ordered]@{ version = $coreVersion }
            engine     = [ordered]@{ version = $engineVersion }
            runtime    = [ordered]@{ version = $runtimeVersion }
            cinematics = [ordered]@{ version = $cinematicsVersion }
        }
        $backups = [ordered]@{
            engine_dll = "$backupDirRel/CvGameCore_Expansion2.vanilla.dll"
            cinematics = "$backupDirRel/cinematics"
            lua51      = 'lua51_original.dll'
        }
    } else {
        $components = [ordered]@{
            engine = [ordered]@{ version = $engineVersion }
        }
        $backups = [ordered]@{
            engine_dll = "$backupDirRel/CvGameCore_Expansion2.vanilla.dll"
        }
    }

    $manifest = [ordered]@{
        schema_version = 1
        mod_version    = $modVersion
        profile        = $Profile
        installed_at   = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        components     = $components
        backups        = $backups
    }

    $json = $manifest | ConvertTo-Json -Depth 5
    Set-Content -LiteralPath $manifestPath -Value $json -Encoding UTF8
    Write-Host "Wrote install manifest:"
    Write-Host "  $manifestPath"
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

    # Backup dir is now empty of useful state; remove it so the game install
    # is back to vanilla layout.
    if (Test-Path $dlcBackupDir) {
        Write-Host "  Removing backup dir: $dlcBackupDir"
        Remove-Item -LiteralPath $dlcBackupDir -Recurse -Force
    }

    # Engine re-enumerates DLC at startup from this cache. Without clearing
    # it, the engine may keep DLC_CivVAccess as a known-but-missing entry
    # until the next forced refresh.
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
$dlcBackupDir    = Join-Path $gameDir "Assets\DLC\$dlcBackupDirName"
$engineBackup    = Join-Path $dlcBackupDir 'CvGameCore_Expansion2.vanilla.dll'
$cinematicBackup = Join-Path $dlcBackupDir 'cinematics'

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

# Manifest is written last so it always reflects a complete deploy. Skipping
# components for fast iteration is a maintainer workflow; the manifest still
# claims the full mod_version for every component since the rest of the
# install is up to date with what's in src/.
if (-not $SkipDlc) {
    Write-InstallManifest -Game $gameDir -Profile 'blind'
}

Write-Host ""
Write-Host "Deploy complete."
Write-Host "  Game dir: $gameDir"
Write-Host "  Version : $modVersion"
Write-Host ""
Write-Host "Reminder: for Lua.log output, set LoggingEnabled=1 in:"
Write-Host "  $env:USERPROFILE\Documents\My Games\Sid Meier's Civilization 5\config.ini"
