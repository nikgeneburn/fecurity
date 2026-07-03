--!strict

local Palette = require("@fec/theme/Palette")

local Theme = {}

Theme.Default = {
    Canvas = Palette.Hex("#0a0a0a"),
    Surface = Palette.Hex("#111111"),
    Selected = Palette.Hex("#1b1b1b"),
    Border = Palette.Hex("#2c2c2c"),
    Text = Palette.Hex("#ffffff"),
    Muted = Palette.Hex("#646464"),
    Hint = Palette.Hex("#575757"),
    Accent = Palette.Hex("#6a62c6"),
    Control = Palette.Hex("#212121"),
    ControlHover = Palette.Hex("#252525"),
    ToggleOff = Palette.Hex("#1d1d1d"),
    ToggleKnobOff = Palette.Hex("#696969"),
    SliderTrack = Palette.Hex("#232323"),
    Success = Palette.Hex("#2fb636"),
}

Theme.Presets = {
    Dark = Theme.Default,
    dark = Theme.Default,
    Fecurity = Theme.Default,
    fecurity = Theme.Default,
    Midnight = {
        Canvas = Palette.Hex("#050505"),
        Surface = Palette.Hex("#101012"),
        Selected = Palette.Hex("#1a1a20"),
        Border = Palette.Hex("#303039"),
        Text = Palette.Hex("#ffffff"),
        Muted = Palette.Hex("#72727a"),
        Hint = Palette.Hex("#5a5a63"),
        Accent = Palette.Hex("#6a62c6"),
        Control = Palette.Hex("#202025"),
        ControlHover = Palette.Hex("#282831"),
        ToggleOff = Palette.Hex("#1b1b20"),
        ToggleKnobOff = Palette.Hex("#707078"),
        SliderTrack = Palette.Hex("#25252d"),
    },
}

Theme.Presets.midnight = Theme.Presets.Midnight

local function CopyFrom(Source: { [string]: any })
    local Copy = {}
    for Key, DefaultValue in pairs(Theme.Default) do
        Copy[Key] = Source[Key] or DefaultValue
    end
    return Copy
end

function Theme.Clone(Accent: Color3?)
    local Copy = CopyFrom(Theme.Default)
    if Accent then
        Copy.Accent = Accent
    end
    return Copy
end

function Theme.Resolve(Value: any, Accent: Color3?)
    local Base = Theme.Default
    if type(Value) == "string" then
        Base = Theme.Presets[Value] or Theme.Presets[string.lower(Value)] or Theme.Default
    elseif type(Value) == "table" then
        Base = Value
    end
    local Copy = CopyFrom(Base)
    if Accent then
        Copy.Accent = Accent
    end
    return Copy
end

function Theme.Apply(Target: { [string]: any }, Source: { [string]: any })
    for Key in pairs(Theme.Default) do
        Target[Key] = Source[Key] or Theme.Default[Key]
    end
end

return Theme
