<#
.SYNOPSIS
    Build the LekMod engine DLL fork (CvGameCore_Expansion2.dll).

.DESCRIPTION
    The LekMod analog of build-engine.ps1. Where the vanilla fork mirrors the
    Firaxis SDK source and overlays src/engine/, LekMod's DLL is an NQMod-lineage
    fork that already carries our additions as commits on the sibling clone's
    `civvaccess` branch. This script compiles that clone's CvGameCoreDLL_Expansion2
    project directly with VC9 (Visual C++ 2008 SP1), linking the Firaxis static
    libs LekMod ships inside the project tree. Output:
    dist/engine-lekmod/CvGameCore_Expansion2.dll (committed so contributors can
    deploy without rebuilding).

    The build recipe (defines, libs, PCH, .def) matches the LekMod VS2008
    Release|Win32 configuration, which is byte-for-byte the same set of defines
    and Firaxis libs the vanilla SDK uses; only the source / include / lib roots
    differ (LekMod nests its sibling libs under the project dir rather than as
    SDK-style siblings). winsqlite3.lib ships in the tree but is not linked
    directly -- it is already baked into CvGameDatabaseWin32.lib.

    Requires:
      - The LekMod clone on its `civvaccess` branch (default: ~/Documents/Lekmod)
      - Windows SDK 7.0 + VC9 installed via build/sdk7-install/install.cmd
        (same toolchain as build-engine.ps1)

.PARAMETER LekModRepo
    Override the LekMod clone root. Defaults to the Lekmod checkout beside this repo, then ~/Documents/Lekmod.

.PARAMETER Clean
    Delete build/engine-lekmod/ intermediates before building.
