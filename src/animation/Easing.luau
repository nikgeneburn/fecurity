--!strict

local Easing = {}

function Easing.OutQuad(Value: number): number
    return 1 - (1 - Value) * (1 - Value)
end

function Easing.Smooth(Value: number): number
    return Value * Value * (3 - 2 * Value)
end

return Easing

