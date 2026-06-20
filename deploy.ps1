<#
.SYNOPSIS
    Deploy (or uninstall) one of the Civ-V-Access install states. One script
    drives every state and both functional profiles, argument-selected.

.DESCRIPTION
    An install is in exactly one mutually-exclusive state at a time; this script
    flips from any prior state into the one -State / -Profile select, and the
    centralized flip-cleanup that runs first guarantees the states never bleed
    into each other (a stale package from another state silently loading is, for
    a blind player, silent wrong numbers).

    States (-State):
      - vanilla : plain BNW plus the accessibility layer. Our fork engine DLL
                  goes into Assets/DLC/Expansion2 (vanilla DLL backed up); the VP
                  substrate is torn down so the session is genuinely vanilla.
      - vp      : the Vox Populi modpack. The baked modpack package (build/
                  modpack-out) is placed at Assets/DLC/ZCivVAccessVP, embedding
                  the Community-Patch-DLL fork (so no Expansion2 DLL swap); the
                  plain-VP substrate is completed from the clone / build/vp-runtime.
      - cp      : the Community-Patch-only modpack (no Vox Populi balance). Like
                  vp but build/modpack-cp-out -> Assets/DLC/ZCivVAccessCP, the cp
                  vendor stage, and the VP substrate removed (CP uses stock BNW).
      - lekmod  : LekMod (prebaked DLC overlay). LekMod's DLC is installed from
                  -LekModClone with our fork DLL swapped in (GUID kept); our DLC
                  overlays it at priority 350.

    Profiles (-Profile):
      - blind  : the full accessibility install -- proxy + Tolk runtime, the UI
                 payload, and the audio-described cinematics, on top of the
                 state's engine / package / substrate.
      - sighted: the multiplayer-compatibility minimum for a sighted partner --
                 the state's MP-hash-relevant pieces (engine DLL, modpack package,
                 LekMod DLC with our fork, VP substrate) plus the fake-DLC manifest with
                 empty UI dirs, and nothing local-only (no proxy/Tolk, no
                 cinematics, no accessibility UI code). A partner's footprint is
                 the host's minus the local-only accessibility runtime.

    The install manifest (CivVAccess.install.json in the deployed DLC dir) records
    profile + variant + per-component versions + backup locations; the external
    installer reads it to drive updates and teardown.

    -Uninstall reverses whatever state the prior manifest records (falling back to
    -State / -Profile when no manifest is present): restores the proxy, removes
    our DLC / the packages / the LekMod DLC as appropriate, and restores backed-up
    engine DLLs and cinematics.

.PARAMETER State
    Which install state to deploy. Default vanilla.

.PARAMETER Profile
    blind (full accessibility install) or sighted (MP-partner minimum). Default
    blind.

.PARAMETER GameDir
    Override the auto-detected Civ V install path.

.PARAMETER ClonePath
    Community-Patch-DLL clone, used to complete a partial plain-VP install for
    the vp state. Defaults to the sibling directory next to this repo. Ignored
    for any asset already staged under build/vp-runtime.

.PARAMETER LekModClone
    LekMod clone supplying the prebaked DLC for the lekmod state (both profiles
    install it). Defaults to the sibling directory next to this repo
    (~/Documents/Lekmod).

.PARAMETER SkipProxy
    Skip the proxy stack and the legacy lua51 rename (blind only).

.PARAMETER SkipDlc
    Skip the DLC payload copy and the install-manifest write.

.PARAMETER SkipCinematics
    Skip the audio-described BNW opening cinematics (blind only).

.PARAMETER Uninstall
    Reverse the installed state.
#>
[CmdletBinding()]
param(
    [ValidateSet('vanilla', 'vp', 'cp', 'lekmod')]
    [string]$State = 'vanilla',
    [ValidateSet('blind', 'sighted')]
    [string]$Profile = 'blind',
    [string]$GameDir,
    [string]$ClonePath,
    [string]$LekModClone,
    [switch]$SkipProxy,
    [switch]$SkipDlc,
    [switch]$SkipCinematics,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

$repoRoot         = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $repoRoot 'tools\dlc-assembly.ps1')

