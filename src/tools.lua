local cfg = require 'oclip.config'
local openssl = require 'openssl'
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

local userprofile = os.getenv('USERPROFILE')
print('userprofile:', userprofile)
local startup_dir =
  string.format('%s\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup', userprofile)
local link_file_name = string.format("%s\\oclip.lnk", startup_dir)

function _M.is_auto_startup()
  if _M.file_exists(link_file_name) then
    return true
  end
  return false
end

function _M.set_auto_startup()
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
  print(vbs_str)
  local cmd = string.format("call %q", fname)
  print("cmd:", cmd)
  os.execute(cmd)
  os.remove(fname)
end

function _M.unset_auto_startup()
  os.remove(link_file_name)
end

function _M.open_config()
  local fpath = cfg.get_config_file_path()
  local cmd = string.format("call notepad.exe %s", fpath)
  os.execute(cmd)
end

return _M
