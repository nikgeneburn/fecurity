--!strict

local Safety = require("@fec/core/Safety")

local FlagManager = {}
FlagManager.__index = FlagManager

function FlagManager.New()
    return setmetatable({
        Values = {},
        Widgets = {},
        SkipFlags = {},
    }, FlagManager)
end

function FlagManager:Register(Flag: string?, Widget: any, Default: any, SkipFlag: boolean?)
    if not Flag then
        return
    end
    if SkipFlag then
        self.SkipFlags[Flag] = true
    else
        self.SkipFlags[Flag] = nil
        self.Widgets[Flag] = Widget
    end
    if self.Values[Flag] == nil then
        self.Values[Flag] = Default
    end
end

function FlagManager:Unregister(Flag: string?, Widget: any?)
    if not Flag then
        return
    end
    if Widget == nil or self.Widgets[Flag] == Widget then
        self.Widgets[Flag] = nil
    end
end

function FlagManager:Set(Flag: string?, Value: any)
    if not Flag then
        return
    end
    self.Values[Flag] = Value
end

function FlagManager:Get(Flag: string, Default: any?): any
    local Value = self.Values[Flag]
    if Value == nil then
        return Default
    end
    return Value
end

function FlagManager:Export(): { [string]: any }
    local Values = {}
    for Flag, Value in pairs(self.Values) do
        if self.SkipFlags[Flag] ~= true then
            Values[Flag] = Value
        end
    end
    return Values
end

function FlagManager:Load(Values: { [string]: any }, RunCallbacks: boolean?)
    for Flag, Value in pairs(Values) do
        if self.SkipFlags[Flag] ~= true then
            self.Values[Flag] = Value
            local Widget = self.Widgets[Flag]
            if Widget and Widget.SetValue then
                Safety.Try("FlagManager.Load", function()
                    Widget:SetValue(Value, RunCallbacks == true)
                end)
            end
        end
    end
end

return FlagManager
