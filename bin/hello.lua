return function(str, ...)
    if not str then
        tmpShell.run("echo", {"Hello, World!"})
    else
        tmpShell.run("echo", {str, ...})
    end
end
