<#
.SYNOPSIS
    Deploy Civ V Access over LekMod, started from the regular menus. LekMod's
    prebaked DLC plus our accessibility DLC, no mod activation, no bake.

.DESCRIPTION
    LekMod ships as a complete DLC whose Override/ is flat DLC-override XML the
    engine loads directly -- not a MODS-folder mod with mod-update actions. So
    unlike Vox Populi there is nothing to merge and nothing to bake: this single
    state installs LekMod's prebaked DLC and layers our accessibility DLC over
    it. It is a fifth install state, mutually exclusive with deploy.ps1
    (vanilla), deploy-vp.ps1 (VP mod-flow), and the two modpack states.

    Four pieces:
      - Proxy stack: dist/proxy/lua51_Win32.dll + the Tolk runtime DLLs.
      - LekMod DLC: the clone's LEKMOD/ tree copied to Assets/DLC/LEKMOD/, with
        its standard-UI set resolved into Lua/UI (mirrors ui_check.bat's
        standard branch: every tmp/ui body de-ignored, flattened by stem; EUI
        is out of scope and tmp/eui is dropped). LekMod's stock engine DLL is
        replaced with our fork (dist/engine-lekmod) -- we kept LekMod's GUID, so
        the engine loads ours as the Expansion2 gameplay core. LekMod's DLC at
        priority 300 is the highest-priority Expansion2 DLL provider; our DLC
        ships no DLL, so it does not compete for the gameplay-core slot.
      - Our DLC: src/dlc + the staged LekMod vendor overlay (build/vendor/lekmod)
        + the LekMod EngineData seam (src/lekmod), at priority 350 so our
        overrides win the stems LekMod also ships (Priority dominates package
        sort-order; verified in deploy-modpack.ps1).
      - Cinematics: the audio-described BNW openings.

    Both DLCs are off the mod-hash list (LekMod's MPModsPack.Civ5Pkg and our
    package both carry <SteamApp>235580</SteamApp> + BNW's <Key>), so a session
    is MP-lobby-visible. Two blind players both run this; a sighted partner runs
    deploy-lekmod-sighted-multiplayer.ps1 against their own LekMod install.

    -Uninstall reverses everything: restores the original lua51, removes our DLC
    and the LekMod DLC, and restores stock BNW cinematics from backup.

    deploy.ps1 flips back to vanilla (it removes the LekMod DLC and our DLC).

.PARAMETER GameDir
    Override the auto-detected Civ V install path.

.PARAMETER LekModClone
    Path to the LekMod clone supplying the prebaked DLC (its LEKMOD/ tree).
    Defaults to the sibling directory next to this repo (~/Documents/Lekmod).

.PARAMETER SkipProxy
    Skip the proxy stack and the legacy lua51 rename.

.PARAMETER SkipCinematics
    Skip the audio-described BNW opening cinematics.

.PARAMETER Uninstall
    Remove the proxy stack, our DLC, and the LekMod DLC; restore stock files.
#>
[CmdletBinding()]
param(
    [string]$GameDir,
    [string]$LekModClone,
    [switch]$SkipProxy,
    [switch]$SkipCinematics,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

$repoRoot         = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $repoRoot 'tools\dlc-assembly.ps1')
$proxyDistDir     = Join-Path $repoRoot 'dist\proxy'
$tolkDistDir      = Join-Path $repoRoot 'third_party\tolk\dist\x86'
$cinematicSrcDir  = Join-Path $repoRoot 'audio described intros'
$dlcSrcDir        = Join-Path $repoRoot 'src\dlc'
$lekmodSeamSrcFile = Join-Path $repoRoot 'src\lekmod\CivVAccess_EngineData.lua'
$vendorStageDir   = Join-Path $repoRoot 'build\vendor\lekmod'
$forkDllSrc       = Join-Path $repoRoot 'dist\engine-lekmod\CvGameCore_Expansion2.dll'
$soundsSrcDir     = Join-Path $repoRoot 'sounds'
$dlcName          = 'DLC_CivVAccess'
$lekmodDlcName    = 'LEKMOD'                 # our deployed LekMod DLC folder (fixed name)
$modpackNames     = @('ZCivVAccessVP', 'ZCivVAccessCP')  # VP/CP modpack packages; removed when flipping to LekMod
$dlcBackupDirName = "$dlcName.backup"
$installManifestName = 'CivVAccess.install.json'
$ourDlcPriority   = 350                      # beats LekMod's 300
$engineDllName    = 'CvGameCore_Expansion2.dll'

if ([string]::IsNullOrWhiteSpace($LekModClone)) {
    $LekModClone = Join-Path (Split-Path -Parent $repoRoot) 'Lekmod'
}

$civ5DocsDir = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5"

$versionsFile = Join-Path $repoRoot 'versions.json'
if (-not (Test-Path $versionsFile)) { throw "versions.json missing at $versionsFile" }
$versions    = Get-Content -LiteralPath $versionsFile -Raw | ConvertFrom-Json
$modVersion  = $versions.mod

$dlcBackupDir    = $null
$cinematicBackup = $null
$stockPkgBackup  = $null   # shared backup of the stock BNW Expansion2.Civ5Pkg (deploy.ps1 / deploy-vp capture it)

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
    'Tolk.dll', 'SAAPI32.dll', 'dolapi32.dll', 'nvdaControllerClient32.dll',
    'BoyCtrl.dll', 'boyctrl.ini', 'ZDSRAPI.dll', 'ZDSRAPI.ini'
)

