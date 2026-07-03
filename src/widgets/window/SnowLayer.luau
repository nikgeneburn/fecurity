--!strict

local RunService = game:GetService("RunService")

local Elements = require("@fec/render/Elements")

local SnowLayer = {}
SnowLayer.__index = SnowLayer

local FlakeCount = 180
local TopY = -0.08
local BottomY = 1.08

function SnowLayer.New(Window: any, Parent: Instance)
    local self = setmetatable({
        Window = Window,
        Flakes = {},
        Elapsed = 0,
        Visible = true,
    }, SnowLayer)

    local Root = Elements.New("Frame", {
        Name = "SnowLayer",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromScale(1, 1),
        ZIndex = 2,
    }, Parent) :: Frame
    self.Root = Root

    for Index = 0, FlakeCount - 1 do
        local Depth = ((Index * 53) % 100) / 100
        local Near = Depth ^ 1.8
        local LeftPercent = (Index * 23 + math.floor(Index / 3) * 11) % 100
        local Size = 2.4 + Near * 13 + (Index % 5) * 0.18
        local Duration = 18 - Near * 11 + (Index * 7 % 5)
        local Delay = (Index * 0.47) % Duration
        local Drift = math.round((((Index * 29) % 120) - 60) * (0.35 + Near * 1.25))
        local Opacity = 0.1 + Near * 0.56
        local Spin = Index % 2 == 0 and 180 or -180

        local Label = Elements.New("TextLabel", {
            Name = "Flake" .. tostring(Index),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(Size, Size),
            Text = "*",
            TextColor3 = Color3.new(1, 1, 1),
            TextTransparency = 1 - Opacity,
            TextSize = Size,
            Font = Enum.Font.GothamBold,
            ZIndex = 2,
        }, Root) :: TextLabel
        table.insert(self.Flakes, {
            Node = Label,
            LeftPercent = LeftPercent,
            Duration = Duration,
            Delay = Delay,
            Drift = Drift,
            Spin = Spin,
        })
    end

    self.Connection = RunService.RenderStepped:Connect(function(Delta)
        self:Step(Delta)
    end)

    return self
end

function SnowLayer:Step(Delta: number)
    if not self.Visible then
        return
    end
    local Size = self.Root.AbsoluteSize
    if Size.X <= 0 or Size.Y <= 0 then
        return
    end
    self.Elapsed += Delta
    for _, Flake in ipairs(self.Flakes) do
        local Phase = ((self.Elapsed + Flake.Delay) % Flake.Duration) / Flake.Duration
        local X = (Flake.LeftPercent / 100) * Size.X + Phase * Flake.Drift
        local Y = (TopY + Phase * (BottomY - TopY)) * Size.Y
        Flake.Node.Position = UDim2.fromOffset(X, Y)
        Flake.Node.Rotation = Phase * Flake.Spin
    end
end

function SnowLayer:SetVisible(Value: boolean)
    self.Visible = Value
    self.Root.Visible = Value
end

function SnowLayer:Destroy()
    if self.Connection then
        self.Connection:Disconnect()
    end
    if self.Root then
        self.Root:Destroy()
    end
end

return SnowLayer
