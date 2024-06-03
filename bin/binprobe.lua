local paths = {...}

if not paths or #paths <= 0 then
  paths = {rom and '/rom/bin' or '/bin'}
end

-- clear current PATH
for k in pairs(shell.PATH) do
  shell.PATH[k] = nil
end
-- load path
for _, p in ipairs(paths) do
  if not p:find('^%/') then
    p = fs.combine(shell:dir(), p)
  end

  for k, v in pairs(fs.list(p)) do
    if not v:find "/" then
      shell.PATH[v:sub(0, -5)] = fs.combine(p, v)
      print(("binprobe: added %s::%s"):format(p, v))
    end
  end
end
