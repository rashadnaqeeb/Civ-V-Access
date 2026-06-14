<#
.SYNOPSIS
    Build the EUI-free Vox Populi modpack DLC for Civ V Access into
    build/modpack-out, ready for deploy-modpack.ps1.

.DESCRIPTION
    Wraps tools/modpack/build_modpack.py. The one input the tool cannot
    generate is the engine-merged CP+VP database; that is a byproduct of any
    normal VP mod-flow play session, left in the cache folder. This script
    copies the current cache databases out of Documents and feeds them to the
    dumper, which freezes them into the modpack's Override/ folder. Everything
    else (the blanking stubs, the embedded CP+VP mod folders, our fork DLL,
    the InGame addin appends, the manifest) the assembler produces.

    IMPORTANT: the cache database must be a clean CP+VP merge. Play one normal
    VP session through the Mods menu first (Squads must not be enabled). A
    modpack session's own database carries whatever that modpack baked, so do
    not build from a cache left by a modpack launch.

.PARAMETER GameDir
    Override the auto-detected Civ V install (used only for the base
    InGame.lua the modpack's own copy appends to).

.PARAMETER ClonePath
    Path to the Community-Patch-DLL clone (pristine CP + VP folders + fork).
    Defaults to the sibling directory next to this repo.

.PARAMETER CacheDir
    Override the auto-detected cache folder holding Civ5DebugDatabase.db and
    Localization-Merged.db.
#>
[CmdletBinding()]
param(
    [string]$GameDir,
    [string]$ClonePath,
    [string]$CacheDir
)

$ErrorActionPreference = 'Stop'

$repoRoot        = Split-Path -Parent $MyInvocation.MyCommand.Path
$forkDll         = Join-Path $repoRoot 'dist\engine-vp\CvGameCore_Expansion2.dll'
$buildDir        = Join-Path $repoRoot 'build\modpack-build'
$outDir          = Join-Path $repoRoot 'build\modpack-out'
$dumperScript    = Join-Path $repoRoot 'tools\modpack\build_modpack.py'

if ([string]::IsNullOrWhiteSpace($ClonePath)) {
    $ClonePath = Join-Path (Split-Path -Parent $repoRoot) 'Community-Patch-DLL'
}

$civ5DocsDir = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5"
if ([string]::IsNullOrWhiteSpace($CacheDir)) {
    $CacheDir = Join-Path $civ5DocsDir 'cache'
}

function Resolve-CivVInstallDir {
    param([string]$ExplicitPath)
    $appName = "Sid Meier's Civilization V"
    $candidates = @()
    if ($ExplicitPath) { $candidates += $ExplicitPath }
    if ($env:CIV5_DIR) { $candidates += $env:CIV5_DIR }
    try {
        $steam = Get-ItemProperty -Path 'HKCU:\Software\Valve\Steam' -ErrorAction Stop
        if ($steam.SteamPath) {
            $sp = ($steam.SteamPath -replace '/', '\').TrimEnd('\')
            $candidates += (Join-Path $sp "steamapps\common\$appName")
            $vdf = Join-Path $sp 'steamapps\libraryfolders.vdf'
            if (Test-Path $vdf) {
                foreach ($m in [regex]::Matches((Get-Content -Raw $vdf), '"path"\s*"([^"]+)"')) {
                    $candidates += (Join-Path ($m.Groups[1].Value -replace '\\\\', '\') "steamapps\common\$appName")
                }
            }
        }
    } catch { }
    $candidates += (Join-Path ${env:ProgramFiles(x86)} "Steam\steamapps\common\$appName")
    foreach ($c in $candidates) {
        if ($c -and (Test-Path (Join-Path $c 'CivilizationV.exe'))) { return (Resolve-Path $c).Path }
    }
    throw "Could not find Civilization V install. Pass -GameDir or set CIV5_DIR."
}

# ---- driver ----
$gameDir = Resolve-CivVInstallDir -ExplicitPath $GameDir
$baseIngame = Join-Path $gameDir 'Assets\DLC\Expansion2\UI\InGame\InGame.lua'

foreach ($p in @($forkDll, $dumperScript, $baseIngame)) {
    if (-not (Test-Path $p)) { throw "Required input missing: $p" }
}

$gameplayDb = Join-Path $CacheDir 'Civ5DebugDatabase.db'
$textDb     = Join-Path $CacheDir 'Localization-Merged.db'
foreach ($p in @($gameplayDb, $textDb)) {
    if (-not (Test-Path $p)) {
        throw "Cache database missing: $p. Play one clean CP+VP session through the Mods menu first (Squads off), then re-run."
    }
}

# Copy the cache DBs to a stable build path (the cache is volatile and the
# apostrophe in the Documents path trips some tools).
if (Test-Path $buildDir) { Remove-Item -LiteralPath $buildDir -Recurse -Force }
New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
$gameplayLocal = Join-Path $buildDir 'gameplay.db'
$textLocal     = Join-Path $buildDir 'text.db'
Copy-Item -LiteralPath $gameplayDb -Destination $gameplayLocal -Force
Copy-Item -LiteralPath $textDb -Destination $textLocal -Force

# build_modpack.py validates the DB is a clean CP+VP merge (BALANCE_VP on,
# Squads off) and aborts otherwise.
Write-Host "Building modpack into $outDir ..."
& py $dumperScript `
    --clone $ClonePath `
    --fork-dll $forkDll `
    --gameplay-db $gameplayLocal `
    --text-db $textLocal `
    --base-ingame $baseIngame `
    --out $outDir
if ($LASTEXITCODE -ne 0) { throw "build_modpack.py failed (exit $LASTEXITCODE)." }

Write-Host ""
Write-Host "Modpack built at: $outDir"
Write-Host "Deploy it with: ./deploy-modpack.ps1"
