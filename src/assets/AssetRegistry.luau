--!strict

local AssetRegistry = {}

local DefaultBaseUrl = "https://raw.githubusercontent.com/nikgeneburn/fecurity/main/"

local function NormalizeBaseUrl(BaseUrl: string): string
    if string.sub(BaseUrl, -1) ~= "/" then
        return BaseUrl .. "/"
    end
    return BaseUrl
end

local function ReadOverrideBaseUrl(): string
    local Env = _G
    if getgenv then
        local Ok, Result = pcall(getgenv)
        if Ok and type(Result) == "table" then
            Env = Result
        end
    end
    local Override = Env.FecurityAssetBaseUrl
    if type(Override) == "string" and Override ~= "" then
        return NormalizeBaseUrl(Override)
    end
    return NormalizeBaseUrl(DefaultBaseUrl)
end

AssetRegistry.BaseUrl = ReadOverrideBaseUrl()

AssetRegistry.CacheRoot = "Fecurity"

AssetRegistry.Folders = {
    "Fecurity",
    "Fecurity/Assets",
    "Fecurity/Assets/Fonts",
    "Fecurity/Assets/Icons",
    "Fecurity/Assets/Images",
    "Fecurity/Configs",
    "Fecurity/Logs",
}

AssetRegistry.Fonts = {
    Main = {
        Url = AssetRegistry.BaseUrl .. "assets/fonts/ProximaNova-Semibold.ttf",
        File = "Fecurity/Assets/Fonts/ProximaNova-Semibold.ttf",
        Bytes = 53740,
        Fallback = Enum.Font.GothamBold,
    },
}

AssetRegistry.Icons = {
    assist = { Url = AssetRegistry.BaseUrl .. "assets/icons/assist.png", File = "Fecurity/Assets/Icons/assist.png", Bytes = 1982, Fallback = "A" },
    visuals = { Url = AssetRegistry.BaseUrl .. "assets/icons/visuals.png", File = "Fecurity/Assets/Icons/visuals.png", Bytes = 2131, Fallback = "V" },
    misc = { Url = AssetRegistry.BaseUrl .. "assets/icons/misc.png", File = "Fecurity/Assets/Icons/misc.png", Bytes = 1770, Fallback = "M" },
    colors = { Url = AssetRegistry.BaseUrl .. "assets/icons/colors.png", File = "Fecurity/Assets/Icons/colors.png", Bytes = 1234, Fallback = "C" },
    trial = { Url = AssetRegistry.BaseUrl .. "assets/icons/trial.png", File = "Fecurity/Assets/Icons/trial.png", Bytes = 1030, Fallback = "T" },
}

AssetRegistry.Images = {
    Logo = { Url = AssetRegistry.BaseUrl .. "assets/images/logo.png", File = "Fecurity/Assets/Images/logo.png", Bytes = 1650, Fallback = nil },
    HitboxPreview = { Url = AssetRegistry.BaseUrl .. "assets/images/hitbox-preview.png", File = "Fecurity/Assets/Images/hitbox-preview.png", Bytes = 211220, Fallback = nil },
}

function AssetRegistry.SetBaseUrl(BaseUrl: string)
    BaseUrl = NormalizeBaseUrl(BaseUrl)
    AssetRegistry.BaseUrl = BaseUrl
    AssetRegistry.Fonts.Main.Url = BaseUrl .. "assets/fonts/ProximaNova-Semibold.ttf"
    for Name, Icon in pairs(AssetRegistry.Icons) do
        Icon.Url = BaseUrl .. "assets/icons/" .. Name .. ".png"
    end
    AssetRegistry.Images.Logo.Url = BaseUrl .. "assets/images/logo.png"
    AssetRegistry.Images.HitboxPreview.Url = BaseUrl .. "assets/images/hitbox-preview.png"
end

return AssetRegistry

