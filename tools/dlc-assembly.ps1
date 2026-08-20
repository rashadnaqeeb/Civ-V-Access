<#
.SYNOPSIS
    Shared assembly of the modded DLC_CivVAccess payload, plus the
    install-dir / Vox Populi substrate helpers the deploy scripts share.

.DESCRIPTION
    Dot-sourced by deploy.ps1, stage-vp-modpack-bake.ps1, and
    package-release.ps1 so they never drift on how the modded accessibility
    DLC is built or how the VP substrate is laid down and torn down. Carries
    two groups of helpers: the install-dir resolver and VP-substrate set
    (Resolve-CivVInstallDir, Complete-VPInstall, Remove-VpSubstrate,
    Backup-StockExpansionPkg, Resolve-VpAsset, the MODS fork DLL place/restore,
    Enable-DatabaseValidation), and the modded-DLC assembly below. The payload
    is the vanilla src/dlc tree with:

      - the per-engine vendor UI overlay laid on top,
      - the EngineData seam swapped to the engine's body,
      - the version Lua written,
      - the accessibility sounds copied in,
      - our DLC manifest's Priority raised (so we win the stems we override),
      - and, for the Vox Populi / Community Patch modpack flow only, the
        net-new-context addin loads appended to InGame.lua.

    The deploy scripts call this with the game's DLC dir as the destination;
    package-release.ps1 calls it with a staging dir, then derives the release
    overlay from the result.
#>

