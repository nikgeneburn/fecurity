--!strict

local Palette = require("@fec/theme/Palette")

local ColorPickerUtils = {}

ColorPickerUtils.Templates = {
    "#ff0000",
    "#5f90f6",
    "#d8f368",
    "#e1ae24",
    "#3ad4bb",
    "#fee2eb",
    "#f25dab",
    "#ffffff",
}

ColorPickerUtils.HueSequence = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
})

function ColorPickerUtils.ToColorAlpha(Value: any): (Color3, number?)
    if typeof(Value) == "Color3" then
        return Value, nil
    end
    if type(Value) == "table" then
        local Color, Alpha = ColorPickerUtils.ToColorAlpha(Value.Color or Value.Value)
        return Color, tonumber(Value.Alpha) or Alpha
    end
    if type(Value) == "string" then
        local Color, Alpha = Palette.ParseWithAlpha(Value)
        return Color or Palette.Hex(Value), Alpha
    end
    return Color3.new(1, 1, 1), nil
end

function ColorPickerUtils.AddGradient(Frame: Frame, Color: ColorSequence, Transparency: NumberSequence?, Rotation: number?)
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = Color
    if Transparency then
        Gradient.Transparency = Transparency
    end
    Gradient.Rotation = Rotation or 0
    Gradient.Parent = Frame
    return Gradient
end

return ColorPickerUtils
