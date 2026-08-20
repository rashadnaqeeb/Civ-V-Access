<#
.SYNOPSIS
    Re-pin Civ V Access's LekMod support to a new upstream LekMod drop: rebase +
    rebuild the engine fork, confirm the pulled-in DLC is pristine upstream,
    re-stage the vendor overlay, then deploy and record the new pin.

.DESCRIPTION
    The LekMod analog of resync-vp.ps1, lighter because LekMod has no CP/VP
    duality and no modpack bake (its prebaked DLC is used directly). The clone
    at ~/Documents/Lekmod IS the LekMod repo: upstream content (LEKMOD/ DLC +
    LEKMOD_DLL/ source) lives on `main`, and our engine additions ride a
    `civvaccess` branch on top. Re-pinning is therefore one rebase of that
    branch onto the new upstream; the new DLC tree comes along in the same tree.

    Like the VP re-pin this is a guided orchestrator, not fire-and-forget: the
    mechanical steps run autonomously, but the two places a re-pin actually
    breaks -- the vendoring drift report and the engine Lua-binding value audit
    -- are surfaced as a hard review stop, and the fork DLL never advances past
    the canary gate.

    Phases, in order:

      engine  Fetch upstream, rebase the civvaccess fork branch from the old
              pin onto the new upstream commit, rebuild the DLL with
              build-engine-lekmod.ps1 (VC9 / SDK 7.0), and run the LekMod
              canary. The branch is snapshotted to civvaccess-resync-backup
              first; a rebase conflict aborts and restores it, then stops with
              the conflicting commit named. The conflicts concentrate in the
              CvAStar pathfinder (3 real merges) -- re-test path preview after.
              If the canary is not GOOD the committed dist/engine-lekmod DLL is
              restored from git, so a bad build never lands. Then the binding
              surface gate: the drop's Lua registrations, preprocessor state
              resolved, must still include every vanilla binding our own Lua
              calls. A removal is invisible to the value audit (the call errors
              at speech time in a swallowed handler), which is how v35's
              deletion of Unit:GetMaxRangedCombatStrength got through.

      mods    Confirm the rebase pulled a pristine upstream DLC: our port
              commits must touch only LEKMOD_DLL/ (the engine), never LEKMOD/
              (the DLC). A non-empty LEKMOD/ diff means the port leaked into
              content and the deploy would ship a forked DLC. Also confirms the
              standard-UI staging tree (LEKMOD/Lua/tmp/ui) the vendor and
              deploy steps read is present, and flags a changed ui_check.bat,
              which our deploy reimplements.

      vendor  Run the vendoring tool's vanilla verify (must still reproduce the
              committed tree byte-for-byte) and re-stage the LekMod overlay,
              then write the old..new Lua-binding diff for the value audit.
              Stops here for human review.

      finish  (Requires -ReviewConfirmed.) Deploy the LekMod stack and record
              the new pin in versions.json. Run only after reviewing the drift
              report and the binding diff, AND re-deriving the MP-options
              control->option table (see below). Leaves the install in the
              player-facing LekMod state.

    With no -Phase, the script runs engine, mods, and vendor, then stops with
    the review checklist and the exact finish command. finish is never part of
    an unattended run.

    There is NO bake / modpack phase: LekMod's prebaked DLC has already-flat
    data the engine loads directly, so nothing is merged.

.PARAMETER NewRef
    The upstream LekMod ref to pin to (default origin/main). LekMod ships no
    version tags, so the recorded pin is the resolved commit SHA. Pass the
    current pin's ref to dry-run the plumbing as a near no-op.

.PARAMETER Phase
    Run a single phase (engine | mods | vendor | finish) instead of the default
    engine->mods->vendor sequence. Use to resume after fixing a recipe or to
    re-run a step.

.PARAMETER ClonePath
    Path to the LekMod clone (fork branch civvaccess). Defaults to the sibling
    directory next to this repo (~/Documents/Lekmod).

