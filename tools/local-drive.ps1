# Re-runs a repo script from a temporary drive letter when the repo was
# reached through a UNC path (\\server\share\...). Dot-source it, then:
#
#   if (Test-UncRoot $root) { exit (Invoke-FromMappedDrive $root 'lint.ps1' @{ Fix = $Fix }) }
#
# Why: the repo usually lives on a network share (a VM's host folder), and
# sessions often start in it by its UNC path. Native tools cannot work from a
# UNC working directory: cmd.exe silently falls back to C:\Windows (so a
# `cmd /c dir` file walk finds nothing), and luacheck builds a relative path
# to .luacheckrc that does not resolve. Mapping the root to a drive letter for
# the run gives every tool an ordinary drive path. The mapping is removed when
# the script finishes.

function Test-UncRoot {
    param([Parameter(Mandatory)] [string] $Root)
    return $Root.StartsWith('\\')
}

# Maps $Root to a free drive letter, runs $ScriptName from it with $Splat, and
# returns the script's exit code. The script's output goes straight to the
# host so the only pipeline output is the exit code.
function Invoke-FromMappedDrive {
    param(
        [Parameter(Mandatory)] [string] $Root,
        [Parameter(Mandatory)] [string] $ScriptName,
        [hashtable] $Splat = @{}
    )
    $used = (Get-PSDrive -PSProvider FileSystem).Name
    $letter = 'WVUTSRQPONMLKJIHG'.ToCharArray() | ForEach-Object { [string]$_ } |
        Where-Object { $used -notcontains $_ } | Select-Object -First 1
    if (-not $letter) { throw "No free drive letter to map $Root" }
    New-PSDrive -Name $letter -PSProvider FileSystem -Root $Root -Persist | Out-Null
    try {
        $global:LASTEXITCODE = 0
        & (Join-Path "${letter}:\" $ScriptName) @Splat | Out-Host
        return $LASTEXITCODE
    } finally {
        Remove-PSDrive -Name $letter -Force
    }
}
