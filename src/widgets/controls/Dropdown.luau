--!strict

local BaseWidget = require("@fec/widgets/BaseWidget")
local Elements = require("@fec/render/Elements")
local Styling = require("@fec/render/Styling")
local FontLoader = require("@fec/assets/FontLoader")
local Tween = require("@fec/animation/Tween")

local Dropdown = {}
Dropdown.__index = Dropdown
setmetatable(Dropdown, { __index = BaseWidget })

local function Contains(List: { any }, Value: any): boolean
    for _, Item in ipairs(List) do
        if Item == Value then
            return true
        end
    end
    return false
end

local function Display(Value: any): string
    if type(Value) == "table" then
        return #Value > 0 and table.concat(Value, ", ") or "None"
    end
    return tostring(Value or "None")
end

function Dropdown.New(Section: any, Options: { [string]: any })
    Options.Values = Options.Values or Options.Options or {}
    local ProvidedDefault = if Options.Default ~= nil then Options.Default else Options.Value
    if Options.Multi then
        Options.Default = ProvidedDefault
        if Options.Default == nil then
            Options.Default = {}
        elseif type(Options.Default) ~= "table" then
            Options.Default = { Options.Default }
        end
    else
        Options.Default = ProvidedDefault or Options.Values[1] or "None"
    end
    if Options.Multi and type(Options.Default) ~= "table" then
        Options.Default = { Options.Default }
    end
    local self = BaseWidget.New(Section, Options, 72)
    setmetatable(self, Dropdown)
    local Theme = self.Window.Theme

    local Title = Elements.New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 16),
        Text = Options.Text or "Dropdown",
        ZIndex = 31,
    }, self.Root) :: TextLabel
    Styling.ApplyText(Title, Theme, 12, Theme.Text)
    FontLoader.Apply(Title, self.Library.AssetCache)

    local Hint = Elements.New("TextLabel", {
        Name = "Hint",
        Position = UDim2.fromOffset(0, 15),
        Size = UDim2.new(1, 0, 0, 14),
        Text = Options.Hint or "",
        ZIndex = 31,
    }, self.Root) :: TextLabel
    Styling.ApplyText(Hint, Theme, 11, Theme.Hint)
    FontLoader.Apply(Hint, self.Library.AssetCache)

    local Box = Elements.New("TextButton", {
        Name = "Box",
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Control,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 32),
        Size = UDim2.new(1, 0, 0, 26),
        Text = "",
        ZIndex = 32,
    }, self.Root) :: TextButton
    self.Box = Box
    Elements.Stroke(Box, Theme.Border, 0.45, 1)

    local Value = Elements.New("TextLabel", {
        Name = "Value",
        Position = UDim2.fromOffset(18, 0),
        Size = UDim2.new(1, -42, 1, 0),
        Text = "",
        ZIndex = 33,
    }, Box) :: TextLabel
    Styling.ApplyText(Value, Theme, 12, Theme.Text)
    FontLoader.Apply(Value, self.Library.AssetCache)
    Styling.FitText(Value, 12, 9)
    self.ValueLabel = Value

    local Arrow = Elements.New("TextLabel", {
        Name = "Arrow",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 0),
        Size = UDim2.fromOffset(12, 26),
        Text = "v",
        ZIndex = 33,
    }, Box) :: TextLabel
    Styling.ApplyText(Arrow, Theme, 12, Theme.Muted)
    FontLoader.Apply(Arrow, self.Library.AssetCache)
    Arrow.TextXAlignment = Enum.TextXAlignment.Center
    self.Arrow = Arrow

    Box.MouseButton1Click:Connect(function()
        self:ToggleMenu()
    end)
    Box.MouseEnter:Connect(function()
        Tween.Play(Box, 0.12, { BackgroundColor3 = self.Window.Theme.ControlHover })
    end)
    Box.MouseLeave:Connect(function()
        Tween.Play(Box, 0.12, { BackgroundColor3 = self.Window.Theme.Control })
    end)
    self.DestroyConnection = self.Root.Destroying:Connect(function()
        self:CloseMenu(true)
    end)

    self:BindTheme(function(NewTheme)
        Title.TextColor3 = NewTheme.Text
        Hint.TextColor3 = NewTheme.Hint
        Box.BackgroundColor3 = NewTheme.Control
        Value.TextColor3 = NewTheme.Text
        Arrow.TextColor3 = NewTheme.Muted
        self:RefreshRows()
    end)
    self:SetValue(self.Value, false)
    return self
end

