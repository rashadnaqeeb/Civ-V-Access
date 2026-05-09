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

    GitHub computes its own digest on each uploaded asset (algorithm-prefixed
    sha256:... in the API), so the SHA256SUMS file is informational - useful
    for the maintainer to verify upload integrity locally.

    The script verifies all build artifacts exist before doing any work; if
    something's missing, it fails up front naming the file rather than half-
    producing a release.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repoRoot      = Split-Path -Parent $MyInvocation.MyCommand.Path
$proxyDistDir  = Join-Path $repoRoot 'dist\proxy'
$engineDistDir = Join-Path $repoRoot 'dist\engine'
$tolkDistDir   = Join-Path $repoRoot 'third_party\tolk\dist\x86'
$dlcSrcDir     = Join-Path $repoRoot 'src\dlc'
$soundsSrcDir  = Join-Path $repoRoot 'sounds'
$cinematicSrc  = Join-Path $repoRoot 'audio described intros'

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
    'core-blind'   = $versions.components.core
    'core-sighted' = $versions.components.core
    'engine'       = $versions.components.engine
    'runtime'      = $versions.components.runtime
    'cinematics'   = $versions.components.cinematics
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

    Write-Host ("  {0,-32} {1,12:N0} bytes" -f $zipName, $size)
    Write-Host "    sha256: $hash"

    [pscustomobject]@{ Name = $zipName; Sha256 = $hash; Size = $size }
}

function Stage-CoreBlind {
    $stage = Join-Path $stagingRoot 'core-blind'
    New-CleanDir $stage

    Copy-Item -Path (Join-Path $dlcSrcDir '*') -Destination $stage -Recurse -Force

    if (Test-Path $soundsSrcDir) {
        $soundsDst = Join-Path $stage 'Sounds'
        New-Item -ItemType Directory -Path $soundsDst -Force | Out-Null
        Copy-Item -Path (Join-Path $soundsSrcDir '*.wav') -Destination $soundsDst -Force
    }

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

New-CleanDir $releaseDir
New-CleanDir $stagingRoot

$artifacts = @()
$artifacts += Compress-Component -Name 'core-blind'   -StageDir (Stage-CoreBlind)
$artifacts += Compress-Component -Name 'core-sighted' -StageDir (Stage-CoreSighted)
$artifacts += Compress-Component -Name 'engine'       -StageDir (Stage-Engine)
$artifacts += Compress-Component -Name 'runtime'      -StageDir (Stage-Runtime)
$artifacts += Compress-Component -Name 'cinematics'   -StageDir (Stage-Cinematics)

$sumsPath  = Join-Path $releaseDir 'SHA256SUMS'
$sumsLines = $artifacts | ForEach-Object { "$($_.Sha256)  $($_.Name)" }
Set-Content -LiteralPath $sumsPath -Value $sumsLines -Encoding ASCII

Remove-Item -LiteralPath $stagingRoot -Recurse -Force

Write-Host ""
Write-Host "Release packaged: $($artifacts.Count) artifacts + SHA256SUMS in $releaseDir"
Write-Host "Next: git tag v$modVersion, push the tag, create a GitHub Release,"
Write-Host "      attach all .zip files plus SHA256SUMS, and publish."
