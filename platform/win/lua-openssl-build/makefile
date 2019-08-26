SRC_DIR=$(LUA_OPENSSL_DIR)\src
OBJ_DIR=objs

LUA_INSTALL_PATH=$(LUA_INSTALL_PATH)
LUA_INC=/I $(SRC_DIR) /I $(LUA_INSTALL_PATH)\include /I $(OPENSSL_PATH)\include \
/I "$(LUA_OPENSSL_DIR)\deps\lua-compat" /I "$(LUA_OPENSSL_DIR)\deps\auxiliar"

OPENSSL_LIB_PATH=$(OPENSSL_PATH)\lib
LUA_LIB_PATH=$(LUA_INSTALL_PATH)\lib
LUA_LIB=lua.lib

OBJS=\
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

DEBUG=NODEBUG
DEF= /D "_WIN32" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_USRDLL" \
     /D "_CRT_SECURE_NO_WARNINGS" \
     /D "_WINDLL"  \
     /D "LUASOCKET_$(DEBUG)" \
     /D LUA_BUILD_AS_DLL /D LUA_LIB \
     /D WIN32_LEAN_AND_MEAN

CFLAGS=$(LUA_INC) /c /O2 /Ot /MT /W3 /nologo $(DEF)
LDFLAGS= /NOLOGO /DLL /INCREMENTAL:NO \
	/SUBSYSTEM:WINDOWS /OPT:REF /OPT:ICF /DYNAMICBASE:NO \
    /MACHINE:X86 /LIBPATH:"$(LUA_LIB_PATH)" $(LUA_LIB) \
    /LIBPATH:"$(OPENSSL_LIB_PATH)" \
    ws2_32.lib kernel32.lib user32.lib gdi32.lib \
    winspool.lib comdlg32.lib advapi32.lib crypt32.lib \
    libcrypto.lib libssl.lib /OUT:

all: openssl.dll install

#compile
{$(SRC_DIR)\}.c{$(OBJ_DIR)}.obj:
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) /Fo$@ $<

{$(LUA_OPENSSL_DIR)\deps\auxiliar\}.c{$(OBJ_DIR)}.obj:
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) /Fo$@ $<

# link
openssl.dll: $(OBJS)
	LINK $? $(LDFLAGS)$@


INSTALL_TOP_LDIR=$(LUA_INSTALL_PATH)\bin
INSTALL_TOP_CDIR=$(LUA_INSTALL_PATH)\bin


install:
    @for %I in ( $(INSTALL_TOP_LDIR) $(INSTALL_TOP_LDIR)\ssl $(INSTALL_TOP_CDIR) ) do if not exist %I mkdir %I
    @copy openssl.dll $(INSTALL_TOP_CDIR)\openssl.dll
    @copy $(LUA_OPENSSL_DIR)\lib\ssl.lua $(INSTALL_TOP_LDIR)\ssl.lua
    @copy $(LUA_OPENSSL_DIR)\lib\crypto.lua $(INSTALL_TOP_LDIR)\crypto.lua
    @copy openssl.lib $(LUA_INSTALL_PATH)\lib

clean:
    rd /S /Q $(OBJ_DIR)
    del *.dll
    del *.exp
    del *.lib