local tools = require 'oclip.tools'

local _M = {}

local cacert_content = require 'oclip.cacert'
local fname = 'cacert.pem'

function _M.get()
    if tools.file_exists(fname) then
      return fname
    end
    fname = os.tmpname()
    print('cafile: ', fname)
    local f = io.open(fname, 'w+')
    if f then
        f:write(cacert_content)
        f:close()
    end
    return fname
end

function _M.exit()
    if fname ~= 'cacert.pem' then
        os.remove(fname)
    end
end

return _M
