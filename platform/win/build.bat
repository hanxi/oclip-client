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
set TRAY_DIR=%cd%
nmake /nologo

:: build lclipboard
cd /d %cur_dir%\..\..\3rd\lclipboard
set CLIPBOARD_DIR=%cd%
call nmake /nologo clean
nmake /nologo


set LUA_LIB_DIR=%LUA_INSTALL_PATH%\bin

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
copy src\websocket\async.lua         %LUA_LIB_DIR%\websocket\async.lua
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

:: install 3rd/lua-MessagePack
copy %cur_dir%\..\..\3rd\lua-MessagePack\src5.3\MessagePack.lua %LUA_LIB_DIR%\MessagePack.lua

:: build lua-openssl
cd /d %cur_dir%\..\..\3rd\lua-openssl
set LUA_OPENSSL_DIR=%cd%
cd /d %cur_dir%\lua-openssl-build
set OPENSSL_PATH="C:\openssl_lib"
: call nmake /nologo clean
nmake /nologo

: use luastatic build one exe.
cd /d %cur_dir%\..\..\3rd\luastatic
copy luastatic.lua       %LUA_LIB_DIR%\luastatic.lua
cd /d %LUA_INSTALL_PATH%\bin
set MAIN_DIR=%cd%

: lua.exe luastatic.lua oclip\main.lua ^
: copas.lua ^
: crypto.lua ^
: ltn12.lua ^
: MessagePack.lua ^
: mime.lua ^
: socket.lua ^
: ssl.lua ^
: websocket.lua ^
: copas\ftp.lua ^
: copas\http.lua ^
: copas\limit.lua ^
: copas\smtp.lua ^
: oclip\config.lua ^
: oclip\rpc.lua ^
: oclip\tools.lua ^
: socket\ftp.lua ^
: socket\headers.lua ^
: socket\http.lua ^
: socket\smtp.lua ^
: socket\tp.lua ^
: socket\url.lua ^
: websocket\async.lua ^
: websocket\bit.lua ^
: websocket\client.lua ^
: websocket\client_copas.lua ^
: websocket\client_ev.lua ^
: websocket\client_sync.lua ^
: websocket\ev_common.lua ^
: websocket\frame.lua ^
: websocket\handshake.lua ^
: websocket\server.lua ^
: websocket\server_copas.lua ^
: websocket\server_ev.lua ^
: websocket\sync.lua ^
: websocket\tools.lua ^
: clipboard.dll ^
: mime\core.dll ^
: openssl.dll ^
: socket\core.dll ^
: ssl.dll ^
: tray.dll

cd /d %cur_dir%
nmake clean
nmake

cd /d %local_dir%

