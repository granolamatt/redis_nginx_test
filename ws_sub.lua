local ffi = require("ffi")
--ffi.cdef[[
--    typedef long useconds_t;
--    int usleep(useconds_t usec);
--]]

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

local redis = require "resty.redis"
local cjson = require "cjson"
local red = redis:new()

if string.ends(ngx.var.uri, '/events') then

    red:set_timeout(0) -- 1 sec
    local ok, err = red:connect("127.0.0.1", 6379)
    if not ok then
        ngx.say("failed to connect: ", err)
        return
    end

    local clients = {}
    local server = require "resty.websocket.server"
    local wb, err = server:new{
        timeout = 0,
        max_payload_len = 65535
    }

    if not wb then
        ngx.log(ngx.ERR, "failed to new websocket: ", err)
        return ngx.exit(444)
    end

    local cstring = string.sub(ngx.var.uri, 1, -7)
    local connect_string = string.gsub(cstring,"/", "::")
    if string.starts(connect_string, '::') then
        connect_string = string.sub(connect_string, 3,-1)
    end

    local ok, err = red:psubscribe(connect_string .. "*")
    if not ok then
        wb:send_close()
        return
    end

    --local yield = coroutine.yield
    local running = true

    function reader() 
        --local self = coroutine.running()
        while running do
            local data, typ, err = wb:recv_frame()
            ngx.log(ngx.INFO, 'got a websocket message')
            -- Websocket related code block (ping/close etc.)
            --yield(self)
        end
    end

    --local connect_string = ngx.var.uri
    ngx.log(ngx.INFO, 'starting websocket for ' .. connect_string)

    ngx.thread.spawn(reader)

    ngx.log(ngx.INFO, 'websocket server started')

    while running do
        local res, err = red:read_reply()
        if res then
            --local item = res[3]
            local item = cjson.encode(res)
            --local item = "Test Data"
            local ok, err = wb:send_text(item)
            if not ok then
                -- better error handling
                break
            end
        else
            local item = "No Activity"
            local ok, err = wb:send_text(item)
            if not ok then
                -- better error handling
                break
            end
        
        end
        --ffi.C.usleep(1000000)
    end

    running = false

    local ok, err = wb:send_close()
    if not ok then
      -- error handling
    end

end
