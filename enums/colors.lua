local funcs = {}

funcs.white = 0x1
funcs.orange = 0x2
funcs.magenta = 0x4
funcs.lightBlue = 0x8
funcs.yellow = 0x10
funcs.lime = 0x20
funcs.pink = 0x40
funcs.gray = 0x80
funcs.lightGray = 0x100
funcs.cyan = 0x200
funcs.purple = 0x400
funcs.blue = 0x800
funcs.brown = 0x1000
funcs.green = 0x2000
funcs.red = 0x4000
funcs.black = 0x8000

function funcs.combine(...)
    local r = 0

    for i = 1, select('#', ...) do
        local c = select(i, ...)
        expect(i, c, "number")
        r = bit32.bor(r, c)
    end

    return r
end

function funcs.subtract(colors, ...)
    expect(1, colors, "number")

    local r = colors

    for i = 1, select('#', ...) do
        local c = select(i, ...)
        expect(i + 1, c, "number")
        r = bit32.band(r, bit32.bnot(c))
    end

    return r
end

function funcs.test(colors, color)
    expect(1, colors, "number")
    expect(2, color, "number")

    return bit32.band(colors, color) == color
end

function funcs.packRGB(r, g, b)
    expect(1, r, "number")
    expect(2, g, "number")
    expect(3, b, "number")

    return
        bit32.band(r * 255, 0xFF) * 2 ^ 16 +
        bit32.band(g * 255, 0xFF) * 2 ^ 8 +
        bit32.band(b * 255, 0xFF)
end

function funcs.unpackRGB(rgb)
    expect(1, rgb, "number")

    return
        bit32.band(bit32.rshift(rgb, 16), 0xFF) / 255,
        bit32.band(bit32.rshift(rgb, 8), 0xFF) / 255,
        bit32.band(rgb, 0xFF) / 255
end

function funcs.rgb8(r, g, b)
    if g == nil and b == nil then
        return funcs.unpackRGB(r)
    else
        return funcs.packRGB(r, g, b)
    end
end

local colorHexLookup = {}
for i = 0, 15 do
    colorHexLookup[2 ^ i] = string.format("%x", i)
end

function funcs.toBlit(color)
    expect(1, color, "number")
    local hex = colorHexLookup[color]
    if hex then return hex end

    if color < 0 or color > 0xffff then
        error("Colour out of range", 2)
    end
    
    return string.format("%x", math.floor(math.log(color, 2)))
end

function funcs.fromBlit(hex)
    expect(1, hex, "string")

    if #hex ~= 1 then
        return nil
    end

    local value = tonumber(hex, 16)

    if not value then
        return nil
    end

    return 2 ^ value
end

return funcs
