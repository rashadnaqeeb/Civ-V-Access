# Lints and format-checks the mod's Lua source.
# Runs luacheck (semantic) and stylua (formatting) back to back. Both are
# read-only by default; pass -Fix to let stylua rewrite files in place.
# Expects tools/bin/luacheck.exe and tools/bin/stylua.exe (both gitignored).
# Must be invoked from the repo root.
#
# Usage:
#   ./lint.ps1                lint + format-check (read-only)
#   ./lint.ps1 -Fix           lint + format rewrite
#   ./lint.ps1 <path> ...     restrict to specific files / dirs
#
# Exit code is nonzero if either tool reports a problem (or, with -Fix,
# if either tool fails to run); a single combined exit keeps CI wiring
# straightforward.

[CmdletBinding()]
param(
    [switch]$Fix,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Paths
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $root

$luacheck = Join-Path $root "tools\bin\luacheck.exe"
$stylua   = Join-Path $root "tools\bin\stylua.exe"

if (-not (Test-Path $luacheck)) {
    Write-Error @"
Missing linter: $luacheck

Install with:
    gh release download v1.2.0 --repo lunarmodules/luacheck --pattern luacheck.exe --dir tools\bin\
"@
    exit 2
}

if (-not (Test-Path $stylua)) {
    Write-Error @"
Missing formatter: $stylua

Install with:
    gh release download v2.4.1 --repo JohnnyMorganz/StyLua --pattern stylua-windows-x86_64.zip --dir tools\bin\
    Expand-Archive tools\bin\stylua-windows-x86_64.zip -DestinationPath tools\bin\
    Remove-Item tools\bin\stylua-windows-x86_64.zip
"@
    exit 2
}

# luacheck and stylua are native Windows .exe binaries. When this script is
# reached via `bash lint.sh`, their stdout is inherited from a process whose
# output is an MSYS / Git-Bash pipe, and writing to that foreign pipe makes
# them abort with "fatal runtime error: I/O error: operation failed to
# complete synchronously" (and stall en route). Run each tool with its
# streams redirected to a native temp file -- a real Windows file handle --
# then relay the file through PowerShell, so the .exe never writes to the
# pipe. Direct ./lint.ps1 use in a PowerShell terminal hits a real console
# and never tripped this; the redirect is harmless there (it only drops the
# tools' own output coloring). Returns the tool's exit code.
function Invoke-Tool {
    param([Parameter(Mandatory)] [string] $Exe, [string[]] $ToolArgs)
    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        & $Exe @ToolArgs *> $tmp
        $code = $LASTEXITCODE
        Get-Content -LiteralPath $tmp -ErrorAction SilentlyContinue | ForEach-Object { Write-Host $_ }
        return $code
    } finally {
        Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue
    }
}

