return function(path)
    if not path then
        error("Please specify a directory")
    end

    if fs.exists(path) then
        error("File/Directory already exists")
    end

    fs.makeDir(path)
end