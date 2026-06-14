<#
.SYNOPSIS
    Deploy Civ V Access in modpack form: our accessibility DLC plus the
    EUI-free Vox Populi modpack DLC, both started from the regular Single
    Player menu. No mod activation, no MODS overlay.

.DESCRIPTION
    The third install state alongside deploy.ps1 (vanilla) and deploy-vp.ps1
    (VP mod-flow); the three are mutually exclusive. This one bakes VP as DLC
    so a plain Single Player launch is a full VP game with the accessibility
    layer over it.

    Shares the proxy/Tolk stack, the cinematics, and the DLC payload build
    with deploy-vp.ps1 (src/dlc + the staged VP vendor overlay + the VP
    EngineData seam). The modpack-specific differences:

      - Our DLC runs at priority 350 so it wins over the modpack's priority
        300 (Priority dominates package sort-order; verified). The mod-flow
        MODS overlay is therefore unnecessary and is not written here.

      - Our DLC's InGame.lua gets a gated block of explicit
        ContextPtr:LoadNewContext calls for the net-new VP/CP contexts. Under
        a DLC the engine's activated-mod addin loop is inert, so without this
        the event popups / overviews / overlays never load. The block is
        gated on that loop having loaded nothing and the CP DLL being present,
        so it is inert in the mod flow and on vanilla.

      - The modpack package (built by build-modpack.ps1 into build/modpack-out)
        is placed at Assets/DLC/ZCivVAccessVP. It embeds our fork DLL, so the
        fork is NOT copied into MODS the way deploy-vp does.

    Run build-modpack.ps1 first; this script refuses to deploy without the
    built package.

.PARAMETER GameDir
    Override the auto-detected Civ V install path.

.PARAMETER ClonePath
    Path to the Community-Patch-DLL clone, used to complete a partial plain-VP
    install (VPUI, the Vox Populi Expansion2.Civ5Pkg, sounds, tips). Defaults
    to the sibling directory next to this repo.

.PARAMETER SkipProxy
    Skip the proxy stack and the legacy lua51 rename.

.PARAMETER SkipCinematics
    Skip the audio-described BNW opening cinematics.

.PARAMETER Uninstall
    Remove the proxy stack, our DLC, the modpack package, and the cinematics
    (restoring stock files from backup). The plain-VP install pieces (VPUI,
    Civ5Pkg, sounds) stay, like deploy-vp's uninstall.
