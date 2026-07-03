--!strict

local Runtime = {}

function Runtime.GetPlayerGui(): Instance
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    return LocalPlayer:WaitForChild("PlayerGui")
end

function Runtime.GetGuiParent(): Instance
    local Ok, CoreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    if Ok and CoreGui then
        return CoreGui
    end

    return Runtime.GetPlayerGui()
end

function Runtime.AttachGui(Gui: ScreenGui): boolean
    local Ok = pcall(function()
        Gui.Parent = Runtime.GetGuiParent()
    end)
    if Ok then
        return true
    end

    local FallbackOk = pcall(function()
        Gui.Parent = Runtime.GetPlayerGui()
    end)
    return FallbackOk
end

function Runtime.FileApi()
    return {
        IsFolder = isfolder,
        MakeFolder = makefolder,
        IsFile = isfile,
        WriteFile = writefile,
        ReadFile = readfile,
        DeleteFile = delfile,
        ListFiles = listfiles,
        GetCustomAsset = getcustomasset,
    }
end

function Runtime.HasFileApi(): boolean
    return type(isfolder) == "function"
        and type(makefolder) == "function"
        and type(isfile) == "function"
        and type(writefile) == "function"
        and type(readfile) == "function"
        and type(delfile) == "function"
end

return Runtime
