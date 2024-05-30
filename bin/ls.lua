return function(opts)
    local showHidden = false

    if opts and opts:find("a") then
        showHidden = true
    end

    local tbl = fs.list(shell.dir())

    for k, v in pairs(tbl) do
        if v:find("^%.") and not showHidden then
            table.remove(tbl, k)
        end
    end

    print(table.unpack(tbl))
end