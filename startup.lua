require("bios")

print("Please specify monitor name or press enter")
local monitor = io.read()

if monitor and monitor ~= "" and peripheral.isPresent(monitor) then
    print("Redirecting to monitor " .. monitor)
    monitor = peripheral.wrap(monitor)
    prevTerm = term.redirect(monitor)
end

if not debugMode then
    term.clear()
end

term.setBackgroundColor(colors.black)
term.setCursorPos(1, 1)

loadfile("/bin/sh.lua", "t", _ENV)(shell)
os.shutdown()
