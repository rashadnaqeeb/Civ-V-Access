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

      finish  (Requires -ReviewConfirmed.) Stage the modpack bake via
              stage-vp-modpack-bake.ps1 (fork DLL into MODS, ValidateGameDatabase
              on, any active package removed; the accessibility DLC on disk is
              left as-is), record the new pin in versions.json, and bump the
              component versions the re-pin moved: engine_vp when the fork DLL
              differs from the last release's, vp_overlay and cp_overlay
              always, vp_runtime when the substrate files changed upstream
              since the last release's pin. Each bumps once per release cycle.
              Run only after reviewing the drift report and the binding diff.
              If the
              install was in a non-VP state, run deploy.ps1 -State vp and then
              stage-vp-modpack-bake.ps1 again first, so the merged-DB session
              runs with the VP-flavored DLC rather than another state's.

      modpack A terminal phase. After a clean CP+VP session has produced a
              fresh merged database (build-modpack refuses a modpack-launch
              cache), bake the VP modpack, bump vp_modpack, and deploy it,
              leaving the install in the player-facing VP modpack state where
              the play audit runs.

      cp-modpack
              The other terminal phase, for the Community-Patch-only modpack.
              It reuses the same re-pinned fork DLL, CP body, and cp vendor
              stage, but bakes from a DIFFERENT cache -- a CP-only session
              (BALANCE_VP off), not the CP+VP session the VP modpack uses --
              so it cannot share the modpack phase's run. Produce a CP-only
              merged DB first (flip to vanilla, enable ONLY (1) Community Patch
              through the Mods menu, play to the map, quit), then run this.
              Bumps cp_modpack after the bake.

    With no -Phase, the script runs engine, mods, and vendor, then stops with
    the review checklist and the exact finish command. finish, modpack, and
    cp-modpack are never part of an unattended run.

.PARAMETER NewTag
    The Community-Patch-DLL release tag to pin to (e.g. Release-5.3.3). Pass
    the current pin to dry-run the plumbing as a near no-op smoke test. Tags
    are fetched from the clone's `upstream` remote (LoneGazebo/Community-Patch-DLL);
    `origin` is our GitHub fork and only carries the tags someone pushed to it.

.PARAMETER Phase
    Run a single phase (engine | mods | vendor | finish | modpack | cp-modpack)
    instead of the default engine->mods->vendor sequence. Use to resume after
    fixing a recipe or to re-run a step.

.PARAMETER ClonePath
    Path to the Community-Patch-DLL clone (fork branch civvaccess). Defaults
    to the sibling directory next to this repo. Must have an `upstream` remote
    pointing at LoneGazebo/Community-Patch-DLL; the engine phase refuses to
    run without it.

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
$forkDllRel   = 'dist/engine-vp/CvGameCore_Expansion2.dll'
$canaryScript = Join-Path $repoRoot 'tools\vp_dll_canary.py'
$vendorScript = Join-Path $repoRoot 'tools\vendoring\vendor.py'
$vendorStage  = Join-Path $repoRoot 'build\vendor\vp'
$reviewDir    = Join-Path $repoRoot 'build\resync'
$backupBranch = 'civvaccess-resync-backup'
$upstreamUrl  = 'https://github.com/LoneGazebo/Community-Patch-DLL.git'
$modNames     = @('(1) Community Patch', '(2) Vox Populi')
# The plain-VP substrate package-release.ps1 ships as vp-runtime (see
# Stage-VpRuntime there); vp_runtime bumps only when these moved upstream.
$substratePaths = @('VPUI', 'MinorCivSounds_VoxPopuli.xml', 'VPUI Text/VPUI_tips_en_us.xml', 'Expansion2_VoxPopuli.Civ5Pkg')

. (Join-Path $repoRoot 'tools\component-versions.ps1')

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
    param([string]$Exe, [string[]]$CmdArgs, [string]$What)
    & $Exe @CmdArgs
    if ($LASTEXITCODE -ne 0) {
        throw "$What failed (exit $LASTEXITCODE): $Exe $($CmdArgs -join ' ')"
    }
}

