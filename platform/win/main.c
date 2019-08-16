#include <stdio.h>
#include <string.h>

#include "win.h"
#include "luavm.h"

static struct tray tray;

static void toggle_cb(struct tray_menu *item)
{
    printf("toggle cb\n");
    item->checked = !item->checked;
    tray_update(&tray);
}

static void hello_cb(struct tray_menu *item)
{
    (void)item;
    printf("hello cb\n");
    clipboard_settext("hello world.\n");
    tray_update(&tray);
}

static void quit_cb(struct tray_menu *item)
{
    (void)item;
    printf("quit cb\n");
    tray_exit();
}

static void submenu_cb(struct tray_menu *item)
{
    (void)item;
    printf("submenu: clicked on %s\n", item->text);
    tray_update(&tray);
}

// Test tray init
static struct tray tray = {
    .menu =
        (struct tray_menu[]){
            {.text = "Hello", .cb = hello_cb},
            {.text = "Checked", .checked = 1, .cb = toggle_cb},
            {.text = "Disabled", .disabled = 1},
            {.text = "-"},
            {.text = "SubMenu",
             .submenu =
                 (struct tray_menu[]){
                     {.text = "FIRST", .checked = 1, .cb = submenu_cb},
                     {.text = "SECOND",
                      .submenu =
                          (struct tray_menu[]){
                              {.text = "THIRD",
                               .submenu =
                                   (struct tray_menu[]){
                                       {.text = "7", .cb = submenu_cb},
                                       {.text = "-"},
                                       {.text = "8", .cb = submenu_cb},
                                       {.text = NULL}}},
                              {.text = "FOUR",
                               .submenu =
                                   (struct tray_menu[]){
                                       {.text = "5", .cb = submenu_cb},
                                       {.text = "6", .cb = submenu_cb},
                                       {.text = NULL}}},
                              {.text = NULL}}},
                     {.text = NULL}}},
            {.text = "-"},
            {.text = "Quit", .cb = quit_cb},
            {.text = NULL}},
};

static void on_clipboard_change(const char *text)
{
    struct lua_State *L = luavm_get_lstate();
    printf("clipboard changed. text: %s\n", text);
}

int main()
{
    if (luavm_init() != 0)
    {
        fprintf(stderr, "failed init luavm.\n");
        return 1;
    }

    if (tray_init(&tray) != 0)
    {
        fprintf(stderr, "failed to create tray\n");
        return 2;
    }

    clipboard_set_cb_textchange(on_clipboard_change);

    while (tray_loop(1) == 0)
    {
        printf("iteration\n");
    }

    luavm_close();
    return 0;
}