$proxyDistDir       = Join-Path $repoRoot 'dist\proxy'
$engineDistDir      = Join-Path $repoRoot 'dist\engine'
$engineLekmodDist   = Join-Path $repoRoot 'dist\engine-lekmod'
$tolkDistDir        = Join-Path $repoRoot 'third_party\tolk\dist\x86'
$cinematicSrcDir    = Join-Path $repoRoot 'audio described intros'
$dlcSrcDir          = Join-Path $repoRoot 'src\dlc'
$soundsSrcDir       = Join-Path $repoRoot 'sounds'
# CP and VP share one EngineData seam body: it feature-detects BALANCE_VP at
# runtime, so the VP body is numerically correct under Community Patch too.
$vpSeamSrcFile      = Join-Path $repoRoot 'src\vp\CivVAccess_EngineData.lua'
$lekmodSeamSrcFile  = Join-Path $repoRoot 'src\lekmod\CivVAccess_EngineData.lua'
$vpRuntimeDir       = Join-Path $repoRoot 'build\vp-runtime'   # pre-staged VP-completion assets, no clone needed

$dlcName            = 'DLC_CivVAccess'
$lekmodDlcName      = 'LEKMOD'                              # our deployed LekMod DLC folder (fixed name)
$modpackNames       = @('ZCivVAccessVP', 'ZCivVAccessCP')  # both modpack packages; removed by the flip-cleanup
$dlcBackupDirName   = "$dlcName.backup"
$installManifestName = 'CivVAccess.install.json'
$manifestFile       = 'CivVAccess_2.Civ5Pkg'               # the functional fake-DLC manifest (sighted ships just this)
$legacyDlcDirs      = @('CivVAccess')
$legacyModDir       = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5\MODS\Civ-V-Access (v 1)"
$ourDlcPriority     = 350                                  # beats the modpack / LekMod packages' 300
$engineDllName      = 'CvGameCore_Expansion2.dll'

if ([string]::IsNullOrWhiteSpace($ClonePath)) {
    $ClonePath = Join-Path (Split-Path -Parent $repoRoot) 'Community-Patch-DLL'
}
if ([string]::IsNullOrWhiteSpace($LekModClone)) {
    $LekModClone = Join-Path (Split-Path -Parent $repoRoot) 'Lekmod'
}

$civ5DocsDir = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5"

$versionsFile = Join-Path $repoRoot 'versions.json'
if (-not (Test-Path $versionsFile)) { throw "versions.json missing at $versionsFile" }
$versions            = Get-Content -LiteralPath $versionsFile -Raw | ConvertFrom-Json
$modVersion          = $versions.mod
$coreVersion         = $versions.components.core
$engineVersion       = $versions.components.engine
$runtimeVersion      = $versions.components.runtime
$cinematicsVersion   = $versions.components.cinematics

# Per-state engine arg / vendor stage / baked package / DLC folder. Computed once.
$modpackEngineArg = $null
$vendorStageDir   = $null
$modpackBuildDir  = $null
$modpackPkgName   = $null
$engineLabel      = $null
switch ($State) {
    'vp' {
        $modpackEngineArg = 'vp'
        $vendorStageDir   = Join-Path $repoRoot 'build\vendor\vp'
        $modpackBuildDir  = Join-Path $repoRoot 'build\modpack-out'
        $modpackPkgName   = 'ZCivVAccessVP'
        $engineLabel      = 'Vox Populi'
    }
    'cp' {
        $modpackEngineArg = 'cp'
        $vendorStageDir   = Join-Path $repoRoot 'build\vendor\cp'
        $modpackBuildDir  = Join-Path $repoRoot 'build\modpack-cp-out'
        $modpackPkgName   = 'ZCivVAccessCP'
        $engineLabel      = 'Community Patch'
    }
    'lekmod' {
        $vendorStageDir   = Join-Path $repoRoot 'build\vendor\lekmod'
        $engineLabel      = 'LekMod'
    }
}

# Set in the driver after Resolve-CivVInstallDir, before any function uses them.
$dlcBackupDir       = $null
$engineBackup       = $null
$cinematicBackup    = $null
$expansionPkgBackup = $null

# BNW opening cinematic filenames the engine expects under Assets/DLC/Expansion2/.
# Only en_US is a full .wmv video; non-English locales are .wma audio dubs the
# engine layers over the en_US.wmv visual track.
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

