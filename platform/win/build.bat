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

:: build lua source
cd /d %cur_dir%\lua-build
: call nmake /nologo clean
nmake /nologo

:: build luasocket
cd /d %cur_dir%\..\..\3rd\luasocket\src
set LUASOCKET_SRC_DIR=%cd%
cd /d %cur_dir%\luasocket-build
: call nmake /nologo clean
nmake /nologo

:: build ltray
cd /d %cur_dir%\..\..\3rd\ltray
: call nmake /nologo clean
nmake /nologo

:: build lclipboard
cd /d %cur_dir%\..\..\3rd\lclipboard
: call nmake /nologo clean
nmake /nologo


set LUA_LIB_DIR=%LUA_INSTALL_PATH%\bin\lua

:: install 3rd/copas
if not exist %LUA_LIB_DIR%\copas mkdir %LUA_LIB_DIR%\copas
cd /d %cur_dir%\..\..\3rd\copas
copy src\copas.lua       %LUA_LIB_DIR%\copas.lua
copy src\copas\ftp.lua   %LUA_LIB_DIR%\copas\ftp.lua
copy src\copas\smtp.lua  %LUA_LIB_DIR%\copas\smtp.lua
copy src\copas\http.lua  %LUA_LIB_DIR%\copas\http.lua
copy src\copas\limit.lua %LUA_LIB_DIR%\copas\limit.lua

:: install 3rd/lua-websockets
if not exist %LUA_LIB_DIR%\websocket mkdir %LUA_LIB_DIR%\websocket
cd /d %cur_dir%\..\..\3rd\lua-websockets
copy src\websocket.lua              %LUA_LIB_DIR%\websocket.lua
copy src\websocket\sync.lua         %LUA_LIB_DIR%\websocket\sync.lua
copy src\websocket\client.lua       %LUA_LIB_DIR%\websocket\client.lua
copy src\websocket\client_sync.lua  %LUA_LIB_DIR%\websocket\client_sync.lua
copy src\websocket\client_ev.lua    %LUA_LIB_DIR%\websocket\client_ev.lua
copy src\websocket\client_copas.lua %LUA_LIB_DIR%\websocket\client_copas.lua
copy src\websocket\ev_common.lua    %LUA_LIB_DIR%\websocket\ev_common.lua
copy src\websocket\server.lua       %LUA_LIB_DIR%\websocket\server.lua
copy src\websocket\server_ev.lua    %LUA_LIB_DIR%\websocket\server_ev.lua
copy src\websocket\server_copas.lua %LUA_LIB_DIR%\websocket\server_copas.lua
copy src\websocket\handshake.lua    %LUA_LIB_DIR%\websocket\handshake.lua
copy src\websocket\tools.lua        %LUA_LIB_DIR%\websocket\tools.lua
copy src\websocket\frame.lua        %LUA_LIB_DIR%\websocket\frame.lua
copy src\websocket\bit.lua          %LUA_LIB_DIR%\websocket\bit.lua

:: build openssl
:: download perl from http://strawberryperl.com/
:: download openssl from https://www.openssl.org/source/
: cd /d %cur_dir%\..\..\3rd\openssl-1.1.0k
: perl Configure VC-WIN32 no-asm --prefix=c:/openssl_lib -static
: nmake
: nmake install

:: build luasec
: cd /d %cur_dir%\..\..\3rd\luasec\src
: set LUASEC_SRC_DIR=%cd%
: cd /d %cur_dir%\luasec-build
: set OPENSSL_PATH="C:\openssl_lib"
: call nmake /nologo clean
: nmake /nologo

:: install 3rd/lua-MessagePack
copy %cur_dir%\..\..\3rd\lua-MessagePack\src5.3\MessagePack.lua %LUA_LIB_DIR%\MessagePack.lua



: TODO: use luastatic build one exe.

: cd /d %cur_dir%\..\..\src
: set ROOT_SRC=%cd%
: cd /d %cur_dir%
: call lua\bin\lua.exe genicon.lua icon.ico icon.h

: call nmake /nologo clean
: nmake /nologo

cd /d %local_dir%

