require("bios")

::askForBootOption::

term.clear()

local opts = {}

for k, v in pairs(fs.list("/boot")) do
    if not v:find("/") then
        opts[v:gsub(".lua$", "")] = fs.combine("/boot", v)
        print("Adding " .. v .. " to boot list")
    end
end

for _, v in pairs({peripheral.find("drive")}) do
    if v.isDiskPresent(peripheral.getName(v)) then
        for _, w in pairs(fs.list("/" .. fs.combine(v.getMountPath(peripheral.getName(v)), "/boot"))) do
            if not w:find("/") then
                opts[w:gsub(".lua$", "")] = "/" .. fs.combine(v.getMountPath(peripheral.getName(v)), "boot", w)
                print("Adding " .. w .. " to boot list")
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

loadfile(bootOpts[option], "t", _ENV)()
