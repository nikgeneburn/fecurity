--!strict

local UserInputService = game:GetService("UserInputService")

local BaseWidget = require("@fec/widgets/BaseWidget")
local Elements = require("@fec/render/Elements")
local Styling = require("@fec/render/Styling")
local FontLoader = require("@fec/assets/FontLoader")
local Palette = require("@fec/theme/Palette")
local Utils = require("@fec/widgets/controls/ColorPickerUtils")

local ColorPicker = {}
ColorPicker.__index = ColorPicker
setmetatable(ColorPicker, { __index = BaseWidget })

function ColorPicker.New(Section: any, Options: { [string]: any })
    Options.Default = Options.Default or Options.Value or Color3.new(1, 1, 1)
    local self = BaseWidget.New(Section, Options, 40)
    setmetatable(self, ColorPicker)
    local Theme = self.Window.Theme
    self.PopupConnections = {}
    self.Alpha = math.clamp(tonumber(Options.Alpha or Options.DefaultAlpha) or 1, 0, 1)
    if self.Flag then
        local AlphaFlag = self.Flag .. ".Alpha"
        self.AlphaFlag = AlphaFlag
        local StoredAlpha = self.Library.FlagManager:Get(AlphaFlag, nil)
        if StoredAlpha ~= nil then
            self.Alpha = math.clamp(tonumber(StoredAlpha) or self.Alpha, 0, 1)
        end
        self.Library.FlagManager:Register(AlphaFlag, {
            SetValue = function(_, Value, RunCallback)
                self:SetAlpha(Value, RunCallback)
            end,
        }, self.Alpha, self.SkipFlag)
    end

    local Title = Elements.New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -44, 0, 16),
        Text = Options.Text or "Color",
        ZIndex = 31,
    }, self.Root) :: TextLabel
    Styling.ApplyText(Title, Theme, 10, Theme.Text)
    FontLoader.Apply(Title, self.Library.AssetCache)

    local Hint = Elements.New("TextLabel", {
        Name = "Hint",
        Position = UDim2.fromOffset(0, 15),
        Size = UDim2.new(1, -44, 0, 14),
        Text = Options.Hint or "",
        ZIndex = 31,
    }, self.Root) :: TextLabel
    Styling.ApplyText(Hint, Theme, 9, Theme.Hint)
    FontLoader.Apply(Hint, self.Library.AssetCache)

    local Swatch = Elements.New("TextButton", {
        Name = "Swatch",
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -1, 0, 5),
        Size = UDim2.fromOffset(15, 15),
        BackgroundColor3 = (Utils.ToColorAlpha(self.Value)),
        BorderSizePixel = 0,
        Text = "",
        ZIndex = 32,
    }, self.Root) :: TextButton
    Elements.Corner(Swatch, 8)
    Elements.Stroke(Swatch, Theme.Border, 0, 1)
    self.Swatch = Swatch

    Swatch.MouseButton1Click:Connect(function()
        self:TogglePicker()
    end)
    self.DestroyConnection = self.Root.Destroying:Connect(function()
        self:ClosePicker()
        if self.AlphaFlag then
            self.Library.FlagManager:Unregister(self.AlphaFlag)
        end
    end)

    self:BindTheme(function(NewTheme)
        Title.TextColor3 = NewTheme.Text
        Hint.TextColor3 = NewTheme.Hint
        if self.Popup then
            self.Popup.BackgroundColor3 = NewTheme.Surface
        end
        if self.Apply then
            self.Apply.BackgroundColor3 = NewTheme.Accent
            self.Apply.TextColor3 = NewTheme.Text
        end
        if self.Hex then
            self.Hex.BackgroundColor3 = NewTheme.Control
            self.Hex.TextColor3 = NewTheme.Text
        end
    end)

    self:SetValue(self.Value, false)
    return self
end

function ColorPicker:DisconnectPopup()
    for _, Connection in ipairs(self.PopupConnections) do
        Connection:Disconnect()
    end
    table.clear(self.PopupConnections)
