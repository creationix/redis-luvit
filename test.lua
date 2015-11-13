local codec = require('redis-codec')
local jsonStringify = require('json').stringify

local function test(str, extra, expected)
  local result, e = codec.decode(str)
  p(str)
  p(e, extra)
  p(result, expected)
  assert(extra == e)
  assert(jsonStringify(result) == jsonStringify(expected))
end

test("*2\r\n*1\r\n+Hello\r\n+World\r\n", "", {{"Hello"},"World"})
test("*2\r\n*1\r\n$5\r\nHello\r\n$5\r\nWorld\r\n", "", {{"Hello"},"World"})
test("set language Lua\r\n", "", {"set", "language", "Lua"})
test("$5\r\n12345\r\n", "", "12345")
test("$5\r\n12345\r")
test("$5\r\n12345\r\nabc", "abc", "12345")
test("+12")
test("+1234\r")
test("+1235\r\n", "", "1235")
test("+1235\r\n1234", "1234", "1235")
test(":45\r")
test(":45\r\n", "", 45)
test("*-1\r\nx", "x", nil)
test("-FATAL, YIKES\r\n", "", {error="FATAL, YIKES"})
test("*12\r\n$4\r\n2048\r\n$1\r\n0\r\n$4\r\n1024\r\n$2\r\n42\r\n$1\r\n5\r\n$1\r\n7\r\n$1\r\n5\r\n$1\r\n7\r\n$1\r\n5\r\n$1\r\n7\r\n$1\r\n5\r\n$1\r\n7\r\n",
     "", { '2048', '0', '1024', '42', '5', '7', '5', '7', '5', '7', '5', '7' })
