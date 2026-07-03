--!strict

local KeybindManager = {}

function KeybindManager.Display(Input: InputObject | Enum.KeyCode | string): string
    if typeof(Input) == "EnumItem" then
        return string.gsub((Input :: EnumItem).Name, "Insert", "INS")
    end
    if typeof(Input) == "Instance" then
        local Object = Input :: InputObject
        if Object.UserInputType == Enum.UserInputType.MouseButton1 then
            return "M1"
        elseif Object.UserInputType == Enum.UserInputType.MouseButton2 then
            return "M2"
        elseif Object.KeyCode ~= Enum.KeyCode.Unknown then
            return KeybindManager.Display(Object.KeyCode)
        end
    end
    return tostring(Input)
end

function KeybindManager.Normalize(Value: any): string
    local Display = KeybindManager.Display(Value)
    Display = string.gsub(Display, "^Enum%.KeyCode%.", "")
    Display = string.gsub(Display, "^Enum%.UserInputType%.MouseButton1$", "M1")
    Display = string.gsub(Display, "^Enum%.UserInputType%.MouseButton2$", "M2")
    Display = string.gsub(Display, "^MouseButton1$", "M1")
    Display = string.gsub(Display, "^MouseButton2$", "M2")
    Display = string.gsub(Display, "^Insert$", "INS")
    return Display
end

function KeybindManager.IsActivation(Input: InputObject, Value: any): boolean
    local Display = KeybindManager.Display(Input)
    return Display == KeybindManager.Normalize(Value)
end

return KeybindManager
