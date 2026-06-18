<#
.SYNOPSIS
    Re-pin Civ V Access's Vox Populi support to a new Community Patch / Vox
    Populi release: rebase + rebuild the engine fork, re-sync the installed
    MODS folders, re-stage the vendor overlay, then deploy and record the
    new supported version.

.DESCRIPTION
    Codifies the proven hand re-pin run (.planning/vp-port.md, remaining-work
    item 4). It is a guided orchestrator, not a fire-and-forget job: the
    mechanical steps run autonomously, but the two places a re-pin actually
    breaks -- the vendoring drift report and the engine Lua-binding value
    audit -- are surfaced as a hard review stop, and the engine DLL never
    advances past the canary gate.

    Phases, in order:

      engine  Fetch upstream tags, rebase the civvaccess fork branch from the
              old pin onto the new tag (the build-fix commit stays at the
              base), rebuild the DLL with build_vp_clang_sdk.py, run the
              va_start canary, and -- only on GOOD -- copy the DLL into
              dist/engine-vp. The fork branch is snapshotted to
              civvaccess-resync-backup first; a rebase conflict aborts and
              restores it, then stops with the conflicting commit named.

      mods    Mirror the clone's (1) Community Patch / (2) Vox Populi folders
              onto the installed MODS folders byte-for-byte, deletions
              included. This reverts our overlay to pristine; the vendor and
              finish phases re-apply it.

      vendor  Run the vendoring tool's vanilla verify (must still reproduce
              the committed tree byte-for-byte) and re-stage the VP overlay,
              then write the old..new Lua-binding diff for the value audit.
              Stops here for human review.

      finish  (Requires -ReviewConfirmed.) Deploy the VP stack (the transient
              mod-overlay used to generate the merged database and smoke-test
              the fork) and record the new pin in versions.json. Run only
              after reviewing the drift report and the binding diff. Leaves
              the install in mod-overlay state; the modpack phase lands it
              back in the player-facing state.

      modpack A terminal phase. After a clean CP+VP session has produced a
              fresh merged database (build-modpack refuses a modpack-launch
              cache), bake the VP modpack and deploy it, leaving the install in
              the player-facing VP modpack state where the play audit runs.

      cp-modpack
              The other terminal phase, for the Community-Patch-only modpack.
              It reuses the same re-pinned fork DLL, CP body, and cp vendor
              stage, but bakes from a DIFFERENT cache -- a CP-only session
              (BALANCE_VP off), not the CP+VP session the VP modpack uses --
              so it cannot share the modpack phase's run. Produce a CP-only
              merged DB first (flip to vanilla, enable ONLY (1) Community Patch
              through the Mods menu, play to the map, quit), then run this.

    With no -Phase, the script runs engine, mods, and vendor, then stops with
    the review checklist and the exact finish command. finish, modpack, and
    cp-modpack are never part of an unattended run.

.PARAMETER NewTag
    The Community-Patch-DLL release tag to pin to (e.g. Release-5.3.3). Pass
    the current pin to dry-run the plumbing as a near no-op smoke test.

.PARAMETER Phase
    Run a single phase (engine | mods | vendor | finish | modpack | cp-modpack)
    instead of the default engine->mods->vendor sequence. Use to resume after
    fixing a recipe or to re-run a step.

.PARAMETER ClonePath
    Path to the Community-Patch-DLL clone (fork branch civvaccess). Defaults
    to the sibling directory next to this repo.

.PARAMETER ModsDir
    Override the auto-detected installed MODS directory (holds (1) Community
    Patch / (2) Vox Populi).

.PARAMETER ReviewConfirmed
    Required by the finish phase. Asserts you have read the drift report and
    the Lua-binding diff, and added any newly drifted getter to the lint seam
    guard's name list.

.PARAMETER SkipBuild
    Reuse the DLL already at clang-output/Release instead of rebuilding.
    Engine-phase debugging only; the rebase and canary still run.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$NewTag,
    [ValidateSet('engine', 'mods', 'vendor', 'finish', 'modpack', 'cp-modpack')]
    [string]$Phase,
    [string]$ClonePath,
    [string]$ModsDir,
    [switch]$ReviewConfirmed,
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'

