vectir = require("/apis/vector")
newShell = require("/apis/shell")
fs = require("/apis/fs")
disk = require("/apis/disk")
shell = newShell.new()
keys = require("/enums/keys")
gps = require("/apis/gps")

local pEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

function os.version()
    return "GoofballOS v1.0.0"
end

os.pullEvent = pEvent

::monitorSelection::
term.clear()
term.setCursorPos(1, 1)

local monitors = table.pack(peripheral.find("monitor"))

if monitors.n > 0 then
    print("Which monitor would you like to use (by number)?")

    print("  1. None")

    for k, v in ipairs(monitors) do
        print("  " .. k + 1 .. ". " .. peripheral.getName(v):gsub("^.", string.upper):gsub("_", " "))
    end

    write("monitor: ")

    local monitor = io.read()

    monitor = tonumber(monitor)

    if monitor == nil then
        goto monitorSelection
    end

    if monitors[monitor - 1] then
        print("Redirecting output")
        print("also mirroring to default")
        term.mirror(true)
        sleep(3)
        defaultTerminal = term.redirect(monitors[monitor - 1])
    elseif monitor == 1 then
        print("Using default terminal")
        sleep(1)
    else
        goto monitorSelection
    end
end

term.setBackgroundColor(colors.black)
if not debugMode then
    term.clear()
end
term.setCursorPos(1, 1)

xpcall(function ()
    loadfile("/bin/sh.lua", "t", _ENV)(shell)
end, function (err)
    local width, height = term.getSize()

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

if not debugMode then
    term.clear()
end

term.setBackgroundColor(colors.black)
term.setCursorPos(1, 1)

os.shutdown()
