<#
.SYNOPSIS
    Orchestrator for the Civ-V-Access build pipeline.

.DESCRIPTION
    Calls the underlying scripts in order:
      1. build-proxy.ps1   - compile lua51_Win32.dll
      2. build-engine.ps1  - compile CvGameCore_Expansion2.dll fork (opt-in)
      3. deploy.ps1        - copy proxy stack, DLC, and (opt-in) engine DLL

    Each script can also be invoked directly. This wrapper just keeps the
    common case ("rebuild and reinstall the proxy + DLC") a single command.

    Engine work is opt-in: the engine DLL takes ~1-2 minutes to build and
    rarely changes, so most iterations are Lua-only and skip it.

.PARAMETER GameDir
    Override the auto-detected Civ V install path (passed to deploy.ps1).

.PARAMETER SkipBuild
    Skip the proxy compile. Useful when only the Lua / DLC payload changed.
    (Alias for skipping build-proxy.ps1; never affects the engine.)

.PARAMETER SkipDeploy
    Skip the deploy step. Useful when validating compiles without touching
    the game install.

.PARAMETER BuildEngine
    Also compile the engine DLL via build-engine.ps1, then deploy it. Off by
    default. Implies -DeployEngine.

.PARAMETER DeployEngine
    Deploy the engine DLL currently in dist/engine/ without rebuilding it.
    Useful when pulling a pre-built DLL from git rather than compiling locally.

.PARAMETER Uninstall
    Hand off to deploy.ps1 -Uninstall: removes proxy + DLC, restores the
    original lua51, and (if a backup exists) restores the vanilla engine DLL.
#>
[CmdletBinding()]
param(
    [string]$GameDir,
    [switch]$SkipBuild,
    [switch]$SkipDeploy,
    [switch]$BuildEngine,
    [switch]$DeployEngine,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

$repoRoot      = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildProxyPs1 = Join-Path $repoRoot 'build-proxy.ps1'
$buildEngPs1   = Join-Path $repoRoot 'build-engine.ps1'
$deployPs1     = Join-Path $repoRoot 'deploy.ps1'

function Invoke-Script {
    param([string]$Script, [string[]]$Args)
    $args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $Script) + $Args
    & powershell.exe @args
    if ($LASTEXITCODE -ne 0) { throw "$(Split-Path -Leaf $Script) failed (exit $LASTEXITCODE)." }
}

if ($Uninstall) {
    $deployArgs = @('-Uninstall')
    if ($GameDir) { $deployArgs += @('-GameDir', $GameDir) }
    Invoke-Script -Script $deployPs1 -Args $deployArgs
    return
}

if (-not $SkipBuild) {
    Invoke-Script -Script $buildProxyPs1 -Args @()
} else {
    Write-Host "Skipping proxy build (-SkipBuild)."
}

if ($BuildEngine) {
    Invoke-Script -Script $buildEngPs1 -Args @()
    # Building the engine implies deploying it; would otherwise be wasted work.
    $DeployEngine = $true
}

if (-not $SkipDeploy) {
    $deployArgs = @()
    if ($GameDir)      { $deployArgs += @('-GameDir', $GameDir) }
    if ($DeployEngine) { $deployArgs += '-DeployEngine' }
    Invoke-Script -Script $deployPs1 -Args $deployArgs
} else {
    Write-Host "Skipping deploy (-SkipDeploy)."
}
