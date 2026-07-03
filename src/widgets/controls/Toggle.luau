--!strict

local BaseWidget = require("@fec/widgets/BaseWidget")
local Elements = require("@fec/render/Elements")
local Styling = require("@fec/render/Styling")
local FontLoader = require("@fec/assets/FontLoader")
local Tween = require("@fec/animation/Tween")

local Toggle = {}
Toggle.__index = Toggle
setmetatable(Toggle, { __index = BaseWidget })

function Toggle.New(Section: any, Options: { [string]: any })
    Options.Default = Options.Default == true
    local self = BaseWidget.New(Section, Options, 40)
    setmetatable(self, Toggle)
    local Theme = self.Window.Theme

    local Title = Elements.New("TextLabel", {
        Name = "Title",
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, -44, 0, 16),
        Text = Options.Text or "Toggle",
        ZIndex = 31,
    }, self.Root) :: TextLabel
    Styling.ApplyText(Title, Theme, 10, Theme.Text)
    FontLoader.Apply(Title, self.Library.AssetCache)
    self.Title = Title

    local Hint = Elements.New("TextLabel", {
        Name = "Hint",
        Position = UDim2.fromOffset(0, 15),
        Size = UDim2.new(1, -44, 0, 14),
        Text = Options.Hint or "",
        ZIndex = 31,
    }, self.Root) :: TextLabel
    Styling.ApplyText(Hint, Theme, 9, Theme.Hint)
    FontLoader.Apply(Hint, self.Library.AssetCache)
    self.Hint = Hint

    local Track = Elements.New("Frame", {
        Name = "Track",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -1, 0, 5),
        Size = UDim2.fromOffset(26, 16),
        BackgroundColor3 = Theme.ToggleOff,
        BorderSizePixel = 0,
        ZIndex = 32,
    }, self.Root) :: Frame
    Elements.Corner(Track, 8)
    self.Track = Track

    local Knob = Elements.New("Frame", {
        Name = "Knob",
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = Theme.ToggleKnobOff,
        BorderSizePixel = 0,
        ZIndex = 33,
    }, Track) :: Frame
    Elements.Corner(Knob, 6)
    self.Knob = Knob

    local Hit = Elements.New("TextButton", {
        Name = "Hitbox",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        ZIndex = 34,
    }, self.Root) :: TextButton
    Hit.MouseButton1Click:Connect(function()
        self:SetValue(not self.Value)
    end)
    self.Hit = Hit

    self:BindTheme(function(NewTheme)
        Title.TextColor3 = NewTheme.Text
        Hint.TextColor3 = NewTheme.Hint
        Track.BackgroundColor3 = self.Value and NewTheme.ControlHover or NewTheme.ToggleOff
        Knob.BackgroundColor3 = self.Value and NewTheme.Accent or NewTheme.ToggleKnobOff
    end)
    self:SetValue(self.Value, false)
    return self
end

function Toggle:SetValue(Value: any, RunCallback: boolean?)
    local On = Value == true
    self:Commit(On, RunCallback)
    local Theme = self.Window.Theme
    Tween.Play(self.Track, 0.12, { BackgroundColor3 = On and Theme.ControlHover or Theme.ToggleOff })
    Tween.Play(self.Knob, 0.12, {
        BackgroundColor3 = On and Theme.Accent or Theme.ToggleKnobOff,
        Position = On and UDim2.fromOffset(13, 2) or UDim2.fromOffset(2, 2),
    })
end

return Toggle
