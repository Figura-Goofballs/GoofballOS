local native = peripheral
local sides = rs.getSides()

---@class peripheral
local funcs = {}

---Returns available peripherals
---@return string[]
function funcs.getAvailable()
    local results = {}

    for _, v in pairs(sides) do
        if native.isPresent(v) then
            table.insert(results, v)

            if native.hasType(v, 'peripheral_hub') then
                local remote = native.call(v, "getNamesRemote")

                for _, name in ipairs(remote) do
                    table.insert(results, name)
                end
            end
        end
    end

    return results
end
funcs.getNames = funcs.getAvailable

---Checks if a peripheral is present
---@param name string
---@return boolean
function funcs.isPresent(name)
    expect(1, name, 'string')

    if native.isPresent(name) then
        return true
    end

    for _, v in pairs(sides) do
        if native.hasType(v, "peripheral_hub") and native.call(v, "isPresentRemote", name) then
            return true
        end
    end
    return false
end

---Gets the peripheral type
---@param peripheral string|peripheral
---@return string|nil
function funcs.getType(peripheral)
    expect(1, peripheral, 'string', 'table')

    if type(peripheral) == "string" then
        if native.isPresent(peripheral) then
            return native.getType(peripheral)
        end

        for _, v in pairs(sides) do
            if native.hasType(v, "peripheral_hub") and native.call(v, "isPresentRemote", peripheral) then
                return native.call(v, "getTypeRemote", peripheral)
            end
        end

        return nil
    else
        local mtable = getmetatable(peripheral)

        if not mtable or mtable.__name ~= "peripheral" or type(mtable.types) ~= "table" then
            error("bad argument #1 (table is not a peripheral)", 2)
        end

        return table.unpack(mtable.types)
    end
end

---Checks whether a peripheral is a specific type
---@param peripheral string|peripheral
---@param _type string
---@return boolean|nil
function funcs.isType(peripheral, _type)
    expect(1, peripheral, "string", "table")
    expect(2, _type, "string")

    if type(peripheral) == "string" then -- Peripheral name passed
        if native.isPresent(peripheral) then
            return native.hasType(peripheral, _type)
        end

        for _, v in pairs(sides) do
            if native.hasType(v, "peripheral_hub") and native.call(v, "isPresentRemote", peripheral) then
                return native.call(v, "hasTypeRemote", peripheral, _type)
            end
        end
    else
        local mtable = getmetatable(peripheral)

        if not mtable or mtable.__name ~= "peripheral" or type(mtable.types) ~= "table" then
            error("bad argument #1 (table is not a peripheral)", 2)
        end

        return mtable.types[_type] ~= nil
    end
end
funcs.hasType = funcs.isType

---Gets a peripheral's methods
---@param name string
---@return table|nil
function funcs.getMethods(name)
    expect(1, name ,'string')

    if native.isPresent(name) then
        return native.getMethods(name)
    end

    for _, v in pairs(sides) do
        if native.hasType(v, "peripheral_hub") and native.call(v, "isPresentRemote", name) then
            return native.call(v, "getMethodsRemote", name)
        end
    end
end

---Gets the name of a peripheral
---@param peripheral peripheral
---@return string
function funcs.getName(peripheral)
    expect(1, peripheral, "table")

    local mtable = getmetatable(peripheral)

    if not mtable or mtable.__name ~= "peripheral" or type(mtable.name) ~= "string" then
        error("bad argument #1 (table is not a peripheral)", 2)
    end

    return mtable.name
end

---Calls a peripheral with a method
---@param name string
---@param method string
---@param ... unknown
---@return any
function funcs.call(name, method, ...)
    expect(1, name, "string")
    expect(2, method, "string")

    if native.isPresent(name) then
        return native.call(name, method, ...)
    end

    for _, v in pairs(sides) do
        if native.hasType(v, "peripheral_hub") and native.call(v, "isPresentRemote", name) then
            return native.call(v, "callRemote", name, method, ...)
        end
    end
end

---Wraps a peripheral into a table
---@param name string
---@return peripheral|nil
function funcs.wrap(name)
    expect(1, name, "string")

    local methods = funcs.getMethods(name)
    if not methods then
        return
    end

    local types = {funcs.getType(name)}
    for _, v in pairs(types) do
        types[v] = true
    end

    local result = setmetatable({}, {
        __name = "peripheral",
        name = name,
        type = types[1],
        types = types,
    })

    for _, method in pairs(methods) do
        result[method] = function(...)
            return funcs.call(name, method, ...)
        end
    end

    return result
end

---Finds all peripherals of a type
---@param _type string
---@param filter function
---@return peripheral
function funcs.find(_type, filter)
    expect(1, _type, "string")
    expect(2, filter, "function", "nil")

    local results = {}
    for _, name in ipairs(peripheral.getNames()) do
        if funcs.hasType(name, _type) then
            local wrapped = peripheral.wrap(name)

            if filter == nil or filter(name, wrapped) then
                table.insert(results, wrapped)
            end
        end
    end

    return table.unpack(results)
end

return funcs