# Empty directories created under the sighted DLC so the manifest's
# <UISkin>/<Skin>/<GameplaySkin> directives resolve without dragging in mod code.
$dlcUiDirs = @('UI\FrontEnd', 'UI\Shared', 'UI\InGame', 'UI\TechTree')

# ---------------------------------------------------------------------------
# Shared deploy pieces (proxy / cinematics / cache). The install-dir resolver
# and the VP-substrate helpers live in tools\dlc-assembly.ps1.
# ---------------------------------------------------------------------------

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
        Copy-Item -LiteralPath (Join-Path $proxyDistDir $f) -Destination (Join-Path $Game $f) -Force
        Write-Host "  $(Join-Path $Game $f)"
    }
    foreach ($f in $tolkFiles) {
        Copy-Item -LiteralPath (Join-Path $tolkDistDir $f) -Destination (Join-Path $Game $f) -Force
        Write-Host "  $(Join-Path $Game $f)"
    }
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

    # First-run backup: copy each stock cinematic only if no backup exists yet.
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

function Clear-DlcCache {
    # The engine re-enumerates the DLC list at startup from this cache; clear it
    # so a newly-added / renamed / removed DLC takes immediately.
    $cacheDir = Join-Path $civ5DocsDir 'cache'
    if (Test-Path $cacheDir) {
        Write-Host "Clearing DLC cache:"
        Write-Host "  $cacheDir"
        Get-ChildItem -LiteralPath $cacheDir -File | Remove-Item -Force
    }
}

# The single flip-cleanup every install runs first: remove both modpack packages,
# the LekMod DLC (unless we are installing LekMod, whose own branch manages it),
# and the legacy directories. This is where the "exclusive states" guarantee
# lives. The VP substrate is state-specific (vp keeps it, the rest tear it down),
# so it is handled per state, not here.
function Invoke-FlipCleanup {
    param([string]$Game, [string]$ForState)

    $dlcRoot = Join-Path $Game 'Assets\DLC'

    foreach ($name in $modpackNames) {
        $d = Join-Path $dlcRoot $name
        if (Test-Path $d) {
            Write-Host "Removing modpack package:"
            Write-Host "  $d"
            Remove-Item -LiteralPath $d -Recurse -Force
        }
    }

    if ($ForState -ne 'lekmod') {
        Get-ChildItem -LiteralPath $dlcRoot -Directory -Filter 'LEKMOD*' -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "Removing LekMod DLC:"
            Write-Host "  $($_.FullName)"
            Remove-Item -LiteralPath $_.FullName -Recurse -Force
        }
    }

    if (Test-Path $legacyModDir) {
        Write-Host "Removing legacy mod directory:"
        Write-Host "  $legacyModDir"
        Remove-Item -LiteralPath $legacyModDir -Recurse -Force
    }
    $legacyBootstrap = Join-Path $Game 'CivVAccess'
    if (Test-Path $legacyBootstrap) {
        Write-Host "Removing legacy bootstrap directory:"
        Write-Host "  $legacyBootstrap"
        Remove-Item -LiteralPath $legacyBootstrap -Recurse -Force
    }
    foreach ($legacy in $legacyDlcDirs) {
        $p = Join-Path $dlcRoot $legacy
        if (Test-Path $p) {
            Write-Host "Removing legacy DLC directory:"
            Write-Host "  $p"
            Remove-Item -LiteralPath $p -Recurse -Force
        }
    }
}

# ---------------------------------------------------------------------------
# Engine / package / DLC placement, per state.
# ---------------------------------------------------------------------------

