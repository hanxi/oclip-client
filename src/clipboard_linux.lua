local signal = require "signal"

local _M = {}

local clip_file = '/tmp/oclip'

local function traceback(msg)
  print(debug.traceback(msg))
end

local on_cliboard_change
function _M.init(_on_cliboard_change)
    on_cliboard_change = _on_cliboard_change

    -- kill -USR1 19443
    signal.signal("SIGUSR1", function() 
        local text = _M.gettext()
        on_cliboard_change(text, false)
    end)
    signal.signal("SIGUSR2", function() 
    end)
end

function _M.settext(text)
    local f = io.open(clip_file, "w+")
    f:write(text)
    f:close()

    if on_cliboard_change then
        on_cliboard_change(text, true)
    end
end

function _M.gettext()
    local f = io.open(clip_file, 'rb')
    if not f then
        return ''
    end

    local text = f:read("a")
    f:close()
    return text
end

return _M
