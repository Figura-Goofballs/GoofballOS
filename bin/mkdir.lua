return function(path)
    if not path:find("^%/") then
        path = fs.combine(shell.dir(), path)
    end

    if not path then
        error("Please specify a directory")
    end

    if fs.exists(path) then
        error("File/Directory already exists")
    end

    fs.makeDir(path)
end