<#
.SYNOPSIS
    Package release artifacts for upload to a GitHub Release.

.DESCRIPTION
    Reads VERSION, stages each component into a temp tree, zips it, and
    writes the zips plus a SHA256SUMS file into dist/release/.

    Components produced:
      - core-blind-{ver}.zip      src/dlc/ + sounds/ as Sounds/. Extracts to
                                  Assets/DLC/DLC_CivVAccess/ on a blind install.
      - core-sighted-{ver}.zip    CivVAccess_2.Civ5Pkg + empty UI dirs.
                                  Extracts to Assets/DLC/DLC_CivVAccess/ on a
                                  sighted-MP install.
      - engine-{ver}.zip          CvGameCore_Expansion2.dll. Extracts to
                                  Assets/DLC/Expansion2/.
      - runtime-{ver}.zip         lua51_Win32.dll + Tolk DLLs. Extracts to the
                                  game root. Blind install only.
      - cinematics-{ver}.zip      Audio-described BNW intros. Extracts to
                                  Assets/DLC/Expansion2/. Blind install only.

    Components whose version field in versions.json is unchanged since the
    previous release are not repackaged - their .zip is downloaded byte-for-
    byte from the previous GitHub release and copied into dist/release/. The
    point is that GitHub's API digest stays identical, so the installer's
    per-component skip can fire reliably. Repackaging an "unchanged" component
    from source is a determinism gamble; fetching the prior bytes is not.

    GitHub computes its own digest on each uploaded asset (algorithm-prefixed
    sha256:... in the API), so the SHA256SUMS file is informational - useful
    for the maintainer to verify upload integrity locally.

    The script verifies all build artifacts exist before doing any work; if
    something's missing, it fails up front naming the file rather than half-
    producing a release.
#>
[CmdletBinding()]
param(
    # Build only these components (by zip prefix, e.g. -Only vp-overlay,vp-runtime).
    # Default builds all. Useful for iterating without re-zipping the large
    # modpack / LekMod components.
    [string[]]$Only,
    # LekMod clone supplying the prebaked LEKMOD tree for the lekmod-dlc
    # component. Defaults to the sibling directory, like deploy.ps1 -State lekmod.
    [string]$LekModClone,
    # Community-Patch-DLL clone supplying the VP-completion assets for the
    # vp-runtime component when build/vp-runtime is not already staged. Defaults
    # to the sibling directory, like deploy.ps1 -State vp.
    [string]$ClonePath
)

$ErrorActionPreference = 'Stop'

$repoRoot      = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $repoRoot 'tools\dlc-assembly.ps1')
$proxyDistDir  = Join-Path $repoRoot 'dist\proxy'
$engineDistDir = Join-Path $repoRoot 'dist\engine'
$tolkDistDir   = Join-Path $repoRoot 'third_party\tolk\dist\x86'
$dlcSrcDir     = Join-Path $repoRoot 'src\dlc'
$soundsSrcDir  = Join-Path $repoRoot 'sounds'
$cinematicSrc  = Join-Path $repoRoot 'audio described intros'

# Mod-state component sources (not committed; produced by the modpack bake
# (build-modpack.ps1 / build-modpack-cp.ps1) and the vendor tool
# (tools/vendoring/vendor.py generate)). The vp-runtime assets are staged from
# the Community-Patch-DLL clone on demand by Stage-VpRuntime below.
$vendorVpDir      = Join-Path $repoRoot 'build\vendor\vp'
$vendorCpDir      = Join-Path $repoRoot 'build\vendor\cp'
$vendorLekmodDir  = Join-Path $repoRoot 'build\vendor\lekmod'
$vpSeamFile       = Join-Path $repoRoot 'src\vp\CivVAccess_EngineData.lua'
$lekmodSeamFile   = Join-Path $repoRoot 'src\lekmod\CivVAccess_EngineData.lua'
$modpackVpDir     = Join-Path $repoRoot 'build\modpack-out'
$modpackCpDir     = Join-Path $repoRoot 'build\modpack-cp-out'
$vpRuntimeDir     = Join-Path $repoRoot 'build\vp-runtime'
$engineLekmodFork = Join-Path $repoRoot 'dist\engine-lekmod\CvGameCore_Expansion2.dll'

