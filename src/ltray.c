#define LUA_LIB

#include <lua.h>
#include <lauxlib.h>

#ifdef _WIN32
#include "tray_win.h"
#endif

#define TRAY_MENU "_tray_menu"
#define ID_FIRST 1000

static struct tray tray;

static void menu_item_cb(struct tray_menu *item)
{
    lua_State *L = (lua_State *)item->context;
    int id = item->id;
    if (lua_getfield(L, LUA_REGISTRYINDEX, TRAY_MENU) != LUA_TTABLE)
    {
        return;
    }

    if (lua_rawgeti(L, -1, id) != LUA_TTABLE)
    {
        return;
    }
    lua_pushboolean(L, item->checked);
    lua_setfield(L, -2, "checked");
    if (lua_getfield(L, -1, "cb") != LUA_TFUNCTION)
    {
        return;
    }
    lua_insert(L, -2);
    lua_call(L, 1, 0);
}

static struct tray_menu *new_menu(lua_State *L, int *id)
{
    int n = lua_rawlen(L, -1);
    if (n <= 0)
    {
        return NULL;
    }
    if (lua_getfield(L, LUA_REGISTRYINDEX, TRAY_MENU) != LUA_TTABLE)
    {
        lua_pop(L, 1);
        lua_newtable(L);
        lua_setfield(L, LUA_REGISTRYINDEX, TRAY_MENU);
        lua_getfield(L, LUA_REGISTRYINDEX, TRAY_MENU);
    }

    struct tray_menu *menu = malloc((n + 1) * sizeof(struct tray_menu));
    for (int i = 0; i < n; i++)
    {
        struct tray_menu *item = &menu[i];
        item->id = (*id)++;
        item->cb = menu_item_cb;
        item->context = L;

        lua_rawgeti(L, -2, i + 1);
        lua_pushnumber(L, item->id);
        lua_setfield(L, -2, "id");

        item->text = NULL;
        if (lua_getfield(L, -1, "text") == LUA_TSTRING)
        {
            int tlen = 0;
            const char *pstr = lua_tolstring(L, -1, &tlen);
            if (tlen > 0)
            {
                item->text = (char *)malloc(tlen + 1);
                strcpy(item->text, pstr);
            }
        }
        lua_pop(L, 1);

        item->checked = 0;
        if (lua_getfield(L, -1, "checked")== LUA_TBOOLEAN) {
            item->checked = lua_toboolean(L, -1);
        }
        lua_pop(L, 1);

        item->disabled = 0;
        if (lua_getfield(L, -1, "disabled")== LUA_TBOOLEAN) {
            item->disabled = lua_toboolean(L, -1);
        }
        lua_pop(L, 1);

        item->submenu = NULL;
        if (lua_getfield(L, -1, "submenu") == LUA_TTABLE)
        {
            item->submenu = new_menu(L, id);
        }
        lua_pop(L, 1);

        lua_rawseti(L, -2, item->id);
    }
    lua_pop(L, 1);

    struct tray_menu *item_tail = &menu[n];
    item_tail->text = NULL;
    return menu;
}

static void delete_menu(struct tray_menu *menu)
{
    for (struct tray_menu *item = menu; item != NULL && item->text != NULL; item++)
    {
        if (item->submenu)
        {
            delete_menu(item->submenu);
        }
        free(item->text);
    }
    free(menu);
}

static void update_tray_conf(lua_State *L)
{
    if (tray.menu)
    {
        delete_menu(tray.menu);
        tray.menu = NULL;
    }
    if (lua_getfield(L, -1, "icon") == LUA_TSTRING)
    {
        const char *icon = lua_tostring(L, -1);
        strcpy(tray.icon, icon);
    }
    lua_pop(L, 1);

    if (lua_getfield(L, -1, "menu") == LUA_TTABLE)
    {
        int id = ID_FIRST;
        tray.menu = new_menu(L, &id);
    }
    lua_pop(L, 1);
}

// tray.init(tray_conf)
static int linit(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TTABLE);
    update_tray_conf(L);
    if (tray_init(&tray) != 0)
    {
        luaL_error(L, "Failed to create tray");
        return 0;
    }
    lua_pushboolean(L, 1);
    return 1;
}

// tray.update(tray_conf)
static int lupdate(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TTABLE);
    update_tray_conf(L);
    tray_update(&tray);
    return 0;
}

// tray.loop()
static int lloop(lua_State *L)
{
    int ret = tray_loop();
    lua_pushnumber(L, ret);
    return 1;
}

// tray.exit()
static int lexit(lua_State *L)
{
    tray_exit();
    return 0;
}

LUAMOD_API int luaopen_tray(lua_State *L)
{
    luaL_checkversion(L);
    luaL_Reg l[] = {
        {"init", linit},
        {"update", lupdate},
        {"loop", lloop},
        {"exit", lexit},
        {NULL, NULL},
    };

    luaL_newlib(L, l);
    return 1;
}
