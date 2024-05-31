local funcs = {}

function funcs.setDir(self, dir)
    if dir:find("^%/") then
        if fs.isDir(dir) then
            self.shellDir = dir
        else
            error("Directory doesn't exist")
        end
    else
        if fs.isDir(fs.combine(self:dir(), dir)) then
            self.shellDir = fs.combine(self:dir(), dir)
        else
            error("Directory doesn't exist")
        end
    end

    self.shellDir = "/" .. fs.combine(self.shellDir) -- normalize
end

function funcs.help(self)
    local tbl = {}

    for k, _ in pairs(self.PATH) do
        table.insert(tbl, k)
    end

    print(table.unpack(tbl))
end

function funcs.execute(self, func, ...)
    func(...)
end

function funcs.run(self, program, args)
    local func
    if type(program) == "string" then
        if self.PATH[program] then
            func = assert(loadfile(self.PATH[program], "t", _ENV))
        elseif fs.exists(self.shellDir:gsub("%/$", "") .. "/" .. program .. ".lua") then
            func = assert(loadfile(self.shellDir:gsub("%/$", "") .. "/" .. program), "t", _ENV)
        else
            error("___NO_FILE___")
        end
    else
        error("Program must be a string")
    end

    self:execute(func, table.unpack(args))
end

function funcs.dir(self)
    return self.shellDir
end

function funcs.getPath(self)
    return self.PATH
end

-- absoluteDir should not include '.lua'
function funcs.addToPath(self, program, absoluteDir)
    self.PATH[program] = absoluteDir
end

function funcs.getAbsolutePath(self, relative)
    if not relative:find("^%/") then
        return self.shellDir:gsub("%/$", "") .. "/" .. relative
    else
        return relative
    end
end

function funcs.getProgram(self, program)
    if self.PATH[program] then
        return self.PATH[program]
    elseif fs.exists(self.shellDir:gsub("%/$", "") .. "/" .. program .. ".lua") then
        return self.shellDir:gsub("%/$", "") .. "/" .. program .. ".lua"
    end
end

funcs.resolveProgram = funcs.getProgram
funcs.programs = funcs.getPath
funcs.resolve = funcs.getAbsolutePath
funcs.path = funcs.getPath

funcs.__index = funcs

local shellToReturn = {
    new = function()
        local new = setmetatable({}, funcs)

        new.shellDir = "/home/user"
        new.PATH = {}

        for k, v in pairs(fs.list("/bin")) do
            if not v:find("/") then
                new.PATH[v:gsub(".lua$", "")] = "/bin/" .. v
                print("Adding " .. v .. " to path")
            end
        end

        return new
    end
}

return shellToReturn
