return function(path, dest)
    if not (path and dest) then
        error("Please specify both a file/directory and destination")
    end

    if fs.exists(dest) then
        error("Destination already exists")
    end

    if not fs.exists(path) then
        error("File/Directory does not exist")
    end

    fs.copy(path, dest)
end