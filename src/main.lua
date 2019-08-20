local copas = require'copas'
local ws = require('websocket')
local ws_client = ws.client.copas()


local function connect()
  print("try to connect")
  local params = {
    mode = "client",
    protocol = "tlsv1",
    cafile = "./oclip/cacert.pem", --<-- added cafile parameters
    verify = "none", --<-- changed "none" to "peer"
    options = "all",
  }
  local ok, err = ws_client:connect('wss://echo.websocket.org/?encoding=text', 'echo', params)
  if not ok then
    print('could not connect',err)
  end
end

copas.addthread(function()
  connect()
  while true do
    
    local message,opcode = ws_client:receive()
    if message then
      print('msg',message,opcode)
    else
      print('connection closed. 5 seconds will retray')
      copas.sleep(5)
      connect()
    end
  end
end)

copas.addthread(function()
  local i = 0
  while true do
    copas.sleep(1)
    i = i + 1
    ws_client:send('hello '..i)
  end

end)


while true do
  copas.step()
  -- processing for other events from your system here
end