function Dropdown:CloseMenu(Immediate: boolean?)
    local Menu = self.Menu
    if Menu then
        self.Menu = nil
        self.OptionRows = nil
        if Immediate then
            Menu:Destroy()
        else
            local CloseTween = Tween.Play(Menu, 0.12, {
                Size = UDim2.fromOffset(Menu.AbsoluteSize.X, 0),
                BackgroundTransparency = 0.15,
            }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            CloseTween.Completed:Connect(function()
                if Menu and Menu.Parent then
                    Menu:Destroy()
                end
            end)
        end
    end
    if self.Window.Dropdown == self then
        self.Window.Dropdown = nil
    end
    if self.Arrow and self.Arrow.Parent then
        if Immediate then
            self.Arrow.Rotation = 0
        else
            Tween.Play(self.Arrow, 0.12, { Rotation = 0 })
        end
    end
end

function Dropdown:ToggleMenu()
    if self.Menu then
        self:CloseMenu()
    else
        self:OpenMenu()
    end
end

function Dropdown:OpenMenu()
    if self.Window.Dropdown and self.Window.Dropdown ~= self then
        self.Window.Dropdown:CloseMenu()
    end
    if self.Options.GetValues then
        local Ok, Values = pcall(self.Options.GetValues)
        if Ok and type(Values) == "table" then
            self.Options.Values = Values
        end
    end
    self.Window.Dropdown = self
    local Theme = self.Window.Theme
    local RootPosition = self.Window.Root.AbsolutePosition
    local BoxPosition = self.Box.AbsolutePosition
    local RowHeight = 24
    local OpenHeight = math.max(RowHeight, math.min(#self.Options.Values, 7) * RowHeight)
    local Menu = Elements.New("Frame", {
        Name = "DropdownMenu",
        BackgroundColor3 = Theme.ControlHover,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(BoxPosition.X - RootPosition.X, BoxPosition.Y - RootPosition.Y + self.Box.AbsoluteSize.Y + 2),
        Size = UDim2.fromOffset(self.Box.AbsoluteSize.X, 0),
        ZIndex = 210,
    }, self.Window.Overlay) :: Frame
    Elements.Stroke(Menu, Theme.Border, 0, 1)
    self.Menu = Menu
    self.OptionRows = {}
    Tween.Play(Menu, 0.14, {
        Size = UDim2.fromOffset(self.Box.AbsoluteSize.X, OpenHeight),
        BackgroundTransparency = 0,
    })
    Tween.Play(self.Arrow, 0.14, { Rotation = 180 })

    local Scroll = Elements.New("ScrollingFrame", {
        Name = "Options",
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, #self.Options.Values * RowHeight),
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarThickness = #self.Options.Values > 7 and 2 or 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 211,
    }, Menu) :: ScrollingFrame

    for Index, Option in ipairs(self.Options.Values) do
        local Row = Elements.New("TextButton", {
            Name = "Option" .. tostring(Index),
            AutoButtonColor = false,
            BackgroundColor3 = Theme.ControlHover,
            BackgroundTransparency = 0.08,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, (Index - 1) * RowHeight),
            Size = UDim2.new(1, -2, 0, RowHeight),
            Text = "",
            ZIndex = 211,
        }, Scroll) :: TextButton
        local Indicator = Elements.New("Frame", {
            Name = "Indicator",
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(9, 12),
            Size = UDim2.fromOffset(5, 5),
            ZIndex = 212,
        }, Row) :: Frame
        Elements.Corner(Indicator, 4)
        local Label = Elements.New("TextLabel", {
            Name = "Label",
            Position = UDim2.fromOffset(20, 0),
            Size = UDim2.new(1, -30, 1, 0),
            Text = tostring(Option),
            ZIndex = 212,
        }, Row) :: TextLabel
        Styling.ApplyText(Label, Theme, 12, Theme.Text)
        FontLoader.Apply(Label, self.Library.AssetCache)
        self.OptionRows[Index] = {
            Option = Option,
            Row = Row,
            Label = Label,
            Indicator = Indicator,
        }
        Row.MouseEnter:Connect(function()
            Tween.Play(Row, 0.1, { BackgroundColor3 = Theme.Control })
        end)
        Row.MouseLeave:Connect(function()
            Tween.Play(Row, 0.12, { BackgroundColor3 = self.Window.Theme.ControlHover })
        end)
        Row.MouseButton1Click:Connect(function()
            Tween.Press(Row, Theme.Control, Theme.ControlHover)
            if self.Options.Multi then
                local Next = table.clone(self.Value)
                if Contains(Next, Option) then
                    for I = #Next, 1, -1 do
                        if Next[I] == Option then
                            table.remove(Next, I)
                        end
                    end
                else
                    table.insert(Next, Option)
                end
                self:SetValue(Next)
                self:RefreshRows()
            else
                self:SetValue(Option)
                self:CloseMenu()
            end
        end)
    end
    self:RefreshRows()
end

function Dropdown:SetValue(Value: any, RunCallback: boolean?)
    if self.Options.Multi and type(Value) ~= "table" then
        Value = { Value }
    end
    self:Commit(Value, RunCallback)
    self.ValueLabel.Text = Display(Value)
end

function Dropdown:SetValues(Values: { any }, PreferredValue: any?)
    self.Options.Values = Values or {}
    local NextValue = PreferredValue or self.Value
    if self.Options.Multi then
        local Source = if type(NextValue) == "table" then NextValue else { NextValue }
        local Filtered = {}
        for _, Item in ipairs(Source) do
            if Contains(self.Options.Values, Item) then
                table.insert(Filtered, Item)
            end
        end
        self:SetValue(Filtered, false)
    elseif not Contains(self.Options.Values, NextValue) then
        self:SetValue(self.Options.Values[1] or "None", false)
    else
        self:SetValue(NextValue, false)
    end
    if self.Menu then
        local OldMenu = self.Menu
        self.Menu = nil
        self.OptionRows = nil
        OldMenu:Destroy()
        self:OpenMenu()
    else
        self:RefreshRows()
    end
end

function Dropdown:RefreshRows()
    if not self.OptionRows then
        return
    end
    local Theme = self.Window.Theme
    for _, Record in ipairs(self.OptionRows) do
        local Selected = if self.Options.Multi then Contains(self.Value, Record.Option) else self.Value == Record.Option
        Record.Indicator.BackgroundColor3 = Theme.Accent
        Record.Indicator.BackgroundTransparency = Selected and 0 or 1
        Record.Label.TextColor3 = Selected and Theme.Text or Theme.Muted
        Record.Row.BackgroundColor3 = Theme.ControlHover
    end
    if self.Menu then
        self.Menu.BackgroundColor3 = Theme.ControlHover
    end
end

function Dropdown:Destroy()
    self:CloseMenu(true)
    if self.DestroyConnection then
        self.DestroyConnection:Disconnect()
        self.DestroyConnection = nil
    end
    BaseWidget.Destroy(self)
end

return Dropdown
