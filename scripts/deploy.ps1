<#
.SYNOPSIS
    Deploys the Civ-V-Access proxy DLL stack and Lua mod into the game install.

.DESCRIPTION
    1. Locates the Civilization V install directory (env, param, registry, Steam libraries).
    2. Verifies the proxy stage directory is populated (build/proxy/stage/).
    3. On first run, renames the stock lua51_Win32.dll to lua51_original.dll.
    4. Copies the proxy DLL + Tolk stack into the game directory.
    5. Deploys the Lua mod to the user's MODS folder.

.PARAMETER GameDir
    Explicit path to the Civilization V install directory. Overrides auto-detection.
#>
[CmdletBinding()]
param(
    [string]$GameDir
)

$ErrorActionPreference = 'Stop'

$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot   = Split-Path -Parent $scriptDir
$stageDir   = Join-Path $repoRoot 'build\proxy\stage'
$modSrcDir  = Join-Path $repoRoot 'src\mod'

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

Write-Host "Locating Civilization V install..."
$gameDir = Resolve-CivVInstallDir -ExplicitPath $GameDir
Write-Host "  Game dir: $gameDir"

# Verify proxy stage is fresh
$stageProxy = Join-Path $stageDir 'lua51_Win32.dll'
if (-not (Test-Path $stageProxy)) {
    Write-Error "Proxy build not found at $stageProxy. Run src\proxy\build_proxy.bat first."
    exit 1
}
foreach ($f in $proxyFiles) {
    $p = Join-Path $stageDir $f
    if (-not (Test-Path $p)) {
        Write-Error "Missing staged file: $p"
        exit 1
    }
}

# One-time DLL rename
$stockDll    = Join-Path $gameDir 'lua51_Win32.dll'
$originalDll = Join-Path $gameDir 'lua51_original.dll'
if (Test-Path $originalDll) {
    Write-Host "  lua51_original.dll already present - proxy previously deployed."
} elseif (Test-Path $stockDll) {
    Write-Host "  Renaming stock lua51_Win32.dll -> lua51_original.dll"
    Rename-Item -LiteralPath $stockDll -NewName 'lua51_original.dll'
} else {
    Write-Error "Neither lua51_Win32.dll nor lua51_original.dll found in $gameDir. Run 'Verify integrity of game files' in Steam and retry."
    exit 1
}

# Copy proxy stack
Write-Host "Copying proxy stack to game directory:"
foreach ($f in $proxyFiles) {
    $src = Join-Path $stageDir $f
    $dst = Join-Path $gameDir $f
    Copy-Item -LiteralPath $src -Destination $dst -Force
    Write-Host "  $dst"
}

# Deploy Lua mod
$modsRoot = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization 5\MODS"
$modDir   = Join-Path $modsRoot 'Civ-V-Access (v 1)'
if (-not (Test-Path $modDir)) {
    New-Item -ItemType Directory -Path $modDir -Force | Out-Null
}

Write-Host "Deploying Lua mod to:"
Write-Host "  $modDir"
Copy-Item -Path (Join-Path $modSrcDir '*') -Destination $modDir -Recurse -Force

Write-Host ""
Write-Host "Deploy complete."
Write-Host "  Proxy:  $gameDir"
Write-Host "  Mod:    $modDir"
Write-Host ""
Write-Host "Reminder: for Lua.log output, set LoggingEnabled=1 in:"
Write-Host "  $env:USERPROFILE\Documents\My Games\Sid Meier's Civilization 5\config.ini"
