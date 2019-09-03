local cfg = require 'oclip.config'
local clipboard = require 'oclip.clipboard_helper'
local tray = require 'oclip.tray_helper'
local openssl = require 'openssl'
local icon = require 'oclip.icon'
local cipher = openssl.cipher
local digest = openssl.digest

local _M = {}

local function get_key_iv(passwd)
  hash_256 = digest.digest('sha256', passwd)
  local key = hash_256:sub(1, 32)
  local iv = hash_256:sub(33, 64)
  key = openssl.hex(key, false)
  iv = openssl.hex(iv, false)
  return key, iv
end

function _M.decrypt(data)
  local passwd = cfg.get('passwd')
  local key, iv = get_key_iv(passwd)
  return cipher.decrypt('aes-128-cbc', data, key, iv)
end

function _M.encrypt(data)
  local passwd = cfg.get('passwd')
  local key, iv = get_key_iv(passwd)
  return cipher.encrypt('aes-128-cbc', data, key, iv)
end

function _M.file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function _M.hex_dump(buf)
  for byte=1, #buf, 16 do
     local chunk = buf:sub(byte, byte+15)
     io.write(string.format('%08X  ',byte-1))
     chunk:gsub('.', function (c) io.write(string.format('%02X ',string.byte(c))) end)
     io.write(string.rep(' ',3*(16-#chunk)))
     io.write(' ',chunk:gsub('%c','.'),"\n") 
  end
end

------- clipboard --------
function _M.set_clipboard(text)
  local crlf = cfg.get('crlf')
  -- _M.hex_dump(text)
  -- not support only '\r'
  if crlf == 'lf' then
    text = text:gsub('\r', '')
  elseif crlf == 'crlf' then
    text = text:gsub('\r', '')
    text = text:gsub('\n', '\r\n')
  end
  -- _M.hex_dump(text)
  clipboard.settext(text)
end

function _M.clipboard_init(on_cliboard_change)
  clipboard.init(on_cliboard_change)
end

------- tray --------
local userprofile = os.getenv('USERPROFILE')
--print('userprofile:', userprofile)
local startup_dir =
  string.format('%s\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup', userprofile)
local link_file_name = string.format("%s\\oclip.lnk", startup_dir)

local function is_auto_startup()
  if _M.file_exists(link_file_name) then
    return true
  end
  return false
end

local function set_auto_startup()
  local vbs_str = string.format([[
set WshShell=WScript.CreateObject("WScript.Shell")
set oShellLink=WshShell.CreateShortcut("%s")
oShellLink.TargetPath="%s"
oShellLink.WindowStyle=1
oShellLink.Description="oclip shortcut"
oShellLink.Save
]], link_file_name, arg[0])
  local fname = os.tmpname()..".vbs"
  local f = io.open(fname, "w+")
  f:write(vbs_str)
  f:close()
  --print(vbs_str)
  local cmd = string.format("call wscript %q", fname)
  print("cmd:", cmd)
  os.execute(cmd)
  os.remove(fname)
end

local function unset_auto_startup()
  os.remove(link_file_name)
end

function _M.open_config()
  local fpath = cfg.get_config_file_path()
  local vbs_str = string.format([[Set oShell = CreateObject("WScript.Shell")
oShell.Run "notepad %s", 1]], fpath)
  local fname = os.tmpname()..".vbs"
  local f = io.open(fname, "w+")
  f:write(vbs_str)
  f:close()
  local cmd = string.format("wscript %s", fname)
  print(cmd)
  os.execute(cmd)
  os.remove(fname)
end

local tray_conf
local function cb_auto_startup(menuitem)
  menuitem.checked = not menuitem.checked
  print('set or unset autostartup file.')

  if menuitem.checked then
    set_auto_startup()
  else
    unset_auto_startup()
  end
  tray.update(tray_conf)
end

local function cb_open_config()
  print('open config file')
  tools.open_config()
end

local function cb_exit()
  tray.exit()
end

function _M.tray_init()
  tray_conf = {
    icon = icon.get(),
    menu = {
      {
        text = 'Auto Startup',
        cb = cb_auto_startup,
        checked = is_auto_startup()
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

function _M.loop()
    return tray.loop()
end

return _M
