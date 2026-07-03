--!strict

local Alignment = {}

function Alignment.Center(Object: GuiObject)
    Object.AnchorPoint = Vector2.new(0.5, 0.5)
    Object.Position = UDim2.fromScale(0.5, 0.5)
end

function Alignment.Fill(Object: GuiObject)
    Object.Position = UDim2.fromOffset(0, 0)
    Object.Size = UDim2.fromScale(1, 1)
end

return Alignment

