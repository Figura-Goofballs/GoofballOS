---@class http.Response
local httpResponse = {}

---Returns the response code and response message returned by the server.
---@return string
---@return number
function httpResponse.getResponseCode() return '',1 end

---Get a table containing the response's headers, in a format similar to that required by http.request. If multiple headers are sent with the same name, they will be combined with a comma.
---@return table
function httpResponse.getResponseHeaders() return {} end

---@class http.Websocket
local httpWebsocket = {}

---Wait for a message from the server
---@param timeout? number
---@return string|nil
---@return boolean|nil
function httpWebsocket.receive(timeout) end

---Send a websocket message to the connected server
---@param message string
---@param binary? boolean
function httpWebsocket.send(message, binary) end

---Closes the websocket
function httpWebsocket.close() end