$repoRoot     = Split-Path -Parent $MyInvocation.MyCommand.Path
$versionsPath = Join-Path $repoRoot 'versions.json'
$forkDllDest  = Join-Path $repoRoot 'dist\engine-vp\CvGameCore_Expansion2.dll'
$canaryScript = Join-Path $repoRoot 'tools\vp_dll_canary.py'
$vendorScript = Join-Path $repoRoot 'tools\vendoring\vendor.py'
$vendorStage  = Join-Path $repoRoot 'build\vendor\vp'
$reviewDir    = Join-Path $repoRoot 'build\resync'
$backupBranch = 'civvaccess-resync-backup'
$modNames     = @('(1) Community Patch', '(2) Vox Populi')

if ([string]::IsNullOrWhiteSpace($ClonePath)) {
    $ClonePath = Join-Path (Split-Path -Parent $repoRoot) 'Community-Patch-DLL'
}
$ClonePath = (Resolve-Path -LiteralPath $ClonePath).Path

if ([string]::IsNullOrWhiteSpace($ModsDir)) {
    $civ5Docs = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5"
    $ModsDir  = Join-Path $civ5Docs 'MODS'
}

# ---------------------------------------------------------------- helpers

function Write-Step { param([string]$Text) Write-Host "`n=== $Text ===" -ForegroundColor Cyan }

# Run a native command and throw on a nonzero exit. PowerShell does not do
# this on its own, and a swallowed build / git failure is exactly the silent
# break this script exists to prevent.
function Invoke-Native {
    param([string]$Exe, [string[]]$Args, [string]$What)
    & $Exe @Args
    if ($LASTEXITCODE -ne 0) {
        throw "$What failed (exit $LASTEXITCODE): $Exe $($Args -join ' ')"
    }
}

function Get-Git {
    param([string[]]$Args)
    $out = & git -C $ClonePath @Args 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Args -join ' ') failed: $out"
    }
    return ($out | Out-String).Trim()
}

function Get-SupportedVp {
    (Get-Content -LiteralPath $versionsPath -Raw | ConvertFrom-Json).supported_vp
}

function Set-SupportedVp {
    param([string]$Tag)
    $raw = Get-Content -LiteralPath $versionsPath -Raw
    if ($raw -notmatch '"supported_vp"\s*:\s*"[^"]*"') {
        throw "versions.json has no supported_vp field to update."
    }
    $raw = $raw -replace '("supported_vp"\s*:\s*")[^"]*(")', "`${1}$Tag`${2}"
    # Preserve the file's hand formatting; targeted replace, no reserialize.
    [System.IO.File]::WriteAllText($versionsPath, $raw)
}

function Assert-CleanCloneOnFork {
    $branch = Get-Git @('symbolic-ref', '--short', 'HEAD')
    if ($branch -ne 'civvaccess') {
        throw "Clone is on '$branch', not civvaccess. Checkout the fork branch before re-pinning."
    }
    $dirty = Get-Git @('status', '--porcelain')
    if ($dirty) {
        throw "Clone working tree is dirty; commit or stash before re-pinning:`n$dirty"
    }
}

# ---------------------------------------------------------------- phases

