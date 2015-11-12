# redis-luvit

A [Redis][] protocol codec for [Luvit][]

## Usage

This is a simple encoder/decoder for talking [RESP][] over a socket.

The encoder is a simple function that accepts a table of strings and encodes
it as a RESP list.  The decoder accepts a chunk of raw data string and tries to
consume one message.

If there is not enough data, it simply returns nothing.  If there is enough, it
returns the parsed value as well as the leftover data.

```lua
local codec = require('redis-codec')

local encoded = codec.encode({"set", "name", "Tim"})

local message, extra = codec.decode("$5\r\nHello\r\n+More\r\n")
```

## Usage with coro-net and coro-wrapper

This codec is transport agnostic.  I like to use it with the coro friendly of
libraries.

```lua
require('./redis-codec')
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
```

Redis: http://redis.io/
Luvit: https://luvit.io/
RESP: http://redis.io/topics/protocol
