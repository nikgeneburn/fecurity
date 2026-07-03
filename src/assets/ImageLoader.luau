--!strict

local Registry = require("@fec/assets/AssetRegistry")

local ImageLoader = {}

function ImageLoader.Get(Cache: any?, Name: string): string?
    local Asset = Registry.Images[Name]
    if not Asset or not Cache then
        return nil
    end
    return Cache:GetCustomAsset(Asset.File)
end

function ImageLoader.Apply(Object: ImageLabel | ImageButton, Cache: any?, Name: string)
    local Asset = ImageLoader.Get(Cache, Name)
    if Asset then
        Object.Image = Asset
        return true
    end
    return false
end

return ImageLoader
