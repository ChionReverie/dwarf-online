--@module=true

--- Allows a user to prepare a socket request, then handle responses.
---
--- @see request_queue.Queue
--- @see request_queue.Entry
---
--- @class request_queue
local request_queue = {}
---@type unknown
exports = request_queue

---@class request_queue.Handle: string

---@enum request_queue.QUEUE_STATUS
request_queue.QUEUE_STATUS = {
    waiting = 'waiting',
    success = 'success',
    timeout = 'timeout',
    error = 'error',
}

---@enum request_queue.READ_STATUS
request_queue.READ_STATUS = {
    error = 'error',
    no_response = 'no_response',
    ok = 'ok',
}

--- Collect socket requests to be handled over time
---
--- Create the a queue with [Queue:new()](lua://request_queue.Queue.new)
--- Add entries with [Queue:push()](lua://request_queue.Queue.push)
--- Check for completed requests and handle them with
--- [Queue:handle_responses()](lua://request_queue.Queue.resolve_responses)
---
---@class request_queue.Queue
---@field list { [request_queue.Handle]: request_queue.Entry }
---@field next_handle integer
request_queue.Queue = {}

---@class request_queue.Queue
local Queue = request_queue.Queue

--- Create a new empty queue
---
--- @return request_queue.Queue
function Queue:new()
    local queue = {
        next_handle = 0,
        list = {},
    }
    setmetatable(queue, self)
    self.__index = self

    return queue
end

--- Add an entry to the queue
---
---@param entry request_queue.Entry
---@return request_queue.Handle
function Queue:push(entry)
    local handle = ("0x%s"):format(self.next_handle) --[[@as request_queue.Handle]]
    self.next_handle = self.next_handle + 1
    self.list[handle] = entry;

    return handle;
end

--- Handle any requests which have received a response or timed out
---
--- Requests which have resolved are removed from the queue.
function Queue:resolve_responses()
    ---@type { [string]: request_queue.Entry }
    local entries_resolved = {}

    for key, entry in pairs(self.list) do
        entry:try_read()
        
        if entry.status == request_queue.QUEUE_STATUS.success then
            if entry.on_success then
                -- Avoid panics when the callback errors
                dfhack.pcall(entry.on_success, entry)
            end
            entries_resolved[key] = entry;
        end

        if entry.status == request_queue.QUEUE_STATUS.timeout then
            if entry.on_error then
                -- Avoid panics when the callback errors
                dfhack.pcall(entry.on_error, entry)
            end
            entries_resolved[key] = entry;
        end

        if entry.status == "error" then
            if entry.on_error then
                -- Avoid panics when the callback errors
                dfhack.pcall(entry.on_error, entry)
            end
            entries_resolved[key] = entry;
        end
    end

    for key, entry in pairs(entries_resolved) do
        entry.client:close()
        self.list[key] = nil
    end
end

---@class request_queue.Entry
---@field status request_queue.QUEUE_STATUS
---@field client luasocket.client
---@field request http.Request
---@field response http.Response
---@field timeout number
---@field on_error? function
---@field on_success? function
request_queue.Entry = {};
---@class request_queue.Entry;
local Entry = request_queue.Entry;

function Entry:new(o)
    local entry = o
    setmetatable(entry, self)
    self.__index = self

    return o
end

--- Retrieves the next line, if available.
---@nodiscard
---@return { line?: string, status: request_queue.READ_STATUS }
function Entry:next_line()
    local is_ok, line = dfhack.pcall(self.client.receive, self.client, "*l");

    if not is_ok then
        return {
            line = line,
            status = request_queue.READ_STATUS.error
        }
    end

    return {
        line = line,
        status = (line ~= nil) and request_queue.READ_STATUS.ok or request_queue.READ_STATUS.no_response
    }
end

---
--- @return request_queue.Entry
function Entry:try_read()
    local status_line = self:next_line();
    
    if status_line.status == request_queue.READ_STATUS.no_response then
        if os.clock() > self.timeout then
            self.status = request_queue.QUEUE_STATUS.timeout
        end
        -- Otherwise, keep waiting
        return self
    end

    dfhack.gui.writeToGamelog(("Status: %s"):format(status_line.status))

    if status_line.status ~= request_queue.READ_STATUS.ok then
        dfhack.gui.writeToGamelog("Something went wrong when reading status line")
        self.status = request_queue.QUEUE_STATUS.error
        return self
    end

    -- Parsing Status
    local http = reqscript('internal/http').exports --[[@as http]]
    local response = http.Response:create_from_status(status_line.line)
    if response == nil then
        dfhack.gui.writeToGamelog("Something went wrong when parsing status line")
        self.status = request_queue.QUEUE_STATUS.error
        return self
    end

    if response.code ~= http.RESPONSE_CODE.ok then
        dfhack.gui.writeToGamelog(("Unexpected response code %s (%s)"):format(response.code, response.comment))
        self.status = request_queue.QUEUE_STATUS.error
        return self
    end

    -- Headers
    local header_line = self:next_line()
    while header_line.status ~= request_queue.READ_STATUS.no_response do
        if header_line.status == request_queue.READ_STATUS.error then
            dfhack.gui.writeToGamelog("Something went wrong while reading header line")
            self.status = request_queue.QUEUE_STATUS.error
            return self
        end

        -- HTTP header block ends with a newline
        local trimmed = header_line.line:trim()
        if trimmed == "" then
            break
        end

        local result = response:take_header_line(trimmed)
        if result == "err" then
            dfhack.gui.writeToGamelog("Something went wrong while parsing header line")
            self.status = request_queue.QUEUE_STATUS.error
            return self
        end

        -- We're silently ignoring unsupported headers
        -- although it might bite us later
        if result == "unsupported" then end

        header_line = self:next_line()
    end

    local content_length = response.content_length
    if content_length == nil then
        dfhack.gui.writeToGamelog("Missing required header: Content length")
        self.status = request_queue.QUEUE_STATUS.error
        return self
    end

    --- Body
    local is_ok, body = dfhack.pcall(self.client.receive, self.client, content_length);
    if not is_ok then
        dfhack.gui.writeToGamelog("Something went wrong while reading request body")
        self.status = request_queue.QUEUE_STATUS.error
        return self
    end

    response.body = body

    self.status = request_queue.QUEUE_STATUS.success
    self.response = response
    return self
end
