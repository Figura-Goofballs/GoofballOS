local ourshell = ...

local paths = ...
-- clear current PATH
for k in pairs(ourshell.PATH) do
  ourshell.PATH[k] = nil
end
-- load path
for _, p in ipairs(paths) do
  p = fs.combine(shell:dir(), p)
  for k, v in pairs(fs.list(p)) do
    if not v:find "/" then
      ourshell.PATH[v:sub(0, -5)] = fs.combine(p, v)
      print(("binprobe: added %s::%s"):format(p, v))
    end
  end
end
