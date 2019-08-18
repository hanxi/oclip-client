#define LUA_LIB

#include <lua.h>
#include <lauxlib.h>

#ifdef _WIN32
#include "clipboard_win.h"
#endif

#define CLIPBOARD_CB "_clip_board_cb"

static void on_clipboard_change(void *context, const char *text, int change_from_set)
{
    struct lua_State *L = (lua_State *)context;
    if (L)
    {
        if (lua_getfield(L, LUA_REGISTRYINDEX, CLIPBOARD_CB) != LUA_TFUNCTION)
        {
            return;
        }
        lua_pushstring(L, text);
        lua_pushboolean(L, change_from_set);
        lua_call(L, 2, 0);
    }
}

// clipboard.init(clipboard_change_cb)
static int linit(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TFUNCTION);
    lua_setfield(L, LUA_REGISTRYINDEX, CLIPBOARD_CB);
    clipboard_init(L, on_clipboard_change);
    return 0;
}

// clipboard.settext(text)
static int lsettext(lua_State *L)
{
    const char *text = luaL_checkstring(L, 1);
    clipboard_settext(text);
    return 0;
}

// clipboard.loop()
static int lloop(lua_State *L)
{
    int ret = clipboard_loop();
    lua_pushnumber(L, ret);
    return 1;
}

// clipboard.exit()
static int lexit(lua_State *L)
{
    clipboard_exit();
    return 0;
}

LUAMOD_API int luaopen_clipboard(lua_State *L)
{
    luaL_checkversion(L);
    luaL_Reg l[] = {
        {"init", linit},
        {"settext", lsettext},
        {"loop", lloop},
        {"exit", lexit},
        {NULL, NULL},
    };

    luaL_newlib(L, l);
    return 1;
}