function Invoke-EnginePhase {
    param([string]$OldTag)

    Write-Step "Engine fork: $OldTag -> $NewTag"
    Assert-CleanCloneOnFork

    Write-Host "Fetching upstream tags..."
    Get-Git @('fetch', 'origin', '--tags') | Out-Null
    try { Get-Git @('rev-parse', '--verify', "refs/tags/$NewTag^{commit}") | Out-Null }
    catch { throw "Tag $NewTag not found in the clone after fetch. Check the tag name." }
    try { Get-Git @('rev-parse', '--verify', "refs/tags/$OldTag^{commit}") | Out-Null }
    catch { throw "Old pin $OldTag (from versions.json) is not a tag in the clone." }

    if ($NewTag -eq $OldTag) {
        Write-Host "NewTag equals the current pin: this is a no-op re-pin / plumbing smoke test." -ForegroundColor Yellow
    }

    $replay = Get-Git @('log', '--oneline', "$OldTag..civvaccess")
    Write-Host "Fork commits to replay onto ${NewTag}:`n$replay"

    Write-Host "Snapshotting civvaccess to $backupBranch..."
    Get-Git @('branch', '-f', $backupBranch, 'civvaccess') | Out-Null

    Write-Host "Rebasing..."
    & git -C $ClonePath rebase --onto $NewTag $OldTag civvaccess 2>&1 | Write-Host
    if ($LASTEXITCODE -ne 0) {
        $stopped = (& git -C $ClonePath log -1 --oneline REBASE_HEAD 2>$null | Out-String).Trim()
        & git -C $ClonePath rebase --abort 2>$null | Out-Null
        Get-Git @('reset', '--hard', $backupBranch) | Out-Null
        throw "Rebase onto $NewTag hit a conflict (near: $stopped). Branch restored from $backupBranch. Resolve the port commits by hand, then re-run -Phase engine."
    }

    # The canary's version immediate must match upstream's MOD_DLL_VERSION_NUMBER.
    $customMods = Join-Path $ClonePath 'CvGameCoreDLL_Expansion2\CustomMods.h'
    $verLine = Select-String -LiteralPath $customMods -Pattern '#define\s+MOD_DLL_VERSION_NUMBER\s+\(\(uint\)\s*(\d+)\)' | Select-Object -First 1
    if ($verLine) {
        $verNum = [int]$verLine.Matches[0].Groups[1].Value
        $verHex = '$0x{0:x}' -f $verNum
        $canaryImm = (Select-String -LiteralPath $canaryScript -Pattern "VERSION_IMM\s*=\s*'([^']+)'" | Select-Object -First 1).Matches[0].Groups[1].Value
        if ($verHex -ne $canaryImm) {
            throw "MOD_DLL_VERSION_NUMBER is now $verNum ($verHex) but the canary's VERSION_IMM is $canaryImm. Update VERSION_IMM in tools/vp_dll_canary.py, then re-run -Phase engine."
        }
        Write-Host "MOD_DLL_VERSION_NUMBER $verNum matches the canary ($canaryImm)."
    }

    $builtDll = Join-Path $ClonePath 'clang-output\Release\CvGameCore_Expansion2.dll'
    if ($SkipBuild) {
        Write-Host "SkipBuild: reusing existing $builtDll" -ForegroundColor Yellow
        if (-not (Test-Path $builtDll)) { throw "No DLL at $builtDll to reuse." }
    }
    else {
        Write-Host "Building the fork DLL (build_vp_clang_sdk.py --config release)..."
        Push-Location $ClonePath
        try { Invoke-Native 'py' @('build_vp_clang_sdk.py', '--config', 'release') 'Engine build' }
        finally { Pop-Location }
        if (-not (Test-Path $builtDll)) { throw "Build reported success but $builtDll is missing." }
    }

    Write-Step "Canary gate"
    & py $canaryScript $builtDll
    if ($LASTEXITCODE -ne 0) {
        throw "Canary did NOT report GOOD (exit $LASTEXITCODE): the va_start miscompile is present. The DLL is NOT being copied. Investigate the /imsvc include order before retrying."
    }

    Copy-Item -LiteralPath $builtDll -Destination $forkDllDest -Force
    Write-Host "GOOD. Copied fork DLL to $forkDllDest" -ForegroundColor Green
    Write-Host "(civvaccess rebased; $backupBranch still points at the pre-rebase state until you delete it.)"
}

