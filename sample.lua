local connect = require('redis-client')

coroutine.wrap(function ()
  -- Connect to redis
  local send = connect { host = "localhost", port = 6379 }

  -- Send some commands
  send("set", "name", "Tim")
  local name = send("get", "name")
  assert(name == "Tim")

  -- Close the connection
  send()
end)()
