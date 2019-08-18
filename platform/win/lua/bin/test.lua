local tray = require "tray"
local clipboard = require "clipboard"

local tray_conf

local function menu1cb(menuitem)
    menuitem.checked = not menuitem.checked
    tray.update(tray_conf)
end

local function exitcb()
    tray.exit()
end

tray_conf = {
    icon = "",
    menu = {
        {
            text = "menu1",
            cb = menu1cb,    
        },
        {
            text = "quit",
            cb = exitcb,    
        },
    }
}
tray.init(tray_conf)

local function on_cliboard_change(text, from)
    print(text, from)
end

clipboard.init(on_cliboard_change)

while true do
    if tray.loop() == -1 then
        break
    end
end
