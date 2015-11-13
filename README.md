# redis-luvit

A [Redis][] protocol codec for [Luvit][]

## Usage

The redis client library wraps the raw codec in an easy to use coroutine based
interface using luvit streams.

Send multiple strings to make a query and the response will come back
pre-decoded.

```lua
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
```

## Using the raw codec directly

This codec is transport agnostic.  I like to use it with the coro friendly
libraries, but it can be used with the node style streams in luvit or even
with a non-luvit lua project.

It is a simple encoder/decoder for talking [RESP][] over a socket.

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

[Redis]: http://redis.io/
[Luvit]: https://luvit.io/
[RESP]: http://redis.io/topics/protocol
