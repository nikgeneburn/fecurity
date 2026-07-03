--!strict

local BaseWidget = require("@fec/widgets/BaseWidget")
local Elements = require("@fec/render/Elements")
local Styling = require("@fec/render/Styling")
local FontLoader = require("@fec/assets/FontLoader")
local Palette = require("@fec/theme/Palette")
local Tween = require("@fec/animation/Tween")

local Button = {}
Button.__index = Button
setmetatable(Button, { __index = BaseWidget })

function Button.New(Section: any, Options: { [string]: any })
    local self = BaseWidget.New(Section, Options, Options.Height or 40)
    setmetatable(self, Button)
    local Theme = self.Window.Theme
    local Base = Options.Tone == "danger" and Color3.fromRGB(166, 34, 24) or Theme.Accent
    local Control = Elements.New("TextButton", {
        Name = "Button",
        AutoButtonColor = false,
        BackgroundColor3 = Base,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 6),
        Size = UDim2.new(1, 0, 0, 26),
        Text = Options.Text or "BUTTON",
        ZIndex = 31,
    }, self.Root) :: TextButton
    Styling.ApplyText(Control, Theme, 12, Theme.Text)
    FontLoader.Apply(Control, self.Library.AssetCache)
    Control.TextXAlignment = Enum.TextXAlignment.Center
    Styling.FitText(Control, 12, 9)
    self.Control = Control
    self.BaseColor = Base

    Control.MouseButton1Down:Connect(function()
        Tween.Play(Control, 0.08, { BackgroundColor3 = Palette.Lighten(self.BaseColor, 0.16) })
    end)
    Control.MouseButton1Up:Connect(function()
        Tween.Play(Control, 0.12, { BackgroundColor3 = self.BaseColor })
    end)
    Control.MouseLeave:Connect(function()
        Tween.Play(Control, 0.12, { BackgroundColor3 = self.BaseColor })
    end)
    Control.MouseButton1Click:Connect(function()
        self.Library:RunCallback(Options.Text or "Button", self.Callback)
    end)

    self:BindTheme(function(NewTheme)
        if Options.Tone ~= "danger" then
            self.BaseColor = NewTheme.Accent
            Control.BackgroundColor3 = self.BaseColor
        end
        Control.TextColor3 = NewTheme.Text
    end)
    return self
end

return Button
