CUR_DIR=$(cd "$(dirname "$0")";pwd)
ROOT_DIR=$(cd "$(dirname "$0")"/../..; pwd)

export LUA_PATH='../share/lua/5.3/?.lua;;'
export LUA_CPATH='../lib/lua/5.3/?.so;;'

## copy oclip src
RUN_DIR=$CUR_DIR/lua/bin
cd $ROOT_DIR/src
mkdir -p $RUN_DIR/oclip
#$CUR_DIR/lua/bin/lua genicon.lua icon.ico icon_bytes.lua
cp *.lua $RUN_DIR/oclip/
cp cacert.pem $RUN_DIR/cacert.pem

cd $RUN_DIR
lua oclip/main.lua $@

