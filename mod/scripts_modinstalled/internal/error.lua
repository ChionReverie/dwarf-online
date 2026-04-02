--@module=true

---@class dwarf_online.Error
---@field message string
---@field cause? dwarf_online.Error The error which caused this one, if any
---@field line string
---@field file string
local Error = {}
---@type unknown
exports = Error;

--- Generate an error
---@param message string
---@param cause? dwarf_online.Error
---@return table
function Error:new(message, cause)
    -- Stack frame of the calling function
    local info = debug.getinfo(2);

    local err = {
        message = message,
        cause = cause,
        line = info.currentline,
        file = info.short_src,
    }

    setmetatable(err, self)
    self.__index = self

    return err
end

---@return string
function Error:build_message()
    local message = ("%s\n%s:%s \n"):format(self.message, self.file, self.line)

    if self.cause then
        message = message .. "\n" .. "Caused by " .. self.cause:build_message() 
    end

    return message
end
