---@class shell
---@field shellDir string
---@field PATH string[]
---@field vars table
local funcs = {}

---Sets the shell's directory
---@param self shell
---@param dir string
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

---Prints all available commands
---@param self shell
function funcs.help(self)
    local tbl = {}

    for k, _ in pairs(self.PATH) do
        table.insert(tbl, k)
    end

    print(table.unpack(tbl))
end

---Executes a function
---@param self shell
---@param func function
---@param ... any
function funcs.execute(self, func, ...)
    func(...)
end

---Runs a program
---@param self shell
---@param program string
---@param env table
---@param args table|any
---@param ... any
function funcs.run(self, program, env, args, ...)
    if type(args) ~= "table" then
        args = {args, ...}
    end

    local func
    if type(program) == "string" then
        if self.PATH[program] then
            func = assert(loadfile(self.PATH[program], "t", env))
        elseif fs.exists(self.shellDir:gsub("%/$", "") .. "/" .. program .. ".lua") then
            func = assert(loadfile(self.shellDir:gsub("%/$", "") .. "/" .. program), "t", env)
        else
            error("___NO_FILE___")
        end
    else
        error("Program must be a string")
    end

    self:execute(func, table.unpack(args))
end

---Returns working directory
---@param self shell
---@return string
function funcs.dir(self)
    return self.shellDir
end

---Returns path (list of programs)
---@param self shell
---@return string[]
function funcs.getPath(self)
    return self.PATH
end

---Adds a program to path (list of programs)
---@param self shell
---@param program string
---@param absoluteDir string
function funcs.addToPath(self, program, absoluteDir)
    self.PATH[program] = absoluteDir
end

---Returns the absoluter path based on a relative path
---@param self shell
---@param relative string
---@return string
function funcs.getAbsolutePath(self, relative)
    if not relative:find("^%/") then
        return fs.combine(self.shellDir, relative)
    else
        return relative
    end
end

---Gets a program
---@param self shell
---@param program string
---@return string|nil
function funcs.getProgram(self, program)
    if self.PATH[program] then
        return self.PATH[program]
    elseif fs.exists(self.shellDir:gsub("%/$", "") .. "/" .. program .. ".lua") then
        return fs.combine(self.shellDir, program .. ".lua")
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
        new.vars = {}

        if fs.exists('/bin') then
            for k, v in pairs(fs.list("/bin")) do
                if not v:find("/") then
                    new.PATH[v:gsub(".lua$", "")] = "/bin/" .. v
                    print("Adding " .. v .. " to path")
                end
            end
        end

        if fs.exists('/rom/bin') then
            for k, v in pairs(fs.list("/rom/bin")) do
                if not v:find("/") then
                    new.PATH[v:gsub(".lua$", "")] = "/rom/bin/" .. v
                    print("Adding " .. v .. " to path")
                end
            end
        end
        return new
    end
}

return shellToReturn
