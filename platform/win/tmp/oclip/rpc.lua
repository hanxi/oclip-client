local ws = require('websocket')
local clipboard = require 'clipboard'
local tools = require 'oclip.tools'
local cfg = require "oclip.config"
local msgpack = require 'MessagePack'

msgpack.set_array 'always_as_map'

local setmetatable = setmetatable
local pack = table.pack or pack
local unpack = table.unpack or unpack


local _M = {}

local mt = {__index = _M}
function _M.new_handler(self, wb)
  local handler =
    setmetatable(
    {
      wb = wb,
      authed = false
    },
    mt
  )
  local token = cfg.get('token')
  handler:send('auth', {token})
  return handler
end

function _M.close(self, code, reason)
  return self.wb:close(code, reason)
end

function _M.process(self, data)
  local proto = msgpack.unpack(data)
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
  print('method:', method)
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
    print('send failed. not connect.', method)
    return
  end

  print('send:', method)
  local proto = {
    method = method,
    params = params or {}
  }
  local data = msgpack.pack(proto)
  self.wb:send(data, ws.BINARY)
end

function _M.send_copy(self, text)
  local content = tools.encrypt(text)
  self:send('copy', {content})
end

------------------------------------------
-- rpc function impletement
------------------------------------------
function _M.auth(self)
  self.authed = true
  return true
end

function string.tohex(str)
  return (str:gsub('.', function (c)
      return string.format('%02X', string.byte(c))
  end))
end

function _M.paste(self, content)
  local text = tools.decrypt(content)
  print("paste:", text, text:tohex())
  clipboard.settext(text)
end

return _M
