--!strict

local Shadows = {}

function Shadows.Apply(Parent: GuiObject, Color: Color3?)
    local Shadow = Instance.new("Frame")
    Shadow.Name = "Shadow"
    Shadow.BackgroundColor3 = Color or Color3.new(0, 0, 0)
    Shadow.BackgroundTransparency = 0.76
    Shadow.BorderSizePixel = 0
    Shadow.Position = UDim2.fromOffset(3, 3)
    Shadow.Size = UDim2.fromScale(1, 1)
    Shadow.ZIndex = math.max(Parent.ZIndex - 1, 0)
    Shadow.Parent = Parent
    return Shadow
end

return Shadows