function Deploy-VanillaEngineDll {
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

# Flipping into a modpack / LekMod state: the active fork rides in the package
# (ZCivVAccess*) or the LEKMOD tree, and the base Assets/DLC/Expansion2 DLL must
# be Firaxis-stock -- so two installs that reached this state by different paths
# (clean vs flipped-from-vanilla, which left our fork there) are byte-identical,
# removing a path-dependent difference in a core always-on DLC. Restore stock
# from the backup a prior vanilla deploy captured; keep the backup for the next
# vanilla flip. No-op when no backup exists (Expansion2 was never swapped).
function Restore-StockExpansionDll {
    param([string]$Game)
    if (-not (Test-Path $engineBackup)) { return }
    $installedDll = Join-Path $Game "Assets\DLC\Expansion2\$engineDllName"
    Write-Host "Restoring stock Expansion2 engine DLL (the fork rides in the package):"
    Write-Host "  $engineBackup -> $installedDll"
    Copy-Item -LiteralPath $engineBackup -Destination $installedDll -Force
}

function Deploy-VanillaBlindDlc {
    param([string]$Game)

    $dlcDir = Join-Path $Game "Assets\DLC\$dlcName"
    Write-Host "Deploying DLC payload to:"
    Write-Host "  $dlcDir"
    # The vanilla blind payload is exactly the shared core build: src/dlc + the
    # version lua + the accessibility sounds, recreated from scratch.
    Copy-CivVAccessCoreDlc -DestDir $dlcDir -DlcSrcDir $dlcSrcDir -ModVersion $modVersion -SoundsSrcDir $soundsSrcDir
}

function Deploy-ModpackBlindDlc {
    param([string]$Game)

    $dlcDir = Join-Path $Game "Assets\DLC\$dlcName"
    Write-Host "Deploying DLC payload (modpack-shaped) to:"
    Write-Host "  $dlcDir"
    # Shared assembly: vendor overlay + seam + version lua + sounds + priority 350
    # + the net-new-context addin block (vp/cp). The VP seam body serves both.
    New-CivVAccessModdedDlc -DestDir $dlcDir -Engine $modpackEngineArg `
        -DlcSrcDir $dlcSrcDir -VendorStageDir $vendorStageDir -SeamFile $vpSeamSrcFile `
        -ModVersion $modVersion -SoundsSrcDir $soundsSrcDir -Priority $ourDlcPriority
    Write-Host "  Set our DLC priority to $ourDlcPriority"
    Write-Host "  Appended net-new-context addin loads to InGame.lua"
}

function Deploy-ModpackPackage {
    param([string]$Game)

    if (-not (Test-Path (Join-Path $modpackBuildDir 'MPModsPack.Civ5Pkg'))) {
        $buildFlag = if ($State -eq 'cp') { ' -CommunityPatchOnly' } else { '' }
        throw "Built modpack missing at $modpackBuildDir. Run build-modpack.ps1$buildFlag first."
    }
    # The flip-cleanup already removed both packages and any LekMod DLC; place the
    # active one. It embeds the fork DLL, so no Expansion2 DLL swap.
    $dst = Join-Path $Game "Assets\DLC\$modpackPkgName"
    Write-Host "Placing modpack package (embeds the fork DLL):"
    Write-Host "  $modpackBuildDir -> $dst"
    Copy-Item -LiteralPath $modpackBuildDir -Destination $dst -Recurse -Force
}

function Deploy-LekModDlc {
    param([string]$Game)

    $cloneLekMod = Join-Path $LekModClone 'LEKMOD'
    if (-not (Test-Path (Join-Path $cloneLekMod 'MPModsPack.Civ5Pkg'))) {
        throw "LekMod clone not found at $cloneLekMod (expected its LEKMOD/MPModsPack.Civ5Pkg). Pass -LekModClone."
    }
    if (-not (Test-Path $forkLekmodDll)) {
        throw "LekMod fork engine DLL missing: $forkLekmodDll. Run build-engine-lekmod.ps1 (or commit the built DLL)."
    }

    # Remove any prior LekMod DLC (ours or a user's) so the state is clean.
    Get-ChildItem -LiteralPath (Join-Path $Game 'Assets\DLC') -Directory -Filter 'LEKMOD*' -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  Removing existing LekMod DLC: $($_.FullName)"
        Remove-Item -LiteralPath $_.FullName -Recurse -Force
    }

    $dst = Join-Path $Game "Assets\DLC\$lekmodDlcName"
    Write-Host "Installing LekMod prebaked DLC:"
    Write-Host "  $cloneLekMod -> $dst"
    Copy-Item -LiteralPath $cloneLekMod -Destination $dst -Recurse -Force

    Resolve-CivVAccessLekModStandardUI -LekModDir $dst

    Write-Host "Replacing LekMod engine DLL with our fork:"
    Write-Host "  $forkLekmodDll -> $dst\$engineDllName"
    Copy-Item -LiteralPath $forkLekmodDll -Destination (Join-Path $dst $engineDllName) -Force
}

