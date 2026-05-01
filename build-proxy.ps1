<#
.SYNOPSIS
    Compile the Civ V Lua proxy DLL and stage the proxy stack.

.DESCRIPTION
    Invokes src/proxy/build_proxy.bat to compile lua51_Win32.dll. The batch
    script uses vswhere -latest -products * to pick whichever Visual Studio
    install on the machine has the C++ x86/x64 build tools, then runs that
    install's cl.exe via vcvarsall.bat x86. Output goes to
    dist/proxy/lua51_Win32.dll, which is committed to the repo so contributors
    can deploy without rebuilding. The Tolk + screen-reader runtime DLLs are
    not built here; they live (already committed) in third_party/tolk/dist/x86/
    and deploy.ps1 reads them directly.

    No engine DLL work; that lives in build-engine.ps1.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildBat = Join-Path $repoRoot 'src\proxy\build_proxy.bat'

if (-not (Test-Path $buildBat)) {
    throw "Proxy build script not found at $buildBat"
}

Write-Host "Compiling proxy via build_proxy.bat..."
& cmd.exe /c "`"$buildBat`""
if ($LASTEXITCODE -ne 0) {
    throw "Proxy build failed (exit $LASTEXITCODE)."
}
