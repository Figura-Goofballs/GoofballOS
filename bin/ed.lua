-- vim:ts=2:sts=2:sw=2:et:fdm=marker:
-- return function(...)
  --{{{ setup
  assert(select('#', ...) <= 1, "Incorrect arguments", 0)
  local err = "ok"
  local pth, buf, cur = "", {}, 1
  if ... then
    pth = fs.combine(shell:dir(), ...)
    local fd = fs.open(pth, "r")
    if type(fd) == "table" then
      local line, siz = fd.readLine(), 0
      while line do
        if type(line) ~= "string" then
          -- weird bug
          line = table.concat(line)
        end
        buf[cur], cur = line, cur+1
        line, siz = fd.readLine(), siz+#line+1
      end
      fd.close()
      print(siz)
      --{{{ error handling
    elseif fd then
      err = fd
      print "?"
    else
      err = "No such file or directory"
      print "?"
      --}}}
    end
  end
  --}}}
  ::getcmd:: --{{{
  local cmd = read()
  --{{{ address handling
  local _, lne = cmd:find("[0-9]+")
  if lne then
    if #buf == 0 then
      err = "Empty buffer"
      print "?"
      goto getcmd
    end
    cur = loadstring("return " .. cmd:sub(1, lne))()
    if cur == 0 or cur > #buf then
      err = "Invalid address"
      print "?"
      if cur == 0 then
        cur = 1
      else
        cur = #buf
      end
      goto getcmd
    end
    cmd = cmd:sub(lne+1, -1)
  end
  --}}}
  --{{{ command parsing
  if #cmd == 0 then goto getcmd end
  local id = cmd:byte()
  if id == 104 then
    -- 'h' command
    print(err)
    goto getcmd
  elseif id == 119 then
    --{{{ 'w' command
    local siz = 0
    local fd = fs.open(pth, "w")
    if type(fd) == "table" then
      for i = 1, #buf do
        buf[i] = tostring(buf[i]) -- FIXME: not sure how it's getting polluted
        fd.writeLine(buf[i])
        siz = siz + #buf[i] + 1
      end
      fd.close()
      print(siz)
      --{{{ error handling
    elseif fd then
      err = fd
      print "?"
    else
      err = "No such file or directory"
      print "?"
      --}}}
    end
    goto getcmd
    --}}}
  elseif id == 113 then
    -- 'q' command
    return
  elseif id == 97 then
    -- 'a' command
    -- falls through to append mode, puts cursor after current line
    cur = cur + 1
  elseif id == 99 then
    -- 'c' command
    table.remove(buf, cur)
    -- fall through to append mode, replacing removed line
  elseif id == 100 then
    -- 'd' command
    if #buf == 0 then
      err = "Empty buffer"
      print "?"
    else
      table.remove(buf, cur)
      if cur > #buf then
        cur = #buf
      end
      if cur == 0 then
        err = "Buffer emptied"
        print "!"
      end
    end
    goto getcmd
  elseif id == 36 then
    -- '$' command
    if #buf == 0 then
      err = "Empty buffer"
      print "?"
    else
      cur = #buf
    end
    goto getcmd
  elseif id == 112 then
    -- 'p' command
    if #buf == 0 then
      err = "Empty buffer"
      print "?"
    else
      print(buf[cur])
    end
    goto getcmd
  else
    err = "Unknown command"
    print "?"
    goto getcmd
  end
  --}}}
  --}}}
  ::getinput:: --{{{
  -- If you made it this far, welcome to input mode!
  -- Here you can type text to append to the buffer.
  local inline = tostring(read())
  if inline == "." then
    -- leaving so soon?
    goto getcmd
  end
  table.insert(buf, cur, inline)
  cur = cur + 1
  goto getinput
  --}}}
-- end
