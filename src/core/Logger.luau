--!strict

local Logger = {}

Logger.Prefix = "[Fecurity]"
Logger.Verbose = false
Logger.LogFile = "Fecurity/Logs/fecurity.log"
Logger.MaxLogBytes = 24000

local function Join(...: any): string
    local Parts = {}
    for Index = 1, select("#", ...) do
        table.insert(Parts, tostring(select(Index, ...)))
    end
    return table.concat(Parts, " ")
end

local function EnsureLogFolder(): boolean
    if type(isfolder) ~= "function" or type(makefolder) ~= "function" then
        return false
    end

    local function FolderExists(Folder: string): boolean
        local Ok, Exists = pcall(isfolder, Folder)
        return Ok and Exists == true
    end

    local function EnsureFolder(Folder: string): boolean
        if FolderExists(Folder) then
            return true
        end
        local Ok = pcall(makefolder, Folder)
        return Ok and FolderExists(Folder)
    end

    if not EnsureFolder("Fecurity") then
        return false
    end
    if not EnsureFolder("Fecurity/Logs") then
        return false
    end
    return true
end

local function Append(Level: string, ...: any)
    if type(writefile) ~= "function" or type(readfile) ~= "function" or type(isfile) ~= "function" then
        return
    end
    local Message = Join(...)
    pcall(function()
        if not EnsureLogFolder() then
            return
        end
        local Existing = ""
        if isfile(Logger.LogFile) then
            local Ok, Body = pcall(readfile, Logger.LogFile)
            if Ok and type(Body) == "string" then
                Existing = Body
            end
        end
        local Stamp = os.date("%Y-%m-%d %H:%M:%S")
        local Line = ("%s %s %s %s\n"):format(Stamp, Logger.Prefix, Level, Message)
        local Next = Existing .. Line
        if #Next > Logger.MaxLogBytes then
            Next = string.sub(Next, #Next - Logger.MaxLogBytes + 1)
        end
        pcall(writefile, Logger.LogFile, Next)
    end)
end

function Logger.SetVerbose(Value: boolean)
    Logger.Verbose = Value
end

function Logger.Info(...: any)
    Append("[Info]", ...)
    print(Logger.Prefix, ...)
end

function Logger.Warn(...: any)
    Append("[Warn]", ...)
    warn(Logger.Prefix, ...)
end

function Logger.Debug(...: any)
    if Logger.Verbose then
        Append("[Debug]", ...)
        print(Logger.Prefix, "[Debug]", ...)
    end
end

function Logger.Error(Scope: string, Err: any)
    Append("[Error]", Scope, "->", tostring(Err))
    warn(Logger.Prefix, "[Error]", Scope, "->", tostring(Err))
end

return Logger
