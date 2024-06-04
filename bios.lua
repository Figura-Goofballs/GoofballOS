if rom ~= false then
    rom = true
end

debugMode = false

function loadfile(filename, mode, env)
    -- Support the previous `loadfile(filename, env)` form instead.
    if type(mode) == "table" and env == nil then
        mode, env = nil, mode
    end

    if type(filename) ~= "string" then
        error("invalid argument 1")
    end

    if type(mode) ~= "string" and type(mode) ~= "nil" then
        error("invalid argument 2")
    end

    if type(env) ~= type(_ENV) and type(env) ~= "nil" then
        error("invalid argument 2")
    end

    local file = fs.open(filename, "r")
    if not file then return nil, "File not found" end

    local func, err = load(file.readAll(), "@/" .. fs.combine(filename), mode, env)
    file.close()
    return func, err
end

local required = {}

function require(path)
    path = path:gsub('%.', '/') .. ".lua"
    if required[path] then
        return required[path]
    else
        local loaded = loadfile(path, 't', _ENV)
        if loaded then
            required[path] = loaded()
            return required[path]
        end
    end
end

function _require(path)
    if rom then
        return require('/rom/' .. path:gsub('^%/', ''))
    else
        return require(path)
    end
end

function expect(index, argument, ...)
    index = tonumber(index) or -1

    local valid = {...}

    local errMsg = ("bad arg #%i (got %s, expected "):format(index, type(argument))

    for k, v in pairs(valid) do
        if k == #valid then
            errMsg = errMsg .. (k ~= 1 and 'or ' or '') .. v
        else
            errMsg = errMsg .. v .. ', '
        end

        if type(argument) == v then
            return
        end
    end

    printError(debug.traceback())
    error(errMsg .. ')')
    while true do
        sleep()
    end
end

function sleep(nTime)
    expect(1, nTime, 'number', 'nil')
    local timer = os.startTimer(nTime or 0)
    repeat
        local _, param = os.pullEvent("timer")
    until param == timer
end

keys = _require("/enums/keys")
colors = _require('/enums/colors')
io = _require("/apis/io")
fs = _require("/apis/fs")
term = _require("/apis/term")
paintutils = _require("/apis/paintutils")
colours = colors
peripheral = _require('/apis/peripheral')

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

function write(sText, left)
    sText = tostring(sText)
    left = left or 1

    local w, h = term.getSize()
    local x, y = term.getCursorPos()

    local function newLine()
        if y + 1 <= h then
            term.setCursorPos(left, y + 1)
        else
            term.setCursorPos(left, h)
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

function read(replChar, history, completionFunc, default, maxLength)
    local blink = term.getCursorBlink()
    term.setCursorBlink(true)

    local historyIter
    if history and #history >= 1 then
        historyIter = 0
    end

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
                write("\n")
                term.setCursorBlink(blink)
                return inText
            elseif param == keys.backspace then
                if #inText > 0 then
                    inText = inText:gsub(".$", "")
                    whitespaceCount = whitespaceCount + 1
                end
            elseif param == keys.up then
                if historyIter == 0 then
                    history[0] = inText
                end

                if historyIter then
                    historyIter = historyIter + 1
                end

                while historyIter > #history do
                    historyIter = historyIter - 1
                end

                whitespaceCount = #inText - #history[historyIter]
                if whitespaceCount < 0 then
                    whitespaceCount = 0
                end

                inText = history[historyIter]
            elseif param == keys.down then
                if historyIter then
                    historyIter = historyIter - 1
                end

                while historyIter < 0 do
                    historyIter = historyIter + 1
                end

                whitespaceCount = #inText - #history[historyIter]
                if whitespaceCount < 0 then
                    whitespaceCount = 0
                end
                
                inText = history[historyIter]
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

function printf(str, ...)
    expect(1, str, 'string')

    print(str:format(...))
end

function printError(...)
    local oldColor = term.getTextColor()
    term.setTextColor(colors.red)
    print(...)
    term.setTextColor(oldColor)
end

function dofile(_sFile)
    local fnFile, e = loadfile(_sFile, nil, _G)
    if fnFile then
        return fnFile()
    else
        error(e, 2)
    end
