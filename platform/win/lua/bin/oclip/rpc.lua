local ws = require('websocket')
local clipboard = require 'clipboard'
local tools = require "oclip.tools"
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
  print('in paste')
  local ret = tools.decrypt(content)
  print("paste:", ret)
  clipboard.settext(ret)
end

return _M
