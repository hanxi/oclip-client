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
local link_file_name = string.format("%s\\oclip", startup_dir)

function _M.is_auto_startup()
  if _M.file_exists(link_file_name) then
    return true
  end
  return false
end

function _M.set_auto_startup()
  local create_dir_cmd = string.format('setlocal EnableExtensions & mkdir %q', startup_dir)
  print('create_dir_cmd:', create_dir_cmd)
  os.execute(create_dir_cmd)
  local mklink_cmd = string.format('mklink %q %q', link_file_name, arg[0])
  print('mklink_cmd:', mklink_cmd)

  local fname = os.tmpname()..".bat"
  local f = io.open(fname, 'w+')

  -- Need use uac create link.
  f:write(string.format('echo %s > "%%temp%%\\run.bat"\n', mklink_cmd))
  f:write([[
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"  
if '%errorlevel%' NEQ '0' (    echo Requesting administrative privileges...    goto UACPrompt) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%temp%\run.bat", "", "", "runas", 0 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
"%temp%\run.bat"
]])
  f:write(mklink_cmd)
  f:close()
  local cmd = string.format("call %q", fname)
  print("cmd:", cmd)
  os.execute(cmd)
  os.remove(fname)
end

function _M.unset_auto_startup()
  os.remove(link_file_name)
end

return _M
