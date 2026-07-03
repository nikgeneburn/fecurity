--!strict

local BaseWidget = require("@fec/widgets/BaseWidget")
local Elements = require("@fec/render/Elements")
local Styling = require("@fec/render/Styling")
local FontLoader = require("@fec/assets/FontLoader")

local Label = {}
Label.__index = Label
setmetatable(Label, { __index = BaseWidget })

function Label.New(Section: any, Options: { [string]: any })
    local self = BaseWidget.New(Section, Options, Options.Height or 22)
    setmetatable(self, Label)
    local Theme = self.Window.Theme
    local Text = Elements.New("TextLabel", {
        Name = "Text",
        Size = UDim2.fromScale(1, 1),
        Text = Options.Text or "",
        ZIndex = 31,
    }, self.Root) :: TextLabel
    Styling.ApplyText(Text, Theme, 11, Options.Tone == "muted" and Theme.Muted or Theme.Text)
    FontLoader.Apply(Text, self.Library.AssetCache)
    self.Text = Text
    self:BindTheme(function(NewTheme)
        Text.TextColor3 = Options.Tone == "muted" and NewTheme.Muted or NewTheme.Text
    end)
    return self
end

return Label
