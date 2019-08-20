SRC_DIR=$(LUASEC_SRC_DIR)
OBJ_DIR=objs

LUA_INSTALL_PATH=$(LUA_INSTALL_PATH)
LUA_INC=/I $(SRC_DIR) /I $(LUA_INSTALL_PATH)\include /I $(OPENSSL_PATH)\include
OPENSSL_LIB_PATH=$(OPENSSL_PATH)\lib
LUA_LIB_PATH=$(LUA_INSTALL_PATH)\lib
LUA_LIB=lua.lib

OBJS=\
$(OBJ_DIR)\x509.obj    \
$(OBJ_DIR)\context.obj \
$(OBJ_DIR)\ssl.obj     \
$(OBJ_DIR)\config.obj  \
$(OBJ_DIR)\ec.obj \
$(OBJ_DIR)\io.obj \
$(OBJ_DIR)\buffer.obj \
$(OBJ_DIR)\timeout.obj \
$(OBJ_DIR)\wsocket.obj

DEBUG=NODEBUG
DEF= /D "_WIN32" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_USRDLL" \
     /D "_CRT_SECURE_NO_WARNINGS" \
     /D "_WINDLL"  \
     /D "LUASOCKET_$(DEBUG)" \
     /D LUA_BUILD_AS_DLL /D LUASOCKET_DEBUG /D WITH_LUASOCKET \


CFLAGS=$(LUA_INC) /c /O2 /Ot /MT /W3 /nologo $(DEF)
LDFLAGS= /NOLOGO /DLL /INCREMENTAL:NO \
	/SUBSYSTEM:WINDOWS /OPT:REF /OPT:ICF /DYNAMICBASE:NO \
    /MACHINE:X86 /LIBPATH:"$(LUA_LIB_PATH)" $(LUA_LIB) \
    /LIBPATH:"$(OPENSSL_LIB_PATH)" libcrypto.lib libssl.lib \
    ws2_32.lib crypt32.lib advapi32.lib user32.lib /OUT:

all: ssl.dll install

#compile
{$(SRC_DIR)}.c{$(OBJ_DIR)}.obj:
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) /Fo$@ $<

{$(SRC_DIR)\luasocket\}.c{$(OBJ_DIR)}.obj:
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) /Fo$@ $<

# link
ssl.dll: $(OBJS)
	LINK $? $(LDFLAGS)$@


INSTALL_TOP_LDIR=$(LUA_INSTALL_PATH)\bin\lua
INSTALL_TOP_CDIR=$(LUA_INSTALL_PATH)\bin


install:
    @for %I in ( $(INSTALL_TOP_LDIR) $(INSTALL_TOP_LDIR)\ssl $(INSTALL_TOP_CDIR) $(INSTALL_TOP_CDIR)\ssl ) do if not exist %I mkdir %I
    @copy ssl.dll $(INSTALL_TOP_CDIR)\ssl.dll
    @copy $(SRC_DIR)\ssl.lua $(INSTALL_TOP_LDIR)\ssl.lua
    @copy $(SRC_DIR)\https.lua $(INSTALL_TOP_LDIR)\ssl\https.lua

clean:
    rd /S /Q $(OBJ_DIR)
    del *.dll
    del *.exp
    del *.lib