end

os.loadAPI = nil
os.unloadAPI = nil

os.sleep = sleep

local pEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

print "POST…" do
    local f = assert(io.open(".postwork", "w"))
    f:write "1"
    local o = assert(io.output())
    -- test nulling
    -- assert(not io.output(nil)) -- can't figure this out
    -- assert(io.output() == nil)
    -- assert(not pcall(io.write, "BAD"))
    io.output(f)
    io.write "2"
    f:close()
    -- assert(io.output() == nil)
    io.output(o)
end

::passwordInput::
term.clear()
term.setCursorPos(1, 1)

if fs.exists("/.password") then
    write("password: ")

    local pass = read()
    local file = fs.open("/.password", "r")

    if (not (pass == file.readAll())) then
        file.close()
        print("incorrect")
        sleep(1)
        goto passwordInput
    end
    file.close()
else
    print("No password exists, what do you want your password to be?")

    local pass = read()

    local file = fs.open("/.password", "w")
    file.write(pass)
    file.close()

    goto passwordInput
end

::askForBootOption::

term.clear()

local opts = {}

if fs.exists('/startup.lua') then
    for k, v in pairs(fs.list("/boot")) do
        if not v:find("/") then
            opts[v:gsub(".lua$", "")] = fs.combine("/boot", v)
            print("Adding " .. v .. " to boot list")
        end
    end
end

if fs.exists('/rom/boot') then
    for k, v in pairs(fs.list("/rom/boot")) do
        if not v:find("/") then
            opts[v:gsub(".lua$", "")] = fs.combine("/rom/boot", v)
            -- print("Adding " .. v .. " to boot list")
        end
    end
end

if peripheral.find then
    for _, v in pairs({peripheral.find("drive")}) do
        if v.isDiskPresent(peripheral.getName(v)) and v.hasData() then
            if fs.exists("/" .. fs.combine(v.getMountPath(peripheral.getName(v)), "/boot")) then
                for _, w in pairs(fs.list("/" .. fs.combine(v.getMountPath(peripheral.getName(v)), "/boot"))) do
                    if not w:find("/") then
                        opts[w:gsub(".lua$", "")] = "/" .. fs.combine(v.getMountPath(peripheral.getName(v)), "boot", w)
                        print("Adding " .. w .. " to boot list")
                    end
                end
            end
        end
    end
end

local iter = 0
local bootOpts = {}

local loaderName = "GoofyBOOT"

local width, height = term.getSize()

paintutils.drawBox(1, 1, width, height, colors.white)
term.setCursorPos((width / 2) - (#loaderName / 2), 1)
term.setTextColor(colors.black)
write(loaderName)
paintutils.drawFilledBox(2, 2, width - 1, height - 1, colors.black)
term.setTextColor(colors.white)

for k, v in pairs(opts) do
    iter = iter + 1
    bootOpts[iter] = v
    term.setCursorPos(4, 2 + iter)
    write(iter .. ". " .. k)
end

term.setCursorPos(4, height - 2)
write("boot option: ")

local option = tonumber(read())

if not option or not bootOpts[option] then
    goto askForBootOption
end

term.clear()
term.setCursorPos(1, 1)

os.pullEvent = pEvent

xpcall(function()
    loadfile(bootOpts[option], "t", _ENV)()
end, function(err)
    local width, height = term.getSize()
    term.clear()
    paintutils.drawFilledBox(1, 1, width, height, colors.blue)

    paintutils.drawPixel(2, 2, colors.white)
    paintutils.drawPixel(2, 5, colors.white)
    paintutils.drawLine(4, 3, 4, 4, colors.white)
    paintutils.drawPixel(5, 2, colors.white)
    paintutils.drawPixel(5, 5, colors.white)

    term.setBackgroundColor(colors.blue)
    -- paintUtils.drawLine(7, 3, 27+7, 3, colors.black)
    term.setCursorPos(8, 3)
    write("An error has occured, error details are printed below", 8)

    term.setCursorPos(1, 8)
    write(err)

    term.setCursorPos(2, height - 1)
    write("Press any key to restart")

    while true do
        os.pullEvent("key")
        os.reboot()
    end
end)