function Deploy-LekModBlindDlc {
    param([string]$Game)

    $dlcDir = Join-Path $Game "Assets\DLC\$dlcName"
    Write-Host "Deploying our DLC payload (LekMod-shaped) to:"
    Write-Host "  $dlcDir"
    # Shared assembly: LekMod vendor overlay + LekMod seam + version lua + sounds
    # + priority 350. No addin block -- LekMod loads its contexts via its own DLC.
    New-CivVAccessModdedDlc -DestDir $dlcDir -Engine 'lekmod' `
        -DlcSrcDir $dlcSrcDir -VendorStageDir $vendorStageDir -SeamFile $lekmodSeamSrcFile `
        -ModVersion $modVersion -SoundsSrcDir $soundsSrcDir -Priority $ourDlcPriority
    Write-Host "  Set our DLC priority to $ourDlcPriority"
}

# The sighted fake-DLC manifest: just CivVAccess_2.Civ5Pkg plus empty UI dirs so
# the manifest's UISkin directives resolve with no mod code shipped. Recreates
# the DLC dir from scratch.
function Deploy-EmptyUiManifest {
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

    foreach ($rel in $dlcUiDirs) {
        New-Item -ItemType Directory -Path (Join-Path $dlcDir $rel) -Force | Out-Null
    }
    Write-Host "  Created empty UISkin directories (no mod code shipped)."
}

# ---------------------------------------------------------------------------
# Install manifest. Shapes are installer-compatible and preserved per state /
# profile (InstallState.cs / Profile.cs read profile + variant; the backup
# filenames feed the installer's backup map and this script's own uninstall).
# ---------------------------------------------------------------------------

function Write-InstallManifest {
    param([string]$Game)

    $dlcDir = Join-Path $Game "Assets\DLC\$dlcName"
    $manifestPath = Join-Path $dlcDir $installManifestName
    $backupDirRel = "Assets/DLC/$dlcBackupDirName"

    $manifest = [ordered]@{
        schema_version = 1
        mod_version    = $modVersion
        profile        = $Profile
        installed_at   = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    }

    switch ($State) {
        'vanilla' {
            if ($Profile -eq 'blind') {
                $manifest.components = [ordered]@{
                    core       = [ordered]@{ version = $coreVersion }
                    engine     = [ordered]@{ version = $engineVersion }
                    runtime    = [ordered]@{ version = $runtimeVersion }
                    cinematics = [ordered]@{ version = $cinematicsVersion }
                }
                $manifest.backups = [ordered]@{
                    engine_dll = "$backupDirRel/CvGameCore_Expansion2.vanilla.dll"
                    cinematics = "$backupDirRel/cinematics"
                    lua51      = 'lua51_original.dll'
                }
            } else {
                $manifest.components = [ordered]@{
                    engine       = [ordered]@{ version = $engineVersion }
                    core_sighted = [ordered]@{ version = $coreVersion }
                }
                $manifest.backups = [ordered]@{
                    engine_dll = "$backupDirRel/CvGameCore_Expansion2.vanilla.dll"
                }
            }
        }
        { $_ -eq 'vp' -or $_ -eq 'cp' } {
            $manifest.variant = if ($State -eq 'cp') { 'modpack-cp' } else { 'modpack' }
            $manifest.modpack = "Assets/DLC/$modpackPkgName"
        }
        'lekmod' {
            # Both profiles install LekMod's DLC fresh (fork embedded), so there
            # is no pre-existing DLL to back up; the footprint is the LEKMOD tree
            # plus our DLC, matching the installer's LekMod component set.
            $manifest.variant = 'lekmod'
            $manifest.lekmod_dlc = "Assets/DLC/$lekmodDlcName"
        }
    }

    Set-Content -LiteralPath $manifestPath -Value ($manifest | ConvertTo-Json -Depth 5) -Encoding UTF8
    Write-Host "Wrote install manifest:"
    Write-Host "  $manifestPath"
}

# ---------------------------------------------------------------------------
# Uninstall. Reverses whatever state/profile $UninstallState / $UninstallProfile
# resolve to (from the prior manifest, falling back to the -State / -Profile
# args). Modular so each state restores exactly what it laid down.
# ---------------------------------------------------------------------------

