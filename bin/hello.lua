local tbl = { ... }

if not tbl then
    shell:run("echo", { "Hello, World!" })
else
    shell:run("echo", tbl)
end
