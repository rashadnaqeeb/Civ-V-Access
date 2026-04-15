@echo on
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvarsall.bat" x86
cd /d "%~dp0src"
nmake
echo BUILD_EXIT=%errorlevel%