function Invoke-ModsPhase {
    Write-Step "MODS sync (mirror clone -> install, deletions included)"
    if (-not (Test-Path $ModsDir)) { throw "Installed MODS directory not found: $ModsDir" }
    foreach ($name in $modNames) {
        $src = Join-Path $ClonePath $name
        $dst = Join-Path $ModsDir $name
        if (-not (Test-Path $src)) { throw "Clone is missing mod folder '$name' at $src" }
        Write-Host "Mirroring '$name'..."
        # /MIR mirrors with deletion; exit codes < 8 are success for robocopy.
        & robocopy $src $dst /MIR /NJH /NJS /NDL /NP /R:1 /W:1 | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "robocopy mirror of '$name' failed (exit $LASTEXITCODE)." }
    }
    Write-Host "MODS folders now byte-identical to the clone (overlay reverted; deploy re-applies it)." -ForegroundColor Green
}

function Invoke-VendorPhase {
    param([string]$OldTag)

    Write-Step "Vendor verify (vanilla tree must still reproduce)"
    Invoke-Native 'py' @($vendorScript, 'verify') 'vendor verify'

    Write-Step "Vendor generate (re-stage VP overlay)"
    & py $vendorScript generate --engine vp --mods $ClonePath --clone $ClonePath
    if ($LASTEXITCODE -ne 0) {
        throw "vendor generate exited $LASTEXITCODE -- a recipe no longer applies to the new tag's source. Read $vendorStage\vendor-report.txt (the 'NOT generated' list), author the per-engine recipe fix in the manifest, then re-run -Phase vendor."
    }

    Write-Step "Vendor generate (re-stage Community-Patch-only overlay)"
    & py $vendorScript generate --engine cp --mods $ClonePath --out (Join-Path $repoRoot 'build\vendor\cp')
    if ($LASTEXITCODE -ne 0) {
        throw "vendor generate --engine cp exited $LASTEXITCODE -- a cp recipe no longer applies (or a cp alias-to-vp reuse broke). Read build\vendor\cp\vendor-report.txt, fix the cp/alias manifest entry, then re-run -Phase vendor."
    }

    New-Item -ItemType Directory -Force -Path $reviewDir | Out-Null
    $diffPath = Join-Path $reviewDir 'lua-binding-diff.txt'
    Write-Host "Writing the Lua-binding value audit ($OldTag..$NewTag) to $diffPath"
    & git -C $ClonePath diff "$OldTag..$NewTag" -- 'CvGameCoreDLL_Expansion2/Lua/' |
        Out-File -LiteralPath $diffPath -Encoding utf8

    Write-Step "REVIEW REQUIRED before finishing"
    Write-Host @"
Two artifacts decide whether this re-pin is safe. Read both:

  1. Drift report:      $vendorStage\vendor-report.txt
       New overlaps, signature drift, recipes that moved. The 'refit files'
       and 'files per root' sections are where re-pins bite.

  2. Lua-binding diff:   $diffPath
       Bindings we speak through. Watch for signature changes and new
       MOD_BALANCE_VP guards on getters -- a getter that now zeros out under
       one balance mode is a silent wrong-number bug. Add any newly drifted
       getter to the lint seam guard's name list.

When both are clear (and the seam-guard list updated), finish with:

  ./resync-vp.ps1 -NewTag $NewTag -Phase finish -ReviewConfirmed
"@ -ForegroundColor Yellow
}

function Invoke-FinishPhase {
    if (-not $ReviewConfirmed) {
        throw "finish requires -ReviewConfirmed. Review the drift report and the Lua-binding diff first (see the vendor phase output)."
    }
    Write-Step "Deploy VP stack (transient mod-overlay for the merged-DB session)"
    & (Join-Path $repoRoot 'deploy-vp.ps1') -ClonePath $ClonePath -RepinBuild
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) { throw "deploy-vp.ps1 failed (exit $LASTEXITCODE)." }

    Write-Step "Record the new pin"
    Set-SupportedVp $NewTag
    Write-Host "versions.json supported_vp -> $NewTag" -ForegroundColor Green
    Write-Host @"

