local funcs = {}

local shellDir = "/home/user"

local PATH = {}
for k, v in pairs(fs.list("/bin")) do
    if not v:find("/") then
        v = v:gsub(".lua$", "")

        PATH[v] = "/bin/" .. v
        print("Adding " .. v .. " to path")
    end
end

function funcs.setDir(dir)
    if dir:find("^%/") then
        if fs.isDir(dir) then
            shellDir = dir
        else
            error("Directory doesn't exist")
        end
    else
        if fs.isDir(fs.combine(shell.dir(), dir)) then
            shellDir = fs.combine(shell.dir(), dir)
        else
            error("Directory doesn't exist")
        end
    end

    shellDir = fs.combine(shellDir) -- normalize
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
        elseif fs.exists(shellDir:gsub("%/$", "") .. "/" .. program .. ".lua") then
            require(shellDir:gsub("%/$", "") .. "/" .. program)(table.unpack(args))
        else
            error("___NO_FILE___")
        end
    else
        error("Program must be a string")
    end
end

function funcs.dir()
    return shellDir
end

function funcs.getPath()
    return PATH
end

-- absoluteDir should not include '.lua'
function funcs.addToPath(program, absoluteDir)
    PATH[program] = absoluteDir
end

function funcs.getAbsolutePath(relative)
    if not relative:find("^%/") then
        return shellDir:gsub("%/$", "") .. "/" .. relative
    else
        return relative
    end
end

function funcs.getProgram(program)
    if PATH[program] then
        return PATH[program]
    elseif fs.exists(shellDir:gsub("%/$", "") .. "/" .. program .. ".lua") then
        return shellDir:gsub("%/$", "") .. "/" .. program .. ".lua"
    end
end

funcs.resolveProgram = funcs.getProgram
funcs.programs = funcs.getPath
funcs.resolve = funcs.getAbsolutePath
funcs.execute = funcs.run
funcs.path = funcs.getPath

return funcs
