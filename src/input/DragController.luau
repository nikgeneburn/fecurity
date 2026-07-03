--!strict

local UserInputService = game:GetService("UserInputService")

local DragController = {}

function DragController.Attach(Handle: GuiObject, Target: GuiObject)
    local Dragging = false
    local StartMouse = Vector2.zero
    local StartPos = Target.Position
    local Connections = {}

    table.insert(Connections, Handle.InputBegan:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        Dragging = true
        StartMouse = UserInputService:GetMouseLocation()
        StartPos = Target.Position
    end))

    table.insert(Connections, UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end))

    table.insert(Connections, UserInputService.InputChanged:Connect(function(Input)
        if not Dragging or Input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end
        local Delta = UserInputService:GetMouseLocation() - StartMouse
        Target.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end))

    return function()
        for _, Connection in ipairs(Connections) do
            Connection:Disconnect()
        end
    end
end

return DragController

