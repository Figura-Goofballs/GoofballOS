local radius, keepItems = ...
radius = tonumber(radius)

if not radius then
    print('Please specify a side length (number, arg 1)')
    return
end

if keepItems == 'true' then
    keepItems = true
elseif keepItems == 'false' then
    keepItems = false
else
    print('Please specify if I should keep junk items (e.g. cobblestone) (true/false, arg 2)')
    return
end

if not turtle then
    print('This must be run from a turtle')
    return
end

local goodMatches = {
    'coal',
    'iron',
    'copper',
    'gold',
    'redstone',
    'emerald',
    'lapis',
    'diamond',
    'debris',
    'netherite',
    'flint'
}

local iter = 0
local override = 0
while true do
    turtle.digDown()
    turtle.down()
    turtle.digDown()
    turtle.down()
    if math.fmod(radius, 2) == 0 then
        iter = iter + 1
    end
    for y = 1, radius do
        for x = 1, radius-1 do
            while true do
                if turtle.inspect() then
                    turtle.dig()
                end
                if turtle.inspectUp() then
                    turtle.digUp()
                end
                if turtle.inspectDown() then
                    turtle.digDown()
                end

                sleep(0.2)

                if not turtle.inspect() and not turtle.inspectUp() and not turtle.inspectDown() then
                    break
                end
            end
            turtle.forward()
        end

        while true do
            if turtle.inspectUp() then
                turtle.digUp()
            end
            if turtle.inspectDown() then
                turtle.digDown()
            end

            sleep(0.2)

            if not turtle.inspectUp() and not turtle.inspectDown() then
                break
            end
        end
        if math.fmod(y + iter, 2) ~= 0 then
            turtle.turnRight()
        else
            turtle.turnLeft()
        end
        if y ~= radius then
            while true do
                if turtle.inspect() then
                    turtle.dig()
                end
    
                sleep(0.2)
    
                if not turtle.inspect() then
                    break
                end
            end
            turtle.forward()
        end
        if math.fmod(y + iter, 2)+override ~= 0 then
            turtle.turnRight()
        else
            turtle.turnLeft()
        end
    end

    for i = 1, 16 do
        local item = turtle.getItemDetail(i)

        if item and not keepItems then
            local name = item.name

            for _, v in pairs(goodMatches) do
                if name:find(v) then
                    goto continue
                end
            end

            turtle.select(i)
            turtle.drop()
        end

        ::continue::
    end

    turtle.digDown()
    turtle.down()
end
