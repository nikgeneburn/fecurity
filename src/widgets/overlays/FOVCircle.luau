--!strict

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Elements = require("@fec/render/Elements")

local FOVCircle = {}
FOVCircle.__index = FOVCircle

local function NewStroke(Parent: Instance, Thickness: number): (UIStroke, UIGradient)
    local Stroke = Instance.new("UIStroke")
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.LineJoinMode = Enum.LineJoinMode.Round
    Stroke.Thickness = Thickness
    Stroke.Transparency = 1
    Stroke.Color = Color3.new(1, 1, 1)
    Stroke.Enabled = false
    Stroke.Parent = Parent
    local Gradient = Instance.new("UIGradient")
    Gradient.Parent = Stroke
    return Stroke, Gradient
end

function FOVCircle.New(Parent: Instance)
    local self = setmetatable({
        Radius = 200,
        Thickness = 2,
        GlowSize = 18,
        GlowLayers = 8,
        GlowTransparency = 0.75,
        RotateSpeed = 1.2,
        RainbowSpeed = 0.2,
        Rotation = 0,
        Color1 = Color3.fromRGB(255, 20, 147),
        Color2 = Color3.fromRGB(255, 255, 255),
        GlowEnabled = false,
        SpinEnabled = false,
        FillEnabled = false,
        RainbowEnabled = false,
        FillTransparency = 0.85,
        SmoothPosition = Vector2.new(0, 0),
        HasExternalPosition = false,
        ExternalPosition = nil,
    }, FOVCircle)

    self.Holder = Elements.New("Frame", {
        Name = "FOVCircle",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(self.Radius * 2, self.Radius * 2),
        Visible = false,
    }, Parent) :: Frame

    self.GlowHolder = Elements.New("Frame", {
        Name = "Glow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 1,
    }, self.Holder) :: Frame
    Elements.Corner(self.GlowHolder, 1000)

    self.Circle = Elements.New("Frame", {
        Name = "Ring",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 5,
    }, self.Holder) :: Frame
    Elements.Corner(self.Circle, 1000)

    self.Fill = Elements.New("Frame", {
        Name = "Fill",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = self.FillTransparency,
        ZIndex = 2,
        Visible = false,
    }, self.Holder) :: Frame
    Elements.Corner(self.Fill, 1000)
    self.FillGradient = Instance.new("UIGradient")
    self.FillGradient.Parent = self.Fill

    self.OuterGlow = {}
    for Index = 1, self.GlowLayers do
        local Stroke, Gradient = NewStroke(self.GlowHolder, 1)
        self.OuterGlow[Index] = { Stroke = Stroke, Gradient = Gradient }
    end

    self.InnerGlow = {}
    for Index = 1, self.GlowLayers do
        local Frame = Elements.New("Frame", {
            Name = "Inner" .. tostring(Index),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
        }, self.GlowHolder) :: Frame
        Elements.Corner(Frame, 1000)
        local Stroke, Gradient = NewStroke(Frame, 1)
        self.InnerGlow[Index] = { Frame = Frame, Stroke = Stroke, Gradient = Gradient }
    end

    self.RingStroke, self.RingGradient = NewStroke(self.Circle, self.Thickness)
    self.RingStroke.Enabled = true
    self.RingStroke.Transparency = 0

    self:SetRadius(self.Radius)
    self:SetColors(self.Color1, self.Color2)

    self.Connection = RunService.RenderStepped:Connect(function(DeltaTime)
        self:Step(DeltaTime)
    end)

    return self
end

function FOVCircle:BuildSequence(): ColorSequence
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Color1),
        ColorSequenceKeypoint.new(1, self.Color2),
    })
end

function FOVCircle:ApplyGradients(Sequence: ColorSequence, Rotation: number)
    self.RingGradient.Color = Sequence
    self.RingGradient.Rotation = Rotation
    self.FillGradient.Color = Sequence
    self.FillGradient.Rotation = Rotation
    for _, Layer in ipairs(self.OuterGlow) do
        Layer.Gradient.Color = Sequence
        Layer.Gradient.Rotation = Rotation
    end
    for _, Layer in ipairs(self.InnerGlow) do
        Layer.Gradient.Color = Sequence
        Layer.Gradient.Rotation = Rotation
    end
