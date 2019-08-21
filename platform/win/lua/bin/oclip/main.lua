local copas = require 'copas'
local ws = require('websocket')
local ws_client = ws.client.copas({timeout = 5})
local msgpack = require 'MessagePack'
local rpc = require 'oclip.rpc'

local token =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1Njc5NjM4NDYuMzQ3LCJuYW1lIjoiZ2l0aHViXzExODU3NTcifQ.rWe411UYB5VB9u-kDqkfUqqM7r8FH3WMjNPrdI0_tms'

local handler
local function connect()
  local params = {
    mode = 'client',
    protocol = 'any',
    cafile = './cacert.pem', --<-- added cafile parameters
    verify = 'peer', --<-- changed "none" to "peer"
    options = 'all'
  }
  local ok, err = ws_client:connect('wss://oclip.hanxi.info/server', '', params)
  if not ok then
    print('could not connect', err)
  end

  handler = rpc:new_handler(ws_client)
  handler:send('auth', {token})
end

copas.addthread(
  function()
    while true do
      copas.sleep(4)
      if ws_client.state == 'OPEN' then
        ws_client:send('ping', ws.TEXT)
      end
    end
  end
)

local function traceback(msg)
  print(debug.traceback(msg))
end


copas.addthread(
  function()
    connect()


    local i = 0
    while true do
      if ws_client.state == 'OPEN' then
        local data, opcode = ws_client:receive()
        if data then
          if opcode == ws.BINARY then
            print('recv binary')
            local proto = msgpack.unpack(data)
            xpcall(handler.process, traceback, handler, proto)
          elseif opcode == ws.TEXT then
            print('received.', data)
          end
        else
          print('connection closed. 5 seconds will retray')
          break
        end
      else
        print('not connect.')
        break
      end
    end
  end
)

copas.loop()