# ---------------------------------------------------------------------------
# Install-dir resolution and the Vox Populi substrate helpers, shared by
# deploy.ps1 and stage-vp-modpack-bake.ps1. These read a handful of caller
# script-scope variables (the same pattern the deploy scripts have always
# used): $ClonePath, $civ5DocsDir, $vpRuntimeDir, $expansionPkgBackup,
# $engineVpDistDir, $vpModsDllDir, $engineVpBackup, $engineDllName. Each
# dot-sourcing script defines what it needs before calling.
# ---------------------------------------------------------------------------

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
                $vdfMatches = [regex]::Matches($raw, '"path"\s*"([^"]+)"')
                foreach ($m in $vdfMatches) {
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

# VP-completion assets come from build/vp-runtime when pre-staged there, else the
# maintainer's Community-Patch-DLL clone. The pre-staged path lets a tester run
# the modpack deploy with no clone on disk.
function Resolve-VpAsset {
    param([string]$RuntimeName, [string]$CloneRelative)
    $rt = Join-Path $vpRuntimeDir $RuntimeName
    if (Test-Path $rt) { return $rt }
    return (Join-Path $ClonePath $CloneRelative)
}

# Completes a partial plain-VP install: the VPUI fake DLC, the Vox Populi
# Expansion2.Civ5Pkg (an added AudioGameData line over stock), the minor-civ
# sound table, and the loading-screen tips. Each piece deploys only when absent,
# so an install the VP installer already set up is left untouched. The Civ5Pkg
# is overwritten in place (unlike the additive pieces), so its stock form is
# backed up to $expansionPkgBackup first. Idempotent.
function Complete-VPInstall {
    param([string]$Game)
    $pieces = @(
        @{ Name = 'VPUI fake DLC'; Src = (Resolve-VpAsset 'VPUI' 'VPUI'); Dst = Join-Path $Game 'Assets\DLC\VPUI'; Dir = $true },
        @{ Name = 'minor-civ sound table'; Src = (Resolve-VpAsset 'MinorCivSounds_VoxPopuli.xml' 'MinorCivSounds_VoxPopuli.xml'); Dst = Join-Path $Game 'Assets\DLC\Expansion2\Sounds\XML\MinorCivSounds_VoxPopuli.xml'; Dir = $false },
        @{ Name = 'loading screen tips'; Src = (Resolve-VpAsset 'VPUI_tips_en_us.xml' 'VPUI Text\VPUI_tips_en_us.xml'); Dst = Join-Path $civ5DocsDir 'Text\VPUI_tips_en_us.xml'; Dir = $false }
    )
    foreach ($piece in $pieces) {
        if (Test-Path $piece.Dst) { continue }
        if (-not (Test-Path $piece.Src)) {
            throw "VP install is missing the $($piece.Name) and it is in neither build/vp-runtime nor the clone: $($piece.Src). Pass -ClonePath or put the Community-Patch-DLL clone (on the civvaccess branch) beside the repo."
        }
        Write-Host "Completing VP install: $($piece.Name)"
        $dstParent = Split-Path -Parent $piece.Dst
        if (-not (Test-Path $dstParent)) { New-Item -ItemType Directory -Path $dstParent -Force | Out-Null }
        Copy-Item -LiteralPath $piece.Src -Destination $piece.Dst -Recurse:$piece.Dir -Force
    }
    $pkgInstalled = Join-Path $Game 'Assets\DLC\Expansion2\Expansion2.Civ5Pkg'
    $pkgSrc = Resolve-VpAsset 'Expansion2_VoxPopuli.Civ5Pkg' 'Expansion2_VoxPopuli.Civ5Pkg'
    if (-not (Test-Path $pkgInstalled)) { throw "BNW package manifest not found at $pkgInstalled. The mod requires BNW." }
    if (-not ((Get-Content -LiteralPath $pkgInstalled -Raw) -match 'MinorCivSounds_VoxPopuli')) {
        if (-not (Test-Path $pkgSrc)) { throw "VP install is missing the Vox Populi Expansion2.Civ5Pkg and neither the bundle nor the clone has it: $pkgSrc." }
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

# Capture the stock BNW Expansion2.Civ5Pkg the moment we see it stock, so a
# later flip out of VP/modpack state can restore it. No-op once captured or once
# the on-disk manifest is already the VP version.
function Backup-StockExpansionPkg {
    param([string]$Game)
    $pkg = Join-Path $Game "Assets\DLC\Expansion2\Expansion2.Civ5Pkg"
    if (-not (Test-Path $pkg)) { return }
    if ((Get-Content -LiteralPath $pkg -Raw) -match 'MinorCivSounds_VoxPopuli') { return }  # already VP, not stock
    if (Test-Path $expansionPkgBackup) { return }                                            # already captured
    $backupDir = Split-Path -Parent $expansionPkgBackup
    if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }
    Write-Host "Capturing stock BNW Expansion2.Civ5Pkg backup:"
    Write-Host "  $pkg -> $expansionPkgBackup"
    Copy-Item -LiteralPath $pkg -Destination $expansionPkgBackup -Force
}

# Tear down the Vox Populi substrate so a no-mod (vanilla / CP-only / LekMod)
# session is genuinely free of VP. VPUI is a UISkin DLC and the swapped
# Expansion2.Civ5Pkg is the always-active BNW manifest, so both load even with
# no mod enabled. Restores the stock Civ5Pkg from $expansionPkgBackup when one
# exists. Idempotent on an install that was never VP-ified.
function Remove-VpSubstrate {
    param([string]$Game)

    $vpui = Join-Path $Game "Assets\DLC\VPUI"
    if (Test-Path $vpui) {
        Write-Host "Removing VPUI fake DLC:"
        Write-Host "  $vpui"
        Remove-Item -LiteralPath $vpui -Recurse -Force
    }

    $pkg = Join-Path $Game "Assets\DLC\Expansion2\Expansion2.Civ5Pkg"
    if ((Test-Path $pkg) -and ((Get-Content -LiteralPath $pkg -Raw) -match 'MinorCivSounds_VoxPopuli')) {
        if (Test-Path $expansionPkgBackup) {
            Write-Host "Restoring stock BNW Expansion2.Civ5Pkg from backup:"
            Write-Host "  $expansionPkgBackup -> $pkg"
            Copy-Item -LiteralPath $expansionPkgBackup -Destination $pkg -Force
        } else {
            Write-Host "WARNING: Expansion2.Civ5Pkg is the VP version but no stock backup"
            Write-Host "exists to restore. This install cannot be made fully vanilla here;"
            Write-Host "verify game files in Steam to restore the stock manifest."
            Write-Host "  (expected backup: $expansionPkgBackup)"
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

# Place our Community-Patch-DLL fork over VP's shipped DLL in MODS\(1) Community
# Patch\ (where VP loads its DLL from), backing up VP's DLL to $engineVpBackup on
# first run. Used by stage-vp-modpack-bake.ps1 for the merged-DB session.
function Install-VpForkDll {
    $stagedDll = Join-Path $engineVpDistDir $engineDllName
    if (-not (Test-Path $stagedDll)) {
        throw "Built VP fork DLL missing: $stagedDll. Build it from the clone's civvaccess branch (build_vp_clang_sdk.py) and copy to dist/engine-vp/, or use the committed artifact."
    }
    $installedDll = Join-Path $vpModsDllDir $engineDllName
    if (-not (Test-Path $installedDll)) {
        throw "VP's engine DLL not found at $installedDll. Install Vox Populi first (the MODS folders are managed by VP's installer / the re-pin sync)."
    }
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

# Restore VP's shipped DLL into MODS from $engineVpBackup and remove the backup.
function Restore-VpForkDll {
    if (Test-Path $engineVpBackup) {
        $installedDll = Join-Path $vpModsDllDir $engineDllName
        Write-Host "  Restoring VP's shipped engine DLL from backup:"
        Write-Host "    $engineVpBackup -> $installedDll"
        Copy-Item -LiteralPath $engineVpBackup -Destination $installedDll -Force
        Remove-Item -LiteralPath $engineVpBackup -Force
    } else {
        Write-Host "  No VP engine DLL backup present; skipping engine restore."
    }
}

# The merged gameplay database the modpack bake consumes (cache\Civ5DebugDatabase.db)
# is only PERSISTED during the engine's database-validation pass, gated on
# ValidateGameDatabase=1 in config.ini. With it off, the DB compiles in memory and
# the session plays fine, but Civ5DebugDatabase.db is left empty and the bake has
# nothing to read. Turn it on for the merged-DB-generation state.
function Enable-DatabaseValidation {
    param([string]$DocsDir)
    $cfg = Join-Path $DocsDir 'config.ini'
    if (-not (Test-Path $cfg)) {
        Write-Host "config.ini not found at $cfg -- set ValidateGameDatabase=1 by hand before the merged-DB session." -ForegroundColor Yellow
        return
    }
    $content = Get-Content -LiteralPath $cfg -Raw
    if ($content -match '(?m)^\s*ValidateGameDatabase\s*=\s*1\s*$') {
        Write-Host "config.ini: ValidateGameDatabase already 1 (debug DB will persist)."
        return
    }
    if ($content -match '(?m)^\s*ValidateGameDatabase\s*=') {
        $content = $content -replace '(?m)^\s*ValidateGameDatabase\s*=.*$', 'ValidateGameDatabase = 1'
    } else {
        $content = $content.TrimEnd() + "`r`nValidateGameDatabase = 1`r`n"
    }
    [System.IO.File]::WriteAllText($cfg, $content)
    Write-Host "config.ini: set ValidateGameDatabase = 1 so Civ5DebugDatabase.db persists for the bake."
}

# Net-new VP / CP contexts the modpack (DLC) flow must load explicitly, because
# under a baked DLC the engine's activated-mod addin loop is inert. This list
# MUST match build_modpack.py's ADDINS / CP_ADDINS for the matching mode (the
# modpack's own InGame.lua uses that copy; ours wins by priority). CP-only loads
# only Community Patch's set -- no Corporations / Vassalage / RandomVC /
# antiquities contexts (those are Vox Populi's).
function Get-CivVAccessIngameAddinBlock {
    param([Parameter(Mandatory)][ValidateSet('vp', 'cp')][string]$Engine)

    $vpAddins = @(
        'CameraView', 'EventChoicePopupCity', 'CityEventPopup', 'Destination',
        'EspionageChoicePopup', 'EventPopup', 'EventChoicePopup', 'EventOverview',
        'GlobalCityBombardRange', 'CBP_IncaFunctions', 'CorporationsOverview',
        'GlobalArchaeologistDigSites', 'OverlayAntiquities_MiniMapOverlayHook',
        'OverlayAntiquities', 'RandomVCPopup', 'VassalageOverview'
    )
    $cpAddins = @(
        'CameraView', 'EventChoicePopupCity', 'CityEventPopup', 'Destination',
        'EspionageChoicePopup', 'EventPopup', 'EventChoicePopup', 'EventOverview',
        'GlobalCityBombardRange'
    )
    $addins = if ($Engine -eq 'cp') { $cpAddins } else { $vpAddins }
    $addinLuaList = ($addins | ForEach-Object { "`t`t`"$_`"," }) -join "`r`n"

    return @"

-- Civ V Access modpack: load net-new VP/CP contexts explicitly. Under a DLC
-- modpack the engine's activated-mod addin loop (above) is inert and loads
-- nothing, so the net-new contexts never appear. Gated on that loop having
-- loaded nothing AND the CP DLL being present, so the mod-activation flow does
-- not double-load and a vanilla game is untouched.
if Game and Game.IsCustomModOption ~= nil and (g_uiAddins == nil or #g_uiAddins == 0) then
	local civvaccess_modpack_addins = {
$addinLuaList
	}
	for _, ctx in ipairs(civvaccess_modpack_addins) do
		ContextPtr:LoadNewContext(ctx)
	end
end
"@
}

# Write CivVAccess_Version.lua into a DLC tree. UTF-8 WITHOUT a BOM: Civ V's
# Lua 5.1 loader treats a BOM as a syntax error on line 1, which silently kills
# the file's globals (boot speech then says "version unknown").
function Write-CivVAccessVersionLua {
    param(
        [Parameter(Mandatory)][string]$DlcRoot,
        [Parameter(Mandatory)][string]$ModVersion
    )
    $dst = Join-Path $DlcRoot 'UI\InGame\CivVAccess_Version.lua'
    $body = @"
-- Generated from versions.json. Do not edit by hand; edits are overwritten on
-- the next deploy or package run.
civvaccess_shared = civvaccess_shared or {}
civvaccess_shared.version = "$ModVersion"
"@
    [System.IO.File]::WriteAllText($dst, $body, [System.Text.UTF8Encoding]::new($false))
}

# Resolve LekMod's standard-UI set into Lua\UI: copy every tmp/ui body in
# de-ignored and flattened by stem (the engine indexes UI by bare stem, and
# ui_check writes flat names too). tmp/ui is purely standard sources --
# EUI variants live in tmp/eui -- so reading only tmp/ui forces the standard set
# regardless of any EUI present. Drops tmp/ afterwards.
#
# Whatever LekMod ships in Lua\UI that tmp/ui has no body for stays put: those
# files are part of the standard set too, reached by stem from a tmp/ui screen
# (the city-state personality helper) rather than staged with it. ui_check.bat
# keeps the same files by backing each one up around its wipe.
#
# The exception is a screen our own accessibility overlay also ships, named by
# $OverlayUiDir. Our copy wins that stem on priority, so keeping LekMod's half
# of the screen would pair its layout against our body -- which is bodied from
# whatever root the vendor chain resolved, not necessarily LekMod's. Both
# halves of such a screen go, matched on the bare stem, so a leftover layout
# cannot outlive the body it belongs to. The sighted profile ships no overlay
# and passes nothing, which leaves LekMod's own pairs intact.
#
# Then the stamp: LekMod's FrontEnd holds the main menu behind its legal screen
# until LekmodUiConfigured reports the standard UI resolved, which ui_check.bat
# writes at the end of its run. This function is our ui_check, so it writes it.
function Resolve-CivVAccessLekModStandardUI {
    param(
        [Parameter(Mandatory)][string]$LekModDir,
        [string]$OverlayUiDir
    )
    $tmpUi = Join-Path $LekModDir 'Lua\tmp\ui'
    if (-not (Test-Path $tmpUi)) { throw "LekMod tmp/ui not found at $tmpUi (clone incomplete?)." }
    $uiDest = Join-Path $LekModDir 'Lua\UI'
    New-Item -ItemType Directory -Path $uiDest -Force | Out-Null

    if ($OverlayUiDir) {
        if (-not (Test-Path $OverlayUiDir)) { throw "Vendor overlay UI not found at $OverlayUiDir. Run: py tools/vendoring/vendor.py generate --engine lekmod --out build/vendor/lekmod" }
        # Bare stems tmp/ui stages, and bare stems our overlay ships.
        $staged = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
        foreach ($f in Get-ChildItem -LiteralPath $tmpUi -Recurse -File) {
            $n = $f.Name -replace '\.ignore$', ''
            if ($n -match '\.(lua|xml)$') { [void]$staged.Add([System.IO.Path]::GetFileNameWithoutExtension($n)) }
        }
        $ours = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
        foreach ($f in Get-ChildItem -LiteralPath $OverlayUiDir -Recurse -File -Include '*.lua', '*.xml') {
            [void]$ours.Add($f.BaseName)
        }
        foreach ($f in Get-ChildItem -LiteralPath $uiDest -File) {
            if (-not $staged.Contains($f.BaseName) -and $ours.Contains($f.BaseName)) {
                Remove-Item -LiteralPath $f.FullName -Force
            }
        }
    }

    $copied = 0
    foreach ($f in Get-ChildItem -LiteralPath $tmpUi -Recurse -File) {
        $name = $f.Name
        if ($name -match '\.ignore$') { $name = $name.Substring(0, $name.Length - '.ignore'.Length) }
        if ($name -notmatch '\.(lua|xml)$') { continue }
        Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $uiDest $name) -Force
        $copied++
    }
    Write-Host "  Resolved $copied standard-UI files into Lua\UI"
    $stamp = Join-Path $uiDest 'LekmodUiConfigured.lua'
    [System.IO.File]::WriteAllText($stamp, "LekmodUiConfigured = true`r`n", [System.Text.UTF8Encoding]::new($false))
    Write-Host "  Wrote the ui_check stamp: LekmodUiConfigured.lua"
    $tmp = Join-Path $LekModDir 'Lua\tmp'
    if (Test-Path $tmp) { Remove-Item -LiteralPath $tmp -Recurse -Force }
}

# The vanilla core DLC payload (src/dlc + version lua + sounds), recreated from
# scratch in $DestDir. Both the modded-DLC assembly and the release core-blind
# component build through this, so they can't disagree on what "core" is (which
# is what keeps the release overlay diff from leaking core files).
function Copy-CivVAccessCoreDlc {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$DestDir,
        [Parameter(Mandatory)][string]$DlcSrcDir,
        [Parameter(Mandatory)][string]$ModVersion,
        [string]$SoundsSrcDir
    )
    if (Test-Path $DestDir) { Remove-Item -LiteralPath $DestDir -Recurse -Force }
    New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    Copy-Item -Path (Join-Path $DlcSrcDir '*') -Destination $DestDir -Recurse -Force
    Write-CivVAccessVersionLua -DlcRoot $DestDir -ModVersion $ModVersion
    if ($SoundsSrcDir -and (Test-Path $SoundsSrcDir)) {
        $soundsDst = Join-Path $DestDir 'Sounds'
        New-Item -ItemType Directory -Path $soundsDst -Force | Out-Null
        Copy-Item -Path (Join-Path $SoundsSrcDir '*.wav') -Destination $soundsDst -Force
    }
}

# Assemble the complete modded DLC_CivVAccess payload into $DestDir.
# $Engine is 'vp', 'cp', or 'lekmod'. $VendorStageDir is build/vendor/<engine>
# (its UI subdir is overlaid). $SeamFile is the engine's CivVAccess_EngineData.lua
# (src/vp for vp+cp, src/lekmod for lekmod). Recreates $DestDir from scratch.
function New-CivVAccessModdedDlc {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$DestDir,
        [Parameter(Mandatory)][ValidateSet('vp', 'cp', 'lekmod')][string]$Engine,
        [Parameter(Mandatory)][string]$DlcSrcDir,
        [Parameter(Mandatory)][string]$VendorStageDir,
        [Parameter(Mandatory)][string]$SeamFile,
        [Parameter(Mandatory)][string]$ModVersion,
        [string]$SoundsSrcDir,
        [int]$Priority = 350
    )

    $vendorUi = Join-Path $VendorStageDir 'UI'
    if (-not (Test-Path $vendorUi)) {
        throw "Vendor stage missing: $vendorUi. Run: py tools/vendoring/vendor.py generate --engine $Engine --out build/vendor/$Engine"
    }
    if (-not (Test-Path $SeamFile)) { throw "EngineData seam missing: $SeamFile" }

    # Core payload first (shared builder), then the mod deltas on top.
    Copy-CivVAccessCoreDlc -DestDir $DestDir -DlcSrcDir $DlcSrcDir -ModVersion $ModVersion -SoundsSrcDir $SoundsSrcDir

    # Vendor overlay: every overridden stem (the engine-bodied files carry their
    # mod body + our appended include; the rest are vanilla-body fallthroughs).
    Copy-Item -Path (Join-Path $vendorUi '*') -Destination (Join-Path $DestDir 'UI') -Recurse -Force
    Copy-Item -LiteralPath $SeamFile -Destination (Join-Path $DestDir 'UI\InGame\CivVAccess_EngineData.lua') -Force

    # Raise our DLC priority so we win the stems both we and the modpack /
    # LekMod ship (their packages sit at 300).
    $pkg = Join-Path $DestDir 'CivVAccess_2.Civ5Pkg'
    (Get-Content -LiteralPath $pkg -Raw) -replace '<Priority>\d+</Priority>', "<Priority>$Priority</Priority>" |
        Set-Content -LiteralPath $pkg -Encoding UTF8 -NoNewline

    # Modpack flow only: explicit net-new-context loads on the winning InGame.lua.
    # LekMod loads its contexts through its own DLC, so it needs no block.
    if ($Engine -eq 'vp' -or $Engine -eq 'cp') {
        $ingame = Join-Path $DestDir 'UI\InGame\InGame.lua'
        Add-Content -LiteralPath $ingame -Value (Get-CivVAccessIngameAddinBlock -Engine $Engine) -Encoding UTF8
    }
}
