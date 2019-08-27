local _M = {}

-- fork from https://github.com/mitchellh/go-homedir/blob/master/homedir.go
local function get_home_dir()
  -- First prefer the HOME environmental variable
  local home = os.getenv('HOME')
  if home ~= nil then
    return home
  end

  -- Prefer standard environment variable USERPROFILE
  home = os.getenv('USERPROFILE')
  if home ~= nil then
    return home
  end

  local drive = os.getenv('HOMEDRIVE')
  local path = os.getenv('HOMEPATH')
  if drive == nil or path == nil then
    return ''
  end
  home = drive .. path
  return home
end

local config_file_name = '.oclip'
local config_file_path
local function get_config_file_path()
  if config_file_path then
    return config_file_path
  end
  local home = get_home_dir()
  local separator = package.config:sub(1,1)
  config_file_path = home .. separator .. config_file_name
  print("cfg_path:", config_file_path)
  return config_file_path
end
local config
local function get_config()
  if config then
    return config
  end

  config = {}
  local cfg_path = get_config_file_path()
  local f = io.open(cfg_path, 'r')
  if not f then
    return config
  end
  local line = f:read("l")
  while line do
    local k,v = line:gmatch("(%w+)[^=]*=%s*(.*)")()
    if k and v then
        config[k] = v
        print(k, "=", v)
    end
    line = f:read("l")
  end
  f:close()
  return config
end

function _M.get(key)
    local cfg = get_config()
    return cfg[key]
end

return _M
