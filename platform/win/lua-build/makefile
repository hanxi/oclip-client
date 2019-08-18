SRC_DIR=$(LUA_SRC_DIR)
OBJ_DIR=objs
CFLAGS=/nologo /MT /O2 /c

LUA_INC=/I $(SRC_DIR)

OBJS=\
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
$(OBJ_DIR)\lzio.obj

INSTALL_TOP= $(LUA_INSTALL_PATH)
INSTALL_BIN= $(INSTALL_TOP)\bin
INSTALL_INC= $(INSTALL_TOP)\include
INSTALL_LIB= $(INSTALL_TOP)\lib

TO_BIN= lua.exe luac.exe
TO_INC= lua.h luaconf.h lualib.h lauxlib.h lua.hpp
TO_LIB= lua.lib

all: lua.exe luac.exe lua.lib install

#compile
{$(SRC_DIR)}.c{$(OBJ_DIR)}.obj:
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) /D LUA_BUILD_AS_DLL $(LUA_INC) /Fo$@ $<

$(OBJ_DIR)\lua.obj: $(SRC_DIR)\lua.c
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) $(LUA_INC) /Fo$@ $?

# link
lua.exe: $(OBJS) $(OBJ_DIR)\lua.obj
    LINK /nologo /OUT:$@ $?

luac.exe: $(OBJS) $(OBJ_DIR)\luac.obj
    LINK /nologo /OUT:$@ $?

lua.lib: $(OBJS)
    LIB /nologo /OUT:$@ $?

install:
    @for %I in ( $(INSTALL_BIN) $(INSTALL_INC) $(INSTALL_LIB) ) do if not exist %I mkdir %I
    @for %I in ($(TO_BIN)) do copy %I $(INSTALL_BIN)
    @for %I in ($(TO_INC)) do copy $(SRC_DIR)\%I $(INSTALL_INC)
    @for %I in ($(TO_LIB)) do copy %I $(INSTALL_LIB)


clean:
    rd /S /Q $(OBJ_DIR)
    del *.exe
    del *.exp
    del *.lib