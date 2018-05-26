local ffi = require("ffi")
ffi.cdef[[
int printf(const char *fmt, ...);
]]

local _M = {}
local lrucache = require("resty.lrucache")
-- cache time in seconds
local cachettl = 300
-- we need to initialize the cache on the lua module level so that
-- it can be shared by all the requests served by each worker process:
-- allow up to 20 items in the cache
local c, err = lrucache.new(20)  
if not c then
    return error("failed to create the cache: " .. (err or "unknown"))
end

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

