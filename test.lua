local codec = require('./redis-codec')
local jsonStringify = require('json').stringify

local function test(str, expected, error)
  local count, result, err = codec.decode(str, 1)
  p(str, result, expected)
  assert(jsonStringify(result) == jsonStringify(expected))
  assert(error == err)
end

test("*2\r\n*1\r\n+Hello\r\n+World\r\n", {{"Hello"},"World"})
test("set language Lua\r\n", {"set", "language", "Lua"})
test("$5\r\n12345\r\n", "12345")
test("$5\r\n12345\r")
test("$5\r\n12345\r\nabc", "12345")
test("+12")
test("+1234\r")
test("+1235\r\n", "1235")
test("+1235\r\n1234", "1235")
test(":45\r")
test(":45\r\n", 45)
test("-FATAL, YIKES\r\n", nil, "FATAL, YIKES")

--
-- local connect = require('coro-net').connect
--
-- coroutine.wrap(function ()
--   local read, write = connect { host = "localhost", port = 6379 }
--   write(encode{"set", "name", "Tim"})
--   p(read())
--   write()
-- end)()
