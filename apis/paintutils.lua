local funcs = {}

local function internalDrawPixel(x, y)
    expect(1, x, 'number')
    expect(2, y, 'number')

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

function funcs.parseImage(img)
    expect(1, img, "string")

    local image = {}
    for line in (img .. "\n"):gmatch("(.-)\n") do
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
    expect(1, x, "number")
    expect(2, y, "number")
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
    x2 = math.floor(x2)
    y1 = math.floor(y1)
    y2 = math.floor(y2)

    if color then
        term.setBackgroundColor(color)
    end

    if x1 == x2 and y1 == y2 then
        internalDrawPixel(x1, y1)
        return
    end

    local dx, dy = x2 - x1, y2 - y1

    if dx == 0 then
        for y = math.abs(y1), math.abs(y2) do
            internalDrawPixel(x1, y)
        end
    elseif dy == 0 then
        for x = math.abs(x1), math.abs(x2) do
            internalDrawPixel(x, y1)
        end
    else
        for x = x1, x2 do
            internalDrawPixel(x, y1 + (x-x1) * (y2-y1) / (x2-x1))
        end
    end
end

function funcs.drawBox(x1, y1, x2, y2, color)
    expect(1, x1, "number")
    expect(2, y1, "number")
    expect(3, x2, "number")
    expect(4, y2, "number")
    expect(5, color, "number", "nil")

    x1 = math.floor(x1)
    x2 = math.floor(x2)
    y1 = math.floor(y1)
    y2 = math.floor(y2)

    term.setBackgroundColor(color)

    x1, y1, x2, y2 = sortCoords(x1, y1, x2, y2)

    funcs.drawLine(x1, y1, x2, y1)
    funcs.drawLine(x2, y1, x2, y2)
    funcs.drawLine(x1, y2, x2, y2)
    funcs.drawLine(x1, y1, x1, y2)
end

function funcs.drawFilledBox(x1, y1, x2, y2, color)
    expect(1, x1, "number")
    expect(2, y1, "number")
    expect(3, x2, "number")
    expect(4, y2, "number")
    expect(5, color, "number", "nil")

    x1 = math.floor(x1)
    x2 = math.floor(x2)
    y1 = math.floor(y1)
    y2 = math.floor(y2)

    term.setBackgroundColor(color)

    x1, y1, x2, y2 = sortCoords(x1, y1, x2, y2)

    for y = y1, y2 do
        funcs.drawLine(x1, y, x2, y)
    end
end

function funcs.drawImage(image, xPos, yPos)
    expect(1, image, "table")
    expect(2, xPos, "number")
    expect(3, yPos, "number")

    for y = 1, #image do
        local tLine = image[y]
        for x = 1, #tLine do
            if tLine[x] > 0 then
                term.setBackgroundColor(tLine[x])
                internalDrawPixel(x + xPos - 1, y + yPos - 1)
            end
        end
    end
end

return funcs