if ([string]::IsNullOrWhiteSpace($LekModClone)) {
    $LekModClone = Join-Path (Split-Path -Parent $repoRoot) 'Lekmod'
}
if ([string]::IsNullOrWhiteSpace($ClonePath)) {
    $ClonePath = Join-Path (Split-Path -Parent $repoRoot) 'Community-Patch-DLL'
}

$releaseDir  = Join-Path $repoRoot 'dist\release'
$stagingRoot = Join-Path $repoRoot 'build\release-staging'

$versionsFile = Join-Path $repoRoot 'versions.json'
if (-not (Test-Path $versionsFile)) { throw "versions.json missing at $versionsFile" }
$versions = Get-Content -LiteralPath $versionsFile -Raw | ConvertFrom-Json
$modVersion = $versions.mod

# Each component's zip is named with its own version, not the mod's. A
# release where engine didn't change since 1.0.0 ships engine-1.0.0.zip even
# when mod is 1.5.0 - identical bytes, identical digest, the installer's
# digest skip means the player doesn't redownload it. Maintainer is
# responsible for bumping the right component versions in versions.json
# before running this script (RELEASING.md has the bump rules).
$componentVersions = @{
    'core-blind'     = $versions.components.core
    'core-sighted'   = $versions.components.core
    'engine'         = $versions.components.engine
    'runtime'        = $versions.components.runtime
    'cinematics'     = $versions.components.cinematics
    'vp-overlay'     = $versions.components.vp_overlay
    'cp-overlay'     = $versions.components.cp_overlay
    'lekmod-overlay' = $versions.components.lekmod_overlay
    'vp-modpack'     = $versions.components.vp_modpack
    'cp-modpack'     = $versions.components.cp_modpack
    'vp-runtime'     = $versions.components.vp_runtime
    'lekmod-dlc'     = $versions.components.lekmod_dlc
}

# Previous release tag + that release's versions.json. Used to decide which
# component zips to re-fetch (component version unchanged) vs. rebuild from
# source. If git describe finds nothing, this is the first release and every
# component is treated as new.
function Get-PreviousReleaseTag {
    $tag = & git describe --tags --abbrev=0 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($tag)) {
        return $null
    }
    return $tag.Trim()
}

function Get-PreviousVersionsJson {
    param([string]$Tag)
    if (-not $Tag) { return $null }
    $json = & git show "${Tag}:versions.json" 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($json)) {
        return $null
    }
    return ($json | ConvertFrom-Json)
}

$prevTag = Get-PreviousReleaseTag
$prevVersions = Get-PreviousVersionsJson -Tag $prevTag
$prevComponentVersions = if ($prevVersions) {
    @{
        'core-blind'     = $prevVersions.components.core
        'core-sighted'   = $prevVersions.components.core
        'engine'         = $prevVersions.components.engine
        'runtime'        = $prevVersions.components.runtime
        'cinematics'     = $prevVersions.components.cinematics
        'vp-overlay'     = $prevVersions.components.vp_overlay
        'cp-overlay'     = $prevVersions.components.cp_overlay
        'lekmod-overlay' = $prevVersions.components.lekmod_overlay
        'vp-modpack'     = $prevVersions.components.vp_modpack
        'cp-modpack'     = $prevVersions.components.cp_modpack
        'vp-runtime'     = $prevVersions.components.vp_runtime
        'lekmod-dlc'     = $prevVersions.components.lekmod_dlc
    }
} else {
    @{}
}

