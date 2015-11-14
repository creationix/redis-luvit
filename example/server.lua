local jsonStringify = require('json').stringify
local send

local function handleSocket(req, read, write)
  if not send then
    send = require('redis-client')()
  end
  p(req)
  for message in read do
    if message.opcode == 1 then
      p(message.payload)
      local list = {}
      for part in message.payload:gmatch("%w+") do
        list[#list + 1] = part
      end
      local res = send(unpack(list))
      p(list, res)
      write {
        opcode = 1,
        payload = jsonStringify(res)
      }
    end
  end
end

require('weblit-websocket')
require('weblit-app')

.bind({
  host = "0.0.0.0",
  port = 8080
})

.use(require('weblit-logger'))
.use(require('weblit-auto-headers'))
.use(require('weblit-etag-cache'))

.websocket({
  path = "/",
  protocol = "resp",
}, handleSocket)

.start()
