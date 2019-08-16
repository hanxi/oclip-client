echo off
set local_dir=%cd%
set cur_dir=%~dp0
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" cd /d "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build"
if exist "%ProgramFiles%\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" cd /d "%ProgramFiles%\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build"
set VSCMD_DEBUG=0
where cl.exe
if %ERRORLEVEL% == 1 call vcvarsall.bat x86
cd /d %cur_dir%

cd /d %cur_dir%\..\..\3rd\lua-5.3.5\src
set LUA_SRC_DIR=%cd%
set LUA_INSTALL_PATH=%cur_dir%\lua

cd /d %cur_dir%\lua-build
call nmake /nologo clean
nmake /nologo

cd /d %cur_dir%\..\..\3rd\luasocket\src
set LUASOCKET_SRC_DIR=%cd%
cd /d %cur_dir%\luasocket-build
call nmake /nologo clean
nmake /nologo

cd /d %cur_dir%\..\..\src
set ROOT_SRC=%cd%
cd /d %cur_dir%
call lua\bin\lua.exe genicon.lua icon.ico icon.h

call nmake /nologo clean
nmake /nologo

cd /d %local_dir%

