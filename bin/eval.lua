local str = ""
local tbl = table.pack(...)

for i = 1, tbl.n do
    str = str .. tbl[i] .. " "
end

load(str, "eval", "t", _ENV)()
