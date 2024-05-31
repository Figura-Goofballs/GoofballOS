
  if ... then
    local n = ...
    if n:find "%.$" then
      local res = help.completeTopic(n:sub(1, -2))
      if #res > 0 then
        print(table.concat(res, " "))
      else
        error("No help topics match", 0)
      end
    else
      local res = help.lookup(n)
      if res then
        local inp = io.input()
        io.input(res)
        local line = io.read "*l"
        repeat
          print(line)
          line = io.read
              "*l"
        until not line
      else
        error("No help for " .. n, 0)
      end
    end
  else
    error "invalid argument; use `help foo` or `help foo.`"
  end
