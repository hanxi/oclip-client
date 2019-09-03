local cfg = require "oclip.config"
local is_windows = cfg.get('is_windows')

if is_windows then
    return require "tray"
else
    return require "oclip.tray_linux"
end
