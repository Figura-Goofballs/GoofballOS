local funcs = {}

local shellDir = "/"

local PATH = {}
for k, v in pairs(fs.list("/bin")) do
    if not v:find("/") then
        v = v:gsub(".lua$", "")

        PATH[v] = "/bin/" .. v
        print("Adding " .. v .. " to path")
    end
end

function funcs.help()
    local tbl = {}
    
    for k, _ in pairs(PATH) do
        table.insert(tbl, k)
    end
    
    print(table.unpack(tbl))
end

function funcs.run(program, args)
    if type(program) == "string" then
        if PATH[program] then
            require(PATH[program])(table.unpack(args))
        else
            error("___NO_FILE___")
        end
    else
        error("Program must be a string")
    end
end

return funcs
