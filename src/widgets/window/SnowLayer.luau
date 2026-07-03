--!strict

local RunService = game:GetService("RunService")

local Elements = require("@fec/render/Elements")

local SnowLayer = {}
SnowLayer.__index = SnowLayer

function SnowLayer.New(Window: any, Parent: Instance)
    local self = setmetatable({
        Window = Window,
        Flakes = {},
        Random = Random.new(6206),
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

    for Index = 1, 70 do
        local Size = self.Random:NextInteger(5, 14)
        local Label = Elements.New("TextLabel", {
            Name = "Flake" .. tostring(Index),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(Size, Size),
            Text = "*",
            TextColor3 = Color3.new(1, 1, 1),
            TextTransparency = self.Random:NextNumber(0.1, 0.62),
            TextSize = Size,
            Font = Enum.Font.GothamBold,
            ZIndex = 2,
        }, Root) :: TextLabel
        table.insert(self.Flakes, {
            Node = Label,
            X = self.Random:NextNumber(0, 1),
            Y = self.Random:NextNumber(-0.2, 1),
            Speed = self.Random:NextNumber(0.025, 0.105),
            Drift = self.Random:NextNumber(-22, 22),
            Spin = self.Random:NextNumber(-35, 35),
            Phase = self.Random:NextNumber(0, 6.28),
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
    local Now = os.clock()
    for _, Flake in ipairs(self.Flakes) do
        Flake.Y += Flake.Speed * Delta * 60
        if Flake.Y > 1.08 then
            Flake.Y = -0.08
            Flake.X = self.Random:NextNumber(0, 1)
        end
        local X = Flake.X * Size.X + math.sin(Now + Flake.Phase) * Flake.Drift
        local Y = Flake.Y * Size.Y
        Flake.Node.Position = UDim2.fromOffset(X, Y)
        Flake.Node.Rotation += Flake.Spin * Delta
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
