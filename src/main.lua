local copas = require 'copas'
local ws = require('websocket')
local ws_client = ws.client.copas({timeout = 5})
local rpc = require 'oclip.rpc'
local clipboard = require 'clipboard'
local tray = require 'tray'
local cfg = require 'oclip.config'
local cafile = require 'oclip.cafile'
local icon = require 'oclip.icon'
local tools = require 'oclip.tools'

local tray_conf

local handler

local function traceback(msg)
  print(debug.traceback(msg))
end

local function cb_auto_startup(menuitem)
  menuitem.checked = not menuitem.checked
  print('set or unset autostartup file.')

  if menuitem.checked then
    tools.set_auto_startup()
  else
    tools.unset_auto_startup()
  end
  tray.update(tray_conf)
end

local function cb_open_config()
  print('open config file')
  tools.open_config()
end

local function cb_restart()
  print('TODO: restart self')
  --tools.restart()
end

local function cb_exit()
  tray.exit()
end

local function tray_init()
  tray_conf = {
    icon = icon.get(),
    menu = {
      {
        text = 'Auto Startup',
        cb = cb_auto_startup,
        checked = tools.is_auto_startup()
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
end

local _send_text

local function on_cliboard_change(text, from)
  print('on_cliboard_change', from, #text)

  -- do not send text in here. need in main thread
  if not from and handler then
    _send_text = text
  end
end
local function clipboard_init()
  clipboard.init(on_cliboard_change)
end

local function connect()
  local params = {
    mode = 'client',
    protocol = 'TLS',
    cafile = cafile.get(), --<-- added cafile parameters
    verify = 'peer', --<-- changed "none" to "peer"
    options = 'all'
  }
  local domain = cfg.get('domain')
  local url = string.format('wss://%s/server', domain)
  print("try connect: ", url)
  local ok, err = ws_client:connect(url, '', params)
  if not ok then
    print('could not connect', err)
  end

  handler = rpc:new_handler(ws_client)
end

local function send_ping()
  while true do
    copas.sleep(5)
    if ws_client.state == 'OPEN' then
      ws_client:send('ping', ws.TEXT)
    else
      --print('closed...')
    end
  end
end

local function send_copy()
  while true do
    copas.sleep(0)
    if ws_client.state == 'OPEN' then
      if _send_text then
        handler:send_copy(_send_text)
        _send_text = nil
      end
    else
      --print('closed...')
    end
  end
end

local function handler_receive()
  while true do
    if ws_client.state == 'OPEN' then
      local data, opcode = ws_client:receive()
      if data then
        if opcode == ws.BINARY then
          handler:process(data)
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

local function net_init()
  copas.addthread(
    function()
      xpcall(connect, traceback)
      xpcall(handler_receive, traceback)
    end
  )

  copas.addthread(
    function()
      xpcall(send_copy, traceback)
    end
  )

  copas.addthread(
    function()
      xpcall(send_ping, traceback)
    end
  )
end


local function main()
  tray_init()
  clipboard_init()
  net_init()

  while true do
    copas.step(0)
    if tray.loop() == -1 then
      print('exit from tray msg.')
      break
    end
  end
  cafile.exit()
  icon.exit()
end

xpcall(main, traceback)
