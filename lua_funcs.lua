function string.split(str, on)
    on = on or " "
    local result = {}
    local delimiter = on:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    for match in (str .. on):gmatch("(.-)" .. delimiter) do
        result[#result+1] = match
    end
    return result
end

function print(...)
    local tbl = table.pack(...)

    for i = 1, tbl.n do
        io.stdout._handle.write(tostring(tbl[i]))
        if i < tbl.n then
            io.stdout._handle.write("    ")
        end
    end
    
    io.stdout._handle.write("\n")
end
