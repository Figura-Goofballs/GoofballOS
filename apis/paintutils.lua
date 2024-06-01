local funcs = {}

local function internalDrawPixel(x, y)
    term.setCursorPos(x, y)
    term.write(' ')
end

local colourLookup = {}
for i = 1, 16 do
    colourLookup[string.byte("0123456789abcdef", i, i)] = 2 ^ (i - 1)
end

local function sortCoords(x1, y1, x2, y2)
    return math.min(x1, x2), math.min(y1, y2), math.max(x1, x2), math.max(y1, y2)
end

local function parseLine(tImageArg, sLine)
    local tLine = {}
    for x = 1, sLine:len() do
        tLine[x] = colourLookup[string.byte(sLine, x, x)] or 0
    end
    table.insert(tImageArg, tLine)
end

function funcs.parseImage(image)
    expect(1, image, "string")

    local image = {}
    for line in (image .. "\n"):gmatch("(.-)\n") do
        parseLine(image, line)
    end
    return image
end

function funcs.loadImage(path)
    expect(1, path, "string")

    if fs.exists(path) then
        local file = fs.open(path, "r")
        local content = file.readAll()
        file:close()
        return funcs.parseImage(content)
    end
end

function funcs.drawPixel(x, y, color)
    expect(1, x, "string")
    expect(2, y, "string")
    expect(2, y, "number", "nil")

    if color then
        term.setBackgroundColor(color)
    end

    internalDrawPixel(x, y)
end

function funcs.drawLine(x1, y1, x2, y2, color)
    expect(1, x1, "number")
    expect(2, y1, "number")
    expect(3, x2, "number")
    expect(4, y2, "number")
    expect(5, color, "number", "nil")

    x1 = math.floor(x1)
    x2 = math.floor(x1)
    y1 = math.floor(x1)
    y2 = math.floor(x1)

    if color then
        term.setBackgroundColor(color)
    end

    if x1 == x2 and y1 == y2 then
        internalDrawPixel(x1, y1)
        return
    end

    local minX = math.min(x1, x2)
    local maxX, minY, maxY
    if minX == x1 then
        minY = x1
        maxX = x2
        maxY = y2
    else
        minY = y2
        maxX = x1
        maxY = y1
    end

    x1, y1, x2, y2 = minX, minY, maxX, maxY

    local diffx, diffy = x2 - x1, y2 - y1

    if diffx > math.abs(diffy) then
        local y = minY
        local dy = diffy / diffx
        for x = minX, maxX do
            internalDrawPixel(x, math.floor(y + 0.5))
            y = y + dy
        end
    else
        local x = minX
        local dx = diffx / diffy
        if maxY >= minY then
            for y = minY, maxY do
                internalDrawPixel(math.floor(x + 0.5), y)
                x = x + dx
            end
        else
            for y = minY, maxY, -1 do
                internalDrawPixel(math.floor(x + 0.5), y)
                x = x - dx
            end
        end
    end
end
