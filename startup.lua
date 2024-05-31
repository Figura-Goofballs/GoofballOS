require("bios")

print("Please specify monitor name or press enter")
local monitor = io.read()

if monitor and monitor ~= "" and peripheral.isPresent(monitor) then
    print("Redirecting to monitor " .. monitor)
    monitor = peripheral.wrap(monitor)
    prevTerm = term.redirect(monitor)
end

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
    term.write("An error has occured, error details")
    -- paintUtils.drawLine(7, 4, 7+18, 4, colors.black)
    term.setCursorPos(8, 4)
    term.write("are printed below")

    term.setCursorPos(1, 8)
    write(err)

    term.setCursorPos(2, height - 1)
    write("Press any key to restart")

    while true do
        local event = os.pullEvent()

        if event == "key" then
            os.reboot()
        end
    end
end)

if not debugMode then
    term.clear()
end

term.setBackgroundColor(colors.black)
term.setCursorPos(1, 1)

os.shutdown()
