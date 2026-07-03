--!strict

local Logger = require("@fec/core/Logger")

local Registry = {}

local Key = "__FECURITY_UI__"

local function Environment(): { [any]: any }
    if getgenv then
        local Ok, Env = pcall(getgenv)
        if Ok and type(Env) == "table" then
            return Env
        end
    end
    return _G
end

function Registry.Get(): any?
    return Environment()[Key]
end

function Registry.Set(Value: any)
    Environment()[Key] = Value
end

function Registry.Clear(Owner: any?)
    local Env = Environment()
    if Owner == nil or Env[Key] == Owner then
        Env[Key] = nil
    end
end

function Registry.Claim(Version: string, Teardown: () -> ()): any
    local Previous = Registry.Get()
    if Previous and Previous.Unload then
        Logger.Info(("Reloading previous Fecurity session %s"):format(tostring(Previous.Version)))
        pcall(function()
            Previous:Unload()
        end)
    elseif Previous and Previous.Teardown then
        pcall(Previous.Teardown)
    end
    local Entry = { Version = Version, Teardown = Teardown }
    Registry.Set(Entry)
    return Entry
end

return Registry
