<#
.SYNOPSIS
    Build the EUI-free Community-Patch-only modpack DLC for Civ V Access into
    build/modpack-cp-out, ready for deploy-modpack-cp.ps1.

.DESCRIPTION
    The Community-Patch-only counterpart of build-modpack.ps1. It is a thin
    wrapper over `build-modpack.ps1 -CommunityPatchOnly`, so the CP and VP
    modpack bakes share one implementation and cannot drift apart across a VP
    re-pin.

    It bakes Community Patch alone -- no Vox Populi balance overhaul -- from a
    clean Community-Patch-only cache database. Produce that database by playing
    one session with ONLY (1) Community Patch enabled (Vox Populi disabled)
    through the Mods menu first; the assembler refuses to bake unless the cache
    shows the Community Patch DLL present with BALANCE_VP off.

    All parameters forward to build-modpack.ps1 (GameDir / ClonePath /
    CacheDir); see that script for their meaning.
#>
[CmdletBinding()]
param(
    [string]$GameDir,
    [string]$ClonePath,
    [string]$CacheDir
)

$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'build-modpack.ps1') -CommunityPatchOnly @PSBoundParameters
