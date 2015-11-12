local codec = require('./redis-codec')
local connect = require('coro-net').connect
local wrap = require('coro-wrapper')

coroutine.wrap(function ()
  local read, write = connect { host = "localhost", port = 6379 }
  read = wrap.reader(read, codec.decode)
  write = wrap.writer(write, codec.encode)

  write {"set", "name", "Tim"}
  p(read())
  write {"get", "name"}
  p(read())
  write {"rpush", "numbers", 5}
  write {"rpush", "numbers", 7}
  p(read())
  p(read())
  write {"lrange", "numbers", 0, -1}
  p(read())
  write()
end)()