end

function ColorPicker:Track(Connection: RBXScriptConnection)
    table.insert(self.PopupConnections, Connection)
    return Connection
end

function ColorPicker:ClosePicker()
    self:DisconnectPopup()
    self.DragTarget = nil
    if self.Popup then
        self.Popup:Destroy()
        self.Popup = nil
        self.Apply = nil
        self.Hex = nil
        self.Preview = nil
        self.Square = nil
        self.SquareCursor = nil
        self.HueCursor = nil
        self.AlphaBar = nil
        self.AlphaCursor = nil
    end
end

function ColorPicker:TogglePicker()
    if self.Popup then
        self:ClosePicker()
    else
        self:OpenPicker()
    end
end

function ColorPicker:CreateColorSquare(Parent: Instance, Theme: { [string]: any })
    local Square = Elements.New("Frame", {
        Name = "ColorSquare",
        BackgroundColor3 = Color3.fromHSV(self.Hue, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, 40),
        Size = UDim2.fromOffset(182, 182),
        ZIndex = 221,
    }, Parent) :: Frame
    self.Square = Square

    local White = Elements.New("Frame", {
        Name = "White",
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 222,
    }, Square) :: Frame
    Utils.AddGradient(White, ColorSequence.new(Color3.new(1, 1, 1)), NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    }))

    local Black = Elements.New("Frame", {
        Name = "Black",
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 223,
    }, Square) :: Frame
    Utils.AddGradient(Black, ColorSequence.new(Color3.new(0, 0, 0)), NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    }), 90)

    local Cursor = Elements.New("Frame", {
        Name = "Cursor",
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(7, 7),
        ZIndex = 224,
    }, Square) :: Frame
    Elements.Corner(Cursor, 4)
    Elements.Stroke(Cursor, Theme.Text, 0.4, 1)
    self.SquareCursor = Cursor

    self:Track(Square.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.DragTarget = "square"
            self:UpdateFromSquare()
        end
    end))
end

function ColorPicker:CreateHueBar(Parent: Instance, Theme: { [string]: any })
    local Bar = Elements.New("Frame", {
        Name = "Hue",
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, 232),
        Size = UDim2.fromOffset(182, 10),
        ZIndex = 221,
    }, Parent) :: Frame
    Utils.AddGradient(Bar, Utils.HueSequence)
    self.HueBar = Bar

    local Cursor = Elements.New("Frame", {
        Name = "HueCursor",
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(7, 7),
        ZIndex = 222,
    }, Bar) :: Frame
    Elements.Corner(Cursor, 4)
    Elements.Stroke(Cursor, Theme.Text, 0.4, 1)
    self.HueCursor = Cursor

    self:Track(Bar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.DragTarget = "hue"
            self:UpdateFromHue()
        end
    end))
end

function ColorPicker:CreateAlphaBar(Parent: Instance, Theme: { [string]: any })
    local Bar = Elements.New("Frame", {
        Name = "Alpha",
        BackgroundColor3 = self.Value,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, 248),
        Size = UDim2.fromOffset(182, 10),
        ZIndex = 221,
    }, Parent) :: Frame
    Utils.AddGradient(Bar, ColorSequence.new(Color3.new(1, 1, 1)), NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    }))
    self.AlphaBar = Bar

    local Cursor = Elements.New("Frame", {
        Name = "AlphaCursor",
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(7, 7),
        ZIndex = 222,
    }, Bar) :: Frame
    Elements.Corner(Cursor, 4)
    Elements.Stroke(Cursor, Theme.Text, 0.4, 1)
    self.AlphaCursor = Cursor

    self:Track(Bar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.DragTarget = "alpha"
            self:UpdateFromAlpha()
        end
    end))
end