function Add-CandidateGameDir {
    param([System.Collections.Generic.List[string]]$List, [string]$Path)
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
    foreach ($key in @(
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 8930',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 8930')) {
        try { Add-CandidateGameDir -List $candidates -Path (Get-ItemProperty -Path $key -ErrorAction Stop).InstallLocation } catch { }
    }
    try {
        $steam = Get-ItemProperty -Path 'HKCU:\Software\Valve\Steam' -ErrorAction Stop
        if (-not [string]::IsNullOrWhiteSpace($steam.SteamPath)) {
            $steamPath = ($steam.SteamPath -replace '/', '\').TrimEnd('\')
            Add-CandidateGameDir -List $candidates -Path (Join-Path $steamPath "steamapps\common\$appName")
            $libraryVdf = Join-Path $steamPath 'steamapps\libraryfolders.vdf'
            if (Test-Path $libraryVdf) {
                foreach ($m in [regex]::Matches((Get-Content -Raw $libraryVdf), '"path"\s*"([^"]+)"')) {
                    Add-CandidateGameDir -List $candidates -Path (Join-Path ($m.Groups[1].Value -replace '\\\\', '\') "steamapps\common\$appName")
                }
            }
        }
    } catch { }
    Add-CandidateGameDir -List $candidates -Path (Join-Path ${env:ProgramFiles(x86)} "Steam\steamapps\common\$appName")
    foreach ($candidate in $candidates) {
        if (Test-Path (Join-Path $candidate 'CivilizationV.exe')) { return (Resolve-Path $candidate).Path }
    }
    $searched = if ($candidates.Count -gt 0) { $candidates -join '; ' } else { '<none>' }
    throw "Could not find Civilization V install directory. Pass -GameDir or set CIV5_DIR. Searched: $searched"
}

function Deploy-ProxyStack {
    param([string]$Game)
    foreach ($f in $ourProxyFiles) { if (-not (Test-Path (Join-Path $proxyDistDir $f))) { throw "Missing built proxy file: $f. Run build-proxy.ps1." } }
    foreach ($f in $tolkFiles) { if (-not (Test-Path (Join-Path $tolkDistDir $f))) { throw "Missing Tolk runtime file: $f" } }
    $stockDll = Join-Path $Game 'lua51_Win32.dll'
    $originalDll = Join-Path $Game 'lua51_original.dll'
    if (Test-Path $originalDll) {
        Write-Host "  lua51_original.dll already present - proxy previously deployed."
    } elseif (Test-Path $stockDll) {
        Write-Host "  Renaming stock lua51_Win32.dll -> lua51_original.dll"
        Rename-Item -LiteralPath $stockDll -NewName 'lua51_original.dll'
    } else {
        throw "Neither lua51_Win32.dll nor lua51_original.dll found in $Game. Verify game files in Steam."
    }
    Write-Host "Copying proxy + Tolk runtime to game directory:"
    foreach ($f in $ourProxyFiles) { Copy-Item -LiteralPath (Join-Path $proxyDistDir $f) -Destination (Join-Path $Game $f) -Force }
    foreach ($f in $tolkFiles) { Copy-Item -LiteralPath (Join-Path $tolkDistDir $f) -Destination (Join-Path $Game $f) -Force }
}

function Clear-OtherInstallStates {
    # Flip away from every other state's artifacts before installing LekMod:
    # the VP/CP modpack packages and the Vox Populi substrate (VPUI fake DLC,
    # the swapped Expansion2.Civ5Pkg, minor-civ sound table, loading tips). All
    # of these auto-load for any DLC present, so leaving them would make a
    # "LekMod" session a hybrid. The VP MODS overlay (the fork DLL + overlaid
    # vendor files under Documents\MODS) is left alone: it is inert in any
    # session that does not enable the VP mod, which LekMod does not.
    param([string]$Game)

    foreach ($name in $modpackNames) {
        $modpackDir = Join-Path $Game "Assets\DLC\$name"
        if (Test-Path $modpackDir) {
            Write-Host "Removing modpack package:"
            Write-Host "  $modpackDir"
            Remove-Item -LiteralPath $modpackDir -Recurse -Force
        }
    }
    Remove-VpSubstrate -Game $Game
}

function Remove-VpSubstrate {
    # Tear down the VP-completion substrate (mirrors deploy.ps1). VPUI is a
    # UISkin DLC and the swapped Expansion2.Civ5Pkg is the always-active BNW
    # manifest, so both load in a no-mod LekMod session. Idempotent: a no-op on
    # an install that was never VP-ified.
    param([string]$Game)

    $vpui = Join-Path $Game "Assets\DLC\VPUI"
    if (Test-Path $vpui) {
        Write-Host "Removing VPUI fake DLC:"
        Write-Host "  $vpui"
        Remove-Item -LiteralPath $vpui -Recurse -Force
    }

    $pkg = Join-Path $Game "Assets\DLC\Expansion2\Expansion2.Civ5Pkg"
    if ((Test-Path $pkg) -and ((Get-Content -LiteralPath $pkg -Raw) -match 'MinorCivSounds_VoxPopuli')) {
        if (Test-Path $stockPkgBackup) {
            Write-Host "Restoring stock BNW Expansion2.Civ5Pkg from backup:"
            Write-Host "  $stockPkgBackup -> $pkg"
            Copy-Item -LiteralPath $stockPkgBackup -Destination $pkg -Force
        } else {
            Write-Host "WARNING: Expansion2.Civ5Pkg is the VP version but no stock backup"
            Write-Host "exists to restore. Verify game files in Steam to restore the stock"
            Write-Host "manifest, or this LekMod session keeps VP's minor-civ sound table."
            Write-Host "  (expected backup: $stockPkgBackup)"
        }
    }

    $minorSounds = Join-Path $Game "Assets\DLC\Expansion2\Sounds\XML\MinorCivSounds_VoxPopuli.xml"
    if (Test-Path $minorSounds) {
        Write-Host "Removing VP minor-civ sound table:"
        Write-Host "  $minorSounds"
        Remove-Item -LiteralPath $minorSounds -Force
    }

    $tips = Join-Path $civ5DocsDir "Text\VPUI_tips_en_us.xml"
    if (Test-Path $tips) {
        Write-Host "Removing VP loading-screen tips:"
        Write-Host "  $tips"
        Remove-Item -LiteralPath $tips -Force
    }
}

function Deploy-LekModDlc {
    param([string]$Game)
    $cloneLekMod = Join-Path $LekModClone 'LEKMOD'
    if (-not (Test-Path (Join-Path $cloneLekMod 'MPModsPack.Civ5Pkg'))) {
        throw "LekMod clone not found at $cloneLekMod (expected its LEKMOD/MPModsPack.Civ5Pkg). Pass -LekModClone."
    }
    if (-not (Test-Path $forkDllSrc)) {
        throw "LekMod fork engine DLL missing: $forkDllSrc. Run build-engine-lekmod.ps1 (or commit the built DLL)."
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
    Write-Host "  $forkDllSrc -> $dst\$engineDllName"
    Copy-Item -LiteralPath $forkDllSrc -Destination (Join-Path $dst $engineDllName) -Force
}

function Deploy-OurDlc {
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

    $cacheDir = Join-Path $civ5DocsDir 'cache'
    if (Test-Path $cacheDir) {
        Write-Host "Clearing DLC cache:"
        Write-Host "  $cacheDir"
        Get-ChildItem -LiteralPath $cacheDir -File | Remove-Item -Force
    }
}

function Deploy-Cinematics {
    param([string]$Game)
    if (-not (Test-Path $cinematicSrcDir)) { throw "Cinematics source directory missing: $cinematicSrcDir" }
    $expansion2Dir = Join-Path $Game 'Assets\DLC\Expansion2'
    if (-not (Test-Path $expansion2Dir)) { throw "BNW (Expansion2) directory not found at $expansion2Dir." }
    foreach ($f in $cinematicFiles) { if (-not (Test-Path (Join-Path $cinematicSrcDir $f))) { throw "Missing cinematic source file: $f" } }
    if (-not (Test-Path $cinematicBackup)) { New-Item -ItemType Directory -Path $cinematicBackup -Force | Out-Null }
    foreach ($f in $cinematicFiles) {
        $installed = Join-Path $expansion2Dir $f
        $backup    = Join-Path $cinematicBackup $f
        if ((Test-Path $installed) -and -not (Test-Path $backup)) { Copy-Item -LiteralPath $installed -Destination $backup -Force }
    }
    Write-Host "Deploying audio-described BNW cinematics."
    foreach ($f in $cinematicFiles) { Copy-Item -LiteralPath (Join-Path $cinematicSrcDir $f) -Destination (Join-Path $expansion2Dir $f) -Force }
}

function Write-InstallManifest {
    param([string]$Game)
    $manifestPath = Join-Path $Game "Assets\DLC\$dlcName\$installManifestName"
    $manifest = [ordered]@{
        schema_version = 1
        mod_version    = $modVersion
        profile        = 'blind'
        variant        = 'lekmod'
        installed_at   = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        lekmod_dlc     = "Assets/DLC/$lekmodDlcName"
    }
    Set-Content -LiteralPath $manifestPath -Value ($manifest | ConvertTo-Json -Depth 5) -Encoding UTF8
    Write-Host "Wrote install manifest: $manifestPath"
}

function Invoke-Uninstall {
    param([string]$Game)
    $stockDll = Join-Path $Game 'lua51_Win32.dll'
    $originalDll = Join-Path $Game 'lua51_original.dll'
    if (Test-Path $originalDll) {
        if (Test-Path $stockDll) { Remove-Item -LiteralPath $stockDll -Force }
        Rename-Item -LiteralPath $originalDll -NewName 'lua51_Win32.dll'
        Write-Host "  Restored stock lua51_Win32.dll"
    }
    foreach ($f in $tolkFiles) { $p = Join-Path $Game $f; if (Test-Path $p) { Remove-Item -LiteralPath $p -Force } }

    $ourDlc = Join-Path $Game "Assets\DLC\$dlcName"
    if (Test-Path $ourDlc) { Write-Host "  Removing our DLC: $ourDlc"; Remove-Item -LiteralPath $ourDlc -Recurse -Force }
    Get-ChildItem -LiteralPath (Join-Path $Game 'Assets\DLC') -Directory -Filter 'LEKMOD*' -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  Removing LekMod DLC: $($_.FullName)"
        Remove-Item -LiteralPath $_.FullName -Recurse -Force
    }

    $proxyLog = Join-Path $Game 'proxy_debug.log'
    if (Test-Path $proxyLog) { Remove-Item -LiteralPath $proxyLog -Force }

    if (Test-Path $cinematicBackup) {
        $expansion2Dir = Join-Path $Game 'Assets\DLC\Expansion2'
        foreach ($f in $cinematicFiles) {
            $backup = Join-Path $cinematicBackup $f
            if (Test-Path $backup) { Copy-Item -LiteralPath $backup -Destination (Join-Path $expansion2Dir $f) -Force }
        }
        Remove-Item -LiteralPath $cinematicBackup -Recurse -Force
    }
    if ((Test-Path $dlcBackupDir) -and ((Get-ChildItem -LiteralPath $dlcBackupDir -Recurse -File | Measure-Object).Count -eq 0)) {
        Remove-Item -LiteralPath $dlcBackupDir -Recurse -Force
    }
    $cacheDir = Join-Path $civ5DocsDir 'cache'
    if (Test-Path $cacheDir) { Get-ChildItem -LiteralPath $cacheDir -File | Remove-Item -Force }
}

# ---- Driver ----
Write-Host "Locating Civilization V install..."
$gameDir = Resolve-CivVInstallDir -ExplicitPath $GameDir
Write-Host "  Game dir: $gameDir"
$dlcBackupDir    = Join-Path $gameDir "Assets\DLC\$dlcBackupDirName"
$cinematicBackup = Join-Path $dlcBackupDir 'cinematics'
$stockPkgBackup  = Join-Path $dlcBackupDir 'Expansion2.Civ5Pkg.stock'

if ($Uninstall) {
    Invoke-Uninstall -Game $gameDir
    Write-Host ""
    Write-Host "LekMod uninstall complete."
    return
}

if (-not $SkipProxy) { Deploy-ProxyStack -Game $gameDir } else { Write-Host "Skipping proxy stack (-SkipProxy)." }
Clear-OtherInstallStates -Game $gameDir
Deploy-LekModDlc -Game $gameDir
Deploy-OurDlc -Game $gameDir
if (-not $SkipCinematics) { Deploy-Cinematics -Game $gameDir } else { Write-Host "Skipping cinematics (-SkipCinematics)." }
Write-InstallManifest -Game $gameDir

Write-Host ""
Write-Host "LekMod deploy complete."
Write-Host "  Game dir: $gameDir"
Write-Host "  Version : $modVersion (variant: LekMod)"
Write-Host ""
Write-Host "Launch from the regular menus (do NOT enable any mods). This install"
Write-Host "state is exclusive with deploy.ps1 (vanilla), deploy-vp.ps1, and the"
Write-Host "modpack states. ./deploy.ps1 flips back to vanilla."
