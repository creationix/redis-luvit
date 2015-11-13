local codec = require('./redis-codec')
local connect = require('coro-net').connect
local wrap = require('coro-wrapper')

local function resp(read, write)
  read = wrap.reader(read, codec.decode)
  write = wrap.writer(write, codec.encode)
  return function (...)
    if select("#", ...) == 0 then
      return write()
    end
    write {...}
    return read()
  end
end

coroutine.wrap(function ()
  local send = resp(assert(connect { host = "localhost", port = 6379 }))

  p(send("set", "name", "Tim"))
  p(send("get", "name"))
  p(send("rpush", "numbers", 5))
  p(send("rpush", "numbers", 7))
  p(send("lrange", "numbers", 0, -1))
  send()
end)()