function Restore-Proxy {
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
    foreach ($f in $tolkFiles) {
        $p = Join-Path $Game $f
        if (Test-Path $p) {
            Write-Host "  Removing $p"
            Remove-Item -LiteralPath $p -Force
        }
    }
    $proxyLog = Join-Path $Game 'proxy_debug.log'
    if (Test-Path $proxyLog) { Remove-Item -LiteralPath $proxyLog -Force }
}

function Remove-OurDlc {
    param([string]$Game)
    $d = Join-Path $Game "Assets\DLC\$dlcName"
    if (Test-Path $d) {
        Write-Host "  Removing DLC: $d"
        Remove-Item -LiteralPath $d -Recurse -Force
    }
}

function Remove-ModpackPackages {
    param([string]$Game)
    foreach ($name in $modpackNames) {
        $d = Join-Path $Game "Assets\DLC\$name"
        if (Test-Path $d) {
            Write-Host "  Removing modpack package: $d"
            Remove-Item -LiteralPath $d -Recurse -Force
        }
    }
}

function Restore-Cinematics {
    param([string]$Game)
    if (Test-Path $cinematicBackup) {
        $expansion2Dir = Join-Path $Game 'Assets\DLC\Expansion2'
        foreach ($f in $cinematicFiles) {
            $backup = Join-Path $cinematicBackup $f
            if (Test-Path $backup) {
                Write-Host "  Restoring vanilla cinematic: $f"
                Copy-Item -LiteralPath $backup -Destination (Join-Path $expansion2Dir $f) -Force
            }
        }
        Remove-Item -LiteralPath $cinematicBackup -Recurse -Force
    } else {
        Write-Host "  No cinematics backup present; skipping cinematics restore."
    }
}

function Remove-EmptyBackupDir {
    if ((Test-Path $dlcBackupDir) -and ((Get-ChildItem -LiteralPath $dlcBackupDir -Recurse -File | Measure-Object).Count -eq 0)) {
        Write-Host "  Removing empty backup dir: $dlcBackupDir"
        Remove-Item -LiteralPath $dlcBackupDir -Recurse -Force
    }
}

function Invoke-Uninstall {
    param([string]$Game, [string]$ForState, [string]$ForProfile)

    if ($ForState -eq 'lekmod') {
        # Both profiles installed the LekMod DLC fresh (we own the LEKMOD tree),
        # so teardown removes it; there is no partner DLL to restore. blind also
        # had the proxy and cinematics.
        if ($ForProfile -eq 'blind') { Restore-Proxy -Game $Game }
        Remove-OurDlc -Game $Game
        Get-ChildItem -LiteralPath (Join-Path $Game 'Assets\DLC') -Directory -Filter 'LEKMOD*' -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "  Removing LekMod DLC: $($_.FullName)"
            Remove-Item -LiteralPath $_.FullName -Recurse -Force
        }
        if ($ForProfile -eq 'blind') { Restore-Cinematics -Game $Game }
        Remove-EmptyBackupDir
        Clear-DlcCache
        return
    }

    if ($ForProfile -eq 'sighted') {
        # vanilla / vp / cp sighted partner: only our DLC and the state's package.
        Remove-OurDlc -Game $Game
        if ($ForState -eq 'vanilla') {
            if (Test-Path $engineBackup) {
                $installedDll = Join-Path $Game "Assets\DLC\Expansion2\$engineDllName"
                Write-Host "  Restoring vanilla engine DLL from backup:"
                Write-Host "    $engineBackup -> $installedDll"
                Copy-Item -LiteralPath $engineBackup -Destination $installedDll -Force
                Remove-Item -LiteralPath $engineBackup -Force
            } else {
                Write-Host "  No engine DLL backup present; skipping engine restore."
            }
        } else {
            Remove-ModpackPackages -Game $Game
        }
        Remove-EmptyBackupDir
        Clear-DlcCache
        return
    }

    # ---- blind uninstalls ----
    Restore-Proxy -Game $Game
    Remove-OurDlc -Game $Game
    Remove-ModpackPackages -Game $Game
    foreach ($legacy in $legacyDlcDirs) {
        $p = Join-Path $Game "Assets\DLC\$legacy"
        if (Test-Path $p) { Write-Host "  Removing legacy DLC: $p"; Remove-Item -LiteralPath $p -Recurse -Force }
    }
    Get-ChildItem -LiteralPath (Join-Path $Game 'Assets\DLC') -Directory -Filter 'LEKMOD*' -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  Removing LekMod DLC: $($_.FullName)"
        Remove-Item -LiteralPath $_.FullName -Recurse -Force
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

    # Restore the vanilla engine DLL if a vanilla deploy ever swapped it. The
    # modpack states never swap Assets/DLC/Expansion2 (their fork is embedded in
    # the package), so a backup here is from a prior vanilla deploy; restoring it
    # is correct on the way out either way.
    if (Test-Path $engineBackup) {
        $installedDll = Join-Path $Game "Assets\DLC\Expansion2\$engineDllName"
        Write-Host "  Restoring vanilla engine DLL from backup:"
        Write-Host "    $engineBackup -> $installedDll"
        Copy-Item -LiteralPath $engineBackup -Destination $installedDll -Force
        Remove-Item -LiteralPath $engineBackup -Force
    } else {
        Write-Host "  No engine DLL backup present; skipping engine restore."
    }

    Restore-Cinematics -Game $Game

    # Remove only consumed backups; the VP substrate's Expansion2.Civ5Pkg.stock
    # (if present) stays with the substrate, so the dir goes only when empty.
    Remove-EmptyBackupDir
    Clear-DlcCache
}

