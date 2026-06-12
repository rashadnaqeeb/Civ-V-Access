<#
.SYNOPSIS
    Deploy the Civ-V-Access stack onto a Vox Populi install: proxy + Tolk,
    the DLC payload with the VP vendor overrides overlaid, the VP
    EngineData seam, and the Community-Patch-DLL fork.

.DESCRIPTION
    The VP variant of deploy.ps1. Same proxy stack, sounds, cinematics, and
    DLC deployment, with three VP-specific differences:

      - Vendor overlay: after the src/dlc payload lands, the staged VP
        overrides from build/vendor/vp/UI are copied on top, replacing the
        vanilla-derived vendor copies with the ones re-sourced from VP /
        Community Patch / VPUI. Run
          py tools/vendoring/vendor.py generate --engine vp
        first; the script refuses to deploy a stale or missing stage.

      - EngineData swap: src/vp/CivVAccess_EngineData.lua replaces the
        vanilla seam implementation in the deployed DLC. Both files share
        the include stem, so call sites never know which engine they run on.

      - Engine DLL: dist/engine-vp/CvGameCore_Expansion2.dll (our civvaccess
        branch of LoneGazebo/Community-Patch-DLL) is placed where VP loads
        its DLL from: MODS\(1) Community Patch\ in the user's Documents.
        VP's shipped DLL is backed up on first install; -Uninstall restores
        it (VP's DLL, not Firaxis vanilla -- this script never touches the
        Assets\DLC\Expansion2 DLL that vanilla sessions load).

      - MODS overlay: mods beat DLC in the VFS, so for every override whose
        stem the (1) Community Patch or (2) Vox Populi mod itself ships
        (build/vendor/vp/provenance.json, written by the vendoring tool),
        the staged copy is also written into the mod's own folder --
        otherwise the mod's copy wins and the appended accessibility
        include never runs. No backups are taken: the pinned clone is the
        pristine source (the MODS folders are byte-identical to it by the
        re-pin contract), and the script refuses to overwrite a mod file
        that matches neither the clone copy nor our staged copy.
        -Uninstall restores the clone copies. The overlaid files are
        harmless to vanilla sessions (which never load mods), so flipping
        to vanilla with deploy.ps1 leaves them in place, like the fork DLL.

    If the game install is missing the non-MODS half of a plain-VP
    (FullNoEUI) install -- the VPUI fake DLC, the Vox Populi
    Expansion2.Civ5Pkg replacement, the minor-civ sound table, the loading
    screen tips -- the script completes it from the Community-Patch-DLL
    clone (-ClonePath). Each piece is checked separately and copied only
    when absent, so an install the VP installer already set up is left
    untouched. -Uninstall deliberately leaves these in place: they make the
    machine a working plain-VP install, which is not ours to remove.

.PARAMETER GameDir
    Override the auto-detected Civ V install path.

.PARAMETER ClonePath
    Path to the Community-Patch-DLL clone. Used to complete a partial VP
    install, as the pristine reference for the MODS overlay, and as the
    restore source on -Uninstall. Defaults to the sibling directory next
    to this repo.

.PARAMETER SkipProxy
    Skip the proxy stack and the legacy lua51 rename.

.PARAMETER SkipDlc
    Skip the DLC payload (and with it the vendor overlay, the EngineData
    swap, and the MODS overlay).

.PARAMETER SkipEngine
    Skip the fork DLL copy into MODS\(1) Community Patch.

.PARAMETER SkipCinematics
    Skip the audio-described BNW opening cinematics.

.PARAMETER Uninstall
    Remove the proxy stack, the DLC, and the cinematics (restoring stock
    files from backup), restore VP's shipped DLL into the MODS folder, and
    restore the MODS-overlaid vendor files from the clone. The VP install
    itself (VPUI, Civ5Pkg, sounds, tips) stays.
