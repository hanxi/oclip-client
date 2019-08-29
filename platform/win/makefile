OBJ_DIR=objs

INC=/I $(LUA_INSTALL_PATH)\include
LUA_LIB_PATH=$(LUA_INSTALL_PATH)\lib
LUA_LIB=lua.lib

DEF= /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_USRDLL" \
     /D "_CRT_SECURE_NO_WARNINGS" \
     /D "_WINDLL" \
     /D "LUASOCKET_NODEBUG" \
     /D LUA_LIB \
     /D UNICODE /D _UNICODE

OPENSSL_LIB_PATH=$(OPENSSL_PATH)\lib
CFLAGS=$(LUA_INC) /c /O2 /Ot /MT /W3 /nologo $(DEF)
LDFLAGS= /NOLOGO \
    /SUBSYSTEM:windows /ENTRY:mainCRTStartup \
    /LIBPATH:"$(LUA_LIB_PATH)" $(LUA_LIB) \
    /LIBPATH:"$(OPENSSL_LIB_PATH)" \
    user32.lib shell32.lib ws2_32.lib \
    kernel32.lib gdi32.lib \
    winspool.lib comdlg32.lib advapi32.lib crypt32.lib \
    libcrypto.lib libssl.lib \
    /OUT:

    
#/SUBSYSTEM:windows /ENTRY:mainCRTStartup

all: oclip.exe

# where /r lua\bin *.lua
DEP_LUA= \
copas.lua \
crypto.lua \
ltn12.lua \
luastatic.lua \
MessagePack.lua \
mime.lua \
socket.lua \
ssl.lua \
websocket.lua \
copas\ftp.lua \
copas\http.lua \
copas\limit.lua \
copas\smtp.lua \
oclip\cacert.lua \
oclip\cafile.lua \
oclip\config.lua \
oclip\main.lua \
oclip\rpc.lua \
oclip\tools.lua \
oclip\icon.lua \
oclip\icon_bytes.lua \
socket\ftp.lua \
socket\headers.lua \
socket\http.lua \
socket\smtp.lua \
socket\tp.lua \
socket\url.lua \
websocket\async.lua \
websocket\bit.lua \
websocket\client.lua \
websocket\client_copas.lua \
websocket\client_ev.lua \
websocket\client_sync.lua \
websocket\ev_common.lua \
websocket\frame.lua \
websocket\handshake.lua \
websocket\server.lua \
websocket\server_copas.lua \
websocket\server_ev.lua \
websocket\sync.lua \
websocket\tools.lua

# where /r lua\bin *.dll
DEP_DLL= \
clipboard.dll \
mime\core.dll \
openssl.dll \
socket\core.dll \
tray.dll

tmp/oclip.lua.c:
    @if not exist tmp mkdir tmp
    @copy bin\oclip.lua tmp\oclip.lua
    @for %I in ( $(DEP_LUA) ) do (echo F | xcopy /Y $(LUA_INSTALL_PATH)\bin\%I tmp\%I)
    @for %I in ( $(DEP_DLL) ) do (echo F | xcopy /Y $(LUA_INSTALL_PATH)\bin\%I tmp\%I)
    set OLD_NM=$(NM)
    set OLD_CC=$(CC)
    cd tmp & set NM="dumpbin /EXPORTS" & set CC="" & $(LUA_INSTALL_PATH)\bin\lua.exe $(LUA_INSTALL_PATH)\bin\luastatic.lua oclip.lua $(DEP_LUA) $(DEP_DLL) & exit 0
    set NM=$(OLD_NM)
    set CC=$(OLD_CC)

#compile
$(OBJ_DIR)\oclip.lua.obj: tmp\oclip.lua.c
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) $(INC) /Fo$@ $?

{$(CLIPBOARD_DIR)}.c{$(OBJ_DIR)}.obj:
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) $(INC) /Fo$@ $<

{$(TRAY_DIR)}.c{$(OBJ_DIR)}.obj:
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) $(INC) /Fo$@ $<

LUA_INC=/I $(LUA_SRC_DIR)
{$(LUA_SRC_DIR)}.c{$(OBJ_DIR)}.obj:
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) /D LUA_COMPAT_5_2 $(LUA_INC) /Fo$@ $<

{$(LUASOCKET_SRC_DIR)}.c{$(OBJ_DIR)}.obj:
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) /I $(LUASOCKET_SRC_DIR) /Fo$@ $<

LUAOPENSSL_INC = /I $(LUA_OPENSSL_DIR) \
/I $(OPENSSL_PATH)\include \
/I "$(LUA_OPENSSL_DIR)\deps\lua-compat" \
/I "$(LUA_OPENSSL_DIR)\deps\auxiliar"

{$(LUA_OPENSSL_DIR)\src\}.c{$(OBJ_DIR)}.obj:
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) $(LUAOPENSSL_INC) /Fo$@ $<