# ---- Driver ----
Write-Host "Locating Civilization V install..."
$gameDir = Resolve-CivVInstallDir -ExplicitPath $GameDir
Write-Host "  Game dir: $gameDir"

# Backup paths derived from gameDir; the dot-sourced helpers read these by name.
$dlcBackupDir       = Join-Path $gameDir "Assets\DLC\$dlcBackupDirName"
$engineBackup       = Join-Path $dlcBackupDir 'CvGameCore_Expansion2.vanilla.dll'
$cinematicBackup    = Join-Path $dlcBackupDir 'cinematics'
$expansionPkgBackup = Join-Path $dlcBackupDir 'Expansion2.Civ5Pkg.stock'
$forkLekmodDll      = Join-Path $engineLekmodDist $engineDllName

# Prior state from the install manifest, for uninstall dispatch and flip notes.
$priorManifestPath = Join-Path $gameDir "Assets\DLC\$dlcName\$installManifestName"
$priorVariant = $null
$priorProfile = $null
if (Test-Path $priorManifestPath) {
    try {
        $prior = Get-Content -LiteralPath $priorManifestPath -Raw | ConvertFrom-Json
        $priorVariant = $prior.variant
        $priorProfile = $prior.profile
    } catch { }
}
$priorState = switch ("$priorVariant") {
    'modpack'    { 'vp' }
    'modpack-cp' { 'cp' }
    'vp'         { 'vp' }     # the retired mod-overlay variant, mapped best-effort
    'lekmod'     { 'lekmod' }
    default      { 'vanilla' }
}

if ($Uninstall) {
    # Prefer the recorded state/profile; fall back to the passed args.
    $uState   = if ($null -ne $priorVariant) { $priorState } else { $State }
    $uProfile = if ($priorProfile) { $priorProfile } else { $Profile }
    Write-Host "Uninstalling state '$uState' (profile '$uProfile')..."
    Invoke-Uninstall -Game $gameDir -ForState $uState -ForProfile $uProfile
    Write-Host ""
    Write-Host "Uninstall complete."
    if ($uState -eq 'vp' -or $uState -eq 'cp') {
        Write-Host "The plain-VP substrate (VPUI, the swapped Expansion2.Civ5Pkg, sounds)"
        Write-Host "remains; it is a working plain-VP install, not ours to remove."
    }
    return
}

# ---- Install ----
Invoke-FlipCleanup -Game $gameDir -ForState $State

# Non-vanilla states run the fork from their package / LEKMOD tree, so the base
# Expansion2 DLL is normalized back to Firaxis-stock (vanilla swaps its own fork
# in below). Matches the installer's same normalization on a flip.
if ($State -ne 'vanilla') { Restore-StockExpansionDll -Game $gameDir }

