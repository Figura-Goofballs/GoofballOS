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
while true do
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)

        if item and turtle.getFuelLevel() <= 500 then
            local name = item.name

            if name:find('coal') then
                turtle.select(i)
                turtle.refuel()
            end
        end
    end

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

                local _, down = turtle.inspectDown()
                local _, forward = turtle.inspect()
                local _, up = turtle.inspectUp()

                local override, overrideDown, overrideUp

                if down and down.name then
                    if down.name:find('water') or down.name:find('lava') then
                        overrideDown = true
                    end
                end

                if up and up.name then
                    if up.name:find('water') or up.name:find('lava') then
                        overrideUp = true
                    end
                end

                if forward and forward.name then
                    if forward.name:find('water') or forward.name:find('lava') then
                        override = true
                    end
                end

                if (not turtle.inspect() or override) and (not turtle.inspectUp() or overrideUp) and (not turtle.inspectDown() or overrideDown) then
                    break
                end
            end
            turtle.forward()
        end

        while true do
            local overrideDown, overrideUp

            if turtle.inspectUp() then
                turtle.digUp()
            end
            if turtle.inspectDown() then
                turtle.digDown()
            end

            local _, up = turtle.inspectUp()
            local _, down = turtle.inspectDown()

            if down and down.name then
                if down.name:find('water') or down.name:find('lava') then
                    overrideDown = true
                end
            end

            if up and up.name then
                if up.name:find('water') or up.name:find('lava') then
                    overrideUp = true
                end
            end

            sleep(0.2)

            if (not turtle.inspectUp() or overrideUp) and (not turtle.inspectDown() or overrideDown) then
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
    
                local override
                
                sleep(0.2)

                local _, forward = turtle.inspect()

                if forward and forward.name then
                    if forward.name:find('water') or forward.name:find('lava') then
                        override = true
                    end
                end
    
                if not turtle.inspect() or override then
                    break
                end
            end
            turtle.forward()
        end
        if math.fmod(y + iter, 2) ~= 0 then
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