Re-pin mechanics done. The install is in the transient VP mod-overlay state,
which cannot load modpack saves. Still by hand, per the release prerequisites:
  - bump the engine_vp component version in versions.json if the DLL changed
  - restate the supported VP version in the release notes / CHANGELOG
  - play one clean CP+VP session through the Mods menu (Squads off) to produce
    the merged database
  - run ./resync-vp.ps1 -NewTag $NewTag -Phase modpack to bake the VP modpack
    and deploy it -- this lands the install back in player-facing modpack
    state, where the VP play audit then runs
  - to keep the Community-Patch-only modpack current too: flip to vanilla,
    play one session with ONLY (1) Community Patch enabled to produce a CP-only
    merged DB, then run ./resync-vp.ps1 -NewTag $NewTag -Phase cp-modpack
  - once satisfied, delete the $backupBranch snapshot in the clone
  - commit dist/engine-vp + versions.json + any manifest recipe fixes
"@
}

function Invoke-ModpackPhase {
    Write-Step "Bake the modpack from the merged database"
    & (Join-Path $repoRoot 'build-modpack.ps1')
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
        throw "build-modpack.ps1 failed (exit $LASTEXITCODE). It needs a clean CP+VP merged cache DB; play one clean CP+VP session through the Mods menu (Squads off), then re-run -Phase modpack."
    }

    Write-Step "Deploy the modpack (player-facing end state)"
    & (Join-Path $repoRoot 'deploy-modpack.ps1')
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) { throw "deploy-modpack.ps1 failed (exit $LASTEXITCODE)." }

    Write-Host "Install is now in player-facing modpack state. Run the play audit here." -ForegroundColor Green
}

function Invoke-CpModpackPhase {
    # The Community-Patch-only modpack rides the same re-pinned fork DLL, CP
    # body, and cp vendor stage, but it bakes from a DIFFERENT cache: a
    # Community-Patch-only session (BALANCE_VP off), not the CP+VP session the
    # VP modpack uses. So it is its own terminal phase, run after a separate
    # manual CP-only merged-DB session (flip to vanilla, enable ONLY (1)
    # Community Patch through the Mods menu, start a game to the map, quit).
    # build-modpack-cp refuses any cache that is not a clean CP-only merge.
    Write-Step "Bake the Community-Patch-only modpack from the CP-only merged database"
    & (Join-Path $repoRoot 'build-modpack-cp.ps1')
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
        throw "build-modpack-cp.ps1 failed (exit $LASTEXITCODE). It needs a clean Community-Patch-only cache DB (BALANCE_VP off); flip to vanilla, play one session with ONLY (1) Community Patch enabled through the Mods menu, then re-run -Phase cp-modpack."
    }

    Write-Step "Deploy the Community-Patch-only modpack (player-facing CP end state)"
    & (Join-Path $repoRoot 'deploy-modpack-cp.ps1')
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) { throw "deploy-modpack-cp.ps1 failed (exit $LASTEXITCODE)." }

    Write-Host "Install is now in player-facing CP-only modpack state. Run the CP play audit here." -ForegroundColor Green
}

# ---------------------------------------------------------------- main

$oldTag = Get-SupportedVp
if ([string]::IsNullOrWhiteSpace($oldTag)) {
    throw "versions.json has no supported_vp value; cannot determine the old pin."
}

Write-Host "Re-sync VP: clone=$ClonePath  old=$oldTag  new=$NewTag" -ForegroundColor Cyan

switch ($Phase) {
    'engine'  { Invoke-EnginePhase -OldTag $oldTag }
    'mods'    { Invoke-ModsPhase }
    'vendor'  { Invoke-VendorPhase -OldTag $oldTag }
    'finish'  { Invoke-FinishPhase }
    'modpack' { Invoke-ModpackPhase }
    'cp-modpack' { Invoke-CpModpackPhase }
    default {
        Invoke-EnginePhase -OldTag $oldTag
        Invoke-ModsPhase
        Invoke-VendorPhase -OldTag $oldTag
        Write-Host "`nengine + mods + vendor complete. Review, then run the finish command above." -ForegroundColor Cyan
    }
}
