vector = _require("/apis/vector")
newShell = _require("/apis/shell")
disk = _require("/apis/disk")
-- shell = newShell.new()
gps = _require("/apis/gps")
parallel = _require('/apis/parallel')

function os.version()
    return "GoofballOS v1.0.0"
end

::monitorSelection::
term.clear()
term.setCursorPos(1, 1)

if peripheral.find then
    local monitors = table.pack(peripheral.find("monitor"))

    if monitors.n > 0 then
        print("Which monitor would you like to use (by number)?")

        print("  1. None")

        for k, v in ipairs(monitors) do
            print("  " .. k + 1 .. ". " .. peripheral.getName(v):gsub("^.", string.upper):gsub("_", " "))
        end

        write("monitor: ")

        local monitor = read()

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
end

term.setBackgroundColor(colors.black)
if not debugMode then
    term.clear()
end
term.setCursorPos(1, 1)

if rom then
    loadfile("/rom/bin/sh.lua", "t", _ENV)(shell)
else
    loadfile("/bin/sh.lua", "t", _ENV)(shell)
end

if not debugMode then
    term.clear()
end

term.setBackgroundColor(colors.black)
term.setCursorPos(1, 1)
