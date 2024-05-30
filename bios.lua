debugMode = true

term = require("/apis/term")

function os.version()
    return "GoofballOS v1.0.0"
end

function os.pullEventRaw(sFilter)
    return coroutine.yield(sFilter)
end

function os.pullEvent(sFilter)
    local eventData = table.pack(os.pullEventRaw(sFilter))
    if eventData[1] == "terminate" then
        error("Terminated", 0)
    end
    return table.unpack(eventData, 1, eventData.n)
end

function string.split(str, on)
    on = on or " "
    local result = {}
    local delimiter = on:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    for match in (str .. on):gmatch("(.-)" .. delimiter) do
        result[#result+1] = match
    end
    return result
end

function write(sText)
    sText = tostring(sText)

    local w, h = term.getSize()
    local x, y = term.getCursorPos()

    local function newLine()
        if y + 1 <= h then
            term.setCursorPos(1, y + 1)
        else
            term.setCursorPos(1, h)
            term.scroll(1)
        end
        x, y = term.getCursorPos()
    end

    -- Print the line with proper word wrapping
    sText = tostring(sText)
    while #sText > 0 do
        local whitespace = string.match(sText, "^[ \t]+")
        if whitespace then
            -- Print whitespace
            term.write(whitespace)
            x, y = term.getCursorPos()
            sText = string.sub(sText, #whitespace + 1)
        end

        local newline = string.match(sText, "^\n")
        if newline then
            -- Print newlines
            newLine()
            sText = string.sub(sText, 2)
        end

        local text = string.match(sText, "^[^ \t\n]+")
        if text then
            sText = string.sub(sText, #text + 1)
            if #text > w then
                -- Print a multiline word
                while #text > 0 do
                    if x > w then
                        newLine()
                    end
                    term.write(text)
                    text = string.sub(text, w - x + 2)
                    x, y = term.getCursorPos()
                end
            else
                -- Print a word normally
                if x + #text - 1 > w then
                    newLine()
                end
                term.write(text)
                x, y = term.getCursorPos()
            end
        end
    end
end
print(read)
-- History and completion func exists here for backwards compatibility, they do nothing right now
function read(replChar, history, completionFunc, default, maxLength)
    local blink = term.getCursorBlink()
    term.setCursorBlink(true)

    maxLength = maxLength or 999999999

    local height, width = term.getSize()
    local x, y = term.getCursorPos()

    local whitespaceCount = 0

    local inText = ""

    if default then
        inText = default
    end

    if replChar then
        write(replChar:rep(#inText))
    else
        write(inText)
    end

    local reading = true
    while reading do
        local width, height = term.getSize()

        local event, param = os.pullEvent()

        if event == "key" then
            if (param == keys.enter or param == keys.numPadEnter) then
                term.setCursorBlink(blink)
                return inText
            elseif param == keys.backspace then
                if #inText > 0 then
                    inText = inText:gsub(".$", "")
                    whitespaceCount = whitespaceCount + 1
                end
            end
        elseif event == "paste" then
            inText = inText .. param
        elseif event == "char" then
            inText = inText .. param

            if whitespaceCount > 0 then
                whitespaceCount = whitespaceCount - 1
            end
        end

        term.setCursorPos(x, y)
        local startWritePos = #inText - width + x
        local endWritePos = #inText

        if startWritePos < 0 then
            startWritePos = 0
        elseif endWritePos + x >= width then
            startWritePos = startWritePos + 1
        end

        while endWritePos - maxLength >= startWritePos do
            startWritePos = startWritePos + 1
        end

        local outText = (inText):sub(startWritePos, endWritePos)

        if replChar then
            outText = replChar:rep(#outText)
        end

        term.write(outText)

        local x2, y2 = term.getCursorPos()
        term.write((" "):rep(whitespaceCount))
        term.setCursorPos(x2, y2)
    end
end

function print(...)
    local tbl = {...}

    for k, v in ipairs(tbl) do
        write(v)

        if k < #tbl then
            write("    ")
        end
    end

    write("\n")
end

function printError(...)
    local oldColor = term.getTextColor()
    term.setTextColor(colors.red)
    print(...)
    term.setTextColor(oldColor)
end

function loadfile(filename, mode, env)
    -- Support the previous `loadfile(filename, env)` form instead.
    if type(mode) == "table" and env == nil then
        mode, env = nil, mode
    end

    if type(filename) == "string" then
        error("invalid argument 1")
    end

    if type(mode) ~= "string" and type(mode) ~= "nil" then
        error("invalid argument 2")
    end

    if type(env) ~= "string" and type(env) ~= "nil" then
        error("invalid argument 2")
    end

    local file = fs.open(filename, "r")
    if not file then return nil, "File not found" end

    local func, err = load(file.readAll(), "@/" .. fs.combine(filename), mode, env)
    file.close()
    return func, err
end

function dofile(_sFile)
    local fnFile, e = loadfile(_sFile, nil, _G)
    if fnFile then
        return fnFile()
    else
        error(e, 2)
    end
end

function sleep(nTime)
    if type(nTime) ~= "number" then error("Number expected") end
    local timer = os.startTimer(nTime or 0)
    repeat
        local _, param = os.pullEvent("timer")
    until param == timer
end

os.loadAPI = nil
os.unloadAPI = nil

os.sleep = sleep

fs = require("/apis/fs")
shell = require("/apis/shell")
