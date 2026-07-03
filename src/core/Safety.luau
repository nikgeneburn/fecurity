--!strict

local Logger = require("@fec/core/Logger")

local Safety = {}

function Safety.Try(Scope: string, Fn: (...any) -> ...any, ...): (boolean, ...any)
    local Result = table.pack(pcall(Fn, ...))
    if not Result[1] then
        Logger.Error(Scope, Result[2])
        return false
    end
    return true, table.unpack(Result, 2, Result.n)
end

function Safety.Callback(Scope: string, Fn: ((...any) -> ...any)?, ...)
    if not Fn then
        return
    end
    local Ok, Err = pcall(Fn, ...)
    if not Ok then
        Logger.Error(Scope, Err)
    end
end

return Safety

