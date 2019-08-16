SRC_DIR=.
OBJ_DIR=objs

CFLAGS=/nologo /MT /O2 /c

INC=/I $(SRC_DIR) /I $(LUA_INSTALL_PATH)\include /I $(ROOT_SRC)
LUA_LIB_PATH=$(LUA_INSTALL_PATH)\lib
LUA_LIB=lua.lib


OBJS=\
$(OBJ_DIR)\luavm.obj

all: oclip.exe

#compile
{$(SRC_DIR)}.c{$(OBJ_DIR)}.obj:
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) $(INC) /Fo$@ $<

{$(ROOT_SRC)}.c{$(OBJ_DIR)}.obj:
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) $(INC) /Fo$@ $<

LDFLAGS= /NOLOGO user32.lib shell32.lib lua.lib \
/LIBPATH:"$(LUA_LIB_PATH)" $(LUA_LIB)
# /SUBSYSTEM:windows /ENTRY:mainCRTStartup \


# link
oclip.exe: $(OBJS) $(OBJ_DIR)\main.obj
    LINK $(LDFLAGS) /OUT:$@ $?

clean:
    rd /S /Q $(OBJ_DIR)
    del *.exe
    del *.exp
    del *.lib