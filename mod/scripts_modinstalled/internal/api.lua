--@module=true


--- @type luasocket
local luasocket = require('plugins.luasocket')
local Error = reqscript('internal/error').exports --[[@as dwarf_online.Error]]

---@class dwarf_online_api
local dwarf_online_api = {}
---@type unknown
exports = dwarf_online_api

---@enum dwarf_online_api.CONNECTION_RESULT
dwarf_online_api.CONNECTION_RESULT = {
    error = 'error',
    ok = 'ok',
}

---@class dwarf_online_api.Api
---@field address string
---@field port integer
---@field queue request_queue.Queue
dwarf_online_api.Api = {}
---@class dwarf_online_api.Api
local Api = dwarf_online_api.Api

---comment
---@param host string Host address and port
---@param queue request_queue.Queue
---@return dwarf_online.Result<dwarf_online_api.Api>
function Api:create(host, queue)
    local list = host:split(":");
    if #list > 2 or #list == 0 then
        -- dfhack.gui.writeToGamelog("Invalid host " .. host)
        return { err = Error:new("Invalid host " .. host) }
    end

    local address = list[1];
    local port = tonumber(list[2]);
    if port == nil then
        port = 80
    end

    local api = {
        queue = queue,
        address = address,
        port = port
    }
    setmetatable(api, self)
    self.__index = self

    return { ok = api }
end

---@param method http.METHOD
---@param resource string
---@param on_success? function Callback if the fetch is successful
---@param on_error? function Callback if the fetch fails
---@nodiscard
---@return dwarf_online.Result<request_queue.Handle>
function Api:fetch(method, resource, on_success, on_error)
    local request_queue = reqscript('internal/request_queue').exports --[[@as request_queue]]

    local is_connected, socket = dfhack.pcall(luasocket.tcp.connect, luasocket.tcp, self.address, self.port)
    if not is_connected then
        return { err = Error:new("Could not connect to the server") }
    end
    local client = socket --[[@as luasocket.client]]


    local http = reqscript('internal/http').exports --[[@as http]]
    local request = http.Request:default()
        :with_method(method)
        :with_resource(resource)
        :with_host(self.address, self.port)

    local req_str = request:build_string()
    client:send(req_str)

    local timeout = os.clock() + 1.0

    local queue_entry = request_queue.Entry:new {
        status = "waiting",
        client = client,
        request = request,
        timeout = timeout,
        on_success = on_success,
        on_error = on_error,
    }

    return { ok = self.queue:push(queue_entry) }
end
