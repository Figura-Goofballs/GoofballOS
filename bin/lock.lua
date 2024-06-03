os.pullEvent = os.pullEventRaw
term.clear()

local code = ...
code = tonumber(code)

print('Please place door to the right of this computer')

redstone.setOutput('right', true)

if not code or #tostring(code) ~= 5 then
    print('Please specify the code to use (5 Numbers)')
    return;
end

if not peripheral.hasType('top', 'monitor') then
    print('Please place an advanced monitor on top')
    return;
end
local monitor = peripheral.wrap('top')

local eachNum = {}
---@diagnostic disable-next-line: discard-returns
tostring(code):gsub('.', function(str)
    table.insert(eachNum, tonumber(str))
end)

local width, height = monitor.getSize()

local numButtons = {
    [1] = {w = math.floor((width / 2) - 1), h = math.floor((height / 2) + 2)},
    [2] = {w = math.floor((width / 2)), h = math.floor((height / 2) + 2)},
    [3] = {w = math.floor((width / 2) + 1), h = math.floor((height / 2) + 2)},
    [4] = {w = math.floor((width / 2) + 2), h = math.floor((height / 2) + 2)},
    [5] = {w = math.floor((width / 2) + 3), h = math.floor((height / 2) + 2)},
    [6] = {w = math.floor((width / 2) - 1), h = math.floor((height / 2) + 3)},
    [7] = {w = math.floor((width / 2)), h = math.floor((height / 2) + 3)},
    [8] = {w = math.floor((width / 2) + 1), h = math.floor((height / 2) + 3)},
    [9] = {w = math.floor((width / 2) + 2), h = math.floor((height / 2) + 3)},
    [0] = {w = math.floor((width / 2) + 3), h = math.floor((height / 2) + 3)},
}

monitor.clear()

for k, v in pairs(numButtons) do
    monitor.setCursorPos(v.w, v.h)
    monitor.write(k)
end

while true do
    monitor.setCursorPos(1, height / 2)
    monitor.write('[     ]')

    local inCode = {0, 0, 0, 0, 0}

    for i = 1, 5 do
        ::event::
        local event, monitorSide, x, y = os.pullEvent() -- I tried filtering

        if event == 'monitor_touch' and monitorSide == 'top' then
            x, y = math.floor(x), math.floor(y)

            for k, v in pairs(numButtons) do
                if x == v.w and y == v.h then
                    monitor.setCursorPos(1 + i, height / 2)
                    monitor.write('*')
                    inCode[i] = k
                end
            end
        else
            goto event
        end
    end

    if inCode[1] == eachNum[1] and inCode[2] == eachNum[2] and inCode[3] == eachNum[3] and inCode[4] == eachNum[4] and inCode[5] == eachNum[5] then
        redstone.setOutput('right', false)
        sleep(3)
        redstone.setOutput('right', true)
    end
end