end

function FOVCircle:SetPosition(Position: Vector2 | UDim2)
    self.HasExternalPosition = true
    if typeof(Position) == "Vector2" then
        self.ExternalPosition = Position
        self.Holder.Position = UDim2.fromOffset(Position.X, Position.Y)
    elseif typeof(Position) == "UDim2" then
        self.ExternalPosition = nil
        self.Holder.Position = Position
    end
end

function FOVCircle:SetRadius(Radius: number)
    self.Radius = tonumber(Radius) or self.Radius
    local Diameter = self.Radius * 2
    self.Holder.Size = UDim2.fromOffset(Diameter, Diameter)
end

function FOVCircle:SetColors(Color1: Color3, Color2: Color3?)
    self.Color1 = Color1 or self.Color1
    self.Color2 = Color2 or self.Color1
end

function FOVCircle:SetFill(State: boolean, Transparency: number?)
    self.FillEnabled = State == true
    self.FillTransparency = tonumber(Transparency) or self.FillTransparency
    self.Fill.Visible = self.FillEnabled
    self.Fill.BackgroundTransparency = self.FillTransparency
end

function FOVCircle:SetGlow(State: boolean)
    self.GlowEnabled = State == true
end

function FOVCircle:SetSpin(State: boolean)
    self.SpinEnabled = State == true
    if not self.SpinEnabled then
        self.Rotation = 0
    end
end

function FOVCircle:SetRainbow(State: boolean, Speed: number?)
    self.RainbowEnabled = State == true
    self.RainbowSpeed = tonumber(Speed) or self.RainbowSpeed
end

function FOVCircle:SetVisible(State: boolean)
    self.Holder.Visible = State == true
end

function FOVCircle:Step(DeltaTime: number)
    if not self.Holder.Visible then
        return
    end

    if not self.HasExternalPosition then
        local Mouse = UserInputService:GetMouseLocation()
        self.SmoothPosition = self.SmoothPosition:Lerp(Vector2.new(Mouse.X, Mouse.Y), math.clamp(DeltaTime * 12, 0, 1))
        self.Holder.Position = UDim2.fromOffset(self.SmoothPosition.X, self.SmoothPosition.Y)
    elseif self.ExternalPosition then
        self.SmoothPosition = self.ExternalPosition
    end
    self.HasExternalPosition = false

    if self.SpinEnabled then
        self.Rotation = (self.Rotation + self.RotateSpeed * DeltaTime * 60) % 360
    end

    if self.RainbowEnabled then
        local Time = tick() * self.RainbowSpeed
        self.Color1 = Color3.fromHSV(Time % 1, 0.78, 1)
        self.Color2 = Color3.fromHSV((Time + 0.35) % 1, 0.78, 1)
    end

    local Sequence = self:BuildSequence()
    self:ApplyGradients(Sequence, self.Rotation)

    local GlowOn = self.GlowEnabled
    local Layers = self.GlowLayers
    local Spread = self.GlowSize
    local BaseTransparency = self.GlowTransparency

    for Index = 1, Layers do
        local Fraction = Index / Layers
        local Transparency = BaseTransparency + (1 - BaseTransparency) * Fraction

        local Outer = self.OuterGlow[Index]
        Outer.Stroke.Enabled = GlowOn
        Outer.Stroke.Thickness = GlowOn and (self.Thickness + Spread * Fraction) or 0
        Outer.Stroke.Transparency = GlowOn and Transparency or 1

        local Inner = self.InnerGlow[Index]
        local Inset = Spread * Fraction
        Inner.Frame.Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(Inset * 2, Inset * 2)
        Inner.Stroke.Enabled = GlowOn
        Inner.Stroke.Thickness = GlowOn and Spread * Fraction or 0
        Inner.Stroke.Transparency = GlowOn and Transparency or 1
    end
end

function FOVCircle:Destroy()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    if self.Holder then
        self.Holder:Destroy()
    end
end

return FOVCircle
