<#
.SYNOPSIS
    Package the LekMod tester bundle: the non-committed inputs a tester needs so
    `deploy-lekmod.ps1` runs with no clone and no build on their machine.

.DESCRIPTION
    The LekMod analog of package-modpack-bundle.ps1. Existing power-users pull
    source and run a deploy script to test changes before a public release. To
    let them also run the LekMod deploy (and flip freely between vanilla and
    LekMod), they need the two things that are not in git and are normally
    clone- or build-derived:

      build/lekmod-clone/LEKMOD   LekMod's prebaked DLC tree (the clone's
                                  LEKMOD/ folder, including Lua/tmp/ui so the
                                  deploy can resolve the standard-UI set)
      build/vendor/lekmod         the staged LekMod vendor overlay the DLC
                                  payload pulls in

    Everything else deploy-lekmod needs is committed: the fork DLL
    (dist/engine-lekmod), our DLC payload (src/dlc), and the LekMod EngineData
    seam (src/lekmod). The fork DLL is NOT bundled for that reason; this carries
    only the upstream LekMod content and the build-derived overlay.

    Neither bundled tree depends on the accessibility source, so they stay valid
    across the code changes a tester pulls and retests. They go stale only on a
    LekMod re-pin -- re-run this script and re-issue the zip then.

    This stages both trees under one build/ root and zips once. The tester
    extracts it into the repo's build/ directory; afterwards `git pull` +
    `./deploy-lekmod.ps1 -LekModClone build/lekmod-clone` is their whole loop.

    Prerequisites (maintainer, one-time per LekMod pin):
      py tools/vendoring/vendor.py generate --engine lekmod \
        --out build/vendor/lekmod --lekmod <clone>          -> build/vendor/lekmod

.PARAMETER ClonePath
    LekMod clone root (its LEKMOD/ tree). Defaults to the sibling directory
    (~/Documents/Lekmod).

.PARAMETER OutDir
    Where to write the zip. Defaults to dist/.
#>
[CmdletBinding()]
param(
    [string]$ClonePath,
    [string]$OutDir
)

$ErrorActionPreference = 'Stop'

$repoRoot     = Split-Path -Parent $MyInvocation.MyCommand.Path
$vendorDir    = Join-Path $repoRoot 'build\vendor\lekmod'
$stageDir     = Join-Path $repoRoot 'build\_lekmod-bundle-stage'

if ([string]::IsNullOrWhiteSpace($ClonePath)) {
    $ClonePath = Join-Path (Split-Path -Parent $repoRoot) 'Lekmod'
}
$lekmodSrc = Join-Path $ClonePath 'LEKMOD'

if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $OutDir = Join-Path $repoRoot 'dist'
}

$versionsFile = Join-Path $repoRoot 'versions.json'
$versions     = Get-Content -LiteralPath $versionsFile -Raw | ConvertFrom-Json
$modVersion   = $versions.mod
$zipPath      = Join-Path $OutDir "civ-v-access-lekmod-bundle-$modVersion.zip"

# ---- 1. Verify the inputs exist ----
if (-not (Test-Path (Join-Path $lekmodSrc 'MPModsPack.Civ5Pkg'))) {
    throw "LekMod DLC missing at $lekmodSrc (expected its MPModsPack.Civ5Pkg). Is the clone fully checked out? Pass -ClonePath."
}
if (-not (Test-Path (Join-Path $lekmodSrc 'Lua\tmp\ui'))) {
    throw "LekMod standard-UI staging tree missing at $lekmodSrc\Lua\tmp\ui -- the deploy reads it to resolve the standard-UI set."
}
if (-not (Test-Path (Join-Path $vendorDir 'UI'))) {
    throw "LekMod vendor stage missing at $vendorDir. Run: py tools/vendoring/vendor.py generate --engine lekmod --out build/vendor/lekmod --lekmod `"$ClonePath`""
}

# ---- 2. Stage both trees under one build/ root, then zip once ----
# The archive root is the staged build/ folder, so the tester extracts straight
# into the repo root and the subtrees land under build/.
if (Test-Path $stageDir) { Remove-Item -LiteralPath $stageDir -Recurse -Force }
$stageBuild = Join-Path $stageDir 'build'
New-Item -ItemType Directory -Path $stageBuild -Force | Out-Null
Write-Host "Staging bundle tree..."
$lekmodDst = Join-Path $stageBuild 'lekmod-clone\LEKMOD'
New-Item -ItemType Directory -Path (Split-Path -Parent $lekmodDst) -Force | Out-Null
Write-Host "  Copying LekMod DLC (large -- includes Art)..."
Copy-Item -LiteralPath $lekmodSrc -Destination $lekmodDst -Recurse -Force
Copy-Item -LiteralPath $vendorDir -Destination (Join-Path $stageBuild 'vendor\lekmod') -Recurse -Force

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
Write-Host "LekMod tester bundle written:"
Write-Host "  $zipPath ($sizeMb MB)"
Write-Host ""
Write-Host "Tester instructions:"
Write-Host "  1. Extract this zip into the repo root (it adds build/lekmod-clone"
Write-Host "     and build/vendor/lekmod; existing build/ contents are kept)."
Write-Host "  2. From then on: git pull, then"
Write-Host "     ./deploy-lekmod.ps1 -LekModClone build/lekmod-clone (LekMod), or"
Write-Host "     ./deploy.ps1 (vanilla). No clone, no build needed."
Write-Host "  Re-extract a fresh bundle only when told (a LekMod re-pin)."
