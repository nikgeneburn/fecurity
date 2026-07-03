--!strict

local UserInputService = game:GetService("UserInputService")
local BaseWidget = require("@fec/widgets/BaseWidget")
local Elements = require("@fec/render/Elements")
local Styling = require("@fec/render/Styling")
local FontLoader = require("@fec/assets/FontLoader")
local KeybindManager = require("@fec/input/KeybindManager")

local Keybind = {}
Keybind.__index = Keybind
setmetatable(Keybind, { __index = BaseWidget })

function Keybind.New(Section: any, Options: { [string]: any })
    Options.Default = Options.Default or Options.Value or "None"
    local ActivationCallback = Options.Callback or Options.OnPressed
    Options.Callback = Options.Changed or Options.OnChanged
    local self = BaseWidget.New(Section, Options, 60)
    setmetatable(self, Keybind)
    self.ActivationCallback = ActivationCallback
    local Theme = self.Window.Theme

    local Title = Elements.New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -92, 0, 16),
        Text = Options.Text or "Keybind",
        ZIndex = 31,
    }, self.Root) :: TextLabel
    Styling.ApplyText(Title, Theme, 14, Theme.Text)
    FontLoader.Apply(Title, self.Library.AssetCache)

    local Hint = Elements.New("TextLabel", {
        Name = "Hint",
        Position = UDim2.fromOffset(0, 15),
        Size = UDim2.new(1, -92, 0, 14),
        Text = Options.Hint or "",
        ZIndex = 31,
    }, self.Root) :: TextLabel
    Styling.ApplyText(Hint, Theme, 13, Theme.Hint)
    FontLoader.Apply(Hint, self.Library.AssetCache)

    local Box = Elements.New("TextButton", {
        Name = "Box",
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Theme.Control,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 1),
        Size = UDim2.fromOffset(90, 20),
        Text = tostring(self.Value),
        ZIndex = 32,
    }, self.Root) :: TextButton
    Styling.ApplyText(Box, Theme, 14, Theme.Text)
    FontLoader.Apply(Box, self.Library.AssetCache)
    Box.TextXAlignment = Enum.TextXAlignment.Center
    Styling.FitText(Box, 14, 11)
    self.Box = Box

    Box.MouseButton1Click:Connect(function()
        self:Listen()
    end)

    self.ActivationConnection = UserInputService.InputBegan:Connect(function(Input, Processed)
        if Processed or self.Listening then
            return
        end
        if KeybindManager.IsActivation(Input, self.Value) then
            self.Library:RunCallback(Options.Text or "Keybind", self.ActivationCallback, self.Value, Input)
        end
    end)
    self.DestroyConnection = self.Root.Destroying:Connect(function()
        self:DisconnectInputs()
    end)

    self:BindTheme(function(NewTheme)
        Title.TextColor3 = NewTheme.Text
        Hint.TextColor3 = NewTheme.Hint
        Box.BackgroundColor3 = NewTheme.Control
        Box.TextColor3 = NewTheme.Text
    end)
    self:SetValue(self.Value, false)
    return self
end

function Keybind:Listen()
    if self.Listening then
        return
    end
    self.Listening = true
    self.Box.Text = "..."
    self.Box.BackgroundColor3 = self.Window.Theme.ControlHover
    if self.ListenConnection then
        self.ListenConnection:Disconnect()
    end
    self.ListenConnection = UserInputService.InputBegan:Connect(function(Input, Processed)
        if Processed then
            return
        end
        self.ListenConnection:Disconnect()
        self.ListenConnection = nil
        self.Listening = false
        self.Box.BackgroundColor3 = self.Window.Theme.Control
        self:SetValue(KeybindManager.Normalize(Input))
    end)
end

function Keybind:SetValue(Value: any, RunCallback: boolean?)
    self:Commit(KeybindManager.Normalize(Value or "None"), RunCallback)
    self.Box.Text = self.Value
end

function Keybind:DisconnectInputs()
    if self.ListenConnection then
        self.ListenConnection:Disconnect()
        self.ListenConnection = nil
    end
    if self.ActivationConnection then
        self.ActivationConnection:Disconnect()
        self.ActivationConnection = nil
    end
    if self.DestroyConnection then
        self.DestroyConnection:Disconnect()
        self.DestroyConnection = nil
    end
end

function Keybind:Destroy()
    self:DisconnectInputs()
    BaseWidget.Destroy(self)
end

return Keybind
