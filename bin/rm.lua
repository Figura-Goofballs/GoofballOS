local path = ...

if not path:find("^%/") then
    path = fs.combine(shell:dir(), path)
end

if not path then
    error("Please specify a file/directory")
end

if not fs.exists(path) then
    error("File/Directory doesn't exist")
end

fs.delete(path)
