require("bios")

local pEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

::passwordInput::
if fs.exists("/.password") then
    write("password: ")
    local pass = read()
    local file = fs.open("/.password", "r")

    if (not (pass == file.readAll())) then
        print("Incorrect password, shutting down")
        file.close()
        sleep(1)
        os.shutdown()
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

os.shutdown()
