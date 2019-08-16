#include "luacode.h"

#include <stdio.h>

static struct lua_State *L = NULL;

void luavm_close()
{
    lua_close(L);
    L = NULL;
}

struct lua_State *luavm_get_lstate()
{
    return L;
}

int luavm_init()
{
    if (L)
    {
        fprintf(stderr, "luavm already init.");
        return 1;
    }

    L = luaL_newstate();
    luaL_openlibs(L); // link lua lib

    int err = luaL_loadbuffer(L, lua_code_str, strlen(lua_code_str), "=[luacode main]");
    assert(err == LUA_OK);

    err = lua_pcall(L, 1, 0, 0);
    if (err)
    {
        fprintf(stderr, "%s\n", lua_tostring(L, -1));
        luavm_close();
        return 1;
    }
    return 0;
}

void luavm_loop_step()
{
}
