echo off
set local_dir=%cd%
set cur_dir=%~dp0

set RUN_DIR=%cur_dir%\lua\bin
cd /d %cur_dir%\..\..\src
set SRC_DIR=%cd%

if not exist %RUN_DIR%\oclip mkdir %RUN_DIR%\oclip
copy main.lua %RUN_DIR%\oclip\main.lua
copy rpc.lua %RUN_DIR%\oclip\rpc.lua
copy tools.lua %RUN_DIR%\oclip\tools.lua
copy cacert.pem %RUN_DIR%\cacert.pem
cd %RUN_DIR%
call lua.exe oclip\main.lua

cd /d %local_dir%