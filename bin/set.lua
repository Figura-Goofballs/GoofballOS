local args = table.pack(...)
local var = args[1]
local val = ''

table.remove(args, 1)

for _, v in ipairs(args) do
    val = val .. tostring(v):gsub("'", ''):gsub('\\n', '\n') .. ' '
end

shell.vars[var] = val