.PARAMETER ReviewConfirmed
    Required by the finish phase. Asserts you have read the drift report and the
    Lua-binding diff, added any newly drifted getter to the lint seam guard's
    name list, and re-derived the MP-options control->option table in
    CivVAccess_MPGameSetupShared.lua from LekMod's MPGameOptions.lua On*Checked
    handlers (the one hand-mapped surface a re-pin can silently shrink).

.PARAMETER SkipBuild
    Reuse the DLL already at dist/engine-lekmod instead of rebuilding.
    Engine-phase debugging only; the rebase and canary still run.
#>
[CmdletBinding()]
param(
    [string]$NewRef = 'origin/main',
    [ValidateSet('engine', 'mods', 'vendor', 'finish')]
    [string]$Phase,
    [string]$ClonePath,
    [switch]$ReviewConfirmed,
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'

$repoRoot     = Split-Path -Parent $MyInvocation.MyCommand.Path
$versionsPath = Join-Path $repoRoot 'versions.json'
$forkDllRel   = 'dist\engine-lekmod\CvGameCore_Expansion2.dll'
$forkDll      = Join-Path $repoRoot $forkDllRel
$canaryScript = Join-Path $repoRoot 'tools\lekmod_dll_canary.py'
$surfaceScript = Join-Path $repoRoot 'tools\lekmod_binding_surface.py'
$vendorScript = Join-Path $repoRoot 'tools\vendoring\vendor.py'
$vendorStage  = Join-Path $repoRoot 'build\vendor\lekmod'
$reviewDir    = Join-Path $repoRoot 'build\resync'
$backupBranch = 'civvaccess-resync-backup'

if ([string]::IsNullOrWhiteSpace($ClonePath)) {
    $ClonePath = Join-Path (Split-Path -Parent $repoRoot) 'Lekmod'
}
$ClonePath = (Resolve-Path -LiteralPath $ClonePath).Path

# ---------------------------------------------------------------- helpers

function Write-Step { param([string]$Text) Write-Host "`n=== $Text ===" -ForegroundColor Cyan }

# Run a native command and throw on a nonzero exit. PowerShell does not do this
# on its own, and a swallowed build / git failure is exactly the silent break
# this script exists to prevent.
function Invoke-Native {
    param([string]$Exe, [string[]]$CmdArgs, [string]$What)
    & $Exe @CmdArgs
    if ($LASTEXITCODE -ne 0) {
        throw "$What failed (exit $LASTEXITCODE): $Exe $($CmdArgs -join ' ')"
    }
}

function Get-Git {
    param([string[]]$GitArgs)
    # git reports progress and summaries on stderr even when it succeeds (fetch is
    # the usual one). Under ErrorActionPreference=Stop the 2>&1 merge turns that
    # first stderr line into a terminating NativeCommandError before the exit-code
    # check ever runs, so a healthy fetch aborts the phase. Drop to Continue across
    # the call and read $LASTEXITCODE for the real success signal.
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $out = & git -C $ClonePath @GitArgs 2>&1
    $gitExit = $LASTEXITCODE
    $ErrorActionPreference = $prevEAP
    if ($gitExit -ne 0) {
        throw "git $($GitArgs -join ' ') failed: $out"
    }
    return ($out | Out-String).Trim()
}

function Get-SupportedLekmod {
    (Get-Content -LiteralPath $versionsPath -Raw | ConvertFrom-Json).supported_lekmod
}

function Set-SupportedLekmod {
    param([string]$Pin)
    $raw = Get-Content -LiteralPath $versionsPath -Raw
    if ($raw -notmatch '"supported_lekmod"\s*:\s*"[^"]*"') {
        throw "versions.json has no supported_lekmod field to update."
    }
    $raw = $raw -replace '("supported_lekmod"\s*:\s*")[^"]*(")', "`${1}$Pin`${2}"
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

# Resolve NewRef to a concrete commit. LekMod has no tags, so the pin is a SHA.
function Resolve-NewCommit {
    try { return Get-Git @('rev-parse', "$NewRef^{commit}") }
    catch { throw "Cannot resolve $NewRef in the clone. Run -Phase engine first (it fetches), or check the ref name." }
}

# ---------------------------------------------------------------- phases

function Invoke-EnginePhase {
    param([string]$OldPin)

    Write-Step "Engine fork: $OldPin -> $NewRef"
    Assert-CleanCloneOnFork

    Write-Host "Fetching upstream..."
    Get-Git @('fetch', 'origin', '--tags') | Out-Null
    try { Get-Git @('rev-parse', '--verify', "$OldPin^{commit}") | Out-Null }
    catch { throw "Old pin $OldPin (from versions.json supported_lekmod) is not a commit in the clone." }
    $newCommit = Resolve-NewCommit

    if ($newCommit -eq (Get-Git @('rev-parse', "$OldPin^{commit}"))) {
        Write-Host "NewRef resolves to the current pin: this is a no-op re-pin / plumbing smoke test." -ForegroundColor Yellow
    }

    $replay = Get-Git @('log', '--oneline', "$OldPin..civvaccess")
    Write-Host "Fork commits to replay onto ${newCommit}:`n$replay"

    Write-Host "Snapshotting civvaccess to $backupBranch..."
    Get-Git @('branch', '-f', $backupBranch, 'civvaccess') | Out-Null

    Write-Host "Rebasing..."
    # git streams rebase progress to stderr; under ErrorActionPreference=Stop a
    # 2>&1 merge would turn the first progress line into a terminating
    # NativeCommandError before the exit-code check. Drop to Continue across the
    # call and read $LASTEXITCODE for the real success/conflict signal.
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & git -C $ClonePath rebase --onto $newCommit $OldPin civvaccess 2>&1 | Write-Host
    $rebaseExit = $LASTEXITCODE
    $ErrorActionPreference = $prevEAP
    if ($rebaseExit -ne 0) {
        $stopped = (& git -C $ClonePath log -1 --oneline REBASE_HEAD 2>$null | Out-String).Trim()
        & git -C $ClonePath rebase --abort 2>$null | Out-Null
        Get-Git @('reset', '--hard', $backupBranch) | Out-Null
        throw "Rebase onto $newCommit hit a conflict (near: $stopped). Branch restored from $backupBranch. The known re-conflict sites are the CvAStar pathfinder merges; resolve the port commits by hand, then re-run -Phase engine."
    }

    if ($SkipBuild) {
        Write-Host "SkipBuild: reusing existing $forkDll" -ForegroundColor Yellow
        if (-not (Test-Path $forkDll)) { throw "No DLL at $forkDll to reuse." }
    }
    else {
        Write-Host "Building the fork DLL (build-engine-lekmod.ps1)..."
        & (Join-Path $repoRoot 'build-engine-lekmod.ps1') -LekModRepo $ClonePath
        if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) { throw "build-engine-lekmod.ps1 failed (exit $LASTEXITCODE)." }
        if (-not (Test-Path $forkDll)) { throw "Build reported success but $forkDll is missing." }
    }

    Write-Step "Canary gate"
    & py $canaryScript $forkDll
    if ($LASTEXITCODE -ne 0) {
        # build-engine-lekmod writes straight to dist; restore the committed DLL
        # so a bad build never lands in the tree. git pathspec uses forward slashes.
        & git -C $repoRoot checkout -- ($forkDllRel -replace '\\', '/') 2>$null
        throw "Canary did NOT report GOOD (exit $LASTEXITCODE): GUID rotated or our port markers missing. The committed dist/engine-lekmod DLL has been restored. Investigate before retrying."
    }

    Write-Host "GOOD. Fork DLL at $forkDll passed the canary." -ForegroundColor Green

    # A removed Lua binding is invisible to the value audit: the call errors at
    # speech time inside a handler the engine swallows. v35 deleted
    # Unit:GetMaxRangedCombatStrength that way (its Method() registration moved
    # into the off arm of the combat-predictor #if) and nothing caught it, so
    # every re-pin now diffs the registration surface against the vanilla SDK.
    Write-Step "Binding surface gate"
    & py $surfaceScript --clone $ClonePath
    if ($LASTEXITCODE -ne 0) {
        throw "This drop removed a Lua binding our own code calls (listed above). Route the call through the EngineData seam with a LekMod body that uses the replacement, add the name to lint.ps1's drift list, then re-run -Phase engine."
    }

    Write-Host "(civvaccess rebased; $backupBranch still points at the pre-rebase state until you delete it.)"
}

function Invoke-ModsPhase {
    param([string]$OldPin)

    Write-Step "DLC check (the rebase pulled the new upstream LEKMOD/ DLC; confirm it is pristine)"
    $newCommit = Resolve-NewCommit
    # Our port must touch only the engine (LEKMOD_DLL/), never the content DLC
    # (LEKMOD/). A non-empty diff means a port commit edited the DLC tree, which
    # the deploy would then ship as a forked DLC -- a silent content divergence.
    $leaked = Get-Git @('diff', '--name-only', "$newCommit..civvaccess", '--', 'LEKMOD/')
    if ($leaked) {
        throw "Our port leaked into the LekMod DLC tree -- these LEKMOD/ files differ from upstream:`n$leaked`nThe port must touch only LEKMOD_DLL/. Move the edit into the engine or revert it, then re-run -Phase engine."
    }
    Write-Host "LEKMOD/ DLC is byte-identical to upstream $newCommit (port confined to the engine)." -ForegroundColor Green

    $tmpUi = Join-Path $ClonePath 'LEKMOD\Lua\tmp\ui'
    if (-not (Test-Path $tmpUi)) {
        throw "Standard-UI staging tree missing at $tmpUi -- the vendor and deploy steps read it. Is the clone fully checked out?"
    }
    Write-Host "Standard-UI staging tree present." -ForegroundColor Green

    # Our deploy is LekMod's ui_check.bat (Resolve-CivVAccessLekModStandardUI in
    # tools/dlc-assembly.ps1). Everything that script does past copying bodies is
    # ours to carry, and getting it wrong breaks the install with nothing in any
    # log to say why -- v35.1 added a stamp file LekMod's FrontEnd gates the main
    # menu on. Surface the diff; only a human can say what it means for us.
    $uiCheckChanged = Get-Git @('diff', '--name-only', "$OldPin..$newCommit", '--', 'LEKMOD/ui_check.bat')
    if ($uiCheckChanged) {
        Write-Host "ui_check.bat changed in this drop. Our deploy reimplements it -- read the diff and mirror whatever it does past copying bodies:" -ForegroundColor Yellow
        Write-Host "  git -C `"$ClonePath`" diff $OldPin..$newCommit -- LEKMOD/ui_check.bat"
    }
    else {
        Write-Host "ui_check.bat unchanged since the old pin." -ForegroundColor Green
    }
}

function Invoke-VendorPhase {
    param([string]$OldPin)

    Write-Step "Vendor verify (vanilla tree must still reproduce)"
    Invoke-Native 'py' @($vendorScript, 'verify') 'vendor verify'

    Write-Step "Vendor generate (re-stage LekMod overlay)"
    # The bare generate defaults --out to the vp dir and exits non-zero; lekmod
    # needs the explicit out and the clone for its standard-UI bodies.
    & py $vendorScript generate --engine lekmod --out $vendorStage --lekmod $ClonePath
    if ($LASTEXITCODE -ne 0) {
        throw "vendor generate --engine lekmod exited $LASTEXITCODE -- a recipe no longer applies to the new drop's source. Read $vendorStage\vendor-report.txt (the 'NOT generated' list), author the per-engine recipe fix in the manifest, then re-run -Phase vendor."
    }

    $newCommit = Resolve-NewCommit
    New-Item -ItemType Directory -Force -Path $reviewDir | Out-Null
    $diffPath = Join-Path $reviewDir 'lekmod-lua-binding-diff.txt'
    Write-Host "Writing the Lua-binding value audit ($OldPin..$newCommit) to $diffPath"
    & git -C $ClonePath diff "$OldPin..$newCommit" -- 'LEKMOD_DLL/CvGameCoreDLL_Expansion2/Lua/' |
        Out-File -LiteralPath $diffPath -Encoding utf8

    Write-Step "REVIEW REQUIRED before finishing"
    Write-Host @"
Three things decide whether this re-pin is safe:

  1. Drift report:      $vendorStage\vendor-report.txt
       New overlaps, signature drift, recipes that moved. The voting popups are
       net-new manifest entries; the rest are LekMod-bodied overrides.

  2. Lua-binding diff:   $diffPath
       Bindings we speak through. Watch for signature changes on getters we
       call. Add any newly drifted getter to the lint seam guard's name list.

  3. MP-options control->option table in CivVAccess_MPGameSetupShared.lua.
       Re-derive it from LekMod's MPGameOptions.lua On*Checked handlers. A
       renamed control or option silently drops its row (never errors), leaving
       a blind host unable to set that option. This is the surface most likely
       to drift across a re-pin.

When all three are clear (and the seam-guard list + MP-options table updated),
finish with:

  ./resync-lekmod.ps1 -NewRef $NewRef -Phase finish -ReviewConfirmed
"@ -ForegroundColor Yellow
}

function Invoke-FinishPhase {
    if (-not $ReviewConfirmed) {
        throw "finish requires -ReviewConfirmed. Review the drift report, the Lua-binding diff, and re-derive the MP-options table first (see the vendor phase output)."
    }
    $newCommit = Resolve-NewCommit

    Write-Step "Deploy the LekMod stack (player-facing end state)"
    & (Join-Path $repoRoot 'deploy.ps1') -State lekmod -LekModClone $ClonePath
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) { throw "deploy.ps1 -State lekmod failed (exit $LASTEXITCODE)." }

    Write-Step "Record the new pin"
    Set-SupportedLekmod $newCommit
    Write-Host "versions.json supported_lekmod -> $newCommit" -ForegroundColor Green
    Write-Host @"

Re-pin mechanics done. The install is in the player-facing LekMod state, where
the play audit runs. Still by hand:
  - bump the engine_lekmod component version in versions.json if the DLL changed
  - run the live LekMod audit (voting system end to end, MP game-options host
    flow, combat-preview modifiers, the GameplayAlertMessage triggers)
  - re-run a static Language_en_US diff of the new LekMod drop against vanilla
    to confirm no vanilla text key was repurposed (the last audit came back
    clean -- zero repurposed keys)
  - once satisfied, delete the $backupBranch snapshot in the clone
  - commit dist/engine-lekmod + versions.json + any manifest recipe fixes
"@
}

# ---------------------------------------------------------------- main

$oldPin = Get-SupportedLekmod
if ([string]::IsNullOrWhiteSpace($oldPin)) {
    throw "versions.json has no supported_lekmod value; cannot determine the old pin."
}

Write-Host "Re-sync LekMod: clone=$ClonePath  old=$oldPin  new=$NewRef" -ForegroundColor Cyan

switch ($Phase) {
    'engine' { Invoke-EnginePhase -OldPin $oldPin }
    'mods'   { Invoke-ModsPhase -OldPin $oldPin }
    'vendor' { Invoke-VendorPhase -OldPin $oldPin }
    'finish' { Invoke-FinishPhase }
    default {
        Invoke-EnginePhase -OldPin $oldPin
        Invoke-ModsPhase -OldPin $oldPin
        Invoke-VendorPhase -OldPin $oldPin
        Write-Host "`nengine + mods + vendor complete. Review, then run the finish command above." -ForegroundColor Cyan
    }
}
