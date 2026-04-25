@echo off
setlocal
rem Build the Civ V Lua 5.1 proxy DLL (32-bit).
rem Output: <repo>\build\proxy\lua51_Win32.dll (+ .lib, .exp)
rem Stage:  <repo>\build\proxy\stage\  (DLL + Tolk stack, ready for deploy)

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
set "OUT=%REPO%\build\proxy"
set "STAGE=%OUT%\stage"
set "TOLK=%REPO%\third_party\tolk\dist\x86"

if not exist "%OUT%" mkdir "%OUT%"
if not exist "%STAGE%" mkdir "%STAGE%"

echo Building lua51_Win32.dll (x86)...
rem /bigobj: miniaudio's single-header implementation produces far more
rem sections than the default COFF limit allows.
cl /nologo /O2 /W3 /LD /MT /bigobj /D_CRT_SECURE_NO_WARNINGS ^
    /Fo"%OUT%\proxy.obj" ^
    /Fe"%OUT%\lua51_Win32.dll" ^
    "%SRC%proxy.c" ^
    /link /DEF:"%SRC%proxy.def" ^
           /IMPLIB:"%OUT%\lua51_Win32.lib" ^
           /OUT:"%OUT%\lua51_Win32.dll" ^
           /MACHINE:X86
if errorlevel 1 (
    echo FAILED: cl
    exit /b 1
)

echo Staging for deploy...
copy /y "%OUT%\lua51_Win32.dll" "%STAGE%\" >nul
if exist "%TOLK%\Tolk.dll"                copy /y "%TOLK%\Tolk.dll"                "%STAGE%\" >nul
if exist "%TOLK%\SAAPI32.dll"             copy /y "%TOLK%\SAAPI32.dll"             "%STAGE%\" >nul
if exist "%TOLK%\dolapi32.dll"            copy /y "%TOLK%\dolapi32.dll"            "%STAGE%\" >nul
if exist "%TOLK%\nvdaControllerClient32.dll" copy /y "%TOLK%\nvdaControllerClient32.dll" "%STAGE%\" >nul
if exist "%TOLK%\BoyCtrl.dll"             copy /y "%TOLK%\BoyCtrl.dll"             "%STAGE%\" >nul
if exist "%TOLK%\boyctrl.ini"             copy /y "%TOLK%\boyctrl.ini"             "%STAGE%\" >nul
if exist "%TOLK%\ZDSRAPI.dll"             copy /y "%TOLK%\ZDSRAPI.dll"             "%STAGE%\" >nul
if exist "%TOLK%\ZDSRAPI.ini"             copy /y "%TOLK%\ZDSRAPI.ini"             "%STAGE%\" >nul

echo SUCCESS: %OUT%\lua51_Win32.dll
echo Staged:  %STAGE%
echo.
echo Deploy step (manual, not handled here):
echo   1. Rename the game's lua51_Win32.dll to lua51_original.dll (one-time).
echo   2. Copy all files from %STAGE% into the game install directory.
exit /b 0
