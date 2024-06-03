local native_io = io
local io = _ENV -- seems shady but it's been working
local i, o
function io.open(f, m)
	local f, e, c = native_io.open(fs.combine(shell:dir(), f), m)
	if f then
		local close = f.close
		function f:close()
			if i == f then
				o = nil
			end
			if o == f then
				o = nil
			end
			close(f)
		end
		return f
	else
		return nil, e, c
	end
end
local function is_none(...)
	return select("#", ...) == 0
end
function io.input(...)
	if is_none(...) then
		return i
	elseif not ... or (...).read then
		i = ...
	else
		i = io.open(..., "r")
	end
end
function io.output(...)
	if is_none(...) then
		return o
	elseif not ... or (...).write then
		o = ...
	else
		o = io.open(..., "w")
	end
end
for _, k in ipairs { "stdin", "stdout", "stderr" } do
	io[k] = native_io[k]
end

