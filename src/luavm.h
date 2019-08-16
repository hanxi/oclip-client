#ifndef LUAVM_H
#define LUAVM_H

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

int luavm_init();
struct lua_State * luavm_get_lstate();
void luavm_close();

#endif