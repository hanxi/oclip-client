local icon_bytes = require "oclip.icon_bytes"

local _M = {}

local icon_file

function _M.get()
    if icon_file then
        return icon_file
    end
    icon_file = os.tmpname()
    print('icon_file: ', icon_file)
    local f = io.open(icon_file, 'wb')
    if f then
        f:write(icon_bytes)
        f:close()
    end
    return icon_file
end

function _M.exit()
    if icon_file then
        os.remove(icon_file)
    end
end

return _M
