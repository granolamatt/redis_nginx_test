local _M = {}
local redis = require("resty.redis")
local red = redis:red
-- one second timeout
red:set_timeout(1000)

-- or connect to a unix domain socket file listened
-- by a redis server:
-- local ok, err = red:connect("unix:/path/to/redis.sock")
local ok, err = red:connect("127.0.0.1", 6379)

function _M.go()
  local osclock = c:get("osclock")
  if osclock == nil then
    osclock = tostring(os.clock())
    c:set("osclock", osclock, cachettl)
  end
  local vv = ffi.C.printf("Hello %s!", "world")
  ngx.header.content_type = 'text/plain';
  return osclock .. " and " .. tostring(vv)
end

return _M

