# Component-version bumps for the re-pin scripts (resync-vp.ps1 and
# resync-lekmod.ps1). Dot-source it after $repoRoot is set.
#
# package-release.ps1 keys fetch-vs-rebuild on the component fields in
# versions.json: a field unchanged since the previous release tag makes the
# packager re-upload that release's zip byte-for-byte. So every component whose
# bytes a re-pin moves (the rebuilt fork, the regenerated overlay, the rebaked
# modpack, the re-pulled LekMod DLC) must bump, or the next release silently
# ships the previous release's bytes under a new upstream pin.
#
# Step-ComponentVersion bumps the patch level once per release cycle. If the
# field already differs from the previous tag's, an earlier re-pin (or a hand
# edit) has moved it and the component already rebuilds on the next release; a
# second bump would only change the asset name. A component the previous
# release did not ship builds from source regardless, so it is left alone too.

# The previous release tag and its versions.json, the same way
# package-release.ps1 finds them. Tag and Versions are $null before the first
# release, in which case every bump applies.
function Get-ReleaseBaseline {
    param([Parameter(Mandatory)][string]$RepoRoot)
    $tag = & git -C $RepoRoot describe --tags --abbrev=0 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($tag)) {
        return @{ Tag = $null; Versions = $null }
    }
    $tag = $tag.Trim()
    $json = & git -C $RepoRoot show "${tag}:versions.json" 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace(($json | Out-String))) {
        return @{ Tag = $tag; Versions = $null }
    }
    return @{ Tag = $tag; Versions = (($json | Out-String) | ConvertFrom-Json) }
}

# Bump components.<Name> by one patch level unless it already moved since the
# baseline release. -ChangedPaths (repo-relative) makes the bump conditional on
# a non-empty working-tree diff of those paths against the baseline tag; use it
# for the fork DLLs, whose bytes a re-pin does not necessarily change. The
# replace is targeted so the file keeps its hand formatting.
function Step-ComponentVersion {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$VersionsPath,
        [Parameter(Mandatory)][hashtable]$Baseline,
        [Parameter(Mandatory)][string]$Why,
        [string[]]$ChangedPaths,
        [string]$RepoRoot
    )
    $raw = Get-Content -LiteralPath $VersionsPath -Raw
    $pattern = '("' + [regex]::Escape($Name) + '"\s*:\s*")(\d+)\.(\d+)\.(\d+)(")'
    $m = [regex]::Match($raw, $pattern)
    if (-not $m.Success) {
        throw "versions.json has no semver components.$Name field to bump."
    }
    $current = "$($m.Groups[2].Value).$($m.Groups[3].Value).$($m.Groups[4].Value)"

    if ($Baseline.Versions) {
        $prev = $Baseline.Versions.components.$Name
        if (-not $prev) {
            Write-Host "  $Name stays $current (not shipped by $($Baseline.Tag); it builds from source on the next release regardless)"
            return
        }
        if ($prev -ne $current) {
            Write-Host "  $Name stays $current (already moved from $prev since $($Baseline.Tag))"
            return
        }
        if ($ChangedPaths) {
            if (-not $RepoRoot) { throw "Step-ComponentVersion -ChangedPaths needs -RepoRoot." }
            & git -C $RepoRoot diff --quiet $Baseline.Tag -- @ChangedPaths
            switch ($LASTEXITCODE) {
                0 { Write-Host "  $Name stays $current (unchanged since $($Baseline.Tag))"; return }
                1 { }
                default { throw "git diff $($Baseline.Tag) -- $($ChangedPaths -join ' ') failed (exit $LASTEXITCODE); cannot decide whether $Name moved." }
            }
        }
    }

    $next = "$($m.Groups[2].Value).$($m.Groups[3].Value).$([int]$m.Groups[4].Value + 1)"
    $raw = $raw.Substring(0, $m.Index) + $m.Groups[1].Value + $next + $m.Groups[5].Value + $raw.Substring($m.Index + $m.Length)
    [System.IO.File]::WriteAllText($VersionsPath, $raw)
    Write-Host "  $Name $current -> $next ($Why)" -ForegroundColor Green
}
