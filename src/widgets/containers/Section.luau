--!strict

local Elements = require("@fec/render/Elements")
local Styling = require("@fec/render/Styling")
local FontLoader = require("@fec/assets/FontLoader")
local AutoLayout = require("@fec/layout/AutoLayout")
local WidgetFactory = require("@fec/widgets/WidgetFactory")

local Section = {}
Section.__index = Section

function Section.New(Column: any, Name: string, Options: { [string]: any }?)
    Options = Options or {}
    local NoHeader = Options.NoHeader == true
    local HeaderHeight = NoHeader and 0 or 28
    local self = setmetatable({
        Column = Column,
        Window = Column.Window,
        Name = Name,
        Order = 0,
    }, Section)

    local Root = Elements.New("Frame", {
        Name = Name,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -30, 0, 24),
        LayoutOrder = #Column.Sections + 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 23,
    }, Column.Scroll) :: Frame
    self.Root = Root

    if not NoHeader then
        local Header = Elements.New("TextLabel", {
            Name = "Header",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, HeaderHeight),
            Text = string.upper(Name),
            ZIndex = 24,
        }, Root) :: TextLabel
        Styling.ApplyText(Header, Column.Window.Theme, 10, Column.Window.Theme.Muted)
        FontLoader.Apply(Header, Column.Window.Library.AssetCache)
        self.Header = Header
    end

    local Body = Elements.New("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 24,
    }, Root) :: Frame
    Body.Position = UDim2.fromOffset(0, HeaderHeight)
    self.Body = Body

    local RootLayout = AutoLayout.Vertical(Root, 0)
    self.RootLayout = RootLayout
    self.BodyLayout = AutoLayout.Vertical(Body, 0)
    AutoLayout.ResizeToContent(Root, RootLayout, 0)

    return self
end

function Section:NextOrder(): number
    self.Order += 1
    return self.Order
end

function Section:AddDivider(Text: string)
    return WidgetFactory.Create("Label", self, { Text = string.upper(Text), Tone = "muted", Height = 28, SkipFlag = true })
end

function Section:AddLabel(Options: { [string]: any })
    return WidgetFactory.Create("Label", self, Options)
end

function Section:AddToggle(Options: { [string]: any })
    return WidgetFactory.Create("Toggle", self, Options)
end

function Section:AddSlider(Options: { [string]: any })
    return WidgetFactory.Create("Slider", self, Options)
end

function Section:AddDropdown(Options: { [string]: any })
    return WidgetFactory.Create("Dropdown", self, Options)
end

function Section:AddList(Options: { [string]: any })
    return self:AddDropdown(Options)
end

function Section:AddButton(Options: { [string]: any })
    return WidgetFactory.Create("Button", self, Options)
end

function Section:AddTextbox(Options: { [string]: any })
    return WidgetFactory.Create("Textbox", self, Options)
end

function Section:AddBox(Options: { [string]: any })
    return self:AddTextbox(Options)
end

function Section:AddKeybind(Options: { [string]: any })
    return WidgetFactory.Create("Keybind", self, Options)
end

function Section:AddBind(Options: { [string]: any })
    return self:AddKeybind(Options)
end

function Section:AddColor(Options: { [string]: any })
    return WidgetFactory.Create("ColorPicker", self, Options)
end

function Section:AddHitboxPreview(Options: { [string]: any })
    return WidgetFactory.Create("HitboxPreview", self, Options)
end

function Section:AddCountdown(Options: { [string]: any })
    return WidgetFactory.Create("Countdown", self, Options)
end

function Section:AddConfigList(Options: { [string]: any })
    return WidgetFactory.Create("ConfigList", self, Options)
end

return Section