function Get-Git {
    param([string[]]$GitArgs)
    $out = & git -C $ClonePath @GitArgs 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "git $($GitArgs -join ' ') failed: $out"
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

# The clone's origin is our GitHub fork, which is only as fresh as the last time
# someone synced it -- pinning from it silently re-pins to a stale drop (or, for
# a tag-based pin, fails to find the tag at all). Every fetch here goes to the
# upstream remote, and its absence is a hard stop with the fix spelled out.
function Get-NormalizedRemoteUrl {
    param([string]$U)
    $U = $U.Trim().TrimEnd('/')
    if ($U.EndsWith('.git', [System.StringComparison]::OrdinalIgnoreCase)) { $U = $U.Substring(0, $U.Length - 4) }
    return $U.ToLowerInvariant()
}

function Assert-UpstreamRemote {
    $url = ''
    try { $url = Get-Git @('remote', 'get-url', 'upstream') } catch { }
    if ([string]::IsNullOrWhiteSpace($url)) {
        throw "The clone at $ClonePath has no 'upstream' remote. Add it and re-run:`n  git -C `"$ClonePath`" remote add upstream $upstreamUrl"
    }
    if ((Get-NormalizedRemoteUrl $url) -ne (Get-NormalizedRemoteUrl $upstreamUrl)) {
        throw "The clone's 'upstream' remote points at $url, expected $upstreamUrl."
    }
}

# ---------------------------------------------------------------- phases

function Invoke-EnginePhase {
    param([string]$OldTag)

    Write-Step "Engine fork: $OldTag -> $NewTag"
    Assert-CleanCloneOnFork

    Assert-UpstreamRemote
    Write-Host "Fetching upstream tags..."
    Get-Git @('fetch', 'upstream', '--tags') | Out-Null
    try { Get-Git @('rev-parse', '--verify', "refs/tags/$NewTag^{commit}") | Out-Null }
    catch { throw "Tag $NewTag not found in the clone after fetching upstream. Check the tag name against LoneGazebo/Community-Patch-DLL's releases." }
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
    # git streams rebase progress to stderr; under ErrorActionPreference=Stop a
    # 2>&1 merge would turn the first progress line into a terminating
    # NativeCommandError before the exit-code check. Drop to Continue across the
    # call and read $LASTEXITCODE for the real success/conflict signal.
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & git -C $ClonePath rebase --onto $NewTag $OldTag civvaccess 2>&1 | Write-Host
    $rebaseExit = $LASTEXITCODE
    $ErrorActionPreference = $prevEAP
    if ($rebaseExit -ne 0) {
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
        # The build script expects clang-cl / lld-link on PATH; the LLVM installer
        # does not add them by default.
        if (-not (Get-Command clang-cl.exe -ErrorAction SilentlyContinue)) {
            $llvmBin = 'C:\Program Files\LLVM\bin'
            if (Test-Path (Join-Path $llvmBin 'clang-cl.exe')) { $env:PATH = "$llvmBin;$($env:PATH)" }
        }
        # On an ARM64 host clang-cl defaults to aarch64, so the script's x86-only
        # flags (-msse3) are rejected; -m32 alone does not retarget. Inject the
        # x86 target through clang's driver override without editing the fork's
        # script. lld-link already gets /MACHINE:x86 from the script.
        $priorOverride = $env:CCC_OVERRIDE_OPTIONS
        if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64' -and -not $priorOverride) {
            $env:CCC_OVERRIDE_OPTIONS = '^--target=i686-pc-windows-msvc'
        }
        Push-Location $ClonePath
        try { Invoke-Native 'py' @('build_vp_clang_sdk.py', '--config', 'release') 'Engine build' }
        finally {
            Pop-Location
            $env:CCC_OVERRIDE_OPTIONS = $priorOverride
        }
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
    param([string]$OldTag)
    if (-not $ReviewConfirmed) {
        throw "finish requires -ReviewConfirmed. Review the drift report and the Lua-binding diff first (see the vendor phase output)."
    }
    Write-Step "Stage the VP modpack bake (fork DLL + ValidateGameDatabase for the merged-DB session)"
    & (Join-Path $repoRoot 'stage-vp-modpack-bake.ps1') -ClonePath $ClonePath
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) { throw "stage-vp-modpack-bake.ps1 failed (exit $LASTEXITCODE)." }

    Write-Step "Record the new pin"
    Set-SupportedVp $NewTag
    Write-Host "versions.json supported_vp -> $NewTag" -ForegroundColor Green

    Write-Step "Bump the component versions this re-pin moved"
    $baseline = Get-ReleaseBaseline -RepoRoot $repoRoot
    Step-ComponentVersion -Name 'engine_vp' -VersionsPath $versionsPath -Baseline $baseline -RepoRoot $repoRoot `
        -ChangedPaths @($forkDllRel) -Why 'fork DLL rebuilt'
    foreach ($overlay in @('vp_overlay', 'cp_overlay')) {
        Step-ComponentVersion -Name $overlay -VersionsPath $versionsPath -Baseline $baseline `
            -Why 'vendor overlay regenerated against the new upstream'
    }
    # vp-runtime is cut from the clone, so its "changed since the last release"
    # is a clone diff from the pin that release shipped, not a repo diff.
    $substrateBase = if ($baseline.Versions -and $baseline.Versions.supported_vp) { $baseline.Versions.supported_vp } else { $OldTag }
    & git -C $ClonePath diff --quiet "$substrateBase" "$NewTag" -- @substratePaths
    switch ($LASTEXITCODE) {
        0 { Write-Host "  vp_runtime stays (substrate files unchanged upstream since $substrateBase)" }
        1 {
            Step-ComponentVersion -Name 'vp_runtime' -VersionsPath $versionsPath -Baseline $baseline `
                -Why "substrate files changed upstream since $substrateBase"
        }
        default { throw "git diff $substrateBase $NewTag in the clone failed (exit $LASTEXITCODE); cannot decide whether vp_runtime moved." }
    }
    Write-Host "vp_modpack / cp_modpack bump in the modpack / cp-modpack phases, once each bake exists."

    Write-Host @"

Re-pin mechanics done. The install is staged for the modpack bake (fork DLL in
MODS, ValidateGameDatabase on); its prior state is otherwise untouched. Still by
hand, per the release prerequisites:
  - restate the supported VP version in the release notes / CHANGELOG
  - play one clean CP+VP session through the Mods menu (Squads off) to produce
    the merged database
  - run ./resync-vp.ps1 -NewTag $NewTag -Phase modpack to bake the VP modpack
    and deploy it -- this lands the install back in player-facing modpack
    state, where the VP play audit then runs
  - to keep the Community-Patch-only modpack current too: flip to vanilla,
    play one session with ONLY (1) Community Patch enabled to produce a CP-only
    merged DB, then run ./resync-vp.ps1 -NewTag $NewTag -Phase cp-modpack
    (skipping it leaves cp_modpack unbumped, and package-release.ps1's
    fork-staleness guard will refuse to let that slide quietly)
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

    Write-Step "Bump vp_modpack (new merged database and fork DLL baked in)"
    Step-ComponentVersion -Name 'vp_modpack' -VersionsPath $versionsPath -Baseline (Get-ReleaseBaseline -RepoRoot $repoRoot) `
        -Why 'modpack rebaked'

    Write-Step "Deploy the modpack (player-facing end state)"
    & (Join-Path $repoRoot 'deploy.ps1') -State vp
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) { throw "deploy.ps1 -State vp failed (exit $LASTEXITCODE)." }

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

    Write-Step "Bump cp_modpack (new merged database and fork DLL baked in)"
    Step-ComponentVersion -Name 'cp_modpack' -VersionsPath $versionsPath -Baseline (Get-ReleaseBaseline -RepoRoot $repoRoot) `
        -Why 'modpack rebaked'

    Write-Step "Deploy the Community-Patch-only modpack (player-facing CP end state)"
    & (Join-Path $repoRoot 'deploy.ps1') -State cp
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) { throw "deploy.ps1 -State cp failed (exit $LASTEXITCODE)." }

    Write-Host "Install is now in player-facing CP-only modpack state. Run the CP play audit here." -ForegroundColor Green
    Write-Host "If VP is your default target, return to VP modpack state with ./deploy.ps1 -State vp when the CP audit is done." -ForegroundColor Yellow
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
    'finish'  { Invoke-FinishPhase -OldTag $oldTag }
    'modpack' { Invoke-ModpackPhase }
    'cp-modpack' { Invoke-CpModpackPhase }
    default {
        Invoke-EnginePhase -OldTag $oldTag
        Invoke-ModsPhase
        Invoke-VendorPhase -OldTag $oldTag
        Write-Host "`nengine + mods + vendor complete. Review, then run the finish command above." -ForegroundColor Cyan
    }
}
