--!strict

local Elements = {}

function Elements.New(ClassName: string, Props: { [string]: any }?, Parent: Instance?): Instance
    local Object = Instance.new(ClassName)
    if Props then
        for Key, Value in pairs(Props) do
            (Object :: any)[Key] = Value
        end
    end
    Object.Parent = Parent
    return Object
end

function Elements.Corner(Parent: Instance, Radius: number?)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Radius or 0)
    Corner.Parent = Parent
    return Corner
end

function Elements.Stroke(Parent: Instance, Color: Color3, Transparency: number?, Thickness: number?)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color
    Stroke.Transparency = Transparency or 0
    Stroke.Thickness = Thickness or 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Parent
    return Stroke
end

function Elements.Padding(Parent: Instance, Left: number, Top: number, Right: number, Bottom: number)
    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, Left)
    Padding.PaddingTop = UDim.new(0, Top)
    Padding.PaddingRight = UDim.new(0, Right)
    Padding.PaddingBottom = UDim.new(0, Bottom)
    Padding.Parent = Parent
    return Padding
end

function Elements.List(Parent: Instance, Direction: Enum.FillDirection, Padding: number?)
    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Direction
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, Padding or 0)
    Layout.Parent = Parent
    return Layout
end

return Elements

