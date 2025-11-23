--- HTTP Module
---
--- Provides support for reading HTTP requests
---
--@module=true
--- @class http
local http = {}
---@type unknown
exports = http


---@enum http.RESPONSE_CODE
http.RESPONSE_CODE = {
    ok = 200
}

---@enum http.METHOD
http.METHOD = {
    get = "GET",
    head = "HEAD",
    post = "POST",
    put = "PUT",
    delete = "DELETE"
}

---@class http.Response
---@field http_version string
---@field code http.RESPONSE_CODE
---@field comment string
---@field body? string
---@field content_length? integer
http.Response = {}
---@class http.Response
local Response = http.Response

---@param text string
---@return http.Response?
function Response:create_from_status(text)
    local res = {}

    local pattern = "(HTTP/%d.%d) (%d+) ([%a%s]+)"
    local version, code, comment = string.match(text, pattern)
    
    res.http_version = version
    res.code = tonumber(code)
    res.comment = comment

    setmetatable(res, self)
    self.__index = self

    return res
end

---@nodiscard
---@param line string
---@return "ok" | "error" | "unsupported"
function Response:take_header_line(line)
    line = line:trim()
    
    local pattern = "([%a-]+):(.*)"
    local name, data = line.match(line, pattern);
    if name == nil or data == nil then
        dfhack.gui.writeToGamelog("Malformed header")
        return "error"
    end
    data = data:trim()
    name = string.lower(name)

    -- Now we get to interpret stuff, I guess.
    -- This should be in a map of some kind, but for now we're
    -- doing if/else
    if name == "content-length" then
        local value = tonumber(data)
        self.content_length = value
        return "ok"
    end

    if name == "content-type" then
        local list = data:split(";")

        local pattern_mime_type = "([a-]+/[a-]+)"
        local head = table.remove(list, 1)

        local mime_type = string.match(head, pattern_mime_type)
    
        local charset, boundary;
        for _, field in ipairs(list) do
            -- #TODO: Is there a more pleasant way which doesn't involve matching three times?
            local pattern_charset = "charset=(.*)"
            local my_charset = string.match(field, pattern_charset)
            
            local pattern_boundary = "boundary=(.*)"
            local my_boundary = string.match(field, pattern_boundary)
            
            if my_charset then
                charset = my_charset
            elseif my_boundary then
                boundary = my_boundary
            end
        end

        self:set_content_type({
            mime_type = mime_type,
            charset = charset,
            boundary = boundary,
        })
        return "ok"
    end

    return "unsupported"
end

function Response:set_content_type(o)
    self.content_type = o
end


---@class http.Request
---@field method http.METHOD
---@field host string
---@field port integer
---@field resource string
---@field headers { [string]: string }
---@field body? string
http.Request = {}
---@class http.Request
local Request = http.Request

--- Construct a request
--- @return http.Request
function Request:default()
    local req = {}
    setmetatable(req, self)
    self.__index = self

    req.method = "GET"
    req.host = "127.0.0.1"
    req.port = 8080
    req.resource = "/"

    req.headers = {}

    req.body = nil

    return req
end

--- Set method in place
---@param method http.METHOD
---@return http.Request Self
function Request:with_method(method)
    self.method = method
    return self
end

--- Change resource in place
---@param resource string
---@return http.Request Self
function Request:with_resource(resource)
    self.resource = resource
    return self
end

function Request:with_host(host, port)
    self.host = host
    self.port = port
    return self
end

function Request:build_string()
    local arr = {};
    table.insert(arr, ("%s %s HTTP/1.1"):format(self.method, self.resource))
    
    local host_header = "Host: "..self.host
    if self.port ~= nil then
        host_header = host_header..self.port
    end
    table.insert(arr, host_header)

    if #self.headers ~= 0 then
        table.insert(arr, table.concat(self.headers, "\n"))
    end
    table.insert(arr, "")
    if self.body then
        table.insert(arr, self.body)
    end
    table.insert(arr, "")

    return table.concat(arr, "\n")
end
