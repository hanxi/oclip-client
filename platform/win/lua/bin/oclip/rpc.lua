local ws = require('websocket')
local msgpack = require 'MessagePack'
msgpack.set_array 'always_as_map'

local setmetatable = setmetatable
local pack = table.pack or pack
local unpack = table.unpack or unpack

local _M = {}

local mt = {__index = _M}
function _M.new_handler(self, wb)
  return setmetatable(
    {
      wb = wb,
      authed = false
    },
    mt
  )
end

function _M.close(self, code, reason)
  return self.wb:close(code, reason)
end

function _M.process(self, proto)
  local method = proto.method
  local params = proto.params
  if not method or not params then
    print('no method. ', method)
    return
  end
  local method_func = _M[method]
  if not method_func then
    print('unknow method', method)
    return
  end
  print('process', method)
  local ret, res_method, res_params = method_func(self, unpack(params))
  if not ret then
    return ret
  end
  if res_method then
    self:send(res_method, res_params)
  end
  return true
end

function _M.send(self, method, params)
  if self.wb.state ~= 'OPEN' then
    print("wtfffffffffff")
    return
  end

  local proto = {
    method = method,
    params = params or {}
  }
  local data = msgpack.pack(proto)
  print('send', method)
  self.wb:send(data, ws.BINARY)
end

------------------------------------------
-- rpc function impletement
------------------------------------------
function _M.auth(self)
  self.authed = true
  print('auth1')
  -- self:send('copy', {'hello'})
  print('auth2')
  --   return true, 'copy', {'hello'}
  return true, 'paste'
end

function _M.paste(self, content)
  print('paste', content)
  local openssl = require "openssl"
  local cipher = require('openssl').cipher
  local key="encrypt key"
  for k,v in pairs(cipher.list()) do
   -- print(k,v)
  end

  local key = '85FC17F7069ACD39A5C636CD0A653065'
  key = openssl.hex(key,false)
  print("ffffffffffffffff", key)
  --iv = openssl.hex(key,false)

  local ret = cipher.decrypt("aes-128-ecb", content, key, iv)
  print("ret:", ret)
  --echo "hello" | openssl enc -e -aes-256-cbc -nosalt -k "shit" -iv 87
 
  local cdata = cipher.encrypt("aes-256-cbc", "hello", key, iv)
  print(openssl.base64(cdata))
end

return _M
