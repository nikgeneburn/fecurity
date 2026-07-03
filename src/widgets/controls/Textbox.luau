--!strict

local BaseWidget = require("@fec/widgets/BaseWidget")
local Elements = require("@fec/render/Elements")
local Styling = require("@fec/render/Styling")
local FontLoader = require("@fec/assets/FontLoader")

local Textbox = {}
Textbox.__index = Textbox
setmetatable(Textbox, { __index = BaseWidget })

function Textbox.New(Section: any, Options: { [string]: any })
    Options.Default = Options.Default or ""
    local self = BaseWidget.New(Section, Options, 52)
    setmetatable(self, Textbox)
    local Theme = self.Window.Theme

    local Title = Elements.New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 16),
        Text = Options.Text or "Textbox",
        ZIndex = 31,
    }, self.Root) :: TextLabel
    Styling.ApplyText(Title, Theme, 14, Theme.Text)
    FontLoader.Apply(Title, self.Library.AssetCache)

    local Box = Elements.New("TextBox", {
        Name = "Box",
        BackgroundColor3 = Theme.Control,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Position = UDim2.fromOffset(0, 22),
        Size = UDim2.new(1, 0, 0, 24),
        Text = tostring(self.Value),
        ZIndex = 32,
    }, self.Root) :: TextBox
    Styling.ApplyText(Box, Theme, 14, Theme.Text)
    FontLoader.Apply(Box, self.Library.AssetCache)
    Box.TextXAlignment = Enum.TextXAlignment.Left
    self.Box = Box

    Box.FocusLost:Connect(function()
        self:SetValue(Box.Text)
    end)

    self:BindTheme(function(NewTheme)
        Title.TextColor3 = NewTheme.Text
        Box.BackgroundColor3 = NewTheme.Control
        Box.TextColor3 = NewTheme.Text
    end)
    return self
end

function Textbox:SetValue(Value: any, RunCallback: boolean?)
    self:Commit(tostring(Value or ""), RunCallback)
    if self.Box.Text ~= self.Value then
        self.Box.Text = self.Value
    end
end

return Textbox