#>
[CmdletBinding()]
param(
    [string]$GameDir,
    [string]$ClonePath,
    [switch]$SkipProxy,
    [switch]$SkipDlc,
    [switch]$SkipEngine,
    [switch]$SkipCinematics,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

$repoRoot         = Split-Path -Parent $MyInvocation.MyCommand.Path
$proxyDistDir     = Join-Path $repoRoot 'dist\proxy'
$engineVpDistDir  = Join-Path $repoRoot 'dist\engine-vp'
$tolkDistDir      = Join-Path $repoRoot 'third_party\tolk\dist\x86'
$cinematicSrcDir  = Join-Path $repoRoot 'audio described intros'
$dlcSrcDir        = Join-Path $repoRoot 'src\dlc'
$vpSeamSrcFile    = Join-Path $repoRoot 'src\vp\CivVAccess_EngineData.lua'
$vendorStageDir   = Join-Path $repoRoot 'build\vendor\vp'
$soundsSrcDir     = Join-Path $repoRoot 'sounds'
$dlcName          = 'DLC_CivVAccess'
$dlcBackupDirName = "$dlcName.backup"  # sibling to DLC dir; holds stock-file backups so they survive the dir nuke on redeploy
$installManifestName = 'CivVAccess.install.json'

if ([string]::IsNullOrWhiteSpace($ClonePath)) {
    $ClonePath = Join-Path (Split-Path -Parent $repoRoot) 'Community-Patch-DLL'
}

$civ5DocsDir = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5"
$vpModsDir    = Join-Path $civ5DocsDir 'MODS'
$vpModsDllDir = Join-Path $vpModsDir '(1) Community Patch'

$versionsFile = Join-Path $repoRoot 'versions.json'
if (-not (Test-Path $versionsFile)) { throw "versions.json missing at $versionsFile" }
$versions    = Get-Content -LiteralPath $versionsFile -Raw | ConvertFrom-Json
$modVersion  = $versions.mod
$coreVersion       = $versions.components.core
$engineVpVersion   = $versions.components.engine_vp
$runtimeVersion    = $versions.components.runtime
$cinematicsVersion = $versions.components.cinematics

# Set in the driver after Resolve-CivVInstallDir, before any function uses them.
$dlcBackupDir       = $null
$engineVpBackup     = $null
$cinematicBackup    = $null
$expansionPkgBackup = $null

# BNW opening cinematic filenames; see deploy.ps1 for the wmv/wma split.
$cinematicFiles = @(
    'Civ5XP2_Opening_Movie_en_US.wmv',
    'Civ5XP2_Opening_Movie_de_DE.wma',
    'Civ5XP2_Opening_Movie_es_ES.wma',
    'Civ5XP2_Opening_Movie_fr_FR.wma',
    'Civ5XP2_Opening_Movie_it_IT.wma',
    'Civ5XP2_Opening_Movie_pl_PL.wma',
    'Civ5XP2_Opening_Movie_ru_RU.wma'
)

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

# Generated version module; see deploy.ps1's Write-VersionLua for the BOM
# rationale.
function Write-VersionLua {
    param([string]$DlcRoot)
    $dst = Join-Path $DlcRoot 'UI\InGame\CivVAccess_Version.lua'
    $body = @"
-- Generated by deploy-vp.ps1 from versions.json. Do not edit by hand;
-- edits will be overwritten on the next deploy.
civvaccess_shared = civvaccess_shared or {}
civvaccess_shared.version = "$modVersion"
"@
    [System.IO.File]::WriteAllText($dst, $body, [System.Text.UTF8Encoding]::new($false))
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

# Completes a partial plain-VP install from the clone. The MODS folders are
# the user-visible half the VP installer (or a re-pin sync) manages; this
# covers the rest: the VPUI fake DLC, the Vox Populi Expansion2.Civ5Pkg (an
# added AudioGameData line over stock), the minor-civ sound table, and the
# loading-screen tips file. Each piece deploys only when absent.
function Complete-VPInstall {
    param([string]$Game)

    $pieces = @(
        @{ Name = 'VPUI fake DLC'
           Src  = Join-Path $ClonePath 'VPUI'
           Dst  = Join-Path $Game 'Assets\DLC\VPUI'
           Dir  = $true },
        @{ Name = 'minor-civ sound table'
           Src  = Join-Path $ClonePath 'MinorCivSounds_VoxPopuli.xml'
           Dst  = Join-Path $Game 'Assets\DLC\Expansion2\Sounds\XML\MinorCivSounds_VoxPopuli.xml'
           Dir  = $false },
        @{ Name = 'loading screen tips'
           Src  = Join-Path $ClonePath 'VPUI Text\VPUI_tips_en_us.xml'
           Dst  = Join-Path $civ5DocsDir 'Text\VPUI_tips_en_us.xml'
           Dir  = $false }
    )

    foreach ($piece in $pieces) {
        if (Test-Path $piece.Dst) { continue }
        if (-not (Test-Path $piece.Src)) {
            throw "VP install is missing the $($piece.Name) and the clone copy is absent: $($piece.Src). Pass -ClonePath or install Vox Populi with its own installer."
        }
        Write-Host "Completing VP install: $($piece.Name)"
        Write-Host "  $($piece.Src) -> $($piece.Dst)"
        $dstParent = Split-Path -Parent $piece.Dst
        if (-not (Test-Path $dstParent)) { New-Item -ItemType Directory -Path $dstParent -Force | Out-Null }
        if ($piece.Dir) {
            Copy-Item -LiteralPath $piece.Src -Destination $piece.Dst -Recurse -Force
        } else {
            Copy-Item -LiteralPath $piece.Src -Destination $piece.Dst -Force
        }
    }

    # The Expansion2.Civ5Pkg replacement needs a backup of the stock manifest
    # (it is overwritten in place, unlike the purely-additive pieces above).
    # Detect "already replaced" by the MinorCivSounds_VoxPopuli reference VP's
    # copy adds -- the stock manifest already has AudioGameData elements of
    # its own, so the element name alone doesn't discriminate.
    $pkgInstalled = Join-Path $Game 'Assets\DLC\Expansion2\Expansion2.Civ5Pkg'
    $pkgSrc = Join-Path $ClonePath 'Expansion2_VoxPopuli.Civ5Pkg'
    if (-not (Test-Path $pkgInstalled)) {
        throw "BNW package manifest not found at $pkgInstalled. The mod requires BNW; verify the game install."
    }
    $pkgIsVP = (Get-Content -LiteralPath $pkgInstalled -Raw) -match 'MinorCivSounds_VoxPopuli'
    if (-not $pkgIsVP) {
        if (-not (Test-Path $pkgSrc)) {
            throw "VP install is missing the Vox Populi Expansion2.Civ5Pkg and the clone copy is absent: $pkgSrc. Pass -ClonePath or install Vox Populi with its own installer."
        }
        if (-not (Test-Path $expansionPkgBackup)) {
            $backupDir = Split-Path -Parent $expansionPkgBackup
            if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }
            Write-Host "Backing up stock Expansion2.Civ5Pkg:"
            Write-Host "  $pkgInstalled -> $expansionPkgBackup"
            Copy-Item -LiteralPath $pkgInstalled -Destination $expansionPkgBackup -Force
        }
        Write-Host "Completing VP install: Vox Populi Expansion2.Civ5Pkg"
        Write-Host "  $pkgSrc -> $pkgInstalled"
        Copy-Item -LiteralPath $pkgSrc -Destination $pkgInstalled -Force
    }
}

function Deploy-ProxyStack {
    param([string]$Game)

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

    # The staged VP vendor tree is a build artifact (not committed); refuse
    # to deploy without it rather than silently shipping the vanilla-derived
    # vendor copies, which would revert VP's UI behavior in-game.
    $vendorUi = Join-Path $vendorStageDir 'UI'
    if (-not (Test-Path $vendorUi)) {
        throw "VP vendor stage missing: $vendorUi. Run: py tools/vendoring/vendor.py generate --engine vp"
    }
    if (-not (Test-Path $vpSeamSrcFile)) {
        throw "VP EngineData seam missing: $vpSeamSrcFile"
    }

    $dlcDir = Join-Path $Game "Assets\DLC\$dlcName"
    if (Test-Path $dlcDir) {
        Write-Host "  Removing existing DLC directory: $dlcDir"
        Remove-Item -LiteralPath $dlcDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $dlcDir -Force | Out-Null
    Write-Host "Deploying DLC payload to:"
    Write-Host "  $dlcDir"
    Copy-Item -Path (Join-Path $dlcSrcDir '*') -Destination $dlcDir -Recurse -Force

    # VP vendor overlay: the staged overrides re-sourced from VP / CP / VPUI
    # replace the vanilla-derived copies file for file.
    Write-Host "Overlaying VP vendor overrides from:"
    Write-Host "  $vendorUi"
    Copy-Item -Path (Join-Path $vendorUi '*') -Destination (Join-Path $dlcDir 'UI') -Recurse -Force

    # EngineData seam swap: the VP implementation ships under the same
    # include stem as the vanilla one it replaces.
    $seamDst = Join-Path $dlcDir 'UI\InGame\CivVAccess_EngineData.lua'
    Write-Host "Swapping in the VP EngineData seam:"
    Write-Host "  $vpSeamSrcFile -> $seamDst"
    Copy-Item -LiteralPath $vpSeamSrcFile -Destination $seamDst -Force

    Write-VersionLua -DlcRoot $dlcDir

    if (Test-Path $soundsSrcDir) {
        $soundsDst = Join-Path $dlcDir 'Sounds'
        New-Item -ItemType Directory -Path $soundsDst -Force | Out-Null
        Write-Host "Deploying sound assets to:"
        Write-Host "  $soundsDst"
        Copy-Item -Path (Join-Path $soundsSrcDir '*.wav') -Destination $soundsDst -Force
    }

    # Engine re-enumerates DLC list at startup from this cache.
    $cacheDir = Join-Path $civ5DocsDir 'cache'
    if (Test-Path $cacheDir) {
        Write-Host "Clearing DLC cache:"
        Write-Host "  $cacheDir"
        Get-ChildItem -LiteralPath $cacheDir -File | Remove-Item -Force
    }
}

function Test-SameFileBytes {
    param([string]$A, [string]$B)
    return (Get-FileHash -LiteralPath $A -Algorithm MD5).Hash -eq
           (Get-FileHash -LiteralPath $B -Algorithm MD5).Hash
}

# The staged overrides whose stem the (1) Community Patch or (2) Vox Populi
# mod itself ships, from the vendoring tool's provenance. These must also be
# overlaid into the mod folders: mods beat DLC in the VFS, so the DLC copy of
# a mod-shipped stem never loads and its accessibility include never runs.
function Get-ModOverlayEntries {
    $provenancePath = Join-Path $vendorStageDir 'provenance.json'
    if (-not (Test-Path $provenancePath)) {
        throw "Vendor provenance missing: $provenancePath. Run: py tools/vendoring/vendor.py generate --engine vp"
    }
    $prov = Get-Content -LiteralPath $provenancePath -Raw | ConvertFrom-Json
    $entries = @()
    foreach ($p in $prov.files.PSObject.Properties) {
        $modFolder = $prov.mod_roots.($p.Value.root)
        if ($modFolder) {
            $entries += [pscustomobject]@{
                Rel       = $p.Name
                ModFolder = $modFolder
                SrcRel    = $p.Value.src_rel
            }
        }
    }
    return $entries
}

function Deploy-ModOverlay {
    param($Entries)

    Write-Host "Overlaying mod-shipped vendor overrides into MODS ($($Entries.Count) files):"
    $copied = 0
    $current = 0
    foreach ($e in $Entries) {
        $staged   = Join-Path $vendorStageDir ('UI\' + ($e.Rel -replace '/', '\'))
        $target   = Join-Path $vpModsDir (Join-Path $e.ModFolder ($e.SrcRel -replace '/', '\'))
        $pristine = Join-Path $ClonePath (Join-Path $e.ModFolder ($e.SrcRel -replace '/', '\'))
        if (-not (Test-Path $staged)) {
            throw "Staged override missing: $staged. Re-run: py tools/vendoring/vendor.py generate --engine vp"
        }
        if (-not (Test-Path $target)) {
            throw "Mod file missing: $target. The MODS folders do not match the pinned clone; re-sync them (re-pin checklist)."
        }
        if (Test-SameFileBytes $target $staged) {
            $current++
            continue
        }
        # No backups: the pinned clone is the pristine source. Refuse to
        # touch a file that is neither VP-stock nor an older copy of ours,
        # rather than silently clobbering unknown local changes.
        if (-not (Test-Path $pristine)) {
            throw "Clone copy missing: $pristine. Pass -ClonePath pointing at the pinned Community-Patch-DLL clone."
        }
        if (-not (Test-SameFileBytes $target $pristine)) {
            # An older copy of ours is recognized by the appended accessibility
            # include (every staged override carries one; suffix-only entries
            # have no header comment, so the first line is vendor code).
            $targetContent = Get-Content -LiteralPath $target -Raw
            if ($targetContent -notmatch 'CivVAccess') {
                throw "Mod file is neither VP-stock nor ours: $target. The MODS folders have drifted from the pinned clone; re-sync them before deploying."
            }
        }
        Copy-Item -LiteralPath $staged -Destination $target -Force
        $copied++
    }
    Write-Host "  $copied file(s) overlaid, $current already current."
}

# Restores the clone's pristine copies over our overlaid mod files. The file
# list comes from the install manifest (captured before the DLC dir was
# removed) or, failing that, the staged provenance.
function Restore-ModOverlay {
    param($OverlayList)

    if (-not $OverlayList -or @($OverlayList).Count -eq 0) {
        Write-Host "  No MODS overlay recorded; skipping mod-file restore."
        return
    }
    $restored = 0
    $stock = 0
    $missing = @()
    foreach ($relPath in $OverlayList) {
        $target   = Join-Path $vpModsDir ($relPath -replace '/', '\')
        $pristine = Join-Path $ClonePath ($relPath -replace '/', '\')
        if (-not (Test-Path $target)) { continue }
        if (-not (Test-Path $pristine)) {
            $missing += $relPath
            continue
        }
        if (Test-SameFileBytes $target $pristine) {
            $stock++
            continue
        }
        Copy-Item -LiteralPath $pristine -Destination $target -Force
        $restored++
    }
    Write-Host "  Restored $restored mod file(s) from the clone ($stock already stock)."
    if ($missing.Count -gt 0) {
        Write-Warning ("Clone copies missing for {0} overlaid mod file(s); they keep the accessibility include (inert without the DLC, but re-sync MODS from the clone to fully clean): {1}" -f $missing.Count, ($missing -join ', '))
    }
}

function Deploy-EngineDll {
    param([string]$Game)

    $stagedDll = Join-Path $engineVpDistDir $engineDllName
    if (-not (Test-Path $stagedDll)) {
        throw "Built VP fork DLL missing: $stagedDll. Build it from the clone's civvaccess branch (build_vp_clang_sdk.py) and copy to dist/engine-vp/, or use the committed artifact."
    }

    # VP loads its DLL from the (1) Community Patch mod folder (that mod's
    # SetDllPath), not from Assets\DLC\Expansion2. If the folder is absent,
    # VP isn't installed -- the fork without VP's database is useless.
    $installedDll = Join-Path $vpModsDllDir $engineDllName
    if (-not (Test-Path $installedDll)) {
        throw "VP's engine DLL not found at $installedDll. Install Vox Populi first (the MODS folders are managed by VP's installer / the re-pin sync)."
    }

    # First-run backup of VP's shipped DLL. Never overwrites the backup.
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
    param([string]$Game, $ModOverlayEntries)

    $dlcDir = Join-Path $Game "Assets\DLC\$dlcName"
    $manifestPath = Join-Path $dlcDir $installManifestName

    $backupDirRel = "Assets/DLC/$dlcBackupDirName"

    $manifest = [ordered]@{
        schema_version = 1
        mod_version    = $modVersion
        profile        = 'blind'
        variant        = 'vp'
        installed_at   = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        components     = [ordered]@{
            core       = [ordered]@{ version = $coreVersion }
            engine_vp  = [ordered]@{ version = $engineVpVersion }
            runtime    = [ordered]@{ version = $runtimeVersion }
            cinematics = [ordered]@{ version = $cinematicsVersion }
        }
        backups        = [ordered]@{
            engine_dll_vp  = "$backupDirRel/CvGameCore_Expansion2.vp-stock.dll"
            expansion2_pkg = "$backupDirRel/Expansion2.Civ5Pkg.stock"
            cinematics     = "$backupDirRel/cinematics"
            lua51          = 'lua51_original.dll'
        }
        # Mod files we overlaid (MODS-relative). Restored from the pinned
        # clone on -Uninstall; left in place by deploy.ps1's vanilla flip.
        mods_overlay   = @($ModOverlayEntries | ForEach-Object { "$($_.ModFolder)/$($_.SrcRel)" })
    }

    $json = $manifest | ConvertTo-Json -Depth 5
    Set-Content -LiteralPath $manifestPath -Value $json -Encoding UTF8
    Write-Host "Wrote install manifest:"
    Write-Host "  $manifestPath"
}

function Invoke-Uninstall {
    param([string]$Game)

    # Capture the overlay list before the DLC dir (and the manifest in it)
    # is removed. Fall back to the staged provenance when absent.
    $overlayList = @()
    $manifestPath = Join-Path $Game "Assets\DLC\$dlcName\$installManifestName"
    if (Test-Path $manifestPath) {
        try {
            $m = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
            if ($m.mods_overlay) { $overlayList = @($m.mods_overlay) }
        } catch {
            Write-Warning "Could not read install manifest at ${manifestPath}: $_"
        }
    }
    if ($overlayList.Count -eq 0 -and (Test-Path (Join-Path $vendorStageDir 'provenance.json'))) {
        try {
            $overlayList = @(Get-ModOverlayEntries | ForEach-Object { "$($_.ModFolder)/$($_.SrcRel)" })
        } catch {
            Write-Warning "Could not enumerate mod overlay from provenance: $_"
        }
    }

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

    foreach ($f in $tolkFiles) {
        $p = Join-Path $Game $f
        if (Test-Path $p) {
            Write-Host "  Removing $p"
            Remove-Item -LiteralPath $p -Force
        }
    }

    $dlcDir = Join-Path $Game "Assets\DLC\$dlcName"
    if (Test-Path $dlcDir) {
        Write-Host "  Removing DLC: $dlcDir"
        Remove-Item -LiteralPath $dlcDir -Recurse -Force
    }

    $proxyLog = Join-Path $Game 'proxy_debug.log'
    if (Test-Path $proxyLog) {
        Remove-Item -LiteralPath $proxyLog -Force
    }

    # Restore VP's shipped DLL into the MODS folder. The backup is the
    # source of truth; missing backup means the fork was never deployed.
    if (Test-Path $engineVpBackup) {
        $installedDll = Join-Path $vpModsDllDir $engineDllName
        Write-Host "  Restoring VP's shipped engine DLL from backup:"
        Write-Host "    $engineVpBackup -> $installedDll"
        Copy-Item -LiteralPath $engineVpBackup -Destination $installedDll -Force
        Remove-Item -LiteralPath $engineVpBackup -Force
    } else {
        Write-Host "  No VP engine DLL backup present; skipping engine restore."
    }

    Restore-ModOverlay -OverlayList $overlayList

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
        Remove-Item -LiteralPath $cinematicBackup -Recurse -Force
    } else {
        Write-Host "  No cinematics backup present; skipping cinematics restore."
    }

    # The VP install completion (VPUI, Vox Populi Expansion2.Civ5Pkg, sound
    # table, tips) stays: it makes this machine a working plain-VP install,
    # which is not ours to remove. The Expansion2.Civ5Pkg.stock backup stays
    # with it so a later full VP removal can restore the stock manifest.

    # Remove the backup dir only when nothing else (e.g. the vanilla
    # deploy's engine backup, or the Civ5Pkg backup above) still lives in
    # it -- the two deploy scripts share the directory.
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
$dlcBackupDir       = Join-Path $gameDir "Assets\DLC\$dlcBackupDirName"
$engineVpBackup     = Join-Path $dlcBackupDir 'CvGameCore_Expansion2.vp-stock.dll'
$cinematicBackup    = Join-Path $dlcBackupDir 'cinematics'
$expansionPkgBackup = Join-Path $dlcBackupDir 'Expansion2.Civ5Pkg.stock'

if ($Uninstall) {
    Invoke-Uninstall -Game $gameDir
    Write-Host ""
    Write-Host "Uninstall complete. The plain-VP install (MODS, VPUI, Civ5Pkg) remains."
    return
}

Complete-VPInstall -Game $gameDir

if (-not $SkipProxy) {
    Deploy-ProxyStack -Game $gameDir
} else {
    Write-Host "Skipping proxy stack (-SkipProxy)."
}

$modOverlayEntries = @()
if (-not $SkipDlc) {
    Deploy-Dlc -Game $gameDir
    $modOverlayEntries = Get-ModOverlayEntries
    Deploy-ModOverlay -Entries $modOverlayEntries
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

if (-not $SkipDlc) {
    Write-InstallManifest -Game $gameDir -ModOverlayEntries $modOverlayEntries
}

Write-Host ""
Write-Host "VP deploy complete."
Write-Host "  Game dir: $gameDir"
Write-Host "  Version : $modVersion (VP variant)"
Write-Host ""
Write-Host "Start a game with the (1) Community Patch and (2) Vox Populi mods"
Write-Host "enabled. For Lua.log output, set LoggingEnabled=1 in:"
Write-Host "  $civ5DocsDir\config.ini"
