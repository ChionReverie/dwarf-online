---@meta

---@class luasocket
luasocket = {}


---@class luasocket.tcp
luasocket.tcp = {}

--- Tries connecting to the address at the given port.
---@param address string
---@param port integer  
---@return luasocket.client
function luasocket.tcp:connect(address, port) end

--- Starts listening on the port for incoming connections.
---@param address string
---@param port integer
---@return luasocket.server
function luasocket.tcp:bind(address, port) end


--- This is a base class for client and server sockets. 
--- You can not create it - it’s like a virtual base class in c++.
--- 
---@class luasocket.socket
luasocket.socket = {}

--- Closes the connection
function luasocket.socket:close() end

--- Sets the operation timeout for this socket. 
--- 
--- It’s possible to set timeout to 0. Then it performs like a 
--- non-blocking socket.
--- @param sec integer
--- @param msec integer
function luasocket.socket:setTimeout(sec, msec) end


--- Client is a connection socket to a server. 
--- 
--- You can get this object either from `tcp:connect(address,port)` 
--- or from server:accept(). It’s a subclass of socket.
---
---@class luasocket.client : luasocket.socket
luasocket.client = {}

--- Sends data
--- @param data string
function luasocket.client:send(data) end

--- Receives data.
--- 
--- Pattern options:
--- * `*l`: Read one line (default if pattern is nil)
--- * integer: Read a specified number of bytes
--- * `*a`: Read all available data
--- 
--- @param pattern? integer | '*l' | '*a'
--- @return any
function luasocket.client:receive(pattern) end


--- Server is a socket that is waiting for clients. 
--- 
--- You can get this object from `tcp:bind(address,port)`.
--- @class luasocket.server
luasocket.server = {}

--- Accepts an incoming connection if it exists.
--- @return luasocket.client
function luasocket.server:accept() end