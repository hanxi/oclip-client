local copas = require 'copas'
local ws = require('websocket')
local ws_client = ws.client.copas({timeout = 5})

local function connect()
  local params = {
    mode = 'client',
    protocol = 'any',
    cafile = './cacert.pem', --<-- added cafile parameters
    verify = 'peer', --<-- changed "none" to "peer"
    options = 'all'
  }
  --local ok, err = ws_client:connect('ws://echo.websocket.org/?encoding=text', 'echo')
  local ok, err = ws_client:connect('wss://echo.websocket.org/?encoding=text', 'echo', params)
  if not ok then
    print('could not connect', err)
  end
end

copas.addthread(
  function()
    connect()

    local i = 0
    while true do
      if ws_client.state == 'OPEN' then
        copas.sleep(1)
        i = i + 1
        ws_client:send('hello ' .. i)
        copas.sleep(1)

        local message, opcode = ws_client:receive()
        if message then
          print('msg', message, opcode)
        else
          print('connection closed. 5 seconds will retray')
        end

        if i == 5 then
          ws_client:close()
          break
        end
      else
        print('not connect.')
      end
    end
  end
)

copas.loop()
