local _M = {}

local home = os.getenv('HOME')
local CLIP_FILE = home..'/.oclip.clip'

local function traceback(msg)
  print(debug.traceback(msg))
end

local on_cliboard_change
function _M.init(_on_cliboard_change)
    on_cliboard_change = _on_cliboard_change


    local copas = require 'copas'
    local socket = require 'socket'
    local cfg = require 'oclip.config'

    local function handler(c)
        c:close()
        local text = _M.gettext()
        on_cliboard_change(text, false)
    end
    copas.addserver(assert(socket.bind("127.0.0.1", cfg.get('port'))), function(c)
        return handler(copas.wrap(c))
    end)
end

function _M.settext(text)
    local f = io.open(CLIP_FILE, 'w+')
    f:write(text)
    f:close()

    if on_cliboard_change then
        on_cliboard_change(text, true)
    end
end

function _M.gettext()
    local f = io.open(CLIP_FILE, 'rb')
    if not f then
        return ''
    end

    local text = f:read('a')
    f:close()
    return text
end

return _M
