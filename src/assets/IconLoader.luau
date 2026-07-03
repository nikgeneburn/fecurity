--!strict

local Registry = require("@fec/assets/AssetRegistry")
local Styling = require("@fec/render/Styling")

local IconLoader = {}

function IconLoader.Apply(Parent: Instance, Name: string, Theme: { [string]: any }, Cache: any?): Instance
    local Icon = Registry.Icons[string.lower(Name)]
    local Asset = Icon and Cache and Cache:GetCustomAsset(Icon.File)

    if Asset then
        local Image = Instance.new("ImageLabel")
        Image.Name = "Icon"
        Image.BackgroundTransparency = 1
        Image.Image = Asset
        Image.ImageColor3 = Theme.Muted
        Image.Size = UDim2.fromOffset(16, 16)
        Image.Parent = Parent
        return Image
    end

    local Label = Instance.new("TextLabel")
    Label.Name = "IconFallback"
    Label.Size = UDim2.fromOffset(16, 16)
    Label.Text = Icon and Icon.Fallback or string.sub(Name, 1, 1)
    Styling.ApplyText(Label, Theme, 11, Theme.Muted)
    Label.TextXAlignment = Enum.TextXAlignment.Center
    Label.Parent = Parent
    return Label
end

return IconLoader

