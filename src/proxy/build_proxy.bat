@echo off
setlocal
rem Build the Civ V Lua 5.1 proxy DLL (32-bit).
rem Output: <repo>\dist\proxy\lua51_Win32.dll (committed to repo)
rem Intermediates (.obj, .lib, .exp): <repo>\build\proxy\

set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (
    echo FAILED: vswhere not found at "%VSWHERE%"
    exit /b 1
)
for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSINSTALL=%%i"
if not defined VSINSTALL (
    echo FAILED: could not locate Visual Studio with C++ build tools
    exit /b 1
)
call "%VSINSTALL%\VC\Auxiliary\Build\vcvarsall.bat" x86
if errorlevel 1 (
    echo FAILED: vcvarsall
    exit /b 1
)

set "SRC=%~dp0"
set "REPO=%~dp0..\.."
set "INTDIR=%REPO%\build\proxy"
set "DIST=%REPO%\dist\proxy"

if not exist "%INTDIR%" mkdir "%INTDIR%"
if not exist "%DIST%" mkdir "%DIST%"

echo Building lua51_Win32.dll (x86)...
rem /bigobj: miniaudio's single-header implementation produces far more
rem sections than the default COFF limit allows.
cl /nologo /O2 /W3 /LD /MT /bigobj /D_CRT_SECURE_NO_WARNINGS ^
    /Fo"%INTDIR%\proxy.obj" ^
    /Fe"%DIST%\lua51_Win32.dll" ^
    "%SRC%proxy.c" ^
    /link /DEF:"%SRC%proxy.def" ^
           /IMPLIB:"%INTDIR%\lua51_Win32.lib" ^
           /OUT:"%DIST%\lua51_Win32.dll" ^
           /MACHINE:X86
if errorlevel 1 (
    echo FAILED: cl
    exit /b 1
)

echo SUCCESS: %DIST%\lua51_Win32.dll
exit /b 0
