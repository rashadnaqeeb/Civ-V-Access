<#
.SYNOPSIS
    Build the Civ V Access installer as a single-file self-contained .NET
    Windows executable.

.DESCRIPTION
    Wraps `dotnet publish` for installer/CivVAccessInstaller.csproj. Produces
    a single CivVAccessInstaller.exe under dist/installer/ that has no
    runtime dependency (the .NET 8 runtime is bundled).

    The build embeds 10 locale resource files (en_US plus the 9 the mod
    itself ships translations for); the active locale is picked from the
    user's system culture and can be changed at runtime from the Language
    menu.

    Run after any change under installer/. The output is meant to be
    attached to a GitHub Release alongside the component zips so players
    can download it once and let it self-resolve subsequent updates.
#>
[CmdletBinding()]
param(
    [string]$Configuration = 'Release',
    [string]$Runtime = 'win-x64'
)

$ErrorActionPreference = 'Stop'

$repoRoot   = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Join-Path $repoRoot 'installer'
$projectCsproj = Join-Path $projectDir 'CivVAccessInstaller.csproj'
$outputDir  = Join-Path $repoRoot 'dist\installer'

if (-not (Test-Path $projectCsproj)) {
    throw "Installer project not found at $projectCsproj"
}

if (Test-Path $outputDir) {
    Remove-Item -LiteralPath $outputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

Write-Host "Publishing installer..."
Write-Host "  Configuration: $Configuration"
Write-Host "  Runtime      : $Runtime"
Write-Host "  Output       : $outputDir"

& dotnet publish $projectCsproj `
    --configuration $Configuration `
    --runtime $Runtime `
    --self-contained true `
    -p:PublishSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true `
    -p:PublishReadyToRun=false `
    -p:PublishTrimmed=false `
    --output $outputDir

if ($LASTEXITCODE -ne 0) {
    throw "dotnet publish failed (exit code $LASTEXITCODE)."
}

$exe = Join-Path $outputDir 'CivVAccessInstaller.exe'
if (-not (Test-Path $exe)) {
    throw "Expected output not produced: $exe"
}

$size = (Get-Item -LiteralPath $exe).Length
$sizeMb = [math]::Round($size / 1MB, 1)

Write-Host ""
Write-Host "Installer built:"
Write-Host "  $exe ($sizeMb MB)"
