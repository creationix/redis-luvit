exports.name = "creationix/redis-client"
exports.version = "1.0.2"
exports.description = "A coroutine based client for Redis"
exports.tags = {"coro", "redis"}
exports.license = "MIT"
exports.author = { name = "Tim Caswell" }
exports.homepage = "https://github.com/creationix/redis-luvit"
exports.dependencies = {
  "creationix/redis-codec@1.0.0",
  "creationix/coro-net@1.2.0",
}

local codec = require('redis-codec')
local connect = require('coro-net').connect

return function (config)
  if not config then config = {} end

  local read, write = assert(connect{
    host = config.host or "localhost",
    port = config.port or 6379,
    encode = codec.encode,
    decode = codec.decode,
  })

  return function (command, ...)
    if not command then return write() end
    write {command, ...}
    local res = read()
    if type(res) == "table" and res.error then
      error(res.error)
    end
    return res
  end
end
