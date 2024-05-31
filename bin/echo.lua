local str = ""

for _, v in ipairs({ ... }) do
    str = str .. " " .. v
end

print(str)