function ColorPicker:CreateTemplates(Parent: Instance)
    local Theme = self.Window.Theme
    for Index, Hex in ipairs(Utils.Templates) do
        local Button = Elements.New("TextButton", {
            Name = "Template" .. tostring(Index),
            AutoButtonColor = false,
            BackgroundColor3 = Palette.Hex(Hex),
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(10 + (Index - 1) * 24, 302),
            Size = UDim2.fromOffset(16, 16),
            Text = "",
            ZIndex = 221,
        }, Parent) :: TextButton
        Elements.Corner(Button, 8)
        Elements.Stroke(Button, Theme.Text, 0.8, 1)
        self:Track(Button.MouseButton1Click:Connect(function()
            self:SetValue(Palette.Hex(Hex))
        end))
    end
end

function ColorPicker:OpenPicker()
    local Theme = self.Window.Theme
    local RootPosition = self.Window.Root.AbsolutePosition
    local BoxPosition = self.Swatch.AbsolutePosition
    local Popup = Elements.New("Frame", {
        Name = "ColorPickerPopup",
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(BoxPosition.X - RootPosition.X - 188, BoxPosition.Y - RootPosition.Y + 22),
        Size = UDim2.fromOffset(204, 328),
        ZIndex = 220,
    }, self.Window.Overlay) :: Frame
    Elements.Stroke(Popup, Theme.Border, 0, 1)
    self.Popup = Popup

    self.Preview = Elements.New("Frame", {
        Name = "Preview",
        BackgroundColor3 = self.Value,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, 10),
        Size = UDim2.fromOffset(182, 20),
        ZIndex = 221,
    }, Popup) :: Frame

    self:CreateColorSquare(Popup, Theme)
    self:CreateHueBar(Popup, Theme)
    self:CreateAlphaBar(Popup, Theme)

    local Hex = Elements.New("TextBox", {
        Name = "Hex",
        BackgroundColor3 = Theme.Control,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Position = UDim2.fromOffset(10, 268),
        Size = UDim2.fromOffset(112, 24),
        Text = Palette.ToRgba(self.Value, self.Alpha),
        ZIndex = 221,
    }, Popup) :: TextBox
    Styling.ApplyText(Hex, Theme, 10, Theme.Text)
    FontLoader.Apply(Hex, self.Library.AssetCache)
    local HexStroke = Elements.Stroke(Hex, Theme.Border, 0, 1)
    self.Hex = Hex
    self.HexStroke = HexStroke

    local Apply = Elements.New("TextButton", {
        Name = "Apply",
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(130, 268),
        Size = UDim2.fromOffset(62, 24),
        Text = "APPLY",
        ZIndex = 221,
    }, Popup) :: TextButton
    Styling.ApplyText(Apply, Theme, 10, Theme.Text)
    FontLoader.Apply(Apply, self.Library.AssetCache)
    Apply.TextXAlignment = Enum.TextXAlignment.Center
    self.Apply = Apply

    self:Track(Apply.MouseButton1Click:Connect(function()
        local Color, Alpha = Palette.ParseWithAlpha(Hex.Text)
        HexStroke.Color = Color and Theme.Border or Palette.Hex("#ff3f38")
        self:SetValue({ Color = Color or self.Value, Alpha = Alpha })
    end))
    self:Track(Hex.FocusLost:Connect(function()
        local Color, Alpha = Palette.ParseWithAlpha(Hex.Text)
        HexStroke.Color = Color and Theme.Border or Palette.Hex("#ff3f38")
        self:SetValue({ Color = Color or self.Value, Alpha = Alpha })
    end))
    self:Track(UserInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end
        if self.DragTarget == "square" then
            self:UpdateFromSquare()
        elseif self.DragTarget == "hue" then
            self:UpdateFromHue()
        elseif self.DragTarget == "alpha" then
            self:UpdateFromAlpha()
        end
    end))
    self:Track(UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.DragTarget = nil
        end
    end))

    self:CreateTemplates(Popup)
    self:UpdateVisuals()
end

