local file = table.concat(table.pack(...), ' ')

if not file:find('^%/') then
    file = fs.combine(shell:dir(), file)
end

if not fs.exists(file) then
    error(('File %s not found'):format(file))
end

file = fs.open(file, 'r')
local content = string.split(file.readAll(), '\n')
file.close()

for k, v in pairs(content) do
    print(k .. ' | ' .. v)

    os.pullEvent('key')
end
