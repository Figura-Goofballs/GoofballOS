return function(str, ...)
    if not str then
        shell.run("echo", {"Hello, World!"})
    else
        shell.run("echo", {str, ...})
    end
end