#>
[CmdletBinding()]
param(
    [string]$GameDir,
    [string]$ClonePath,
    [switch]$SkipProxy,
    [switch]$SkipCinematics,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

$repoRoot         = Split-Path -Parent $MyInvocation.MyCommand.Path
$proxyDistDir     = Join-Path $repoRoot 'dist\proxy'
$tolkDistDir      = Join-Path $repoRoot 'third_party\tolk\dist\x86'
$cinematicSrcDir  = Join-Path $repoRoot 'audio described intros'
$dlcSrcDir        = Join-Path $repoRoot 'src\dlc'
$vpSeamSrcFile    = Join-Path $repoRoot 'src\vp\CivVAccess_EngineData.lua'
$vendorStageDir   = Join-Path $repoRoot 'build\vendor\vp'
$soundsSrcDir     = Join-Path $repoRoot 'sounds'
$modpackBuildDir  = Join-Path $repoRoot 'build\modpack-out'
$dlcName          = 'DLC_CivVAccess'
$modpackName      = 'ZCivVAccessVP'   # sorts after Expansion2; priority 300 in its manifest
$dlcBackupDirName = "$dlcName.backup"
$installManifestName = 'CivVAccess.install.json'
$ourDlcPriority   = 350               # beats the modpack's 300

if ([string]::IsNullOrWhiteSpace($ClonePath)) {
    $ClonePath = Join-Path (Split-Path -Parent $repoRoot) 'Community-Patch-DLL'
}

$civ5DocsDir = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5"

$versionsFile = Join-Path $repoRoot 'versions.json'
if (-not (Test-Path $versionsFile)) { throw "versions.json missing at $versionsFile" }
$versions    = Get-Content -LiteralPath $versionsFile -Raw | ConvertFrom-Json
$modVersion  = $versions.mod

$dlcBackupDir       = $null
$cinematicBackup    = $null
$expansionPkgBackup = $null

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

# Gated explicit addin loads for the modpack (DLC) flow. Net-new VP/CP contexts
# (Squads dropped). Appended to our DLC's InGame.lua, which wins at priority 350.
$ingameAddinBlock = @'

-- Civ V Access modpack: load net-new VP/CP contexts explicitly. Under a DLC
-- modpack the engine's activated-mod addin loop (above) is inert and loads
-- nothing, so the net-new contexts never appear. Gated on that loop having
-- loaded nothing AND the CP DLL being present, so the mod-activation flow does
-- not double-load and a vanilla game is untouched.
if Game and Game.IsCustomModOption ~= nil and (g_uiAddins == nil or #g_uiAddins == 0) then
	local civvaccess_modpack_addins = {
		"CameraView", "EventChoicePopupCity", "CityEventPopup", "Destination",
		"EspionageChoicePopup", "EventPopup", "EventChoicePopup", "EventOverview",
		"GlobalCityBombardRange", "CBP_IncaFunctions", "CorporationsOverview",
		"GlobalArchaeologistDigSites", "OverlayAntiquities_MiniMapOverlayHook",
		"OverlayAntiquities", "RandomVCPopup", "VassalageOverview",
	}
	for _, ctx in ipairs(civvaccess_modpack_addins) do
		ContextPtr:LoadNewContext(ctx)
	end
end
'@

function Write-VersionLua {
    param([string]$DlcRoot)
    $dst = Join-Path $DlcRoot 'UI\InGame\CivVAccess_Version.lua'
    $body = @"
-- Generated by deploy-modpack.ps1 from versions.json. Do not edit by hand.
civvaccess_shared = civvaccess_shared or {}
civvaccess_shared.version = "$modVersion"
"@
    [System.IO.File]::WriteAllText($dst, $body, [System.Text.UTF8Encoding]::new($false))
}

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

function Complete-VPInstall {
    param([string]$Game)
    $pieces = @(
        @{ Name = 'VPUI fake DLC'; Src = Join-Path $ClonePath 'VPUI'; Dst = Join-Path $Game 'Assets\DLC\VPUI'; Dir = $true },
        @{ Name = 'minor-civ sound table'; Src = Join-Path $ClonePath 'MinorCivSounds_VoxPopuli.xml'; Dst = Join-Path $Game 'Assets\DLC\Expansion2\Sounds\XML\MinorCivSounds_VoxPopuli.xml'; Dir = $false },
        @{ Name = 'loading screen tips'; Src = Join-Path $ClonePath 'VPUI Text\VPUI_tips_en_us.xml'; Dst = Join-Path $civ5DocsDir 'Text\VPUI_tips_en_us.xml'; Dir = $false }
    )
    foreach ($piece in $pieces) {
        if (Test-Path $piece.Dst) { continue }
        if (-not (Test-Path $piece.Src)) {
            throw "VP install is missing the $($piece.Name) and the clone copy is absent: $($piece.Src). Pass -ClonePath or install Vox Populi first."
        }
        Write-Host "Completing VP install: $($piece.Name)"
        $dstParent = Split-Path -Parent $piece.Dst
        if (-not (Test-Path $dstParent)) { New-Item -ItemType Directory -Path $dstParent -Force | Out-Null }
        Copy-Item -LiteralPath $piece.Src -Destination $piece.Dst -Recurse:$piece.Dir -Force
    }
    $pkgInstalled = Join-Path $Game 'Assets\DLC\Expansion2\Expansion2.Civ5Pkg'
    $pkgSrc = Join-Path $ClonePath 'Expansion2_VoxPopuli.Civ5Pkg'
    if (-not (Test-Path $pkgInstalled)) { throw "BNW package manifest not found at $pkgInstalled. The mod requires BNW." }
    if (-not ((Get-Content -LiteralPath $pkgInstalled -Raw) -match 'MinorCivSounds_VoxPopuli')) {
        if (-not (Test-Path $pkgSrc)) { throw "VP install is missing the Vox Populi Expansion2.Civ5Pkg and the clone copy is absent: $pkgSrc." }
        if (-not (Test-Path $expansionPkgBackup)) {
            $backupDir = Split-Path -Parent $expansionPkgBackup
            if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }
            Write-Host "Backing up stock Expansion2.Civ5Pkg -> $expansionPkgBackup"
            Copy-Item -LiteralPath $pkgInstalled -Destination $expansionPkgBackup -Force
        }
        Write-Host "Completing VP install: Vox Populi Expansion2.Civ5Pkg"
        Copy-Item -LiteralPath $pkgSrc -Destination $pkgInstalled -Force
    }
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
    foreach ($f in $ourProxyFiles) {
        Copy-Item -LiteralPath (Join-Path $proxyDistDir $f) -Destination (Join-Path $Game $f) -Force
    }
    foreach ($f in $tolkFiles) {
        Copy-Item -LiteralPath (Join-Path $tolkDistDir $f) -Destination (Join-Path $Game $f) -Force
    }
}

function Deploy-DlcModpack {
    param([string]$Game)
    $vendorUi = Join-Path $vendorStageDir 'UI'
    if (-not (Test-Path $vendorUi)) { throw "VP vendor stage missing: $vendorUi. Run: py tools/vendoring/vendor.py generate --engine vp" }
    if (-not (Test-Path $vpSeamSrcFile)) { throw "VP EngineData seam missing: $vpSeamSrcFile" }

    $dlcDir = Join-Path $Game "Assets\DLC\$dlcName"
    if (Test-Path $dlcDir) {
        Write-Host "  Removing existing DLC directory: $dlcDir"
        Remove-Item -LiteralPath $dlcDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $dlcDir -Force | Out-Null
    Write-Host "Deploying DLC payload (modpack-shaped) to:"
    Write-Host "  $dlcDir"
    Copy-Item -Path (Join-Path $dlcSrcDir '*') -Destination $dlcDir -Recurse -Force
    # Full VP vendor overlay (every overridden stem, including the mod-overlay
    # stems -- in the modpack flow our DLC wins by priority so there is no MODS
    # overlay to carry them).
    Copy-Item -Path (Join-Path $vendorUi '*') -Destination (Join-Path $dlcDir 'UI') -Recurse -Force
    Copy-Item -LiteralPath $vpSeamSrcFile -Destination (Join-Path $dlcDir 'UI\InGame\CivVAccess_EngineData.lua') -Force
    Write-VersionLua -DlcRoot $dlcDir

    if (Test-Path $soundsSrcDir) {
        $soundsDst = Join-Path $dlcDir 'Sounds'
        New-Item -ItemType Directory -Path $soundsDst -Force | Out-Null
        Copy-Item -Path (Join-Path $soundsSrcDir '*.wav') -Destination $soundsDst -Force
    }

    # Modpack delta 1: priority 350 so we win over the modpack's 300.
    $pkg = Join-Path $dlcDir 'CivVAccess_2.Civ5Pkg'
    (Get-Content -LiteralPath $pkg -Raw) -replace '<Priority>\d+</Priority>', "<Priority>$ourDlcPriority</Priority>" |
        Set-Content -LiteralPath $pkg -Encoding UTF8 -NoNewline
    Write-Host "  Set our DLC priority to $ourDlcPriority"

    # Modpack delta 2: explicit addin loads on the winning InGame.lua.
    $ingame = Join-Path $dlcDir 'UI\InGame\InGame.lua'
    Add-Content -LiteralPath $ingame -Value $ingameAddinBlock -Encoding UTF8
    Write-Host "  Appended net-new-context addin loads to InGame.lua"

    $cacheDir = Join-Path $civ5DocsDir 'cache'
    if (Test-Path $cacheDir) {
        Write-Host "Clearing DLC cache:"
        Write-Host "  $cacheDir"
        Get-ChildItem -LiteralPath $cacheDir -File | Remove-Item -Force
    }
}

function Deploy-ModpackPackage {
    param([string]$Game)
    if (-not (Test-Path (Join-Path $modpackBuildDir 'MPModsPack.Civ5Pkg'))) {
        throw "Built modpack missing at $modpackBuildDir. Run build-modpack.ps1 first."
    }
    $dst = Join-Path $Game "Assets\DLC\$modpackName"
    if (Test-Path $dst) {
        Write-Host "  Removing existing modpack package: $dst"
        Remove-Item -LiteralPath $dst -Recurse -Force
    }
    Write-Host "Placing modpack package (embeds the fork DLL):"
    Write-Host "  $modpackBuildDir -> $dst"
    Copy-Item -LiteralPath $modpackBuildDir -Destination $dst -Recurse -Force
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
        variant        = 'modpack'
        installed_at   = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        modpack        = "Assets/DLC/$modpackName"
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
    foreach ($name in @($dlcName, $modpackName)) {
        $d = Join-Path $Game "Assets\DLC\$name"
        if (Test-Path $d) { Write-Host "  Removing $d"; Remove-Item -LiteralPath $d -Recurse -Force }
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
$dlcBackupDir       = Join-Path $gameDir "Assets\DLC\$dlcBackupDirName"
$cinematicBackup    = Join-Path $dlcBackupDir 'cinematics'
$expansionPkgBackup = Join-Path $dlcBackupDir 'Expansion2.Civ5Pkg.stock'

if ($Uninstall) {
    Invoke-Uninstall -Game $gameDir
    Write-Host ""
    Write-Host "Modpack uninstall complete. The plain-VP install (VPUI, Civ5Pkg, sounds) remains."
    return
}

Complete-VPInstall -Game $gameDir
if (-not $SkipProxy) { Deploy-ProxyStack -Game $gameDir } else { Write-Host "Skipping proxy stack (-SkipProxy)." }
Deploy-DlcModpack -Game $gameDir
Deploy-ModpackPackage -Game $gameDir
if (-not $SkipCinematics) { Deploy-Cinematics -Game $gameDir } else { Write-Host "Skipping cinematics (-SkipCinematics)." }
Write-InstallManifest -Game $gameDir

Write-Host ""
Write-Host "Modpack deploy complete."
Write-Host "  Game dir: $gameDir"
Write-Host "  Version : $modVersion (modpack variant)"
Write-Host ""
Write-Host "Launch from the regular Single Player menu (do NOT enable any mods)."
Write-Host "This install state is exclusive with deploy.ps1 (vanilla) and"
Write-Host "deploy-vp.ps1 (VP mod flow)."
