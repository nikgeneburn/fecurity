--!strict

local Registry = require("@fec/assets/AssetRegistry")

local FontLoader = {}

function FontLoader.Apply(Object: TextLabel | TextButton | TextBox, Cache: any?)
    Object.Font = Registry.Fonts.Main.Fallback
    if not Cache then
        return
    end
    local Asset = Cache:GetCustomAsset(Registry.Fonts.Main.File)
    if not Asset then
        return
    end
    pcall(function()
        Object.FontFace = Font.new(Asset, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    end)
end

return FontLoader

