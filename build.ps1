<#
.SYNOPSIS
    Unified build + deploy driver for Civ-V-Access.

.DESCRIPTION
    Compiles the proxy DLL and deploys the proxy stack + DLC payload into the
    game install. Runs both steps by default; skip either with -SkipBuild or
    -SkipDeploy. Use -Uninstall to remove the proxy stack, the DLC, and any
    legacy MODS/ directory left over from earlier mod-packaged installs.

.PARAMETER GameDir
    Explicit path to the Civilization V install directory. Overrides auto-detection.

.PARAMETER SkipBuild
    Skip the proxy compile step. Useful when only the Lua payload changed.

.PARAMETER SkipDeploy
    Skip the deploy step. Useful when validating the compile without touching
    the game install.

.PARAMETER Uninstall
    Remove the DLC, restore the original lua51_Win32.dll, and delete any
    legacy MODS/Civ-V-Access (v 1)/ directory from the user's Documents.
#>
[CmdletBinding()]
param(
    [string]$GameDir,
    [switch]$SkipBuild,
    [switch]$SkipDeploy,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

$repoRoot  = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildBat  = Join-Path $repoRoot 'src\proxy\build_proxy.bat'
$stageDir  = Join-Path $repoRoot 'build\proxy\stage'
$dlcSrcDir = Join-Path $repoRoot 'src\dlc'
$dlcName   = 'CivVAccess'
$legacyModDir = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5\MODS\Civ-V-Access (v 1)"

$proxyFiles = @(
    'lua51_Win32.dll',
    'Tolk.dll',
    'SAAPI32.dll',
    'dolapi32.dll',
    'nvdaControllerClient32.dll'
)

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
                $matches = [regex]::Matches($raw, '"path"\s*"([^"]+)"')
                foreach ($m in $matches) {
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

function Invoke-ProxyBuild {
    if (-not (Test-Path $buildBat)) {
        throw "Proxy build script not found at $buildBat"
    }
    Write-Host "Compiling proxy via build_proxy.bat..."
    & cmd.exe /c "`"$buildBat`""
    if ($LASTEXITCODE -ne 0) {
        throw "Proxy build failed (exit $LASTEXITCODE)."
    }
}

function Invoke-Deploy {
    param([string]$ExplicitGameDir)

    Write-Host "Locating Civilization V install..."
    $gameDir = Resolve-CivVInstallDir -ExplicitPath $ExplicitGameDir
    Write-Host "  Game dir: $gameDir"

    $stageProxy = Join-Path $stageDir 'lua51_Win32.dll'
    if (-not (Test-Path $stageProxy)) {
        throw "Proxy build not found at $stageProxy. Run without -SkipBuild or build manually first."
    }
    foreach ($f in $proxyFiles) {
        $p = Join-Path $stageDir $f
        if (-not (Test-Path $p)) { throw "Missing staged file: $p" }
    }

    $stockDll    = Join-Path $gameDir 'lua51_Win32.dll'
    $originalDll = Join-Path $gameDir 'lua51_original.dll'
    if (Test-Path $originalDll) {
        Write-Host "  lua51_original.dll already present - proxy previously deployed."
    } elseif (Test-Path $stockDll) {
        Write-Host "  Renaming stock lua51_Win32.dll -> lua51_original.dll"
        Rename-Item -LiteralPath $stockDll -NewName 'lua51_original.dll'
    } else {
        throw "Neither lua51_Win32.dll nor lua51_original.dll found in $gameDir. Run 'Verify integrity of game files' in Steam and retry."
    }

    Write-Host "Copying proxy stack to game directory:"
    foreach ($f in $proxyFiles) {
        $src = Join-Path $stageDir $f
        $dst = Join-Path $gameDir $f
        Copy-Item -LiteralPath $src -Destination $dst -Force
        Write-Host "  $dst"
    }

    $dlcDir = Join-Path $gameDir "Assets\DLC\$dlcName"
    if (Test-Path $dlcDir) {
        Write-Host "  Removing existing DLC directory: $dlcDir"
        Remove-Item -LiteralPath $dlcDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $dlcDir -Force | Out-Null
    Write-Host "Deploying DLC payload to:"
    Write-Host "  $dlcDir"
    Copy-Item -Path (Join-Path $dlcSrcDir '*') -Destination $dlcDir -Recurse -Force

    # Clean up any orphan legacy install so the mod loader doesn't pick up
    # stale entries from previous non-DLC deploys.
    if (Test-Path $legacyModDir) {
        Write-Host "Removing legacy mod directory:"
        Write-Host "  $legacyModDir"
        Remove-Item -LiteralPath $legacyModDir -Recurse -Force
    }
    $legacyBootstrap = Join-Path $gameDir 'CivVAccess'
    if ((Test-Path $legacyBootstrap) -and ($legacyBootstrap -ne $dlcDir)) {
        Write-Host "Removing legacy bootstrap directory:"
        Write-Host "  $legacyBootstrap"
        Remove-Item -LiteralPath $legacyBootstrap -Recurse -Force
    }

    return @{ GameDir = $gameDir; DlcDir = $dlcDir }
}

function Invoke-Uninstall {
    param([string]$ExplicitGameDir)

    Write-Host "Locating Civilization V install..."
    $gameDir = Resolve-CivVInstallDir -ExplicitPath $ExplicitGameDir
    Write-Host "  Game dir: $gameDir"

    $stockDll    = Join-Path $gameDir 'lua51_Win32.dll'
    $originalDll = Join-Path $gameDir 'lua51_original.dll'
    if (Test-Path $originalDll) {
        if (Test-Path $stockDll) {
            Write-Host "  Removing proxy lua51_Win32.dll"
            Remove-Item -LiteralPath $stockDll -Force
        }
        Write-Host "  Restoring lua51_original.dll -> lua51_Win32.dll"
        Rename-Item -LiteralPath $originalDll -NewName 'lua51_Win32.dll'
    } else {
        Write-Host "  No lua51_original.dll found; skipping proxy restore."
    }

    foreach ($f in @('Tolk.dll','SAAPI32.dll','dolapi32.dll','nvdaControllerClient32.dll')) {
        $p = Join-Path $gameDir $f
        if (Test-Path $p) {
            Write-Host "  Removing $p"
            Remove-Item -LiteralPath $p -Force
        }
    }

    $dlcDir = Join-Path $gameDir "Assets\DLC\$dlcName"
    if (Test-Path $dlcDir) {
        Write-Host "  Removing DLC: $dlcDir"
        Remove-Item -LiteralPath $dlcDir -Recurse -Force
    }

    $legacyBootstrap = Join-Path $gameDir 'CivVAccess'
    if (Test-Path $legacyBootstrap) {
        Write-Host "  Removing legacy bootstrap: $legacyBootstrap"
        Remove-Item -LiteralPath $legacyBootstrap -Recurse -Force
    }

    if (Test-Path $legacyModDir) {
        Write-Host "  Removing legacy mod directory: $legacyModDir"
        Remove-Item -LiteralPath $legacyModDir -Recurse -Force
    }

    $proxyLog = Join-Path $gameDir 'proxy_debug.log'
    if (Test-Path $proxyLog) {
        Remove-Item -LiteralPath $proxyLog -Force
    }

    return @{ GameDir = $gameDir }
}

if ($Uninstall) {
    $result = Invoke-Uninstall -ExplicitGameDir $GameDir
    Write-Host ""
    Write-Host "Uninstall complete."
    Write-Host "  Game dir: $($result.GameDir)"
    return
}

if (-not $SkipBuild) {
    Invoke-ProxyBuild
} else {
    Write-Host "Skipping proxy build (-SkipBuild)."
}

if (-not $SkipDeploy) {
    $result = Invoke-Deploy -ExplicitGameDir $GameDir
    Write-Host ""
    Write-Host "Deploy complete."
    Write-Host "  Proxy: $($result.GameDir)"
    Write-Host "  DLC:   $($result.DlcDir)"
    Write-Host ""
    Write-Host "Reminder: for Lua.log output, set LoggingEnabled=1 in:"
    Write-Host "  $env:USERPROFILE\Documents\My Games\Sid Meier's Civilization 5\config.ini"
} else {
    Write-Host "Skipping deploy (-SkipDeploy)."
}
