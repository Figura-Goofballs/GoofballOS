local shell = newShell.new()

local history = {}

if not debugMode then
    term.clear()
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

while true do
    write(shell:dir() .. "$ ")

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