function ColorPicker:UpdateFromSquare()
    if not self.Square then
        return
    end
    local Mouse = UserInputService:GetMouseLocation()
    local Position = self.Square.AbsolutePosition
    local Size = self.Square.AbsoluteSize
    self.Saturation = math.clamp((Mouse.X - Position.X) / math.max(Size.X, 1), 0, 1)
    self.Brightness = 1 - math.clamp((Mouse.Y - Position.Y) / math.max(Size.Y, 1), 0, 1)
    self:SetValue(Color3.fromHSV(self.Hue, self.Saturation, self.Brightness))
end

function ColorPicker:UpdateFromHue()
    if not self.HueBar then
        return
    end
    local Mouse = UserInputService:GetMouseLocation()
    local Position = self.HueBar.AbsolutePosition
    local Size = self.HueBar.AbsoluteSize
    self.Hue = math.clamp((Mouse.X - Position.X) / math.max(Size.X, 1), 0, 1)
    self:SetValue(Color3.fromHSV(self.Hue, self.Saturation, self.Brightness))
end

function ColorPicker:UpdateFromAlpha()
    if not self.AlphaBar then
        return
    end
    local Mouse = UserInputService:GetMouseLocation()
    local Position = self.AlphaBar.AbsolutePosition
    local Size = self.AlphaBar.AbsoluteSize
    self:SetAlpha((Mouse.X - Position.X) / math.max(Size.X, 1))
end

function ColorPicker:SetAlpha(Value: any, RunCallback: boolean?)
    self.Alpha = math.clamp(tonumber(Value) or self.Alpha or 1, 0, 1)
    if self.Flag then
        self.Library.FlagManager:Set(self.Flag .. ".Alpha", self.Alpha)
    end
    if RunCallback ~= false then
        self.Library:RunCallback(self.Options.Text or "Color", self.Callback, self.Value, self.Alpha)
    end
    self:UpdateVisuals()
end

function ColorPicker:UpdateVisuals()
    local Color = self.Value
    self.Swatch.BackgroundColor3 = Color
    self.Swatch.BackgroundTransparency = 1 - self.Alpha
    if self.Preview then
        self.Preview.BackgroundColor3 = Color
        self.Preview.BackgroundTransparency = 1 - self.Alpha
    end
    if self.Square then
        self.Square.BackgroundColor3 = Color3.fromHSV(self.Hue, 1, 1)
    end
    if self.SquareCursor then
        self.SquareCursor.Position = UDim2.new(self.Saturation, -4, 1 - self.Brightness, -4)
    end
    if self.HueCursor then
        self.HueCursor.Position = UDim2.new(self.Hue, -3, 0, 1)
    end
    if self.AlphaBar then
        self.AlphaBar.BackgroundColor3 = Color
    end
    if self.AlphaCursor then
        self.AlphaCursor.Position = UDim2.new(self.Alpha, -3, 0, 1)
    end
    if self.Hex then
        self.Hex.Text = self.Alpha < 0.999 and Palette.ToRgba(Color, self.Alpha) or Palette.ToHex(Color)
    end
end

function ColorPicker:SetValue(Value: any, RunCallback: boolean?)
    local Color, Alpha = Utils.ToColorAlpha(Value)
    if Alpha ~= nil then
        self.Alpha = math.clamp(Alpha, 0, 1)
    end
    if self.Flag then
        self.Library.FlagManager:Set(self.Flag .. ".Alpha", self.Alpha)
    end
    self.Hue, self.Saturation, self.Brightness = Color3.toHSV(Color)
    self:Commit(Color, RunCallback)
    self:UpdateVisuals()
end

function ColorPicker:Destroy()
    self:ClosePicker()
    if self.AlphaFlag then
        self.Library.FlagManager:Unregister(self.AlphaFlag)
    end
    if self.DestroyConnection then
        self.DestroyConnection:Disconnect()
        self.DestroyConnection = nil
    end
    BaseWidget.Destroy(self)
end

return ColorPicker
