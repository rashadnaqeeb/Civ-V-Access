<#
.SYNOPSIS
    Package the one-time VP modpack tester bundle: the non-committed build
    artifacts a tester needs so `deploy-modpack.ps1` runs with no clone and no
    build on their machine.

.DESCRIPTION
    Existing power-users already pull source and run deploy.ps1 to test changes
    before a public release. To let them also run deploy-modpack.ps1 (and flip
    between vanilla and VP freely), they need three things that are not in git
    and are normally clone- or build-derived:

      build/modpack-out   the baked modpack DLC (CP + VP + fork DLL + merged DB)
      build/vendor/vp     the staged VP vendor overlay the DLC payload pulls in
      build/vp-runtime    the VP-completion assets deploy-modpack would otherwise
                          take from the Community-Patch-DLL clone (VPUI, the VP
                          Expansion2.Civ5Pkg, minor-civ sounds, loading tips)

    None of these depend on the accessibility source, so they stay valid across
    the code changes a tester pulls and retests. They go stale only on a VP
    re-pin or a fork rebuild -- re-run this script and re-issue the zip then.

    This script stages build/vp-runtime from the clone, then zips all three into
    one archive whose internal layout mirrors the repo's build/ subtree. The
    tester extracts it into the repo's build/ directory once; afterwards
    `git pull` + `./deploy-modpack.ps1` / `./deploy.ps1` is their whole loop.

    Prerequisites (maintainer, one-time per VP pin):
      build-modpack.ps1                                   -> build/modpack-out
      py tools/vendoring/vendor.py generate --engine vp   -> build/vendor/vp

.PARAMETER ClonePath
    Community-Patch-DLL clone root. Defaults to the sibling directory.

.PARAMETER OutDir
    Where to write the zip. Defaults to dist/.
#>
[CmdletBinding()]
param(
    [string]$ClonePath,
    [string]$OutDir
)

$ErrorActionPreference = 'Stop'

$repoRoot        = Split-Path -Parent $MyInvocation.MyCommand.Path
$modpackBuildDir = Join-Path $repoRoot 'build\modpack-out'
$vendorVpDir     = Join-Path $repoRoot 'build\vendor\vp'
$vpRuntimeDir    = Join-Path $repoRoot 'build\vp-runtime'
$stageDir        = Join-Path $repoRoot 'build\_bundle-stage'

if ([string]::IsNullOrWhiteSpace($ClonePath)) {
    $ClonePath = Join-Path (Split-Path -Parent $repoRoot) 'Community-Patch-DLL'
}
if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $OutDir = Join-Path $repoRoot 'dist'
}

$versionsFile = Join-Path $repoRoot 'versions.json'
$versions     = Get-Content -LiteralPath $versionsFile -Raw | ConvertFrom-Json
$modVersion   = $versions.mod
$zipPath      = Join-Path $OutDir "civ-v-access-vp-bundle-$modVersion.zip"

# ---- 1. Verify the baked inputs exist ----
if (-not (Test-Path (Join-Path $modpackBuildDir 'MPModsPack.Civ5Pkg'))) {
    throw "Baked modpack missing at $modpackBuildDir. Run build-modpack.ps1 first."
}
if (-not (Test-Path (Join-Path $vendorVpDir 'UI'))) {
    throw "VP vendor stage missing at $vendorVpDir. Run: py tools/vendoring/vendor.py generate --engine vp --mods `"$ClonePath`""
}

# ---- 2. Stage the VP-completion assets from the clone into build/vp-runtime ----
# Flat names matching Resolve-VpAsset in deploy-modpack.ps1.
$vpAssets = @(
    @{ Name = 'VPUI';                          Src = Join-Path $ClonePath 'VPUI';                          Dir = $true  },
    @{ Name = 'MinorCivSounds_VoxPopuli.xml';  Src = Join-Path $ClonePath 'MinorCivSounds_VoxPopuli.xml';  Dir = $false },
    @{ Name = 'VPUI_tips_en_us.xml';           Src = Join-Path $ClonePath 'VPUI Text\VPUI_tips_en_us.xml'; Dir = $false },
    @{ Name = 'Expansion2_VoxPopuli.Civ5Pkg';  Src = Join-Path $ClonePath 'Expansion2_VoxPopuli.Civ5Pkg';  Dir = $false }
)
if (Test-Path $vpRuntimeDir) { Remove-Item -LiteralPath $vpRuntimeDir -Recurse -Force }
New-Item -ItemType Directory -Path $vpRuntimeDir -Force | Out-Null
Write-Host "Staging VP-completion assets from clone:"
Write-Host "  $ClonePath"
foreach ($a in $vpAssets) {
    if (-not (Test-Path $a.Src)) {
        throw "VP-completion asset missing in clone: $($a.Src). Is the clone on the civvaccess branch and fully checked out?"
    }
    Copy-Item -LiteralPath $a.Src -Destination (Join-Path $vpRuntimeDir $a.Name) -Recurse:$a.Dir -Force
    Write-Host "  + $($a.Name)"
}

# ---- 3. Stage the three trees under one build/ root, then zip once ----
# The archive root is the staged build/ folder, so the tester extracts straight
# into the repo root and the three subtrees land under build/.
if (Test-Path $stageDir) { Remove-Item -LiteralPath $stageDir -Recurse -Force }
$stageBuild = Join-Path $stageDir 'build'
New-Item -ItemType Directory -Path $stageBuild -Force | Out-Null
Write-Host "Staging bundle tree..."
Copy-Item -LiteralPath $modpackBuildDir -Destination (Join-Path $stageBuild 'modpack-out') -Recurse -Force
New-Item -ItemType Directory -Path (Join-Path $stageBuild 'vendor') -Force | Out-Null
Copy-Item -LiteralPath $vendorVpDir    -Destination (Join-Path $stageBuild 'vendor\vp')   -Recurse -Force
Copy-Item -LiteralPath $vpRuntimeDir   -Destination (Join-Path $stageBuild 'vp-runtime')  -Recurse -Force

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
if (Test-Path $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
Write-Host "Compressing bundle (this is the slow part)..."
Add-Type -AssemblyName System.IO.Compression.FileSystem
# Zip the contents of the stage dir (which is just build/), so the archive root
# holds build/ -- ready to extract directly into the repo root.
[System.IO.Compression.ZipFile]::CreateFromDirectory(
    $stageDir, $zipPath,
    [System.IO.Compression.CompressionLevel]::Optimal, $false)

Remove-Item -LiteralPath $stageDir -Recurse -Force

$sizeMb = [math]::Round((Get-Item -LiteralPath $zipPath).Length / 1MB, 1)
Write-Host ""
Write-Host "VP modpack tester bundle written:"
Write-Host "  $zipPath ($sizeMb MB)"
Write-Host ""
Write-Host "Tester instructions:"
Write-Host "  1. Extract this zip into the repo root (it adds build/modpack-out,"
Write-Host "     build/vendor/vp, build/vp-runtime; existing build/ contents are kept)."
Write-Host "  2. From then on: git pull, then ./deploy-modpack.ps1 (VP) or"
Write-Host "     ./deploy.ps1 (vanilla). No clone, no build needed."
Write-Host "  Re-extract a fresh bundle only when told (a VP re-pin or fork rebuild)."
