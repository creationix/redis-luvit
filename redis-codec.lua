local jsonStringify = require('json').stringify


local function encode(list)
  local len = #list
  local parts = {"*" .. len .. '\r\n'}
  for i = 1, len do
    local str = list[i]
    parts[i + 1] = "$" .. #str .. "\r\n" .. str .. "\r\n"
  end
  return table.concat(parts)
end

local byte = string.byte
local find = string.find
local sub = string.sub

local function parse(chunk, index)
  local first = byte(chunk, index)
  if first == 43 then -- '+' Simple string
    local start = find(chunk, "\r\n", index, true)
    if not start then return end
    return start + 2, sub(chunk, index + 1, start - 1)
  elseif first == 45 then -- '-' Error
    local start = find(chunk, "\r\n", index, true)
    if not start then return end
    return start + 2, nil, sub(chunk, index + 1, start - 1)
  elseif first == 58 then -- ':' Integer
    local start = find(chunk, "\r\n", index, true)
    if not start then return end
    return start + 2, tonumber(sub(chunk, index + 1, start - 1))
  elseif first == 36 then -- '$' Bulk String
    local start = find(chunk, "\r\n", index, true)
    if not start then return end
    local len = tonumber(sub(chunk, index + 1, start - 1))
    if #chunk < start + 3 + len then return end
    return start + 2, sub(chunk, start + 2, start + 1 + len)
  elseif first == 42 then -- '*' List
    local start = find(chunk, "\r\n", index, true)
    if not start then return end
    local len = tonumber(sub(chunk, index + 1, start - 1))
    local list = {}
    index = start + 2
    for i = 1, len do
      local value, err
      start, value, err = parse(chunk, index)
      if not start then return end
      if not value then return next, nil, err end
      list[i] = value
      index = start
    end
    return index, list
  else
    local list = {}
    local stop = find(chunk, "\r\n", index, true)
    if not stop then return end
    while index < stop do
      local e = find(chunk, " ", index, true)
      if not e then
        list[#list + 1] = sub(chunk, index, stop - 1)
        break
      end
      list[#list + 1] = sub(chunk, index, e - 1)
      index = e + 1
    end
    return stop + 2, list
  end
end

local function test(str, expected, error)
  local count, result, err = parse(str, 1)
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