# Engine-seam guard. Every engine getter whose value or signature drifts
# across engines (vanilla / Vox Populi), and every fork-added binding, must
# be called through CivVAccess_EngineData.lua -- a raw call lints clean and
# runs clean on vanilla but breaks or silently lies on another engine, the
# failure class the EngineData port exists to prevent. This stage greps
# mod-authored Lua (CivVAccess_*.lua; vendor copies are exempt because we
# ship them verbatim) for the known-drifted method names outside
# EngineData itself and fails on any hit. The name lists are the VP port
# plan's drift audit plus the fork's extension bindings; each VP re-pin's
# value-audit diff is what keeps them current.
#
# Two tiers, because the failure modes differ. DRIFT reads exist on every
# engine but differ in value / signature; only code that runs on more than
# one engine can be bitten, so a VP-only screen (gated off vanilla, one
# engine) opts out of the drift sweep with a `civvaccess-seam-exempt` marker.
# FORK bindings exist on no stock engine (vanilla or stock VP), so they must
# never be called raw outside EngineData on ANY file -- EngineData owns the
# forkPresent() gate that degrades gracefully when the fork is absent, and a
# raw call crashes the supported no-fork degraded mode. The marker does NOT
# waive the fork sweep: a VP-only screen still runs fork / no-fork on its own
# engine, so fork discipline still applies to it.
function Invoke-SeamGuard {
    # Drift reads: value or signature differs across engines. The vassalage
    # primitives (VP-only Team bindings, absent on vanilla -- a raw call
    # crashes there) live here: both-engines callers (DiploRelationships D10,
    # VictoryProgress D24) route them through EngineData.vassalInfo, while the
    # VP-only Vassal Overview uses them raw and is marked seam-exempt.
    # "IsVassal" matches only the exact :IsVassal( call -- "IsVassalOfSomeone"
    # needs its own entry because the trailing \s*\( anchor stops the shorter
    # name matching it.
    $driftMethods = @(
        "GetCombatDamage", "GetMaxDefenseStrength", "DefenseModifier",
        "GetExcessHappiness", "GetHappinessFromBuildings", "GetHappinessFromPolicies",
        "GetUnhappinessFromCityCount", "GetUnhappinessFromCapturedCityCount",
        "GetUnhappinessFromCityPopulation", "GetUnhappinessFromCityForUI",
        "GetTourism", "GetBaseTourism", "GetCultureFromSpecialist",
        "CapitalDefenseModifier", "CapitalDefenseFalloff",
        "GetCombatModifierFromCapitalDistance",
        "GetInfluencePerTurn", "GetTourismPerTurnIncludingInstantTimes100",
        "GetBestDefender", "CanMoveOrAttackInto",
        "GetOwnerForDominationVictory",
        "IsVassalOfSomeone", "GetMaster", "GetNumVassals", "GetNumTurnsIsVassal",
        "IsVassal",
        "GetNumHistoricEvents", "GetHistoricEventTourism",
        "IsResourceImproveable", "GetSeeThrough",
        "IsImprovementEmbassy", "GetBuildingInvestment"
    )
    # Fork extension bindings: added by our forked DLL, present on no stock
    # engine. The seam-exempt marker does NOT waive these -- see the function
    # header. EngineData is the only file allowed to call them raw.
    $forkMethods = @(
        "GetMissionQueue", "GeneratePath", "GeneratePathWithFlags", "GetPath", "ComputePath",
        "GetBestBuildRoute", "GetBuildRoutePath", "GetClosestSearchedPlot",
        "HasLineOfSight", "GetCycleUnits",
        "GetMemberDelegationDetails", "GetMemberKnowledgeDetails", "GetMemberVoteOpinionDetails"
    )
    # Deal:GetNumResource (drifted: unregistered in VP) shares its name with
    # the undrifted zero-arg Plot:GetNumResource(), so it gets its own
    # alternative requiring at least one argument; the deal getter always
    # takes (playerId, resourceType). It is a drift read, so it rides the
    # drift pattern (waived by the exempt marker).
    $driftPattern = "[:.](?:(?:" + ($driftMethods -join "|") + ")\s*\(|GetNumResource\s*\([^)])"
    $forkPattern  = "[:.](?:" + ($forkMethods -join "|") + ")\s*\("
    # src\vp holds per-engine implementation files deploy-vp.ps1 swaps in
    # (currently the VP CivVAccess_EngineData.lua); sweep it with the same
    # rule so any future mod-authored file there can't bypass the seam.
    $allFiles = Get-ChildItem -Path (Join-Path $root "src\dlc"), (Join-Path $root "src\vp") -Recurse -Filter "CivVAccess_*.lua" |
        Where-Object { $_.Name -ne "CivVAccess_EngineData.lua" }
    # File-level opt-out for VP-only screens (see the function header for why
    # this waives only the drift sweep, never the fork sweep). Apply the marker
    # ONLY where a drift name is genuinely called raw; a blanket marker on every
    # VP-only file would mask real violations.
    $driftFiles = @()
    foreach ($f in $allFiles) {
        if (Select-String -LiteralPath $f.FullName -Pattern "civvaccess-seam-exempt" -SimpleMatch -Quiet) {
            $rel = $f.FullName.Substring($root.Length).TrimStart("\")
            Write-Host ("seam guard: exempting {0} from the drift sweep (marked seam-exempt; fork bindings still guarded)" -f $rel) -ForegroundColor DarkGray
        } else {
            $driftFiles += $f
        }
    }
    # Case-sensitive: the EngineData seam functions reuse these names in
    # camelCase (EngineData.generatePath), and those routed calls are the
    # goal state, not violations. Comment-only lines are allowed to name
    # the methods (docs reference engine behavior); code lines are not.
    # Drift names sweep only non-exempt files; fork names sweep all files.
    $hits = @()
    $hits += @($driftFiles | Select-String -CaseSensitive -Pattern $driftPattern | Where-Object { $_.Line -notmatch '^\s*--' })
    $hits += @($allFiles   | Select-String -CaseSensitive -Pattern $forkPattern  | Where-Object { $_.Line -notmatch '^\s*--' })
    foreach ($hit in $hits) {
        # Windows PowerShell 5.1 has no GetRelativePath; trim the root prefix.
        $rel = $hit.Path.Substring($root.Length).TrimStart("\")
        Write-Host ("{0}:{1}: raw engine-seam call; route through EngineData: {2}" -f $rel, $hit.LineNumber, $hit.Line.Trim())
    }
    if ($hits.Count -gt 0) { return 1 }
    return 0
}

$targets = if ($Paths -and $Paths.Count -gt 0) { $Paths } else { @("src", "tests") }

Write-Host "--- luacheck" -ForegroundColor Cyan
# -q: print only files that have warnings, plus the final summary. Without
# it luacheck emits a "Checking ... OK" line per file (~300 lines), which
# buries the stylua output below it.
$luacheckExit = Invoke-Tool -Exe $luacheck -ToolArgs (@("-q") + $targets)

# --respect-ignores so explicitly-named paths honor .styluaignore the same
# way directory traversal does. Without it stylua silently bypasses the
# ignore file for paths handed to it directly, so `lint.ps1 <vendor-file>`
# reports drift on a file the full run skips -- a verdict that contradicts
# the authoritative `lint.ps1` run over src / tests.
if ($Fix) {
    Write-Host "--- stylua (rewrite)" -ForegroundColor Cyan
    $styluaExit = Invoke-Tool -Exe $stylua -ToolArgs (@("--respect-ignores") + $targets)
} else {
    Write-Host "--- stylua --check" -ForegroundColor Cyan
    $styluaExit = Invoke-Tool -Exe $stylua -ToolArgs (@("--respect-ignores", "--check") + $targets)
}

# The seam guard always sweeps all of src\dlc regardless of $Paths: it
# checks a repo invariant, and a violation anywhere should fail even a
# single-file run.
Write-Host "--- engine-seam guard" -ForegroundColor Cyan
$seamExit = Invoke-SeamGuard

# Report in a way the user can act on: tell them which stage failed.
if ($luacheckExit -ne 0 -and $styluaExit -ne 0) {
    Write-Host "lint + format-check both failed" -ForegroundColor Red
} elseif ($luacheckExit -ne 0) {
    Write-Host "lint failed" -ForegroundColor Red
} elseif ($styluaExit -ne 0) {
    if ($Fix) {
        Write-Host "format rewrite failed" -ForegroundColor Red
    } else {
        Write-Host "format-check failed (run ./lint.ps1 -Fix to rewrite)" -ForegroundColor Yellow
    }
}
if ($seamExit -ne 0) {
    Write-Host "engine-seam guard failed (route the flagged calls through CivVAccess_EngineData.lua)" -ForegroundColor Red
}

# Combined exit: nonzero if any stage failed. Luacheck's exit beats the
# others when several fail so the numeric code still pins one specific
# tool; the seam guard ranks last.
if ($luacheckExit -ne 0) { exit $luacheckExit }
if ($styluaExit -ne 0) { exit $styluaExit }
exit $seamExit