#>
[CmdletBinding()]
param(
    [string]$LekModRepo,
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'

$repoRoot     = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildRoot    = Join-Path $repoRoot 'build\engine-lekmod'
$distDir      = Join-Path $repoRoot 'dist\engine-lekmod'
$projectName  = 'CvGameCoreDLL_Expansion2'
$outDllName   = 'CvGameCore_Expansion2.dll'

# Toolchain locations -- identical to build-engine.ps1 (VC9 + Windows SDK 7.0).
$vc9Root      = 'C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC'
$sdk7Root     = 'C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0'
$vc9Bin       = Join-Path $vc9Root 'bin'
$cl           = Join-Path $vc9Bin 'cl.exe'
$linkExe      = Join-Path $vc9Bin 'link.exe'
$vsCommon7Ide = 'C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE'

function Resolve-LekModProjDir {
    param([string]$Explicit)
    $candidates = @()
    if ($Explicit) { $candidates += $Explicit }
    $candidates += (Join-Path (Split-Path -Parent $repoRoot) 'Lekmod')
    $candidates += (Join-Path $HOME 'Documents\Lekmod')
    foreach ($c in $candidates) {
        $proj = Join-Path $c "LEKMOD_DLL\$projectName"
        if (Test-Path (Join-Path $proj 'CvGameCoreDLL.def')) { return (Resolve-Path $proj).Path }
    }
    throw "Could not find the LekMod DLL project. Clone https://github.com/EnormousApplePie/Lekmod beside this repo or to ~/Documents/Lekmod (and check out the civvaccess branch), or pass -LekModRepo."
}

function Assert-Toolchain {
    if (-not (Test-Path $cl)) {
        throw "VC9 cl.exe not found at $cl. Run build/sdk7-install/install.cmd elevated to install the vc_stdx86 component."
    }
    $sdkInclude = Join-Path $sdk7Root 'Include\windows.h'
    if (-not (Test-Path $sdkInclude)) {
        throw "Windows SDK 7.0 headers not found at $sdkInclude. Run build/sdk7-install/install.cmd."
    }
}

function Build-Engine {
    param([string]$ProjDir)

    $defFile = Join-Path $ProjDir 'CvGameCoreDLL.def'
    if (-not (Test-Path $defFile)) { throw "Module-definition file missing: $defFile" }

    $objDir = Join-Path $buildRoot 'obj'
    $pchDir = Join-Path $buildRoot 'pch'
    if ($Clean) {
        foreach ($d in @($objDir, $pchDir)) {
            if (Test-Path $d) { Remove-Item -LiteralPath $d -Recurse -Force }
        }
    }
    foreach ($d in @($objDir, $pchDir, $distDir)) {
        if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    }

    # Include / lib roots match the LekMod VS2008 Release|Win32 config, where
    # $(SolutionDir) is the project dir itself (the sibling libs are nested
    # under it, not parented like the SDK layout).
    $includes = @(
        (Join-Path $vc9Root 'include'),
        (Join-Path $sdk7Root 'Include'),
        (Join-Path $ProjDir 'CvWorldBuilderMap\include'),
        (Join-Path $ProjDir 'CvGameCoreDLLUtil\include'),
        (Join-Path $ProjDir 'CvLocalization\include'),
        (Join-Path $ProjDir 'CvGameDatabase\include'),
        (Join-Path $ProjDir 'FirePlace\include'),
        (Join-Path $ProjDir 'FirePlace\include\FireWorks'),
        (Join-Path $ProjDir 'ThirdPartyLibs\Lua51\include')
    )
    $libDirs = @(
        (Join-Path $vc9Root 'lib'),
        (Join-Path $sdk7Root 'Lib'),
        (Join-Path $ProjDir 'CvWorldBuilderMap\lib'),
        (Join-Path $ProjDir 'CvGameCoreDLLUtil\lib'),
        (Join-Path $ProjDir 'CvLocalization\lib'),
        (Join-Path $ProjDir 'CvGameDatabase\lib'),
        (Join-Path $ProjDir 'FirePlace\lib'),
        (Join-Path $ProjDir 'ThirdPartyLibs\Lua51\lib')
    )
    $libs = @(
        'CvWorldBuilderMapWin32.lib',
        'CvGameCoreDLLUtilWin32.lib',
        'CvLocalizationWin32.lib',
        'CvGameDatabaseWin32.lib',
        'FireWorksWin32.lib',
        'FLuaWin32.lib',
        'lua51_Win32.lib',
        'winmm.lib'
    )
    $defines = @(
        'FXS_IS_DLL', 'WIN32', 'NDEBUG', '_WINDOWS', '_USRDLL',
        'CVGAMECOREDLL_EXPORTS', 'FINAL_RELEASE', '_CRT_SECURE_NO_WARNINGS'
    )

    $env:PATH    = "$vc9Bin;$vsCommon7Ide;$($env:PATH)"
    $env:INCLUDE = ($includes -join ';')
    $env:LIB     = ($libDirs  -join ';')

    $clShared = @(
        '/nologo', '/c', '/EHsc', '/O2', '/Ob2', '/Oi', '/Oy',
        '/MD', '/GS-', '/Gy', '/fp:strict', '/W3', '/Zi'
    )
    foreach ($d in $defines) { $clShared += "/D$d" }

    Push-Location $ProjDir
    try {
        # ---------- 1. Precompiled header ----------
        Write-Host ""
        Write-Host "Compiling precompiled header (_precompile.cpp -> CvGameCoreDLLPCH.pch)..."
        $pchObj = Join-Path $objDir '_precompile.obj'
        $pchPch = Join-Path $pchDir 'CvGameCoreDLLPCH.pch'
        $argsPch = $clShared + @(
            '/YcCvGameCoreDLLPCH.h',
            "/Fp$pchPch",
            "/Fo$pchObj",
            "/Fd$($pchDir)\vc90.pdb",
            '_precompile.cpp'
        )
        & $cl @argsPch
        if ($LASTEXITCODE -ne 0) { throw "PCH compile failed (exit $LASTEXITCODE)" }

        # ---------- 2. All other source files ----------
        $allCpp = Get-ChildItem -LiteralPath $ProjDir -Filter '*.cpp' -File -Recurse |
                  Where-Object { $_.Name -ne '_precompile.cpp' } |
                  Sort-Object FullName
        Write-Host ""
        Write-Host "Compiling $($allCpp.Count) source files with /MP..."

        $relSources = $allCpp | ForEach-Object {
            $_.FullName.Substring($ProjDir.Length).TrimStart('\','/')
        }

        $argsAll = $clShared + @(
            '/MP',
            '/YuCvGameCoreDLLPCH.h',
            "/Fp$pchPch",
            "/Fo$objDir\",
            "/Fd$($pchDir)\vc90.pdb"
        ) + $relSources

        & $cl @argsAll
        if ($LASTEXITCODE -ne 0) { throw "Source compile failed (exit $LASTEXITCODE)" }

        # ---------- 3. Link ----------
        Write-Host ""
        Write-Host "Linking $outDllName..."
        $outDll = Join-Path $distDir $outDllName
        $outLib = Join-Path $distDir ([IO.Path]::ChangeExtension($outDllName, '.lib'))
        $outPdb = Join-Path $distDir ([IO.Path]::ChangeExtension($outDllName, '.pdb'))

        $objs = Get-ChildItem -LiteralPath $objDir -Filter '*.obj' -File |
                ForEach-Object { $_.FullName }

        $argsLink = @(
            '/NOLOGO',
            '/DLL',
            '/SUBSYSTEM:WINDOWS',
            '/MACHINE:X86',
            '/LARGEADDRESSAWARE',
            '/OPT:REF',
            '/OPT:ICF',
            '/DYNAMICBASE:NO',
            '/DEBUG',
            "/PDB:$outPdb",
            "/DEF:$defFile",
            "/IMPLIB:$outLib",
            "/OUT:$outDll"
        )
        foreach ($d in $libDirs) { $argsLink += "/LIBPATH:$d" }
        $argsLink += $libs
        $argsLink += $objs

        & $linkExe @argsLink
        if ($LASTEXITCODE -ne 0) { throw "Link failed (exit $LASTEXITCODE)" }

        Write-Host ""
        Write-Host "SUCCESS: $outDll"
        Write-Host "         $outLib"
        Write-Host "         $outPdb"
    } finally {
        Pop-Location
    }
}

# ---- Driver ----
Assert-Toolchain
$proj = Resolve-LekModProjDir -Explicit $LekModRepo
Write-Host "LekMod DLL project: $proj"
Build-Engine -ProjDir $proj
