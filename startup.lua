require("bios")

print("Please specify monitor name or press enter")
local monitor = io.read()

if monitor and monitor ~= "" and peripheral.isPresent(monitor) then
    print("Redirecting to monitor " .. monitor)
    monitor = peripheral.wrap(monitor)
    prevTerm = term.redirect(monitor)
end

require("/bin/sh")()
os.shutdown()
