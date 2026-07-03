--!strict

local UserInputService = game:GetService("UserInputService")
local BaseWidget = require("@fec/widgets/BaseWidget")
local Elements = require("@fec/render/Elements")
local Styling = require("@fec/render/Styling")
local FontLoader = require("@fec/assets/FontLoader")

local Slider = {}
Slider.__index = Slider
setmetatable(Slider, { __index = BaseWidget })

local function Format(Options: { [string]: any }, Value: number): string
    if Options.Suffix then
        local Text = Options.Decimals and string.format("%." .. tostring(Options.Decimals) .. "f", Value) or tostring(math.floor(Value + 0.5))
        return Text .. (Options.SuffixSpacing == false and "" or " ") .. Options.Suffix
    end
    if Options.Format == "percent" then
        return tostring(math.floor(Value + 0.5)) .. "%"
    elseif Options.Format == "ms" then
        return tostring(math.floor(Value + 0.5)) .. " MS"
    elseif Options.Format == "coefficient" then
        return "x" .. string.format("%.2f", Value)
    elseif Options.Format == "fixed2" then
        return string.format("%.2f", Value)
    end
    return tostring(math.floor(Value + 0.5))
end

function Slider.New(Section: any, Options: { [string]: any })
    Options.Min = Options.Min or 0
    Options.Max = Options.Max or 100
    Options.Step = Options.Step or 1
    Options.Default = Options.Default or Options.Value or Options.Min
    local self = BaseWidget.New(Section, Options, 70)
    setmetatable(self, Slider)
    self.Connections = {}
    local Theme = self.Window.Theme

    local Title = Elements.New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0.78, 0, 0, 16),
        Text = Options.Text or "Slider",
        ZIndex = 31,
    }, self.Root) :: TextLabel
    Styling.ApplyText(Title, Theme, 14, Theme.Text)
    FontLoader.Apply(Title, self.Library.AssetCache)
    self.Title = Title

    local ValueLabel = Elements.New("TextLabel", {
        Name = "Value",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0.25, 0, 0, 16),
        Text = "",
        ZIndex = 31,
    }, self.Root) :: TextLabel
    Styling.ApplyText(ValueLabel, Theme, 14, Theme.Text)
    FontLoader.Apply(ValueLabel, self.Library.AssetCache)
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.ValueLabel = ValueLabel

    local Track = Elements.New("Frame", {
        Name = "Track",
        Position = UDim2.fromOffset(0, 30),
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Theme.SliderTrack,
        BorderSizePixel = 0,
        ZIndex = 31,
    }, self.Root) :: Frame
    self.Track = Track

    local Fill = Elements.New("Frame", {
        Name = "Fill",
        Size = UDim2.fromOffset(0, 2),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 32,
    }, Track) :: Frame
    self.Fill = Fill

    local Knob = Elements.New("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(0, 1),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 33,
    }, Track) :: Frame
    Elements.Corner(Knob, 6)
    self.Knob = Knob

    local Dragging = false
    local function SetFromMouse()
        local X = UserInputService:GetMouseLocation().X - Track.AbsolutePosition.X
        local Ratio = math.clamp(X / math.max(Track.AbsoluteSize.X, 1), 0, 1)
        local Raw = Options.Min + (Options.Max - Options.Min) * Ratio
        local Stepped = math.floor((Raw / Options.Step) + 0.5) * Options.Step
        self:SetValue(math.clamp(Stepped, Options.Min, Options.Max))
    end

    self:TrackConnection(Track.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            SetFromMouse()
        end
    end))
    self:TrackConnection(Knob.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
        end
    end))
    self:TrackConnection(UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end))
    self:TrackConnection(UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            SetFromMouse()
        end
    end))
    self.DestroyConnection = self.Root.Destroying:Connect(function()
        self:DisconnectInputs()
    end)

    self:BindTheme(function(NewTheme)
        Title.TextColor3 = NewTheme.Text
        ValueLabel.TextColor3 = NewTheme.Text
        Track.BackgroundColor3 = NewTheme.SliderTrack
        Fill.BackgroundColor3 = NewTheme.Accent
        Knob.BackgroundColor3 = NewTheme.Accent
    end)
    self:SetValue(self.Value, false)
    return self
end

function Slider:TrackConnection(Connection: RBXScriptConnection)
    table.insert(self.Connections, Connection)
    return Connection
end

function Slider:DisconnectInputs()
    for _, Connection in ipairs(self.Connections) do
        Connection:Disconnect()
    end
    table.clear(self.Connections)
    if self.DestroyConnection then
        self.DestroyConnection:Disconnect()
        self.DestroyConnection = nil
    end
end

function Slider:SetValue(Value: any, RunCallback: boolean?)
    local Number = tonumber(Value) or self.Options.Min
    Number = math.clamp(Number, self.Options.Min, self.Options.Max)
    self:Commit(Number, RunCallback)
    local Ratio = (Number - self.Options.Min) / math.max(self.Options.Max - self.Options.Min, 1)
    self.Fill.Size = UDim2.new(Ratio, 0, 0, 2)
    self.Knob.Position = UDim2.new(Ratio, 0, 0, 1)
    self.ValueLabel.Text = Format(self.Options, Number)
end

function Slider:Destroy()
    self:DisconnectInputs()
    BaseWidget.Destroy(self)
end

return Slider
