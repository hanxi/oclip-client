local copas = require 'copas'
local ws = require('websocket')
local ws_client = ws.client.copas({timeout = 5})
local rpc = require 'oclip.rpc'
local clipboard = require 'clipboard'
local tray = require 'tray'

local tray_conf

local handler

local function traceback(msg)
  print(debug.traceback(msg))
end

local function cb_auto_startup(menuitem)
  menuitem.checked = not menuitem.checked
  print('TODO: set or unset autostartup file.')
  tray.update(tray_conf)
end

local function cb_open_config(menuitem)
  print('TODO: open config file')
end

local function cb_exit()
  tray.exit()
end

tray_conf = {
  icon = '',
  menu = {
    {
      text = 'Auto Startup',
      cb = cb_auto_startup
    },
    {
      text = 'Open Config',
      cb = cb_open_config
    },
    {
      text = 'Quit',
      cb = cb_exit
    }
  }
}
tray.init(tray_conf)

local function on_cliboard_change(text, from)
  print('on_cliboard_change', text, from)
  if not from and handler then
    -- encrypto text and copy to remote server
    --handler:send_copy(text)

    copas.addthread(
      function()
        xpcall(handler.send_copy, traceback, handler, text)
      end
    )
  end
end
clipboard.init(on_cliboard_change)

local function connect()
  local params = {
    mode = 'client',
    protocol = 'TLS',
    cafile = './cacert.pem', --<-- added cafile parameters
    verify = 'peer', --<-- changed "none" to "peer"
    options = 'all'
  }
  local ok, err = ws_client:connect('wss://oclip.hanxi.info/server', '', params)
  if not ok then
    print('could not connect', err)
  end

  handler = rpc:new_handler(ws_client)
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

copas.addthread(
  function()
    connect()

    local i = 0
    while true do
      if ws_client.state == 'OPEN' then
        local data, opcode = ws_client:receive()
        if data then
          if opcode == ws.BINARY then
            xpcall(handler.process, traceback, handler, data)
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

while true do
  copas.step(0)

  if tray.loop() == -1 then
    break
  end
end
