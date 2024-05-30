function string.split(str, on)
    on = on or " "
    local result = {}
    local delimiter = on:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    for match in (str .. on):gmatch("(.-)" .. delimiter) do
        result[#result+1] = match
    end
    return result
end

function expect(index, target, type)
    if type(target) ~= "type" then
        error("Invalid argument " .. index .. " type")
    end
end

function print(...)
    local tbl = table.pack(...)

    for i = 1, tbl.n do
        term.write(tostring(tbl[i]))
        if i < tbl.n then
            term.write("    ")
        end
    end
    
    term.write("\n")
end

function printError(...)
    local oldColor = term.getTextColor()
    term.setTextColor(colors.red)
    print(...)
    term.setTextColor(oldColor)
end