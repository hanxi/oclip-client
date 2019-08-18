#ifndef CLIPBOARD_WIN_H
#define CLIPBOARD_WIN_H

#include <stdio.h>
#include <windows.h>

#define WC_CLIPBOARD_CLASS_NAME "CLIPBOARD"
#define WM_TRAY_CALLBACK_MESSAGE (WM_USER + 1)
#define ID_TRAY_FIRST 1000

static WNDCLASSEX wc;
static HWND hwnd;
static HWND hwndnextviewer;
static UINT format_list[] = {
    CF_TEXT,
};
static void* _context = NULL;
static void (*_clipboard_onchange_text)(void *, const char *, int);
static int change_from_set = 0;

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
                _clipboard_onchange_text(_context, lpstr, change_from_set);
            }
            change_from_set = 0;
            GlobalUnlock(hglb);
            CloseClipboard();
        }
    }
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
                change_from_set = 1;
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
    }
    return DefWindowProc(hwnd, msg, wparam, lparam);
}

static int clipboard_init(void* context, void (*p)(void *, const char *, int))
{
    memset(&wc, 0, sizeof(wc));
    wc.cbSize = sizeof(WNDCLASSEX);
    wc.lpfnWndProc = _wnd_proc;
    wc.hInstance = GetModuleHandle(NULL);
    wc.lpszClassName = WC_CLIPBOARD_CLASS_NAME;
    if (!RegisterClassEx(&wc))
    {
        return -1;
    }

    hwnd = CreateWindowEx(0, WC_CLIPBOARD_CLASS_NAME, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    if (hwnd == NULL)
    {
        return -1;
    }

    _context = context;
    _clipboard_onchange_text = p;

    UpdateWindow(hwnd);
    return 0;
}

static int clipboard_loop()
{
    MSG msg;
    PeekMessage(&msg, NULL, 0, 0, PM_REMOVE);
    if (msg.message == WM_QUIT)
    {
        return -1;
    }
    TranslateMessage(&msg);
    DispatchMessage(&msg);
    return 0;
}

static void clipboard_exit()
{
    PostQuitMessage(0);
    UnregisterClass(WC_CLIPBOARD_CLASS_NAME, GetModuleHandle(NULL));
}

#endif
