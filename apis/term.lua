local native_term = term.native and term.native() or term
local redirectTarget = native_term

local function wrap(_function)
    return function(...)
        return redirectTarget[_function](...)
    end
end

local term = _ENV

term.redirect = function(target)
    expect(1, target, "table")
    if target == term or target == _G.term then
        error("term is not a recommended redirect target, try term.current() instead", 2)
    end
    for k, v in pairs(native_term) do
        if type(k) == "string" and type(v) == "function" then
            if type(target[k]) ~= "function" then
                target[k] = function()
                    error("Redirect object is missing method " .. k .. ".", 2)
                end
            end
        end
    end
    local oldRedirectTarget = redirectTarget
    redirectTarget = target
    return oldRedirectTarget
end

function term.current()
    return redirectTarget
end

function term.native()
    return native_term
end

for _, method in ipairs { "nativePaletteColor", "nativePaletteColour" } do
    term[method] = native_term[method]
    native_term[method] = nil
end

for k, v in pairs(native_term) do
    if type(k) == "string" and type(v) == "function" and rawget(term, k) == nil then
        term[k] = wrap(k)
    end
end

return term
