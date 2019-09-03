local cfg = require "oclip.config"
local is_windows = cfg.get('is_windows')

if is_windows then
    return require "clipboard"
else
    return require "oclip.clipboard_linux"
end

