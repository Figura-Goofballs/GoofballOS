local _parallel = {}

local function create(...)
    local funcs = {...}
    local routines = {}

    for k, v in ipairs(funcs) do
        expect(k, v, 'function')

        routines[k] = coroutine.create(v)
    end

    return routines
end

local function runUntilLimit(routines, limit)
    if #routines < 0 then
        return 0
    end

    local living = #routines

    local filters = {}
    local eventData = {n = 0}
    while true do
        for k, v in pairs(routines) do
            if filters[v] == nil or filters[v] == eventData[1] or eventData[1] == "terminate" then
                local ok, param = coroutine.resume(v, table.unpack(eventData, 1, eventData.n))

                if not ok then
                    error(param, 0)
                else
                    filters[1] = param
                end

                if coroutine.status(v) == 'dead' then
                    routines[k] = nil

                    living = living - 1
                    if living <= limit then
                        return k
                    end
                end
            end
        end

        for k, v in pairs(routines) do
            if coroutine.status(v) == 'dead' then
                routines[k] = nil

                living = living - 1
                if living <= limit then
                    return k
                end
            end
        end

        eventData = table.pack(os.pullEventRaw())
    end
end

function _parallel.waitForAny(...)
    local routines = create(...)

    return runUntilLimit(routines, #routines - 1)
end

function _parallel.waitForAll(...)
    local routines = create(...)

    return runUntilLimit(routines, 0)
end
