local funcs = {}

funcs.CHANNEL_GPS = 65534

local function vec3(x, y, z, distance)
    local mtable = {vec = vector.new(tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0), distance = distance}

    mtable.__type = "vec3"

    return mtable
end

local function trilaterate(a, b, c)
    if a.__type ~= "vec3" or b.__type ~= "vec3" or c.__type ~= "vec3" then
        error("Invalid type for 1 or more arguments")
    end

    if not a.distance or not b.distance or not c.distance then
        error("all vectors must have a distance value set")
    end

    local da, db, dc = a.distance, b.distance, c.distance
    a, b, c = a.vec, b.vec, c.vec

    local a2b = b - a
    local a2c = c - a

    if math.abs(a2b:normalize():dot(a2c:normalize())) > 0.999 then
        return nil
    end

    local d = a2b:length()
    local ex = a2b:normalize()
    local i = ex:dot(a2c)
    local ey = (a2c - ex * i):normalize()
    local j = ey:dot(a2c)
    local ez = ex:cross(ey)

    local x = (da * da - db * db + d * d) / (2 * d)
    local y = (da * da - dc * dc - x * x + (x - i) * (x - i) + j * j) / (2 * j)

    local result = a + ex * x + ey * y
    local zSquared = da * da - x * x - y * y

    if zSquared > 0 then
        local z = math.sqrt(zSquared)
        local result1 = result + ez * z
        local result2 = result - ez * z

        local rounded1, rounded2 = result1:round(0.001), result2:round(0.001)
        if rounded1.x ~= rounded2.x or rounded1.y ~= rounded2.y or rounded1.z ~= rounded2.z then
            return rounded1, rounded2
        else
            return rounded1
        end
    end

    return result:round(0.001)
end

local function narrow(p1, p2, fix)
    local dist1 = math.abs((p1 - fix.vec):length() - fix.distance)
    local dist2 = math.abs((p2 - fix.vec):length() - fix.distance)

    if math.abs(dist1 - dist2) < 0.01 then
        return p1, p2
    elseif dist1 < dist2 then
        return p1:round(0.01)
    else
        return p2:round(0.01)
    end
end

function funcs.locate(timeout, debug)
    if commands then
        return commands.getBlockPosition()
    end

    local modem = nil
    local modemSide = nil
    for _, side in ipairs(rs.getSides()) do
        if peripheral.getType(side) == "modem" and peripheral.call(side, "isWireless") then
            modem = peripheral.wrap(side)
            modemSide = side
            break
        end
    end

    if not modem then
        if debug then
            print("No wireless/ender modem attached")
        end

        return nil
    end

    if debug then
        print("Calculating position")
    end

    local close = false
    if not modem.isOpen(funcs.CHANNEL_GPS) then
        close = true
        modem.open(funcs.CHANNEL_GPS)
    end

    modem.transmit(funcs.CHANNEL_GPS, funcs.CHANNEL_GPS, "PING")

    local anchors = {}
    local pos1, pos2 = nil, nil
    local timeout = os.startTimer(_nTimeout or 2)

    while true do
        local e, p1, p2, p3, p4, p5 = os.pullEvent()

        if e == "modem_message" then
            local side, channel, replyChannel, message, distance = p1, p2, p3, p4, p5

            if side == modemSide and channel == funcs.CHANNEL_GPS and replyChannel == funcs.CHANNEL_GPS and distance then
                if type(message) == "table" and #message == 3 and tonumber(message[1]) and tonumber(message[2]) and tonumber(message[3]) then
                    local anchor = vec3(message[1], message[2], message[3], distance)

                    if debug then
                        print(anchor.distance .. " meters from anchor at " .. tostring(anchor.vec))
                    end

                    if anchor.distance == 0 then
                        pos1, pos2 = anchor.vec, nil
                    else
                        local insertIndex = math.min(3, #anchors + 1)

                        for i, older in ipairs(anchors) do
                            if (older.vec - anchor.vec):length() < 1 then
                                insertIndex = i
                                break
                            end
                        end

                        anchors[insertIndex] = anchor

                        if #anchors >= 3 then
                            if not pos1 then
                                pos1, pos2 = trilaterate(anchors[1], anchors[2], anchors[3])
                            else
                                pos1, pos2 = narrow(pos1, pos2, anchors[3])
                            end
                        end
                    end

                    if pos1 and not pos2 then
                        break
                    end
                end
            end
        elseif e == "timer" then
            local timer = p1
            if timer == timeout then
                break
            end
        end
    end

    if close then
        modem.close(funcs.CHANNEL_GPS)
    end

    if pos1 and pos2 then
        if debug then
            print("Ambiguous position")
            print("Could be " .. pos1.x .. "," .. pos1.y .. "," .. pos1.z .. " or " .. pos2.x .. "," .. pos2.y .. "," .. pos2.z)
        end

        return nil
    elseif pos1 then
        if debug then
            print("Position is " .. pos1.x .. "," .. pos1.y .. "," .. pos1.z)
        end

        return pos1.x, pos1.y, pos1.z
    else
        if debug then
            print("Could not determine position")
        end

        return nil
    end
end

function funcs.host(x, y, z)
    if pocket or turtle then
        error("GPS Hosts must be stationary")
    end

    local x2, y2, z2
    x, y, z = tonumber(x), tonumber(y), tonumber(z)

    if not x or not y or not z then
        print("No coordinates inputted, trying to locate")
        x, y, z, x2, y2, z2 = funcs.locate(2, true)
    end

    if (not x or not y or not z) or (x2 or y2 or z2) then
        error("Please specify x, y, and z")
    end

    print("Locating wireless/ender modem")

    local modem = nil
    local modemSide = nil
    for _, side in ipairs(rs.getSides()) do
        if peripheral.getType(side) == "modem" and peripheral.call(side, "isWireless") then
            modem = peripheral.wrap(side)
            modemSide = side
            break
        end
    end

    if not modem then
        if debug then
            error("No wireless/ender modem attached")
        end

        return nil
    end

    print("Opening channel " .. funcs.CHANNEL_GPS .. " on modem " .. modemSide)
    modem.open(gps.CHANNEL_GPS)

    local numServed = 0
    while true do
        local e, p1, p2, p3, p4, p5 = os.pullEvent("modem_message")
        if e == "modem_message" then
            local side, channel, replyChannel, message, distance = p1, p2, p3, p4, p5
            if side == modemSide and channel == gps.CHANNEL_GPS and message == "PING" and distance then
                modem.transmit(replyChannel, funcs.CHANNEL_GPS, {x, y, z})

                numServed = numServed + 1
                if numServed > 1 then
                    local _, y = term.getCursorPos()
                    term.setCursorPos(1, y - 1)
                end

                print("Serving request. " .. numServed .. " GPS request" .. (numServed > 1 and "s" or "") .. " served")
            end
        end
    end
end

return funcs
