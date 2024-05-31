local native_term = term.native and term.native() or term
local redirectTarget = native_term

local function wrap(_function)
    return function(...)
        return redirectTarget[_function](...)
    end
end

local _term = term

function _term.redirect(target)
    if type(target) ~= "table" then error("expected table") end
    if target == _term or target == _G.term then
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

function _term.current()
    return redirectTarget
end

function _term.native()
    return native_term
end

function _term.write(text)
    redirectTarget.write(tostring(text))
end

function _term.clear()
    redirectTarget.clear()
end

function _term.setCursorPos(x, y)
    redirectTarget.setCursorPos(x, y)
end

function _term.getCursorPos()
    return redirectTarget.getCursorPos()
end

function _term.scroll(amount)
    redirectTarget.scroll(amount)
end

function _term.setCursorBlink(blink)
    redirectTarget.setCursorBlink(blink)
end

function _term.getCursorBlink()
    return redirectTarget.getCursorBlink()
end

function _term.getSize()
    return redirectTarget.getSize()
end

function _term.clearLine()
    redirectTarget.clearLine()
end

function _term.getTextColor()
    return redirectTarget.getTextColor()
end
_term.getTextColour = _term.getTextColor

function _term.setTextColor(color)
    redirectTarget.setTextColor(color)
end
_term.setTextColour = _term.setTextColor

function _term.getBackgroundColor()
    return redirectTarget.getBackgroundColor()
end
_term.getBackgroundColour = _term.getBackgroundColor

function _term.setBackgroundColor(color)
    redirectTarget.setBackgroundColor(color)
end
_term.setBackgroundColour = _term.setBackgroundColor

function _term.isColor()
    return redirectTarget.isColor()
end
_term.isColour = _term.isColor

function _term.blit(text, textColour, backgroundColour)
    redirectTarget.blit(text, textColour, backgroundColour)
end

function _term.setPaletteColor(...)
    redirectTarget.setPaletteColor(...)
end
_term.setPaletteColour = _term.setPaletteColor

function _term.getPaletteColor(color)
    return redirectTarget.getPaletteColor(color)
end



for _, method in ipairs { "nativePaletteColor", "nativePaletteColour" } do
    _term[method] = native_term[method]
    native_term[method] = nil
end

for k, v in pairs(native_term) do
    if type(k) == "string" and type(v) == "function" and rawget(_term, k) == nil then
        _term[k] = wrap(k)
    end
end

return _term
