--!strict

local Elements = require("@fec/render/Elements")

local AutoLayout = {}

function AutoLayout.Vertical(Parent: Instance, Padding: number?)
    local Layout = Elements.List(Parent, Enum.FillDirection.Vertical, Padding or 0)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    return Layout
end

function AutoLayout.Horizontal(Parent: Instance, Padding: number?)
    local Layout = Elements.List(Parent, Enum.FillDirection.Horizontal, Padding or 0)
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    return Layout
end

function AutoLayout.ResizeToContent(Frame: GuiObject, Layout: UIListLayout, Extra: number?)
    local function Update()
        Frame.Size = UDim2.new(Frame.Size.X.Scale, Frame.Size.X.Offset, 0, Layout.AbsoluteContentSize.Y + (Extra or 0))
    end
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update)
    task.defer(Update)
end

return AutoLayout

