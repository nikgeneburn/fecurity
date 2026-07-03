--!strict

local Serializer = require("@fec/config/Serializer")
local Logger = require("@fec/core/Logger")
local Runtime = require("@fec/core/Runtime")

local ConfigManager = {}
ConfigManager.__index = ConfigManager

local function CleanName(Name: string): string
    local Clean = string.gsub(tostring(Name or ""), "[^%w_%-%s]", "")
    if Clean == "" then
        Clean = "Default"
    end
    return Clean
end

local function SortedNames(Names: { [string]: boolean }): { string }
    local Results = {}
    for Name in pairs(Names) do
        table.insert(Results, Name)
    end
    table.sort(Results)
    return Results
end

function ConfigManager.New(Flags: any)
    return setmetatable({
        Flags = Flags,
        Folder = "Fecurity/Configs",
        IndexFile = "Fecurity/Configs/index.json",
        KnownConfigs = {},
        IndexLoaded = false,
    }, ConfigManager)
end

function ConfigManager:FolderExists(Path: string): boolean
    local Ok, Exists = pcall(isfolder, Path)
    return Ok and Exists == true
end

function ConfigManager:FileExists(Path: string): boolean
    local Ok, Exists = pcall(isfile, Path)
    return Ok and Exists == true
end

function ConfigManager:EnsureFolders()
    if not Runtime.HasFileApi() then
        return false
    end
    for _, Folder in ipairs({ "Fecurity", self.Folder }) do
        if not self:FolderExists(Folder) then
            local Ok, Err = pcall(makefolder, Folder)
            if not Ok then
                Logger.Warn("Config folder failed", Folder, Err)
                return false
            end
        end
    end
    return true
end

function ConfigManager:LoadIndex()
    if self.IndexLoaded or not Runtime.HasFileApi() then
        return
    end
    self.IndexLoaded = true
    if not self:FileExists(self.IndexFile) then
        return
    end
    local Ok, Body = pcall(readfile, self.IndexFile)
    if not Ok or type(Body) ~= "string" then
        Logger.Warn("Config index read failed", self.IndexFile, Body)
        return
    end
    local Data = Serializer.Decode(Body)
    if type(Data) ~= "table" then
        return
    end
    for _, Name in ipairs(Data) do
        if type(Name) == "string" then
            self.KnownConfigs[CleanName(Name)] = true
        end
    end
end

function ConfigManager:SaveIndex()
    if not Runtime.HasFileApi() then
        return false
    end
    if not self:EnsureFolders() then
        return false
    end
    local Ok, Err = pcall(writefile, self.IndexFile, Serializer.Encode(SortedNames(self.KnownConfigs)))
    if not Ok then
        Logger.Warn("Config index write failed", self.IndexFile, Err)
        return false
    end
    return true
end

function ConfigManager:Remember(Name: string): string
    local Clean = CleanName(Name)
    self:LoadIndex()
    self.KnownConfigs[Clean] = true
    self:SaveIndex()
    return Clean
end

function ConfigManager:Path(Name: string): string
    return self.Folder .. "/" .. CleanName(Name) .. ".json"
end

function ConfigManager:Save(Name: string)
    if not Runtime.HasFileApi() then
        return false
    end
    if not self:EnsureFolders() then
        return false
    end
    local Clean = CleanName(Name)
    local Path = self:Path(Clean)
    local Ok, Err = pcall(writefile, Path, Serializer.Encode(self.Flags:Export()))
    if not Ok then
        Logger.Warn("Config write failed", Path, Err)
        return false
    end
    self:Remember(Clean)
    return true
end

function ConfigManager:Load(Name: string, RunCallbacks: boolean?)
    if not Runtime.HasFileApi() then
        return false
    end
    local Clean = CleanName(Name)
    local Path = self:Path(Clean)
    if not self:FileExists(Path) then
        return false
    end
    local Ok, Body = pcall(readfile, Path)
    if not Ok or type(Body) ~= "string" then
        Logger.Warn("Config read failed", Path, Body)
        return false
    end
    local Data = Serializer.Decode(Body)
    if type(Data) ~= "table" then
        return false
    end
    self.Flags:Load(Data, RunCallbacks)
    self:Remember(Clean)
    return true
end

function ConfigManager:GetConfigs(): { string }
    if not Runtime.HasFileApi() then
        return {}
    end
    self:LoadIndex()
    if type(listfiles) == "function" and self:FolderExists(self.Folder) then
        local Ok, Paths = pcall(listfiles, self.Folder)
        if Ok and type(Paths) == "table" then
            for _, Path in ipairs(Paths) do
                local Name = string.match(Path, "([^/\\]+)%.json$")
                if Name and Name ~= "index" then
                    self.KnownConfigs[CleanName(Name)] = true
                end
            end
        elseif not Ok then
            Logger.Warn("Config listing failed", self.Folder, Paths)
        end
    end
    return SortedNames(self.KnownConfigs)
end

return ConfigManager