switch ($State) {
    'vanilla' {
        Deploy-VanillaEngineDll -Game $gameDir
        Backup-StockExpansionPkg -Game $gameDir
        Remove-VpSubstrate -Game $gameDir
        if ($Profile -eq 'blind') {
            if (-not $SkipProxy) { Deploy-ProxyStack -Game $gameDir } else { Write-Host "Skipping proxy stack (-SkipProxy)." }
            if (-not $SkipDlc)   { Deploy-VanillaBlindDlc -Game $gameDir } else { Write-Host "Skipping DLC payload (-SkipDlc)." }
            if (-not $SkipCinematics) { Deploy-Cinematics -Game $gameDir } else { Write-Host "Skipping cinematics (-SkipCinematics)." }
        } else {
            if (-not $SkipDlc) { Deploy-EmptyUiManifest -Game $gameDir } else { Write-Host "Skipping DLC manifest (-SkipDlc)." }
        }
    }
    { $_ -eq 'vp' -or $_ -eq 'cp' } {
        if ($State -eq 'vp') { Complete-VPInstall -Game $gameDir } else { Remove-VpSubstrate -Game $gameDir }
        Deploy-ModpackPackage -Game $gameDir
        if ($Profile -eq 'blind') {
            if (-not $SkipProxy) { Deploy-ProxyStack -Game $gameDir } else { Write-Host "Skipping proxy stack (-SkipProxy)." }
            if (-not $SkipDlc)   { Deploy-ModpackBlindDlc -Game $gameDir } else { Write-Host "Skipping DLC payload (-SkipDlc)." }
            if (-not $SkipCinematics) { Deploy-Cinematics -Game $gameDir } else { Write-Host "Skipping cinematics (-SkipCinematics)." }
        } else {
            if (-not $SkipDlc) { Deploy-EmptyUiManifest -Game $gameDir } else { Write-Host "Skipping DLC manifest (-SkipDlc)." }
        }
    }
    'lekmod' {
        # Both profiles install LekMod's prebaked DLC from the clone with our fork
        # swapped in (the MP-hash-relevant piece); they differ only in the
        # accessibility payload and the local-only runtime.
        Deploy-LekModDlc -Game $gameDir
        if ($Profile -eq 'blind') {
            if (-not $SkipProxy) { Deploy-ProxyStack -Game $gameDir } else { Write-Host "Skipping proxy stack (-SkipProxy)." }
            if (-not $SkipDlc) { Deploy-LekModBlindDlc -Game $gameDir } else { Write-Host "Skipping DLC payload (-SkipDlc)." }
            if (-not $SkipCinematics) { Deploy-Cinematics -Game $gameDir } else { Write-Host "Skipping cinematics (-SkipCinematics)." }
        } else {
            if (-not $SkipDlc) { Deploy-EmptyUiManifest -Game $gameDir } else { Write-Host "Skipping DLC manifest (-SkipDlc)." }
        }
    }
}

Clear-DlcCache

if (-not $SkipDlc) {
    Write-InstallManifest -Game $gameDir
}

Write-Host ""
$stateLabel = if ($State -eq 'vanilla') { 'vanilla' } else { $engineLabel }
Write-Host "Deploy complete: $stateLabel ($Profile)."
Write-Host "  Game dir: $gameDir"
Write-Host "  Version : $modVersion"

if ($State -eq 'vanilla' -and ($priorState -eq 'vp' -or $priorState -eq 'cp' -or $priorState -eq 'lekmod')) {
    Write-Host ""
    Write-Host "Flipped from '$priorState' state to vanilla. The mod-state packages have"
    Write-Host "been removed; this is a clean vanilla state. (The VP substrate, if any,"
    Write-Host "stays -- it is a working plain-VP install and inert in vanilla sessions.)"
}

if ($State -ne 'vanilla') {
    Write-Host ""
    Write-Host "This install state is exclusive with the other states. Launch from the"
    Write-Host "regular menus (do NOT enable any mods). ./deploy.ps1 flips back to vanilla."
}

if ($Profile -eq 'blind') {
    Write-Host ""
    Write-Host "Reminder: for Lua.log output, set LoggingEnabled=1 in:"
    Write-Host "  $civ5DocsDir\config.ini"
}
