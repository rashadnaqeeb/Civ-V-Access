<#
.SYNOPSIS
    Shared assembly of the modded DLC_CivVAccess payload.

.DESCRIPTION
    Dot-sourced by deploy-modpack.ps1, deploy-lekmod.ps1, and
    package-release.ps1 so the three never drift on how the modded accessibility
    DLC is built. The payload is the vanilla src/dlc tree with:

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

# Resolve LekMod's standard-UI set into Lua\UI: clear it, then copy every
# tmp/ui body in de-ignored and flattened by stem (the engine indexes UI by bare
# stem, and ui_check writes flat names too). tmp/ui is purely standard sources --
# EUI variants live in tmp/eui -- so reading only tmp/ui forces the standard set
# regardless of any EUI present. Drops tmp/ afterwards.
function Resolve-CivVAccessLekModStandardUI {
    param([Parameter(Mandatory)][string]$LekModDir)
    $tmpUi = Join-Path $LekModDir 'Lua\tmp\ui'
    if (-not (Test-Path $tmpUi)) { throw "LekMod tmp/ui not found at $tmpUi (clone incomplete?)." }
    $uiDest = Join-Path $LekModDir 'Lua\UI'
    if (Test-Path $uiDest) { Remove-Item -LiteralPath $uiDest -Recurse -Force }
    New-Item -ItemType Directory -Path $uiDest -Force | Out-Null
    $copied = 0
    foreach ($f in Get-ChildItem -LiteralPath $tmpUi -Recurse -File) {
        $name = $f.Name
        if ($name -match '\.ignore$') { $name = $name.Substring(0, $name.Length - '.ignore'.Length) }
        if ($name -notmatch '\.(lua|xml)$') { continue }
        Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $uiDest $name) -Force
        $copied++
    }
    Write-Host "  Resolved $copied standard-UI files into Lua\UI"
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