{$(LUA_OPENSSL_DIR)\deps\auxiliar\}.c{$(OBJ_DIR)}.obj:
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) $(LUAOPENSSL_INC) /Fo$@ $<

OBJS = \
$(OBJ_DIR)\oclip.lua.obj \
$(OBJ_DIR)\lclipboard.obj \
$(OBJ_DIR)\ltray.obj \
$(OBJ_DIR)\lapi.obj \
$(OBJ_DIR)\lauxlib.obj \
$(OBJ_DIR)\lbaselib.obj \
$(OBJ_DIR)\lbitlib.obj \
$(OBJ_DIR)\lcode.obj \
$(OBJ_DIR)\lcorolib.obj \
$(OBJ_DIR)\lctype.obj \
$(OBJ_DIR)\ldblib.obj \
$(OBJ_DIR)\ldebug.obj \
$(OBJ_DIR)\ldo.obj \
$(OBJ_DIR)\ldump.obj \
$(OBJ_DIR)\lfunc.obj \
$(OBJ_DIR)\lgc.obj \
$(OBJ_DIR)\linit.obj \
$(OBJ_DIR)\liolib.obj \
$(OBJ_DIR)\llex.obj \
$(OBJ_DIR)\lmathlib.obj \
$(OBJ_DIR)\lmem.obj \
$(OBJ_DIR)\loadlib.obj \
$(OBJ_DIR)\lobject.obj \
$(OBJ_DIR)\lopcodes.obj \
$(OBJ_DIR)\loslib.obj \
$(OBJ_DIR)\lparser.obj \
$(OBJ_DIR)\lstate.obj \
$(OBJ_DIR)\lstring.obj \
$(OBJ_DIR)\lstrlib.obj \
$(OBJ_DIR)\ltable.obj \
$(OBJ_DIR)\ltablib.obj \
$(OBJ_DIR)\ltm.obj \
$(OBJ_DIR)\lundump.obj \
$(OBJ_DIR)\lutf8lib.obj \
$(OBJ_DIR)\lvm.obj \
$(OBJ_DIR)\lzio.obj \
$(OBJ_DIR)\auxiliar.obj \
$(OBJ_DIR)\buffer.obj \
$(OBJ_DIR)\compat.obj \
$(OBJ_DIR)\except.obj \
$(OBJ_DIR)\inet.obj \
$(OBJ_DIR)\io.obj \
$(OBJ_DIR)\luasocket.obj \
$(OBJ_DIR)\options.obj \
$(OBJ_DIR)\select.obj \
$(OBJ_DIR)\tcp.obj \
$(OBJ_DIR)\timeout.obj \
$(OBJ_DIR)\udp.obj \
$(OBJ_DIR)\wsocket.obj \
$(OBJ_DIR)\mime.obj \
$(OBJ_DIR)\auxiliar.obj \
$(OBJ_DIR)\asn1.obj \
$(OBJ_DIR)\bio.obj \
$(OBJ_DIR)\cipher.obj \
$(OBJ_DIR)\cms.obj \
$(OBJ_DIR)\compat.obj \
$(OBJ_DIR)\crl.obj \
$(OBJ_DIR)\csr.obj \
$(OBJ_DIR)\dh.obj \
$(OBJ_DIR)\digest.obj \
$(OBJ_DIR)\dsa.obj \
$(OBJ_DIR)\ec.obj \
$(OBJ_DIR)\engine.obj \
$(OBJ_DIR)\hmac.obj \
$(OBJ_DIR)\lbn.obj \
$(OBJ_DIR)\lhash.obj \
$(OBJ_DIR)\misc.obj \
$(OBJ_DIR)\ocsp.obj \
$(OBJ_DIR)\openssl.obj \
$(OBJ_DIR)\ots.obj \
$(OBJ_DIR)\pkcs12.obj \
$(OBJ_DIR)\pkcs7.obj \
$(OBJ_DIR)\pkey.obj \
$(OBJ_DIR)\rsa.obj \
$(OBJ_DIR)\ssl.obj \
$(OBJ_DIR)\th-lock.obj \
$(OBJ_DIR)\util.obj \
$(OBJ_DIR)\x509.obj \
$(OBJ_DIR)\xattrs.obj \
$(OBJ_DIR)\xexts.obj \
$(OBJ_DIR)\xname.obj \
$(OBJ_DIR)\xstore.obj \
$(OBJ_DIR)\xalgor.obj \
$(OBJ_DIR)\callback.obj \
$(OBJ_DIR)\srp.obj \
$(OBJ_DIR)\subsidiar.obj

# link
oclip.exe: $(OBJS) $(EX_DLLS)
    LINK $? $(LDFLAGS)$@

clean:
    rd /S /Q $(OBJ_DIR)
    del *.exe
    del *.exp
    del *.lib
    rd /S /Q tmp