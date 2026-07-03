--!strict

local Logger = require("@fec/core/Logger")
local Runtime = require("@fec/core/Runtime")
local Registry = require("@fec/assets/AssetRegistry")

local AssetCache = {}
AssetCache.__index = AssetCache

function AssetCache.New()
    return setmetatable({
        Ready = false,
        Failed = {},
    }, AssetCache)
end

function AssetCache:FolderExists(Folder: string): boolean
    if type(isfolder) ~= "function" then
        return false
    end
    local Ok, Exists = pcall(isfolder, Folder)
    return Ok and Exists == true
end

function AssetCache:FileExists(Path: string): boolean
    if type(isfile) ~= "function" then
        return false
    end
    local Ok, Exists = pcall(isfile, Path)
    return Ok and Exists == true
end

function AssetCache:EnsureFolders()
    if not Runtime.HasFileApi() then
        return false
    end
    local Ready = true
    for _, Folder in ipairs(Registry.Folders) do
        if not self:FolderExists(Folder) then
            local Ok, Err = pcall(makefolder, Folder)
            if not Ok then
                Ready = false
                Logger.Warn("Asset cache folder failed", Folder, Err)
            end
        end
    end
    return Ready
end

function AssetCache:Download(Url: string): string?
    local Ok, Body = pcall(function()
        return game:HttpGet(Url)
    end)
    if Ok and type(Body) == "string" and #Body > 0 then
        return Body
    end
    return nil
end

function AssetCache:IsValidBody(Asset: { Url: string, File: string, Bytes: number? }, Body: string): boolean
    if #Body <= 0 then
        return false
    end
    if Asset.Bytes and #Body ~= Asset.Bytes then
        return false
    end
    return true
end

function AssetCache:DeleteBadFile(Path: string)
    if type(delfile) == "function" then
        local Ok, Err = pcall(delfile, Path)
        if not Ok then
            Logger.Warn("Asset cache delete failed", Path, Err)
        end
    end
end

function AssetCache:EnsureAsset(Asset: { Url: string, File: string, Bytes: number? })
    if not Runtime.HasFileApi() then
        return nil
    end
    if self:FileExists(Asset.File) then
        local Ok, Body = pcall(readfile, Asset.File)
        if Ok and type(Body) == "string" and self:IsValidBody(Asset, Body) then
            self.Failed[Asset.File] = nil
            return Asset.File
        end
        self:DeleteBadFile(Asset.File)
    end
    local Body = self:Download(Asset.Url)
    if Body and self:IsValidBody(Asset, Body) then
        local Ok, Err = pcall(writefile, Asset.File, Body)
        if Ok then
            self.Failed[Asset.File] = nil
            return Asset.File
        end
        Logger.Warn("Asset cache write failed", Asset.File, Err)
    end
    self.Failed[Asset.File] = true
    Logger.Warn("Asset download failed", Asset.Url)
    return nil
end

function AssetCache:EnsureAll()
    table.clear(self.Failed)
    local Ready = self:EnsureFolders()
    if not self:EnsureAsset(Registry.Fonts.Main) then
        Ready = false
    end
    for _, Icon in pairs(Registry.Icons) do
        if not self:EnsureAsset(Icon) then
            Ready = false
        end
    end
    for _, Image in pairs(Registry.Images) do
        if not self:EnsureAsset(Image) then
            Ready = false
        end
    end
    self.Ready = Ready
    return Ready
end

function AssetCache:GetCustomAsset(Path: string): string?
    if type(getcustomasset) ~= "function" then
        return nil
    end
    if not self:FileExists(Path) then
        return nil
    end
    local Ok, Value = pcall(getcustomasset, Path)
    if Ok then
        return Value
    end
    return nil
end

return AssetCache
