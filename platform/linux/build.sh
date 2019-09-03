CUR_DIR=$(cd "$(dirname "$0")";pwd)
ROOT_DIR=$(cd "$(dirname "$0")"/../..; pwd)

LUA_SRC_DIR=$ROOT_DIR/3rd/lua-5.3.5
LUA_INSTALL_DIR=$CUR_DIR/lua
LUA_LIB_DIR=$CUR_DIR/lua/share/lua/5.3

## build lua
cd $LUA_SRC_DIR
make linux INSTALL_TOP=$LUA_INSTALL_DIR
make install INSTALL_TOP=$LUA_INSTALL_DIR

## build luasocket
LUASOCKET_SRC_DIR=$ROOT_DIR/3rd/luasocket
cd $LUASOCKET_SRC_DIR
make LUAV=5.3 PLAT=linux LUAPREFIX_linux=$CUR_DIR/lua
make install LUAV=5.3 PLAT=linux LUAPREFIX_linux=$CUR_DIR/lua

cd $ROOT_DIR/3rd/copas
make install LUA_DIR=$LUA_LIB_DIR

## install 3rd/lua-websockets
mkdir -p $LUA_LIB_DIR/websocket
cd $ROOT_DIR/3rd/lua-websockets
cp src/websocket.lua              $LUA_LIB_DIR/websocket.lua
cp src/websocket/async.lua        $LUA_LIB_DIR/websocket/async.lua
cp src/websocket/sync.lua         $LUA_LIB_DIR/websocket/sync.lua
cp src/websocket/client.lua       $LUA_LIB_DIR/websocket/client.lua
cp src/websocket/client_sync.lua  $LUA_LIB_DIR/websocket/client_sync.lua
cp src/websocket/client_ev.lua    $LUA_LIB_DIR/websocket/client_ev.lua
cp src/websocket/client_copas.lua $LUA_LIB_DIR/websocket/client_copas.lua
cp src/websocket/ev_common.lua    $LUA_LIB_DIR/websocket/ev_common.lua
cp src/websocket/server.lua       $LUA_LIB_DIR/websocket/server.lua
cp src/websocket/server_ev.lua    $LUA_LIB_DIR/websocket/server_ev.lua
cp src/websocket/server_copas.lua $LUA_LIB_DIR/websocket/server_copas.lua
cp src/websocket/handshake.lua    $LUA_LIB_DIR/websocket/handshake.lua
cp src/websocket/tools.lua        $LUA_LIB_DIR/websocket/tools.lua
cp src/websocket/frame.lua        $LUA_LIB_DIR/websocket/frame.lua
cp src/websocket/bit.lua          $LUA_LIB_DIR/websocket/bit.lua

## install 3rd/lua-MessagePack
cp $ROOT_DIR/3rd/lua-MessagePack/src5.3/MessagePack.lua $LUA_LIB_DIR/MessagePack.lua

## install openssl lib
# sudo yum install openssl-devel
cd $ROOT_DIR/3rd/lua-openssl
make PREFIX=$CUR_DIR/lua LUA_VERSION=5.3
make install PREFIX=$CUR_DIR/lua LUA_VERSION=5.3
cp lib/*.lua $LUA_LIB_DIR/

## install 3rd/lua-signal
cd $ROOT_DIR/3rd/lua-signal
make PREFIX=$CUR_DIR/lua LUA_LIBDIR=$CUR_DIR/lua/lib/lua/5.3
make install PREFIX=$CUR_DIR/lua LUA_LIBDIR=$CUR_DIR/lua/lib/lua/5.3

## use luastatic build one exe.
cp $ROOT_DIR/3rd/luastatic/luastatic.lua $LUA_LIB_DIR/luastatic.lua

## gen src/cacert.lua
cd $ROOT_DIR/src
echo 'return [[' > cacert.lua
cat cacert.pem >> cacert.lua
echo ']]' >> cacert.lua

## copy oclip src
RUN_DIR=$CUR_DIR/lua/bin
cd $ROOT_DIR/src
mkdir -p $RUN_DIR/oclip
$CUR_DIR/lua/bin/lua genicon.lua icon.ico icon_bytes.lua
cp *.lua $RUN_DIR/oclip/
cp cacert.pem $RUN_DIR/cacert.pem

## build oclip
cd $CUR_DIR
#make clean
#make


