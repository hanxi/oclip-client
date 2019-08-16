#ifndef WIN_H
#define WIN_H

#include <stdio.h>
#include <windows.h>
#include <shellapi.h>
#include "icon.h"

struct tray_menu;

struct tray
{
    const char *icon;
    struct tray_menu *menu;
};

struct tray_menu
{
    char *text;
    int disabled;
    int checked;

    void (*cb)(struct tray_menu *);
    void *context;

    struct tray_menu *submenu;
};

#define WM_TRAY_CALLBACK_MESSAGE (WM_USER + 1)
#define WC_TRAY_CLASS_NAME "OCLIP"
#define ID_TRAY_FIRST 1000

static WNDCLASSEX wc;
static NOTIFYICONDATA nid;
static HWND hwnd;
static HMENU hmenu = NULL;
static HWND hwndnextviewer;
static UINT format_list[] = {
    CF_TEXT,
};
static void (*_clipboard_onchange_text)(const char *);

static void _clipboard_onchange(HWND hwnd)
{
    UINT format = GetPriorityClipboardFormat(format_list, 1);
    if (format == CF_TEXT)
    {
        if (OpenClipboard(hwnd))
        {
            HGLOBAL hglb = GetClipboardData(format);
            LPSTR lpstr = GlobalLock(hglb);
            if (_clipboard_onchange_text)
            {
                _clipboard_onchange_text(lpstr);
            }
            GlobalUnlock(hglb);
            CloseClipboard();
        }
    }
}

static void clipboard_set_cb_textchange(void (*p)(const char *))
{
    _clipboard_onchange_text = p;
}

static void clipboard_settext(const char *text)
{
    size_t len = strlen(text);
    HGLOBAL hmem = GlobalAlloc(GMEM_MOVEABLE | GMEM_DDESHARE, len);
    if (hmem != NULL)
    {
        if (OpenClipboard(hwnd))
        {
            PVOID pdata = GlobalLock(hmem);
            if (pdata != NULL)
            {
                CopyMemory(pdata, text, len);
            }
            GlobalUnlock(hmem);
            if (EmptyClipboard())
            {
                if (SetClipboardData(CF_TEXT, hmem))
                {
                }
                else
                {
                    GlobalFree(hmem);
                }
            }
            CloseClipboard();
        }
        else
        {
            GlobalFree(hmem);
        }
    }
}

static const char *_get_icon()
{
    static TCHAR icon_path[MAX_PATH];
    if (GetTempPath(MAX_PATH, icon_path) != 0)
    {
        strcat(icon_path, WC_TRAY_CLASS_NAME);
        FILE *fp = fopen(icon_path, "wb");
        if (fp)
        {
            fwrite(icon_bytes, sizeof((icon_bytes)[0]), sizeof(icon_bytes), fp);
            fclose(fp);
            return icon_path;
        }
    }
    return "";
}

static LRESULT CALLBACK _wnd_proc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam)
{
    switch (msg)
    {
    case WM_CREATE:
        hwndnextviewer = SetClipboardViewer(hwnd);
        return 0;
    case WM_CHANGECBCHAIN:
        // If the next window is closing, repair the chain.
        if ((HWND)wparam == hwndnextviewer)
        {
            hwndnextviewer = (HWND)lparam;
        }
        else if (hwndnextviewer != NULL)
        {
            // Otherwise, pass the message to the next link.
            SendMessage(hwndnextviewer, msg, wparam, lparam);
        }
        return 0;
    case WM_DRAWCLIPBOARD:
        SendMessage(hwndnextviewer, msg, wparam, lparam);
        _clipboard_onchange(hwnd);
        return 0;
    case WM_CLOSE:
        DestroyWindow(hwnd);
        return 0;
    case WM_DESTROY:
        ChangeClipboardChain(hwnd, hwndnextviewer);
        PostQuitMessage(0);
        return 0;
    case WM_TRAY_CALLBACK_MESSAGE:
        if (lparam == WM_LBUTTONUP || lparam == WM_RBUTTONUP)
        {
            POINT p;
            GetCursorPos(&p);
            SetForegroundWindow(hwnd);
            WORD cmd = TrackPopupMenu(hmenu,
                                      TPM_LEFTALIGN | TPM_RIGHTBUTTON | TPM_RETURNCMD | TPM_NONOTIFY,
                                      p.x, p.y, 0, hwnd, NULL);
            SendMessage(hwnd, WM_COMMAND, cmd, 0);
            return 0;
        }
        break;
    case WM_COMMAND:
        if (wparam >= ID_TRAY_FIRST)
        {
            MENUITEMINFO item = {
                .cbSize = sizeof(MENUITEMINFO),
                .fMask = MIIM_ID | MIIM_DATA,
            };
            if (GetMenuItemInfo(hmenu, wparam, FALSE, &item))
            {
                struct tray_menu *menu = (struct tray_menu *)item.dwItemData;
                if (menu != NULL && menu->cb != NULL)
                {
                    menu->cb(menu);
                }
            }
            return 0;
        }
        break;
    }
    return DefWindowProc(hwnd, msg, wparam, lparam);
}

