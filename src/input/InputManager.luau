--!strict

local UserInputService = game:GetService("UserInputService")

local InputManager = {}
InputManager.__index = InputManager

function InputManager.New()
    return setmetatable({
        Connections = {},
    }, InputManager)
end

function InputManager:Connect(Signal: RBXScriptSignal, Fn: (...any) -> ())
    local Connection = Signal:Connect(Fn)
    table.insert(self.Connections, Connection)
    return Connection
end

function InputManager:MousePosition(): Vector2
    return UserInputService:GetMouseLocation()
end

function InputManager:Destroy()
    for _, Connection in ipairs(self.Connections) do
        Connection:Disconnect()
    end
    table.clear(self.Connections)
end

return InputManager