# Fork-staleness guard. The modpack and LekMod-DLC zips EMBED an engine fork DLL
# (both modpacks embed engine_vp; lekmod-dlc embeds engine_lekmod). If a fork is
# rebuilt (its engine_* version bumped) but the dependent component's version is
# not, Resolve-Component would reuse the prior release's zip with the stale fork
# inside - a silent MP desync / wrong-numbers ship. Warn loudly so the
# maintainer bumps the dependent version too.
$forkCoupling = @{
    'vp-modpack' = 'engine_vp'
    'cp-modpack' = 'engine_vp'
    'lekmod-dlc' = 'engine_lekmod'
}
if ($prevVersions) {
    foreach ($comp in $forkCoupling.Keys) {
        $engField = $forkCoupling[$comp]
        $engNow   = $versions.components.$engField
        $engPrev  = $prevVersions.components.$engField
        $compNow  = $componentVersions[$comp]
        $compPrev = $prevComponentVersions[$comp]
        if ($engPrev -and ($engNow -ne $engPrev) -and $compPrev -and ($compNow -eq $compPrev)) {
            Write-Warning ("$engField changed ($engPrev -> $engNow) but $comp stayed at $compNow. " +
                "The $comp zip embeds that fork DLL; bump $comp in versions.json or the release will reuse " +
                "the prior zip with the stale fork (MP desync / wrong numbers).")
        }
    }
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

# Same Tolk runtime files deploy.ps1 ships.
$tolkFiles = @(
    'Tolk.dll',
    'SAAPI32.dll',
    'dolapi32.dll',
    'nvdaControllerClient32.dll',
    'BoyCtrl.dll',
    'boyctrl.ini',
    'ZDSRAPI.dll',
    'ZDSRAPI.ini'
)

# Same cinematic files deploy.ps1 ships.
$cinematicFiles = @(
    'Civ5XP2_Opening_Movie_en_US.wmv',
    'Civ5XP2_Opening_Movie_de_DE.wma',
    'Civ5XP2_Opening_Movie_es_ES.wma',
    'Civ5XP2_Opening_Movie_fr_FR.wma',
    'Civ5XP2_Opening_Movie_it_IT.wma',
    'Civ5XP2_Opening_Movie_pl_PL.wma',
    'Civ5XP2_Opening_Movie_ru_RU.wma'
)

# Empty UI dirs the sighted-MP DLC needs so the engine resolves the manifest's
# UISkin directives without dragging in any mod code (matches deploy-sighted-
# multiplayer.ps1).
$sightedUiDirs = @('UI\FrontEnd', 'UI\Shared', 'UI\InGame', 'UI\TechTree')

function New-CleanDir {
    param([string]$Path)
    if (Test-Path $Path) { Remove-Item -LiteralPath $Path -Recurse -Force }
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

# The vanilla core DLC tree (src/dlc + version lua + sounds). Delegates to the
# shared Copy-CivVAccessCoreDlc so the core-blind component and the overlay
# diff's reference are built by the SAME code as the modded DLC's core portion;
# they therefore can't disagree on what "core" is (which is what keeps core
# files - version lua included - out of every overlay delta).
function Build-CoreTree {
    param([string]$DestDir)
    Copy-CivVAccessCoreDlc -DestDir $DestDir -DlcSrcDir $dlcSrcDir -ModVersion $modVersion -SoundsSrcDir $soundsSrcDir
}

$script:coreRefDir = $null
function Get-CoreReferenceDir {
    if ($script:coreRefDir -and (Test-Path $script:coreRefDir)) { return $script:coreRefDir }
    $dir = Join-Path $stagingRoot '_coreref'
    Build-CoreTree -DestDir $dir
    $script:coreRefDir = $dir
    return $dir
}

# Overlay = the files in the assembled modded DLC that differ from (or are
# absent in) the vanilla core. Extracted over core-blind on a mod install, this
# reproduces the full modded DLC. There are no deletions to represent: the
# modded DLC is always core plus vendor/seam/manifest changes.
function Get-OverlayDelta {
    param([string]$FullDir, [string]$CoreDir, [string]$OutDir)
    New-CleanDir $OutDir
    $base = [System.IO.Path]::GetFullPath($FullDir)
    foreach ($f in Get-ChildItem -LiteralPath $FullDir -Recurse -File) {
        $rel = $f.FullName.Substring($base.Length).TrimStart('\')
        $coreFile = Join-Path $CoreDir $rel
        $differs = $true
        if (Test-Path -LiteralPath $coreFile) {
            # Length first: a size mismatch is a guaranteed difference, so only
            # equal-length files (the common case for the large mod trees) pay
            # for the two SHA-256 reads.
            if ($f.Length -eq (Get-Item -LiteralPath $coreFile).Length) {
                $differs = (Get-FileHash -LiteralPath $f.FullName).Hash -ne (Get-FileHash -LiteralPath $coreFile).Hash
            }
        }
        if ($differs) {
            $dst = Join-Path $OutDir $rel
            New-Item -ItemType Directory -Path (Split-Path -Parent $dst) -Force | Out-Null
            Copy-Item -LiteralPath $f.FullName -Destination $dst -Force
        }
    }
}

function Compress-Component {
    param(
        [string]$Name,
        [string]$StageDir
    )
    $version = $componentVersions[$Name]
    if (-not $version) { throw "No component version registered for '$Name' in versions.json." }
    $zipName = "$Name-$version.zip"
    $zipPath = Join-Path $releaseDir $zipName
    if (Test-Path $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
    [System.IO.Compression.ZipFile]::CreateFromDirectory($StageDir, $zipPath)

    $hash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLower()
    $size = (Get-Item -LiteralPath $zipPath).Length

    Write-Host ("  {0,-32} {1,12:N0} bytes (built)" -f $zipName, $size)
    Write-Host "    sha256: $hash"

    [pscustomobject]@{ Name = $zipName; Sha256 = $hash; Size = $size }
}

# Pull the previous release's same-named asset so the new release ships
# identical bytes (and therefore an identical API digest) for components
# whose version field hasn't moved. Authoritative pre-check for "is this
# component unchanged" lives in versions.json; the maintainer is responsible
# for not bumping a component whose source didn't change (see RELEASING.md).
function Copy-PreviousComponent {
    param(
        [string]$Name,
        [string]$Tag
    )
    $version = $componentVersions[$Name]
    $zipName = "$Name-$version.zip"
    $zipPath = Join-Path $releaseDir $zipName
    if (Test-Path $zipPath) { Remove-Item -LiteralPath $zipPath -Force }

    # PowerShell 7.4+ turns a nonzero native exit into a terminating error under
    # ErrorActionPreference='Stop'; disable that here so a failed download lands
    # on the actionable throw below (via $LASTEXITCODE) instead of a raw native
    # error stack.
    $PSNativeCommandUseErrorActionPreference = $false
    & gh release download $Tag --pattern $zipName --dir $releaseDir --clobber
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $zipPath)) {
        throw "Could not fetch $zipName from release $Tag. Either the release is missing the asset (component version was bumped without a prior release shipping it), or gh is not authenticated. Bump the component's version in versions.json or run 'gh auth login'."
    }

    $hash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLower()
    $size = (Get-Item -LiteralPath $zipPath).Length

    Write-Host ("  {0,-32} {1,12:N0} bytes (reused from {2})" -f $zipName, $size, $Tag)
    Write-Host "    sha256: $hash"

    [pscustomobject]@{ Name = $zipName; Sha256 = $hash; Size = $size }
}

# Decide per component: rebuild from source when the version field moved,
# else fetch the previous release's bytes verbatim. Returns the artifact
# record either way.
function Resolve-Component {
    param(
        [string]$Name,
        [scriptblock]$Stager
    )
    $version = $componentVersions[$Name]
    $prevVersion = $prevComponentVersions[$Name]
    $unchanged = $prevTag -and $prevVersion -and ($prevVersion -eq $version)

    if ($unchanged) {
        return Copy-PreviousComponent -Name $Name -Tag $prevTag
    }
    $stage = & $Stager
    return Compress-Component -Name $Name -StageDir $stage
}

function Stage-CoreBlind {
    $stage = Join-Path $stagingRoot 'core-blind'
    Build-CoreTree -DestDir $stage
    return $stage
}

# Mod-state DLC overlay: assemble the full modded DLC for the engine, then keep
# only what differs from the vanilla core. $Engine is vp / cp / lekmod.
function Stage-Overlay {
    param([Parameter(Mandatory)][ValidateSet('vp', 'cp', 'lekmod')][string]$Engine)

    $vendor = switch ($Engine) {
        'vp'     { $vendorVpDir }
        'cp'     { $vendorCpDir }
        'lekmod' { $vendorLekmodDir }
    }
    $seam = if ($Engine -eq 'lekmod') { $lekmodSeamFile } else { $vpSeamFile }

    $full = Join-Path $stagingRoot "overlay-$Engine-full"
    New-CivVAccessModdedDlc -DestDir $full -Engine $Engine -DlcSrcDir $dlcSrcDir `
        -VendorStageDir $vendor -SeamFile $seam -ModVersion $modVersion `
        -SoundsSrcDir $soundsSrcDir -Priority 350

    $overlay = Join-Path $stagingRoot "overlay-$Engine"
    Get-OverlayDelta -FullDir $full -CoreDir (Get-CoreReferenceDir) -OutDir $overlay
    return $overlay
}

# Baked modpack package. Zipped straight from the bake output (the zip root is
# the package contents; the installer extracts it to Assets/DLC/ZCivVAccess*).
function Stage-Modpack {
    param([switch]$Cp)
    $dir = if ($Cp) { $modpackCpDir } else { $modpackVpDir }
    $label = if ($Cp) { 'CP' } else { 'VP' }
    $script = if ($Cp) { 'build-modpack-cp.ps1' } else { 'build-modpack.ps1' }
    if (-not (Test-Path (Join-Path $dir 'MPModsPack.Civ5Pkg'))) {
        throw "Baked $label modpack missing at $dir. Run $script first."
    }
    return $dir
}

# Vox Populi substrate, two-rooted: game/ entries extract under the game install,
# docs/ entries under the Civ V Documents tree (matches the installer's routed
# extraction in ApplyVpRuntime).
function Stage-VpRuntime {
    # Populate build/vp-runtime from the Community-Patch-DLL clone when it is not
    # already staged (flat names match Resolve-VpAsset in tools/dlc-assembly.ps1).
    if (-not (Test-Path (Join-Path $vpRuntimeDir 'VPUI'))) {
        $vpAssets = @(
            @{ Name = 'VPUI';                         Src = Join-Path $ClonePath 'VPUI';                          Dir = $true  },
            @{ Name = 'MinorCivSounds_VoxPopuli.xml'; Src = Join-Path $ClonePath 'MinorCivSounds_VoxPopuli.xml';  Dir = $false },
            @{ Name = 'VPUI_tips_en_us.xml';          Src = Join-Path $ClonePath 'VPUI Text\VPUI_tips_en_us.xml'; Dir = $false },
            @{ Name = 'Expansion2_VoxPopuli.Civ5Pkg'; Src = Join-Path $ClonePath 'Expansion2_VoxPopuli.Civ5Pkg';  Dir = $false }
        )
        New-CleanDir $vpRuntimeDir
        Write-Host "  Staging VP-completion assets from clone: $ClonePath"
        foreach ($a in $vpAssets) {
            if (-not (Test-Path $a.Src)) {
                throw "VP-completion asset missing in clone: $($a.Src). Pass -ClonePath or put the Community-Patch-DLL clone (on the civvaccess branch) beside the repo."
            }
            Copy-Item -LiteralPath $a.Src -Destination (Join-Path $vpRuntimeDir $a.Name) -Recurse:$a.Dir -Force
        }
    }
    $stage = Join-Path $stagingRoot 'vp-runtime'
    New-CleanDir $stage

    $gameDlc = Join-Path $stage 'game\Assets\DLC'
    $gameExp2 = Join-Path $stage 'game\Assets\DLC\Expansion2'
    $gameSounds = Join-Path $gameExp2 'Sounds\XML'
    $docsText = Join-Path $stage 'docs\Text'
    New-Item -ItemType Directory -Path $gameDlc -Force | Out-Null
    New-Item -ItemType Directory -Path $gameSounds -Force | Out-Null
    New-Item -ItemType Directory -Path $docsText -Force | Out-Null

    Copy-Item -LiteralPath (Join-Path $vpRuntimeDir 'VPUI') -Destination (Join-Path $gameDlc 'VPUI') -Recurse -Force
    Copy-Item -LiteralPath (Join-Path $vpRuntimeDir 'Expansion2_VoxPopuli.Civ5Pkg') -Destination (Join-Path $gameExp2 'Expansion2.Civ5Pkg') -Force
    Copy-Item -LiteralPath (Join-Path $vpRuntimeDir 'MinorCivSounds_VoxPopuli.xml') -Destination (Join-Path $gameSounds 'MinorCivSounds_VoxPopuli.xml') -Force
    Copy-Item -LiteralPath (Join-Path $vpRuntimeDir 'VPUI_tips_en_us.xml') -Destination (Join-Path $docsText 'VPUI_tips_en_us.xml') -Force

    return $stage
}

# LekMod's prebaked DLC plus its Lekmap map scripts, resolved to the standard-UI
# set with our fork swapped in (matches deploy.ps1 -State lekmod's
# Deploy-LekModDlc). Two-rooted, like vp-runtime: "dlc/" entries extract to
# Assets/DLC/LEKMOD, "maps/" entries to Assets/Maps/Lekmap (the installer's
# routed extraction in ApplyLekmodDlc).
function Stage-LekmodDlc {
    $src = Join-Path $LekModClone 'LEKMOD'
    if (-not (Test-Path (Join-Path $src 'MPModsPack.Civ5Pkg'))) {
        throw "LekMod DLC missing at $src (expected LEKMOD/MPModsPack.Civ5Pkg). Pass -LekModClone or extract the LekMod bundle to build/lekmod-clone."
    }
    if (-not (Test-Path $engineLekmodFork)) {
        throw "LekMod fork DLL missing: $engineLekmodFork. Run build-engine-lekmod.ps1 first."
    }
    $lekmapSrc = Join-Path $LekModClone 'Lekmap'
    if (-not (Test-Path $lekmapSrc)) {
        throw "Lekmap map scripts missing at $lekmapSrc. Expected the Lekmap directory beside LEKMOD in the LekMod clone."
    }
    $stage = Join-Path $stagingRoot 'lekmod-dlc'
    New-CleanDir $stage
    $dlcStage = Join-Path $stage 'dlc'
    $mapsStage = Join-Path $stage 'maps'
    New-Item -ItemType Directory -Path $dlcStage -Force | Out-Null

    Write-Host "  Copying LekMod DLC tree (large)..."
    Copy-Item -Path (Join-Path $src '*') -Destination $dlcStage -Recurse -Force
    Resolve-CivVAccessLekModStandardUI -LekModDir $dlcStage
    Copy-Item -LiteralPath $engineLekmodFork -Destination (Join-Path $dlcStage 'CvGameCore_Expansion2.dll') -Force

    Write-Host "  Copying Lekmap map scripts..."
    Copy-Item -LiteralPath $lekmapSrc -Destination $mapsStage -Recurse -Force
    return $stage
}

function Stage-CoreSighted {
    $stage = Join-Path $stagingRoot 'core-sighted'
    New-CleanDir $stage

    $manifest = Join-Path $dlcSrcDir 'CivVAccess_2.Civ5Pkg'
    if (-not (Test-Path $manifest)) { throw "DLC manifest missing: $manifest" }
    Copy-Item -LiteralPath $manifest -Destination $stage -Force

    foreach ($rel in $sightedUiDirs) {
        New-Item -ItemType Directory -Path (Join-Path $stage $rel) -Force | Out-Null
    }

    return $stage
}

function Stage-Engine {
    $stage = Join-Path $stagingRoot 'engine'
    New-CleanDir $stage

    $src = Join-Path $engineDistDir 'CvGameCore_Expansion2.dll'
    if (-not (Test-Path $src)) { throw "Engine DLL missing: $src. Run build-engine.ps1 first." }
    Copy-Item -LiteralPath $src -Destination $stage -Force

    return $stage
}

function Stage-Runtime {
    $stage = Join-Path $stagingRoot 'runtime'
    New-CleanDir $stage

    $proxy = Join-Path $proxyDistDir 'lua51_Win32.dll'
    if (-not (Test-Path $proxy)) { throw "Proxy DLL missing: $proxy. Run build-proxy.ps1 first." }
    Copy-Item -LiteralPath $proxy -Destination $stage -Force

    foreach ($f in $tolkFiles) {
        $src = Join-Path $tolkDistDir $f
        if (-not (Test-Path $src)) { throw "Tolk runtime file missing: $src" }
        Copy-Item -LiteralPath $src -Destination $stage -Force
    }

    return $stage
}

function Stage-Cinematics {
    $stage = Join-Path $stagingRoot 'cinematics'
    New-CleanDir $stage

    if (-not (Test-Path $cinematicSrc)) { throw "Cinematics source dir missing: $cinematicSrc" }

    foreach ($f in $cinematicFiles) {
        $src = Join-Path $cinematicSrc $f
        if (-not (Test-Path $src)) { throw "Cinematic source file missing: $src" }
        Copy-Item -LiteralPath $src -Destination $stage -Force
    }

    return $stage
}

# ---- Driver ----
Write-Host "Packaging release $modVersion"
Write-Host "  Output: $releaseDir"
Write-Host ""

# A full run wipes the release dir for a clean set. A -Only run must NOT: it
# rebuilds a subset for iteration, and the per-component stagers already remove
# their own zip before writing, so other components' zips are left intact.
if ($Only) {
    New-Item -ItemType Directory -Path $releaseDir -Force | Out-Null
} else {
    New-CleanDir $releaseDir
}
New-CleanDir $stagingRoot

if ($prevTag) {
    Write-Host "Previous release: $prevTag"
} else {
    Write-Host "No previous release tag; building every component from source."
}
Write-Host ""

# All components, in order. -Only filters this list (by zip prefix).
$plan = @(
    @{ Name = 'core-blind';     Stager = { Stage-CoreBlind } }
    @{ Name = 'core-sighted';   Stager = { Stage-CoreSighted } }
    @{ Name = 'engine';         Stager = { Stage-Engine } }
    @{ Name = 'runtime';        Stager = { Stage-Runtime } }
    @{ Name = 'cinematics';     Stager = { Stage-Cinematics } }
    @{ Name = 'vp-overlay';     Stager = { Stage-Overlay -Engine 'vp' } }
    @{ Name = 'cp-overlay';     Stager = { Stage-Overlay -Engine 'cp' } }
    @{ Name = 'lekmod-overlay'; Stager = { Stage-Overlay -Engine 'lekmod' } }
    @{ Name = 'vp-modpack';     Stager = { Stage-Modpack } }
    @{ Name = 'cp-modpack';     Stager = { Stage-Modpack -Cp } }
    @{ Name = 'vp-runtime';     Stager = { Stage-VpRuntime } }
    @{ Name = 'lekmod-dlc';     Stager = { Stage-LekmodDlc } }
)

if ($Only) {
    $unknown = $Only | Where-Object { $_ -notin ($plan.Name) }
    if ($unknown) { throw "Unknown -Only component(s): $($unknown -join ', '). Valid: $($plan.Name -join ', ')." }
    $plan = $plan | Where-Object { $_.Name -in $Only }
    Write-Host "Building only: $($plan.Name -join ', ')"
    Write-Host ""
}

$artifacts = @()
foreach ($c in $plan) {
    $artifacts += Resolve-Component -Name $c.Name -Stager $c.Stager
}

# SHA256SUMS is the full-release integrity manifest. Only a full run writes it,
# so a -Only iteration can't silently overwrite it with a partial set.
Remove-Item -LiteralPath $stagingRoot -Recurse -Force

if ($Only) {
    Write-Host ""
    Write-Host "Built $($artifacts.Count) component(s) in $releaseDir (partial -Only run; SHA256SUMS not rewritten)."
} else {
    $sumsPath  = Join-Path $releaseDir 'SHA256SUMS'
    $sumsLines = $artifacts | ForEach-Object { "$($_.Sha256)  $($_.Name)" }
    Set-Content -LiteralPath $sumsPath -Value $sumsLines -Encoding ASCII

    Write-Host ""
    Write-Host "Release packaged: $($artifacts.Count) artifacts + SHA256SUMS in $releaseDir"
    Write-Host "Next: git tag v$modVersion, push the tag, create a GitHub Release,"
    Write-Host "      attach all .zip files plus SHA256SUMS, and publish."
}
