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
