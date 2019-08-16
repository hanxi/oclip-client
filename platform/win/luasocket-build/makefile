SRC_DIR=$(LUASOCKET_SRC_DIR)
OBJ_DIR=objs

LUA_INSTALL_PATH=$(LUA_INSTALL_PATH)
LUA_INC=/I $(SRC_DIR) /I $(LUA_INSTALL_PATH)\include
LUA_LIB_PATH=$(LUA_INSTALL_PATH)\lib
LUA_LIB=lua.lib

SOCKET_OBJS=\
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
$(OBJ_DIR)\wsocket.obj

MIME_OBJS=\
$(OBJ_DIR)\mime.obj \
$(OBJ_DIR)\compat.obj


DEBUG=NODEBUG
DEF= /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_USRDLL" \
     /D "_CRT_SECURE_NO_WARNINGS" \
     /D "_WINDLL"  \
     /D "LUASOCKET_$(DEBUG)" \
     /D LUA_BUILD_AS_DLL
CFLAGS=$(LUA_INC) /O2 /Ot /MT /W3 /nologo $(DEF)
LDFLAGS= /NOLOGO /DLL /INCREMENTAL:NO \
    /MANIFEST /MANIFESTFILE:"intermediate.manifest" \
    /MANIFESTUAC:"level='asInvoker' uiAccess='false'" \
	/SUBSYSTEM:WINDOWS /OPT:REF /OPT:ICF /DYNAMICBASE:NO \
    /MACHINE:X86 /LIBPATH:"$(LUA_LIB_PATH)" $(LUA_LIB) ws2_32.lib /OUT:

all: socket.dll mime.dll install

#compile
{$(SRC_DIR)}.c{$(OBJ_DIR)}.obj:
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) /Fo$@ /c $<

# link
socket.dll: $(SOCKET_OBJS)
	LINK $(SOCKET_OBJS) $(LDFLAGS)$@

mime.dll: $(MIME_OBJS)
	LINK $(MIME_OBJS) $(LDFLAGS)$@


INSTALL_TOP_LDIR=$(LUA_INSTALL_PATH)\bin\lua
INSTALL_SOCKET_LDIR=$(INSTALL_TOP_LDIR)\socket
INSTALL_TOP_CDIR=$(LUA_INSTALL_PATH)\bin
INSTALL_SOCKET_CDIR=$(INSTALL_TOP_CDIR)\socket
INSTALL_MIME_CDIR=$(INSTALL_TOP_CDIR)\mime

#------
# Files to install
#
TO_SOCKET_LDIR= \
	$(SRC_DIR)\http.lua \
	$(SRC_DIR)\url.lua \
	$(SRC_DIR)\tp.lua \
	$(SRC_DIR)\ftp.lua \
	$(SRC_DIR)\headers.lua \
	$(SRC_DIR)\smtp.lua

TO_TOP_LDIR= \
	$(SRC_DIR)\ltn12.lua \
	$(SRC_DIR)\socket.lua \
	$(SRC_DIR)\mime.lua

install:
    @for %I in ( $(INSTALL_TOP_LDIR) $(INSTALL_TOP_CDIR) $(INSTALL_SOCKET_LDIR) $(INSTALL_SOCKET_CDIR) $(INSTALL_MIME_CDIR) ) do if not exist %I mkdir %I
    @for %I in ($(TO_TOP_LDIR)) do copy %I $(INSTALL_TOP_LDIR)
    @for %I in ($(TO_SOCKET_LDIR)) do copy %I $(INSTALL_SOCKET_LDIR)
    @copy socket.dll $(INSTALL_SOCKET_CDIR)\core.dll
    @copy mime.dll $(INSTALL_MIME_CDIR)\core.dll

clean:
    rd /S /Q $(OBJ_DIR)
    del *.dll
    del *.exp
    del *.lib