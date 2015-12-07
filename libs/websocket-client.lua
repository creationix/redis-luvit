exports.name = "creationix/websocket-client"
exports.version = "1.0.0"
exports.description = "A coroutine based client for Websockets"
exports.tags = {"coro", "websocket"}
exports.license = "MIT"
exports.author = { name = "Tim Caswell" }
exports.homepage = "https://github.com/creationix/redis-luvit"
exports.dependencies = {
  "luvit/http-codec@1.0.0",
  "creationix/websocket-codec@1.0.8",
  "creationix/coro-net@1.2.0",
  "creationix/coro-tls@1.2.1",
  "creationix/coro-wrapper@1.0.0",
}

local connect = require('coro-net').connect
local websocketCodec = require('websocket-codec')
local httpCodec = require('http-codec')
local tlsWrap = require('coro-tls').wrap
local wrapper = require('coro-wrapper')

return function (url, subprotocol)

  local protocol, host, port, path = string.match(url, "^(wss?)://([^:/]+):?(%d*)(/?[^#]*)")
  local tls
  if protocol == "ws" then
    port = tonumber(port) or 80
    tls = false
  elseif protocol == "wss" then
    port = tonumber(port) or 443
    tls = true
  else
    error("Sorry, only ws:// or wss:// protocols supported")
  end
  if #path == 0 then path = "/" end

  local sockread, sockwrite, socket  = assert(connect{
    host = host,
    port = port,
  })
  local read,write = sockread, sockwrite
	
  if tls then
    sockread, sockwrite = tlsWrap(  sockread, sockwrite )
  end
  
  read = wrapper.reader( sockread, httpCodec.decoder())
  write = wrapper.writer( sockwrite, httpCodec.encoder())

  -- Perform the websocket handshake
  assert(websocketCodec.handshake({
    host = host,
    path = path,
    protocol = subprotocol
  }, function (req)
    write(req)
    local res = read()
    if not res then error("Missing server response") end
    if res.code == 400 then
      p { req = req, res = res }
      local reason = read() or res.reason
      error("Invalid request: " .. reason)
    end
    return res
  end))

  -- Upgrade the protocol to websocket
  read =  wrapper.reader(sockread, websocketCodec.decode )
  write = wrapper.writer(sockwrite, websocketCodec.encode)

  return read, write, socket
end
