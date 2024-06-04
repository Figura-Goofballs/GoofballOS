local vmetatable

local vector = {}

function vector.add(self, other)
    if getmetatable(self) ~= vmetatable then expect(1, self, "vector") end
    if getmetatable(other) ~= vmetatable then expect(2, other, "vector") end

    return vector.new(
        self.x + other.x,
        self.y + other.y,
        self.z + other.z
    )
end

function vector.sub(self, other)
    if getmetatable(self) ~= vmetatable then expect(1, self, "vector") end
    if getmetatable(other) ~= vmetatable then expect(2, other, "vector") end

    return vector.new(
        self.x - other.x,
        self.y - other.y,
        self.z - other.z
)
end

function vector.mul(self, factor)
    if getmetatable(self) ~= vmetatable then expect(1, self, "vector") end
    expect(2, factor, "number")

    return vector.new(
        self.x * factor,
        self.y * factor,
        self.z * factor
    )
end

function vector.div(self, factor)
    if getmetatable(self) ~= vmetatable then expect(1, self, "vector") end
    expect(2, factor, "number")

    return vector.new(
        self.x / factor,
        self.y / factor,
        self.z / factor
    )
end

function vector.unm(self)
    if getmetatable(self) ~= vmetatable then expect(1, self, "vector") end
    return vector.new(
        -self.x,
        -self.y,
        -self.z
    )
end

function vector.dot(self, other)
    if getmetatable(self) ~= vmetatable then expect(1, self, "vector") end
    if getmetatable(other) ~= vmetatable then expect(2, other, "vector") end

    return self.x * other.x + self.y * other.y + self.z * other.z
end

function vector.cross(self, other)
    if getmetatable(self) ~= vmetatable then expect(1, self, "vector") end
    if getmetatable(other) ~= vmetatable then expect(2, other, "vector") end

    return vector.new(
        self.y * other.z - self.z * other.y,
        self.z * other.x - self.x * other.z,
        self.x * other.y - self.y * other.x
    )
end

function vector.length(self)
    if getmetatable(self) ~= vmetatable then expect(1, self, "vector") end
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function vector.normalize(self)
    return self:mul(1 / self:length())
end

function vector.round(self, tolerance)
    if getmetatable(self) ~= vmetatable then expect(1, self, "vector") end
    expect(2, tolerance, "number", "nil")

    tolerance = tolerance or 1.0
    return vector.new(
        math.floor((self.x + tolerance * 0.5) / tolerance) * tolerance,
        math.floor((self.y + tolerance * 0.5) / tolerance) * tolerance,
        math.floor((self.z + tolerance * 0.5) / tolerance) * tolerance
    )
end

function vector.equals(self, other)
    if getmetatable(self) ~= vmetatable then expect(1, self, "vector") end
    if getmetatable(other) ~= vmetatable then expect(2, other, "vector") end

    return self.x == other.x and self.y == other.y and self.z == other.z
end

vmetatable = {
    __name = "vector",
    __index = vector,
    __add = vector.add,
    __sub = vector.sub,
    __mul = vector.mul,
    __div = vector.div,
    __unm = vector.unm,
    __tostring = function(self)
        if getmetatable(self) ~= vmetatable then expect(1, self, "vector") end

        return self.x .. "," .. self.y .. "," .. self.z
    end,
    __eq = vector.equals,
}

--- Construct a new [`Vector`] with the given coordinates.
--
-- @tparam number x The X coordinate or direction of the vector.
-- @tparam number y The Y coordinate or direction of the vector.
-- @tparam number z The Z coordinate or direction of the vector.
-- @treturn Vector The constructed vector.
function vector.new(x, y, z)
    return setmetatable({
        x = tonumber(x) or 0,
        y = tonumber(y) or 0,
        z = tonumber(z) or 0,
    }, vmetatable)
end

return vector
