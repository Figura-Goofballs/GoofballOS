local args = table.pack(...)
local url = args[1]
local run = false

table.remove(args, 1)
if url == 'run' then
    url = args[1]
    table.remove(args, 1)

    run = true
end

local filePath = ''

for i = 1, args.n - 1 do
    filePath = filePath .. (args[i] or '') .. ' '
end

if not filePath:find('^%/') then
    filePath = fs.combine(shell:dir(), filePath)
end

if not http then
    print('HTTP api not enabled')
    return
end

if not filePath and not run then
    print('please specify a file name')
end

print('Connecting to ' .. url)

local response, err = http.get(url)

if response and response.getResponseCode() == 200 then
    print('Success!')

    if not run then
        print('Saving file!')

        local file = fs.open(filePath, 'w')

        file.write(response.readAll())
        file.close()
    else
        print('Running!')

---@diagnostic disable-next-line: param-type-mismatch
        local func = load(response.readAll(), nil, 'bt', _ENV)

        if not func then
            print('something went wrong while running the response')
        else
            func()
        end
    end

    response.close()
else
    print('Failure')
    printError(err)
end
