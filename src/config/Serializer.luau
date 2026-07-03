--!strict

local HttpService = game:GetService("HttpService")

local Serializer = {}

local function Pack(Value: any, Seen: { [any]: boolean }?): any
    local ValueType = typeof(Value)
    if ValueType == "Color3" then
        return {
            __FecurityType = "Color3",
            R = Value.R,
            G = Value.G,
            B = Value.B,
        }
    end
    if type(Value) ~= "table" then
        return Value
    end

    Seen = Seen or {}
    if Seen[Value] then
        return nil
    end
    Seen[Value] = true

    local Copy = {}
    for Key, Child in pairs(Value) do
        Copy[Key] = Pack(Child, Seen)
    end
    Seen[Value] = nil
    return Copy
end

local function Unpack(Value: any): any
    if type(Value) ~= "table" then
        return Value
    end
    if Value.__FecurityType == "Color3" then
        return Color3.new(tonumber(Value.R) or 1, tonumber(Value.G) or 1, tonumber(Value.B) or 1)
    end
    local Copy = {}
    for Key, Child in pairs(Value) do
        Copy[Key] = Unpack(Child)
    end
    return Copy
end

function Serializer.Encode(Value: any): string
    return HttpService:JSONEncode(Pack(Value))
end

function Serializer.Decode(Value: string): any?
    local Ok, Result = pcall(function()
        return HttpService:JSONDecode(Value)
    end)
    if Ok then
        return Unpack(Result)
    end
    return nil
end

return Serializer
