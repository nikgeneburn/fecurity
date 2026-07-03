--!strict

local Elements = require("@fec/render/Elements")
local AutoLayout = require("@fec/layout/AutoLayout")
local Tokens = require("@fec/theme/Tokens")
local Section = require("@fec/widgets/containers/Section")

local Column = {}
Column.__index = Column

function Column.New(Tab: any, Index: number)
    local Window = Tab.Window
    local self = setmetatable({
        Tab = Tab,
        Window = Window,
        Index = Index,
        Sections = {},
    }, Column)

    local Root = Elements.New("Frame", {
        Name = "Column" .. tostring(Index),
        BackgroundColor3 = Window.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, Tokens.PanelTop),
        Size = UDim2.fromOffset(Tokens.PanelWidth, Tokens.PanelHeight),
        ZIndex = 21,
    }, Window.Content) :: Frame
    self.Stroke = Elements.Stroke(Root, Window.Theme.Border, 0, 1)
    self.Root = Root

    local Scroll = Elements.New("ScrollingFrame", {
        Name = "Scroll",
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromScale(1, 1),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Window.Theme.Accent,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 22,
    }, Root) :: ScrollingFrame
    Elements.Padding(Scroll, 15, 16, 15, 16)
    local Layout = AutoLayout.Vertical(Scroll, 0)
    self.Scroll = Scroll
    self.Layout = Layout
    self:ApplyLayout(Index, 1)
    Window:RegisterThemeBinding(function(Theme)
        Root.BackgroundColor3 = Theme.Surface
        self.Stroke.Color = Theme.Border
        Scroll.ScrollBarImageColor3 = Theme.Accent
    end)

    return self
end

function Column:ApplyLayout(Index: number, Count: number)
    self.Index = Index
    local TargetSize = self.Window.TargetSize or UDim2.fromOffset(Tokens.WindowSize.X, Tokens.WindowSize.Y)
    local WindowWidth = TargetSize.X.Offset > 0 and TargetSize.X.Offset or Tokens.WindowSize.X
    local WindowHeight = TargetSize.Y.Offset > 0 and TargetSize.Y.Offset or Tokens.WindowSize.Y
    local X, Width = Tokens.PanelLayout(Index, Count, WindowWidth)
    self.Root.Position = UDim2.fromOffset(X, Tokens.PanelTop)
    self.Root.Size = UDim2.fromOffset(Width, Tokens.PanelHeightFor(WindowHeight))
end

function Column:AddSection(Name: string, Options: { [string]: any }?)
    local NewSection = Section.New(self, Name, Options)
    table.insert(self.Sections, NewSection)
    return NewSection
end

return Column
