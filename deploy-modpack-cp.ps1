<#
.SYNOPSIS
    Deploy Civ V Access in Community-Patch-only modpack form: our accessibility
    DLC plus the EUI-free Community Patch modpack DLC, both started from the
    regular Single Player menu. No mod activation, no MODS overlay.

.DESCRIPTION
    The Community-Patch-only counterpart of deploy-modpack.ps1, and the fourth
    mutually exclusive install state alongside deploy.ps1 (vanilla),
    deploy-vp.ps1 (VP mod flow), and deploy-modpack.ps1 (VP modpack). It is a
    thin wrapper over `deploy-modpack.ps1 -CommunityPatchOnly`, so the CP and VP
    modpack deploys share one implementation and cannot drift apart.

    It lays down the cp vendor stage (build/vendor/cp), the Community-Patch-only
    baked package (build/modpack-cp-out, placed at Assets/DLC/ZCivVAccessCP),
    and the Community Patch InGameUIAddin set. The EngineData seam body is the
    same as VP's -- it feature-detects BALANCE_VP at runtime, so it is
    numerically correct under Community Patch too. No plain-VP base completion
    is performed (the package embeds Community Patch in full and CP uses the
    stock BNW base).

    Build the package first with build-modpack-cp.ps1. All parameters forward
    to deploy-modpack.ps1; see that script for their meaning.
#>
[CmdletBinding()]
param(
    [string]$GameDir,
    [string]$ClonePath,
    [switch]$SkipProxy,
    [switch]$SkipCinematics,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'deploy-modpack.ps1') -CommunityPatchOnly @PSBoundParameters
