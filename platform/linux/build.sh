set -x -o

CUR_DIR=$(cd "$(dirname "$0")";pwd)
ROOT_DIR=$(cd "$(dirname "$0")"/../..; pwd)

LUA_SRC_DIR=$ROOT_DIR/3rd/lua-5.3.5
LUA_INSTALL_DIR=$CUR_DIR/lua
LUA_LIB_DIR=$CUR_DIR/lua/share/lua/5.3
LUA_CLIB_DIR=$CUR_DIR/lua/lib/lua/5.3

## clean 
cd $LUA_INSTALL_DIR
find . -name '*.lua' | xargs rm -f
find . -name '*.so' | xargs rm -f

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
mkdir -p $CUR_DIR/tmp
cd $LUA_INSTALL_DIR/bin
find . -name '*.lua' | while read line; do
    install -D $line $CUR_DIR/tmp/$line
done
cd $LUA_INSTALL_DIR/share/lua/5.3/
find . -name '*.lua' | while read line; do
    install -D $line $CUR_DIR/tmp/$line
done
cd $CUR_DIR/tmp
DEP_LUA=$(find . -name '*.lua')

cp $CUR_DIR/bin/oclip.lua $CUR_DIR/tmp/oclip.lua
mkdir -p $CUR_DIR/tmp/lib
cp -rf $LUA_CLIB_DIR/* $CUR_DIR/tmp/lib/
cp $LUA_INSTALL_DIR/lib/liblua.a $CUR_DIR/tmp/
cd $CUR_DIR/tmp
DEP_SO=$(find ./lib -name '*.so')

CC="" $LUA_INSTALL_DIR/bin/lua $LUA_INSTALL_DIR/share/lua/5.3/luastatic.lua oclip.lua liblua.a $DEP_LUA $DEP_SO -I$LUA_INSTALL_DIR/include

INC=" \
-I$LUA_INSTALL_DIR/include \
-I$ROOT_DIR/3rd/luasocket \
-I$ROOT_DIR/3rd/lua-openssl \
-I$ROOT_DIR/3rd/lua-openssl/deps/lua-compat \
-I$ROOT_DIR/3rd/lua-openssl/deps/auxiliar"

LUASOCKET_SRC=" \
    $ROOT_DIR/3rd/luasocket/src/mime.c \
    $ROOT_DIR/3rd/luasocket/src/compat.c \
    $ROOT_DIR/3rd/luasocket/src/luasocket.c \
    $ROOT_DIR/3rd/luasocket/src/timeout.c \
    $ROOT_DIR/3rd/luasocket/src/buffer.c \
    $ROOT_DIR/3rd/luasocket/src/io.c \
    $ROOT_DIR/3rd/luasocket/src/auxiliar.c \
    $ROOT_DIR/3rd/luasocket/src/options.c \
    $ROOT_DIR/3rd/luasocket/src/inet.c \
    $ROOT_DIR/3rd/luasocket/src/except.c \
    $ROOT_DIR/3rd/luasocket/src/select.c \
    $ROOT_DIR/3rd/luasocket/src/tcp.c \
    $ROOT_DIR/3rd/luasocket/src/udp.c \
    $ROOT_DIR/3rd/luasocket/src/usocket.c \
    $ROOT_DIR/3rd/luasocket/src/unixstream.c \
    $ROOT_DIR/3rd/luasocket/src/unixdgram.c \
    $ROOT_DIR/3rd/luasocket/src/unix.c"

LUA_OPENSSL_SRC=" \
    $ROOT_DIR/3rd/lua-openssl/src/asn1.c \
    $ROOT_DIR/3rd/lua-openssl/src/bio.c \
    $ROOT_DIR/3rd/lua-openssl/src/cipher.c \
    $ROOT_DIR/3rd/lua-openssl/src/cms.c \
    $ROOT_DIR/3rd/lua-openssl/src/compat.c \
    $ROOT_DIR/3rd/lua-openssl/src/crl.c \
    $ROOT_DIR/3rd/lua-openssl/src/csr.c \
    $ROOT_DIR/3rd/lua-openssl/src/dh.c \
    $ROOT_DIR/3rd/lua-openssl/src/digest.c \
    $ROOT_DIR/3rd/lua-openssl/src/dsa.c \
    $ROOT_DIR/3rd/lua-openssl/src/ec.c \
    $ROOT_DIR/3rd/lua-openssl/src/engine.c \
    $ROOT_DIR/3rd/lua-openssl/src/hmac.c \
    $ROOT_DIR/3rd/lua-openssl/src/lbn.c \
    $ROOT_DIR/3rd/lua-openssl/src/lhash.c \
    $ROOT_DIR/3rd/lua-openssl/src/misc.c \
    $ROOT_DIR/3rd/lua-openssl/src/ocsp.c \
    $ROOT_DIR/3rd/lua-openssl/src/openssl.c \
    $ROOT_DIR/3rd/lua-openssl/src/ots.c \
    $ROOT_DIR/3rd/lua-openssl/src/pkcs12.c \
    $ROOT_DIR/3rd/lua-openssl/src/pkcs7.c \
    $ROOT_DIR/3rd/lua-openssl/src/pkey.c \
    $ROOT_DIR/3rd/lua-openssl/src/rsa.c \
    $ROOT_DIR/3rd/lua-openssl/src/ssl.c \
    $ROOT_DIR/3rd/lua-openssl/src/th-lock.c \
    $ROOT_DIR/3rd/lua-openssl/src/util.c \
    $ROOT_DIR/3rd/lua-openssl/src/x509.c \
    $ROOT_DIR/3rd/lua-openssl/src/xattrs.c \
    $ROOT_DIR/3rd/lua-openssl/src/xexts.c \
    $ROOT_DIR/3rd/lua-openssl/src/xname.c \
    $ROOT_DIR/3rd/lua-openssl/src/xstore.c \
    $ROOT_DIR/3rd/lua-openssl/src/xalgor.c \
    $ROOT_DIR/3rd/lua-openssl/src/callback.c \
    $ROOT_DIR/3rd/lua-openssl/src/srp.c \
    $ROOT_DIR/3rd/lua-openssl/deps/auxiliar/subsidiar.c"

#OPENSSL_LIBS="$(pkg-config openssl --static --libs)"
# use static
OPENSSL_LIBS="-l:libssl.a -lgssapi_krb5 -lkrb5 -lcom_err -lk5crypto -l:libcrypto.a -ldl -lz"
DEF=" -DPTHREADS"
cc -Os oclip.lua.c liblua.a $DEF $LUASOCKET_SRC $LUA_OPENSSL_SRC $OPENSSL_LIBS -lm -o ../oclip $INC

cd $CUR_DIR
strip oclip

