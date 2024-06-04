local native = http

---@class http
local funcs = {}

local methods = {
    GET = true, POST = true, HEAD = true,
    OPTIONS = true, PUT = true, DELETE = true,
    PATCH = true, TRACE = true,
}

---Checks keys
---@param options table
---@param key string
---@param _type string
---@param optional? boolean
local function checkKey(options, key, _type, optional)
    local value = options[key]
    local valueType = type(value)

    if (value ~= nil or not optional) and valueType ~= _type then
        error(("bad field '%s' (%s expected, got %s"):format(key, _type, valueType), 4)
    end
end

---Checks request options
---@param options table
---@param body boolean|nil
local function checkRequestOptions(options, body)
    checkKey(options, "url", "string")

    if body == false then
        checkKey(options, "body", "nil")
    else
        checkKey(options, "body", "string", not body)
    end

    checkKey(options, "headers", "table", true)
    checkKey(options, "method", "string", true)
    checkKey(options, "redirect", "boolean", true)
    checkKey(options, "timeout", "number", true)

    if options.method and not methods[options.method] then
        error("Unsupported HTTP method", 3)
    end
end

---Checks websocket options
---@param options {url: string, headers?: table, timeout?: number}
---@param body any
local function checkWebsocketOptions(options, body)
    checkKey(options, "url", "string")
    checkKey(options, "headers", "table", true)
    checkKey(options, "timeout", "number", true)
end

---Wraps an HTTP request
---@param url string
---@param ... unknown
---@return http.Response|nil
---@return string|nil
---@return http.Response|nil
local function wrapRequest(url, ...)
    local ok, err = native.request(...)

    if ok then
        while true do
            local event, param1, param2, param3 = os.pullEvent()

            if event == "http_success" and param1 == url then
                return param2
            elseif event == "http_failure" and param1 == url then
                return nil, param2, param3
            end
        end
    end

    return nil, err
end

---Makes an HTTP GET request
---@param url http.Url
---@param headers table|nil
---@param binary boolean|nil
---@return http.Response|nil
---@return string|nil
---@return http.Response|nil
function funcs.get(url, headers, binary)
    if type(url) == "table" then
        checkRequestOptions(url, false)

        return wrapRequest(url.url, url)
    end

    expect(1, url, "string")
    expect(2, headers, "table", "nil")
    expect(3, binary, "boolean", "nil")

    return wrapRequest(url, url, nil, headers, binary)
end

---Makes an HTTP POST request
---@param url http.Url
---@param post string
---@param headers table|nil
---@param binary boolean|nil
---@return http.Response|nil
---@return string|nil
---@return http.Response|nil
function funcs.post(url, post, headers, binary)
    if type(url) == "table" then
        checkRequestOptions(url, true)
        return wrapRequest(url.url, url)
    end

    expect(1, url, "string")
    expect(2, post, "string")
    expect(3, headers, "table", "nil")
    expect(4, binary, "boolean", "nil")

    return wrapRequest(url, url, post, headers, binary)
end

---Asynchronously makes an HTTP request 
---@param url http.Url
---@param post string|nil
---@param headers table|nil
---@param binary boolean|nil
---@return boolean
---@return string
function funcs.request(url, post, headers, binary)
    if type(url) == "table" then
        checkRequestOptions(url)

        url = url.url
    else
        expect(1, url, "string")
        expect(2, post, "string", "nil")
        expect(3, headers, "table", "nil")
        expect(4, binary, "boolean", "nil")
    end

    local ok, err = native.request(url, post, headers, binary)
    if not ok then
---@diagnostic disable-next-line: undefined-field
        os.queueEvent("http_failure", url, err)
    end

    return ok, err
end

funcs.checkURLAsync = native.checkURL

---Checks whether a URL can be requested
---@param url string
---@return boolean
---@return string
function funcs.checkURL(url)
    expect(1, url, "string")

    local ok, err = native.checkURL(url)
    if not ok then
        return ok, err
    end

    while true do
        local _, _url, ok, err = os.pullEvent("http_check")
        if url == _url then
            return ok, err
        end
    end
end

---Asynchronously opens a websocket
---@param url http.Url
---@param headers any
---@return boolean
---@return string
function funcs.websocketAsync(url, headers)
    if type(url) == "table" then
---@diagnostic disable-next-line: param-type-mismatch
        checkWebsocketOptions(url)

        url = url.url
    else
        expect(1, url, "string")
        expect(2, headers, "table", "nil")
    end

    local ok, err = native.websocket(url, headers)
    if not ok then
        os.queueEvent("websocket_failure", url, err)
    end

---@diagnostic disable-next-line: return-type-mismatch
    return ok, err
end

---Opens a websocket
---@param url http.Url
---@param headers any
---@return http.Websocket|false
---@return string|nil
function funcs.websocket(url, headers)
    local actual_url
    if type(url) == "table" then
---@diagnostic disable-next-line: param-type-mismatch
        checkWebsocketOptions(url)
        actual_url = url.url
    else
        expect(1, url, "string")
        expect(2, headers, "table", "nil")
        actual_url = url
    end

    local ok, err = native.websocket(url, headers)
    if not ok then
        return ok, err
    end

    while true do
        local event, _url, param = os.pullEvent()

        if event == "websocket_success" and _url == actual_url then
            return param
        elseif event == "websocket_failure" and _url == actual_url then
            return false, param
        end
    end
end

return funcs
