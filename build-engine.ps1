<#
.SYNOPSIS
    Build the Civ V engine DLL fork (CvGameCore_Expansion2.dll).

.DESCRIPTION
    Mirrors the vanilla SDK source from the Civ V Modding SDK install into
    build/engine/source/, applies our overlay from src/engine/ on top, then
    compiles with VC9 (Visual C++ 2008 SP1) and links against the Firaxis-
    shipped static libs. Output: dist/engine/CvGameCore_Expansion2.dll (committed
    to the repo so contributors can deploy without rebuilding).

    Requires:
      - Civ V Modding SDK installed (default: Steam install)
      - Windows SDK 7.0 components installed via build/sdk7-install/install.cmd
        (specifically vc_stdx86 -> VS 9.0\VC\bin\cl.exe and v7.0\Include + Lib)

    The overlay step is a no-op when src/engine/ does not exist or is empty.
    A vanilla smoke build is the same code path with no overlay applied.

.PARAMETER SdkSourceDir
    Override the SDK source root. Defaults to the Steam install path.

.PARAMETER Clean
    Delete build/engine/source/ before mirroring. Forces a from-scratch build.
#>
[CmdletBinding()]
param(
    [string]$SdkSourceDir,
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'

$repoRoot     = Split-Path -Parent $MyInvocation.MyCommand.Path
$overlayDir   = Join-Path $repoRoot 'src\engine'
$buildRoot    = Join-Path $repoRoot 'build\engine'
$workDir      = Join-Path $buildRoot 'source'
$distDir      = Join-Path $repoRoot 'dist\engine'
$projectName  = 'CvGameCoreDLL_Expansion2'
$outDllName   = 'CvGameCore_Expansion2.dll'

# Toolchain locations (set by Windows SDK 7.0 vc_stdx86 + WinSDK MSI installs).
$vc9Root      = 'C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC'
$sdk7Root     = 'C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0'
$vc9Bin       = Join-Path $vc9Root 'bin'
$cl           = Join-Path $vc9Bin 'cl.exe'
$linkExe      = Join-Path $vc9Bin 'link.exe'
# cl.exe / link.exe load mspdb80.dll, msobj80.dll, mspdbcore.dll from
# Common7\IDE\ rather than VC\bin\. Without this on PATH, /Zi builds fail with
# STATUS_DLL_NOT_FOUND (0xC0000135).
$vsCommon7Ide = 'C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE'

function Resolve-SdkSourceDir {
    param([string]$Explicit)
    if ($Explicit) {
        if (-not (Test-Path $Explicit)) { throw "Override SDK source not found: $Explicit" }
        return (Resolve-Path $Explicit).Path
    }
    $candidates = @(
        "C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V SDK\CvGameCoreSource"
    )
    foreach ($c in $candidates) {
        if (Test-Path (Join-Path $c $projectName)) { return $c }
    }
    throw "Could not find Civ V SDK source. Pass -SdkSourceDir or install the SDK from Steam (`Sid Meier's Civilization V SDK`)."
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

function Sync-SdkSource {
    param([string]$Src, [string]$Dst)
    Write-Host "Mirroring SDK source:"
    Write-Host "  from $Src"
    Write-Host "  to   $Dst"
    if ($Clean -and (Test-Path $Dst)) {
        Write-Host "  (clean) removing $Dst"
        Remove-Item -LiteralPath $Dst -Recurse -Force
    }
    New-Item -ItemType Directory -Path $Dst -Force | Out-Null
    # robocopy returns 0 (no copy) or 1 (copied) on success; >=8 is a real
    # error. Wrap so PS doesn't treat 1 as failure.
    $rc = & robocopy $Src $Dst /MIR /NFL /NDL /NJH /NJS /NP /R:1 /W:1
    $code = $LASTEXITCODE
    if ($code -ge 8) { throw "robocopy failed mirroring SDK source (exit $code)" }
}

function Apply-Overlay {
    param([string]$OverlaySrc, [string]$WorkRoot)
    if (-not (Test-Path $OverlaySrc)) {
        Write-Host "Overlay: src/engine/ not present (vanilla build)."
        return
    }
    $items = Get-ChildItem -LiteralPath $OverlaySrc -Recurse -File -ErrorAction SilentlyContinue
    if (-not $items -or $items.Count -eq 0) {
        Write-Host "Overlay: src/engine/ is empty (vanilla build)."
        return
    }
    Write-Host "Applying overlay from ${OverlaySrc}:"
    foreach ($f in $items) {
        $rel = $f.FullName.Substring($OverlaySrc.Length).TrimStart('\','/')
        $dst = Join-Path $WorkRoot $rel
        $dstDir = Split-Path -Parent $dst
        if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
        Copy-Item -LiteralPath $f.FullName -Destination $dst -Force
        Write-Host "  $rel"
    }
}

function Build-Engine {
    param([string]$WorkRoot)

    $projDir = Join-Path $WorkRoot $projectName
    if (-not (Test-Path $projDir)) {
        throw "Project dir missing after sync: $projDir"
    }
    $defFile = Join-Path $projDir 'CvGameCoreDLL.def'
    if (-not (Test-Path $defFile)) { throw "Module-definition file missing: $defFile" }

    # Per-config output dirs under build/engine/.
    $objDir = Join-Path $buildRoot 'obj'
    $pchDir = Join-Path $buildRoot 'pch'
    foreach ($d in @($objDir, $pchDir, $distDir)) {
        if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    }

    # Include and lib paths -- match vs2013.vcxproj's Mod|Win32 config
    # exactly, except using SDK 7.0 + VC9 instead of $(VCInstallDir).
    $includes = @(
        (Join-Path $vc9Root 'include'),
        (Join-Path $sdk7Root 'Include'),
        (Join-Path $WorkRoot 'CvWorldBuilderMap\include'),
        (Join-Path $WorkRoot 'CvGameCoreDLLUtil\include'),
        (Join-Path $WorkRoot 'CvLocalization\include'),
        (Join-Path $WorkRoot 'CvGameDatabase\include'),
        (Join-Path $WorkRoot 'FirePlace\include'),
        (Join-Path $WorkRoot 'FirePlace\include\FireWorks'),
        (Join-Path $WorkRoot 'ThirdPartyLibs\Lua51\include')
    )
    $libDirs = @(
        (Join-Path $vc9Root 'lib'),
        (Join-Path $sdk7Root 'Lib'),
        (Join-Path $WorkRoot 'CvWorldBuilderMap\lib'),
        (Join-Path $WorkRoot 'CvGameCoreDLLUtil\lib'),
        (Join-Path $WorkRoot 'CvLocalization\lib'),
        (Join-Path $WorkRoot 'CvGameDatabase\lib'),
        (Join-Path $WorkRoot 'FirePlace\lib'),
        (Join-Path $WorkRoot 'ThirdPartyLibs\Lua51\lib')
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

    # Compose env so cl.exe / link.exe find headers, libs, and helper exes.
    $env:PATH    = "$vc9Bin;$vsCommon7Ide;$($env:PATH)"
    $env:INCLUDE = ($includes -join ';')
    $env:LIB     = ($libDirs  -join ';')

    # cl.exe shared flags. Mirrors vcxproj Mod|Win32 ClCompile node.
    $clShared = @(
        '/nologo', '/c', '/EHsc', '/O2', '/Ob2', '/Oi', '/Oy',
        '/MD', '/GS-', '/Gy', '/fp:strict', '/W3', '/Zi'
    )
    foreach ($d in $defines) { $clShared += "/D$d" }

    Push-Location $projDir
    try {
        # ---------- 1. Compile precompiled header ----------
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

        # ---------- 2. Compile all other source files ----------
        $allCpp = Get-ChildItem -LiteralPath $projDir -Filter '*.cpp' -File -Recurse |
                  Where-Object { $_.Name -ne '_precompile.cpp' } |
                  Sort-Object FullName
        Write-Host ""
        Write-Host "Compiling $($allCpp.Count) source files with /MP..."

        # cl.exe accepts many sources on one command line. With /MP it forks
        # one cl per logical core and parallelizes. Pass relative paths
        # (we're cd'd into projDir) so /Fo dir prefix is short and the same
        # file layout works under overlay.
        $relSources = $allCpp | ForEach-Object {
            $_.FullName.Substring($projDir.Length).TrimStart('\','/')
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
$sdk = Resolve-SdkSourceDir -Explicit $SdkSourceDir
Sync-SdkSource -Src $sdk -Dst $workDir
Apply-Overlay -OverlaySrc $overlayDir -WorkRoot $workDir
Build-Engine -WorkRoot $workDir
