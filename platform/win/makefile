MAIN_DIR=$(MAIN_DIR)
OBJ_DIR=objs


INC=/I $(MAIN_DIR) /I $(LUA_INSTALL_PATH)\include
LUA_LIB_PATH=$(LUA_INSTALL_PATH)\lib
LUA_LIB=lua.lib

DEF= /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_USRDLL" \
     /D "_CRT_SECURE_NO_WARNINGS" \
     /D "_WINDLL" \
     /D LUA_LIB

CFLAGS=$(LUA_INC) /c /O2 /Ot /MT /W3 /nologo $(DEF)
LDFLAGS= /NOLOGO  /MT /SUBSYSTEM:windows /ENTRY:mainCRTStartup \
    /LIBPATH:"$(LUA_LIB_PATH)" $(LUA_LIB) \
    /OUT:

all: oclip.exe

#compile
$(OBJ_DIR)\main.lua.obj: $(MAIN_DIR)\oclip\main.lua.c
    @if not exist $(OBJ_DIR) mkdir $(OBJ_DIR)
    $(CC) $(CFLAGS) $(INC) /Fo$@ $?

EX_DLLS = $(LUA_INSTALL_PATH)\lib\clipboard.lib \
$(LUA_INSTALL_PATH)\lib\mime.lib \
$(LUA_INSTALL_PATH)\lib\openssl.lib \
$(LUA_INSTALL_PATH)\lib\socket.lib \
$(LUA_INSTALL_PATH)\lib\tray.lib

# link
oclip.exe: $(OBJ_DIR)\main.lua.obj $(EX_DLLS)
    LINK $? $(LDFLAGS)$@

clean:
    rd /S /Q $(OBJ_DIR)
    del *.exe
    del *.exp
    del *.lib