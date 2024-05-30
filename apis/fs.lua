local native_fs = fs -- CC: Tweaked does the same thing

local fs = _ENV
for k, v in pairs(native_fs) do
    if not (k == "complete") and not (k == "find") and not (k == "isDriveRoot") then
        fs[k] = v
    end
end

function fs.isDriveRoot(path)
    return fs.getDir(path) == ".." or fs.getDrive(path) ~= fs.getDrive(fs.getDir(path))
end

local find_escape = {
    -- Escape standard Lua pattern characters
    ["^"] = "%^", ["$"] = "%$", ["("] = "%(", [")"] = "%)", ["%"] = "%%",
    ["."] = "%.", ["["] = "%[", ["]"] = "%]", ["+"] = "%+", ["-"] = "%-",
    -- Aside from wildcards.
    ["*"] = ".*",
    ["?"] = ".",
}

local function find(path, segments, iter, out)
    local segment = segments[iter]

    if (not segment) and fs.exists(path) then -- At the end of the pattern, insert path into table if it exists
        table.insert(out, path)
    elseif segment.exact then
        return find(fs.combine(path, segment.contents), segments, iter + 1, out)
    else -- we have a pattern
        if not fs.isDir(path) then
            return
        end

        for _, v in ipairs(fs.list(path)) do
            if v:find(segment.contents) then find(fs.combine(path, v), segments, iter + 1, out) end
        end
    end

end

function fs.find(pattern)
    pattern = fs.combine(pattern)

    if not pattern:find("[*?]") then
        if fs.exists(pattern) then
            return {pattern}
        else
            return {}
        end
    end

    local segments = {}
    for segment in pattern:gmatch("[^/]+") do
        if segment:find("[*?]") then
            table.insert(segments, {
                exact = false,
                contents = "^" .. segment:gsub(".", find_escape) .. "$"
            })
        else
            table.insert(segments, {
                exact = true,
                contents = segment
            })
        end
    end

    local out = {}
    find("", segments, 1, out)
    return out
end
