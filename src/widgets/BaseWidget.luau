--!strict

local Elements = require("@fec/render/Elements")

local BaseWidget = {}
BaseWidget.__index = BaseWidget

function BaseWidget.New(Section: any, Options: { [string]: any }, Height: number)
    local self = setmetatable({
        Section = Section,
        Window = Section.Window,
        Library = Section.Window.Library,
        Options = Options,
        Flag = Options.Flag,
        SkipFlag = Options.SkipFlag == true,
        Value = Options.Default,
        Callback = Options.Callback,
        ThemeUnbinds = {},
    }, BaseWidget)

    self.Root = Elements.New("Frame", {
        Name = Options.Text or "Widget",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Height),
        LayoutOrder = Section:NextOrder(),
        ZIndex = 30,
    }, Section.Body) :: Frame

    if self.Flag then
        self.Library.FlagManager:Register(self.Flag, self, self.Value, self.SkipFlag)
        local Stored = self.Library.FlagManager:Get(self.Flag, nil)
        if Stored ~= nil then
            self.Value = Stored
        end
    end
    self.FlagDestroyConnection = self.Root.Destroying:Connect(function()
        self:UnregisterFlag()
    end)
    self.ThemeDestroyConnection = self.Root.Destroying:Connect(function()
        self:UnbindTheme()
    end)

    return self
end

function BaseWidget:UnbindTheme()
    for _, Unbind in ipairs(self.ThemeUnbinds) do
        pcall(Unbind)
    end
    table.clear(self.ThemeUnbinds)
    if self.ThemeDestroyConnection then
        self.ThemeDestroyConnection:Disconnect()
        self.ThemeDestroyConnection = nil
    end
end

function BaseWidget:UnregisterFlag()
    if self.Flag then
        self.Library.FlagManager:Unregister(self.Flag, self)
    end
    if self.FlagDestroyConnection then
        self.FlagDestroyConnection:Disconnect()
        self.FlagDestroyConnection = nil
    end
end

function BaseWidget:Commit(Value: any, RunCallback: boolean?)
    self.Value = Value
    self.Library.FlagManager:Set(self.Flag, Value)
    if RunCallback ~= false then
        self.Library:RunCallback(self.Options.Text or "Widget", self.Callback, Value, self.Alpha)
    end
end

function BaseWidget:SetValue(Value: any, RunCallback: boolean?)
    self:Commit(Value, RunCallback)
end

function BaseWidget:Destroy()
    self:UnregisterFlag()
    self:UnbindTheme()
    if self.Root then
        self.Root:Destroy()
    end
end

function BaseWidget:BindTheme(Binding: (any) -> ())
    if self.Window and self.Window.RegisterThemeBinding then
        local Unbind = self.Window:RegisterThemeBinding(Binding)
        if Unbind then
            table.insert(self.ThemeUnbinds, Unbind)
        end
    end
end

function BaseWidget:AddColor(Options: { [string]: any })
    return self.Section:AddColor(Options)
end

function BaseWidget:AddBind(Options: { [string]: any })
    return self.Section:AddBind(Options)
end

return BaseWidget