static HMENU _tray_menu(struct tray_menu *m, UINT *id)
{
    HMENU hmenu = CreatePopupMenu();
    for (; m != NULL && m->text != NULL; m++, (*id)++)
    {
        if (strcmp(m->text, "-") == 0)
        {
            InsertMenu(hmenu, *id, MF_SEPARATOR, TRUE, "");
        }
        else
        {
            MENUITEMINFO item;
            memset(&item, 0, sizeof(item));
            item.cbSize = sizeof(MENUITEMINFO);
            item.fMask = MIIM_ID | MIIM_TYPE | MIIM_STATE | MIIM_DATA;
            item.fType = 0;
            item.fState = 0;
            if (m->submenu != NULL)
            {
                item.fMask = item.fMask | MIIM_SUBMENU;
                item.hSubMenu = _tray_menu(m->submenu, id);
            }
            if (m->disabled)
            {
                item.fState |= MFS_DISABLED;
            }
            if (m->checked)
            {
                item.fState |= MFS_CHECKED;
            }
            item.wID = *id;
            item.dwTypeData = m->text;
            item.dwItemData = (ULONG_PTR)m;

            InsertMenuItem(hmenu, *id, TRUE, &item);
        }
    }
    return hmenu;
}

static void tray_update(struct tray *tray)
{
    HMENU prevmenu = hmenu;
    UINT id = ID_TRAY_FIRST;
    hmenu = _tray_menu(tray->menu, &id);
    SendMessage(hwnd, WM_INITMENUPOPUP, (WPARAM)hmenu, 0);
    HICON icon;
    if (tray->icon == NULL)
    {
        tray->icon = _get_icon();
    }
    ExtractIconEx(tray->icon, 0, NULL, &icon, 1);
    if (nid.hIcon)
    {
        DestroyIcon(nid.hIcon);
    }
    nid.hIcon = icon;
    Shell_NotifyIcon(NIM_MODIFY, &nid);

    if (prevmenu != NULL)
    {
        DestroyMenu(prevmenu);
    }
}

static int tray_init(struct tray *tray)
{
    memset(&wc, 0, sizeof(wc));
    wc.cbSize = sizeof(WNDCLASSEX);
    wc.lpfnWndProc = _wnd_proc;
    wc.hInstance = GetModuleHandle(NULL);
    wc.lpszClassName = WC_TRAY_CLASS_NAME;
    if (!RegisterClassEx(&wc))
    {
        return -1;
    }

    hwnd = CreateWindowEx(0, WC_TRAY_CLASS_NAME, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    if (hwnd == NULL)
    {
        return -1;
    }
    UpdateWindow(hwnd);

    memset(&nid, 0, sizeof(nid));
    nid.cbSize = sizeof(NOTIFYICONDATA);
    nid.hWnd = hwnd;
    nid.uID = 0;
    nid.uFlags = NIF_ICON | NIF_MESSAGE;
    nid.uCallbackMessage = WM_TRAY_CALLBACK_MESSAGE;
    Shell_NotifyIcon(NIM_ADD, &nid);

    tray_update(tray);
    return 0;
}

static int tray_loop(int blocking)
{
    MSG msg;
    if (blocking)
    {
        GetMessage(&msg, NULL, 0, 0);
    }
    else
    {
        PeekMessage(&msg, NULL, 0, 0, PM_REMOVE);
    }
    if (msg.message == WM_QUIT)
    {
        return -1;
    }
    TranslateMessage(&msg);
    DispatchMessage(&msg);
    return 0;
}

static void tray_exit()
{
    Shell_NotifyIcon(NIM_DELETE, &nid);
    if (nid.hIcon != 0)
    {
        DestroyIcon(nid.hIcon);
    }
    if (hmenu != 0)
    {
        DestroyMenu(hmenu);
    }
    PostQuitMessage(0);
    UnregisterClass(WC_TRAY_CLASS_NAME, GetModuleHandle(NULL));
}

#endif
