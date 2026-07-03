--!strict

local Registry = require("@fec/core/Registry")
local Safety = require("@fec/core/Safety")
local AssetCache = require("@fec/assets/AssetCache")
local AssetRegistry = require("@fec/assets/AssetRegistry")
local FlagManager = require("@fec/config/FlagManager")
local ConfigManager = require("@fec/config/ConfigManager")
local Window = require("@fec/widgets/window/Window")

local Library = {}
Library.__index = Library

function Library.New()
    local self = setmetatable({
        Version = "0.1.0",
        Windows = {},
        ConfigWidgets = {},
        AssetCache = AssetCache.New(),
        AssetRegistry = AssetRegistry,
        FlagManager = FlagManager.New(),
    }, Library)
    self.Flags = self.FlagManager.Values
    self.ConfigManager = ConfigManager.New(self.FlagManager)
    self.AssetCache:EnsureAll()
    self.RegistryEntry = Registry.Claim(self.Version, function()
        self:Unload()
    end)
    return self
end

function Library:RunCallback(Scope: string, Callback: ((...any) -> ...any)?, ...)
    Safety.Callback(Scope, Callback, ...)
end

function Library:CreateWindow(Options: { [string]: any })
    local NewWindow = Window.New(self, Options or {})
    table.insert(self.Windows, NewWindow)
    return NewWindow
end

function Library:Notify(Options: { [string]: any })
    local Target = self.Windows[1]
    if Target then
        return Target:Notify(Options)
    end
    return nil
end

function Library:AddWarning(Options: { [string]: any })
    local Target = self.Windows[1]
    if Target then
        return Target:AddWarning(Options)
    end
    return nil
end

function Library:SaveConfig(Name: string)
    local Saved = self.ConfigManager:Save(Name)
    if Saved then
        self:RefreshConfigLists(Name)
    end
    return Saved
end

function Library:LoadConfig(Name: string, RunCallbacks: boolean?)
    local Loaded = self.ConfigManager:Load(Name, RunCallbacks)
    if Loaded then
        self:RefreshConfigLists(Name)
    end
    return Loaded
end

function Library:GetConfigs()
    return self.ConfigManager:GetConfigs()
end

function Library:RegisterConfigList(Widget: any)
    table.insert(self.ConfigWidgets, Widget)
end

function Library:RefreshConfigLists(SelectedName: string?)
    for Index = #self.ConfigWidgets, 1, -1 do
        local Widget = self.ConfigWidgets[Index]
        if not Widget.Root or not Widget.Root.Parent then
            table.remove(self.ConfigWidgets, Index)
        elseif Widget.RefreshConfigs then
            Widget:RefreshConfigs(SelectedName)
        end
    end
end

function Library:SetAccent(Color: Color3)
    for _, WindowObject in ipairs(self.Windows) do
        WindowObject:SetAccent(Color)
    end
end

function Library:SetAssetBaseUrl(BaseUrl: string)
    self.AssetRegistry.SetBaseUrl(BaseUrl)
    return self.AssetCache:EnsureAll()
end

function Library:SetTheme(NameOrTheme: any)
    for _, WindowObject in ipairs(self.Windows) do
        WindowObject:SetTheme(NameOrTheme)
    end
    return true
end

function Library:Toggle()
    for _, WindowObject in ipairs(self.Windows) do
        WindowObject:Toggle()
    end
end

function Library:Open()
    for _, WindowObject in ipairs(self.Windows) do
        WindowObject:Open()
    end
end

function Library:Close()
    for _, WindowObject in ipairs(self.Windows) do
        WindowObject:Close()
    end
end

function Library:Unload()
    for _, WindowObject in ipairs(self.Windows) do
        WindowObject:Destroy()
    end
    table.clear(self.Windows)
    table.clear(self.ConfigWidgets)
    Registry.Clear(self.RegistryEntry)
end

return Library
