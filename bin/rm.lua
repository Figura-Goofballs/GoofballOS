return function(path)
    if not path then
        error("Please specify a file/directory")
    end
    
    if not fs.exists(path) then
        error("File/Directory doesn't exist")
    end

    fs.delete(path)
end