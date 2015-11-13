local connect = require('redis-client')
local split = require('coro-split')
local send

local function test()
  p(send("incr", "count"))
  local count = send("get", "count")
  p(send("rpush", "numbers", count))
  p(send("lpop", "numbers"))
end

coroutine.wrap(function ()
  send = connect { host = "localhost", port = 6379 }
  send("set", "count", 0)
  split(test, test, test, test)
  test() test()
  split(test, test, test, test, test)
  send()
end)()
