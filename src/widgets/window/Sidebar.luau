--!strict

local Elements = require("@fec/render/Elements")
local Gradients = require("@fec/render/Gradients")
local ImageLoader = require("@fec/assets/ImageLoader")
local Styling = require("@fec/render/Styling")
local FontLoader = require("@fec/assets/FontLoader")
local Tokens = require("@fec/theme/Tokens")

local Sidebar = {}
Sidebar.__index = Sidebar

function Sidebar.New(Window: any)
    local self = setmetatable({
        Window = Window,
        Buttons = {},
    }, Sidebar)

    local Root = Elements.New("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Window.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(Tokens.SidebarWidth, Tokens.WindowSize.Y),
        ZIndex = 22,
    }, Window.Root) :: Frame
    self.Stroke = Elements.Stroke(Root, Window.Theme.Border, 0, 1)
    self.Root = Root

    local Logo = Elements.New("ImageLabel", {
        Name = "Logo",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(8, 18),
        Size = UDim2.fromOffset(50, 48),
        ImageColor3 = Window.Theme.Accent,
        ZIndex = 24,
    }, Root) :: ImageLabel
    local HasLogo = ImageLoader.Apply(Logo, Window.Library.AssetCache, "Logo")
    local Gradient = Gradients.AccentVertical(Logo, Window.Theme.Accent)
    self.Logo = Logo
    self.LogoGradient = Gradient

    if not HasLogo then
        local Fallback = Elements.New("TextLabel", {
            Name = "LogoFallback",
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(8, 18),
            Size = UDim2.fromOffset(50, 48),
            Text = "F",
            ZIndex = 25,
        }, Root) :: TextLabel
        Styling.ApplyText(Fallback, Window.Theme, 28, Window.Theme.Accent)
        FontLoader.Apply(Fallback, Window.Library.AssetCache)
        Fallback.TextXAlignment = Enum.TextXAlignment.Center
        self.LogoFallback = Fallback
    end

    return self
end

function Sidebar:AddButton(TabObject: any)
    local Button = require("@fec/widgets/tab/TabButton").New(self.Window, TabObject, #self.Buttons + 1)
    table.insert(self.Buttons, Button)
    return Button
end

function Sidebar:RefreshTheme()
    self.Root.BackgroundColor3 = self.Window.Theme.Surface
    self.Stroke.Color = self.Window.Theme.Border
    self.Logo.ImageColor3 = self.Window.Theme.Accent
    Gradients.SetAccent(self.LogoGradient, self.Window.Theme.Accent)
    if self.LogoFallback then
        self.LogoFallback.TextColor3 = self.Window.Theme.Accent
    end
end

return Sidebar
