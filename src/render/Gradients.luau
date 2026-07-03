--!strict

local Gradients = {}

function Gradients.AccentVertical(Parent: Instance, Accent: Color3): UIGradient
    local Gradient = Instance.new("UIGradient")
    Gradient.Rotation = 90
    Gradient.Color = Gradients.AccentSequence(Accent)
    Gradient.Parent = Parent
    return Gradient
end

function Gradients.AccentSequence(Accent: Color3): ColorSequence
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, Accent:Lerp(Color3.new(1, 1, 1), 0.26)),
        ColorSequenceKeypoint.new(1, Accent:Lerp(Color3.new(0, 0, 0), 0.46)),
    })
end

function Gradients.SetAccent(Gradient: UIGradient, Accent: Color3)
    Gradient.Color = Gradients.AccentSequence(Accent)
end

return Gradients
