local shell = newShell.new()

local history = {}

if not debugMode then
    term.clear()
end

shell.vars.prompt = "$ "

local promptEscapes = {
    u = function()
        return "user"
    end,
    h = function()
        return tostring(os.getComputerID())
    end,
    p = function()
        return shell:dir()
    end,
    n = function()
        return '\n'
    end
}

local function formatPrompt(prompt)
    local formatted = prompt

    for k, v in pairs(promptEscapes) do
        local repl = v()

        formatted = formatted:gsub('%%' .. k, repl)
    end

    local blit = ''
    local blitChar = 'r'
    local text = ''
    local background = ''
    local setBlit = false

    local tbl = {}

    formatted:gsub('.', function(str)
        if setBlit then
            blitChar = str

            setBlit = false
            return ''
        elseif str == '&' then
            setBlit = true
            return ''
        elseif str == '\n' then
            tbl[#tbl + 1] = {
                text = text,
                blit = blit,
                background = background
            }

            text = ''
            blit = ''
            background = ''

            return ''
        else
            blit = blit .. blitChar
            text = text .. str
            background = background .. 'w'
            return ''
        end
    end)

    tbl[#tbl + 1] = {
        text = text,
        blit = blit,
        background = background
    }

    return tbl
end

fs.makeDir("/home/user")

print(shell, newShell.new())

if not debugMode then
    term.clear()
    term.setCursorPos(1, 1)
end

term.setTextColor(colors.yellow)
print("Welcome to " .. os.version() .. " \n")
term.setTextColor(colors.white)
print(
    "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.")
print()

if fs.exists('/home/user/.shrc') then
    local file = fs.open('/home/user/.shrc', 'r')

    for _, input in ipairs(string.split(file.readAll(), '\n')) do
        local program, args

        local inTbl = string.split(input, " ")

        program = inTbl[1]

        table.remove(inTbl, 1)

        args = inTbl

        local env = _ENV
        env.shell = shell
        env.turtle = turtle

        if program == "sh" then
            shell:run("sh", env)
        elseif program == "exit" then
            return
        elseif program == "help" then
            shell:help()
        else
            local success, message = pcall(shell.run, shell, program, env, args)

            if not success then
                if message:find("___NO_FILE___") then
                    --printError("Could not find " .. program .. " in path")
                else
                    printError(message)
                end
            end
        end
    end

    file.close()
end


while true do
    for i, v in ipairs(formatPrompt(shell.vars.prompt)) do
        if i ~= 1 then
            write('\n')
        end

        term.blit(v.text, v.blit, v.background)
    end

    local input = read(nil, history)
    table.insert(history, 1, input)

    local program, args

    if input then
        local inTbl = string.split(input, " ")

        program = inTbl[1]

        table.remove(inTbl, 1)

        args = inTbl
    end

    if program and program ~= "" then
        local env = _ENV
        env.shell = shell

        if program == "sh" then
            shell:run("sh", env)
        elseif program == "exit" then
            return
        elseif program == "help" then
            shell:help()
        else
            local success, message = pcall(shell.run, shell, program, env, args)

            if not success then
                if message:find("___NO_FILE___") then
                    printError("Could not find " .. program .. " in path")
                else
                    printError(message)
                end
            end
        end
    end

    coroutine.yield()
end
