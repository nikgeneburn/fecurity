--!strict

local Palette = {}

function Palette.Hex(Hex: string): Color3
    local Clean = string.gsub(Hex, "#", "")
    local R = tonumber(string.sub(Clean, 1, 2), 16) or 255
    local G = tonumber(string.sub(Clean, 3, 4), 16) or 255
    local B = tonumber(string.sub(Clean, 5, 6), 16) or 255
    return Color3.fromRGB(R, G, B)
end

function Palette.Darken(Color: Color3, Amount: number): Color3
    return Color3.new(
        math.clamp(Color.R * (1 - Amount), 0, 1),
        math.clamp(Color.G * (1 - Amount), 0, 1),
        math.clamp(Color.B * (1 - Amount), 0, 1)
    )
end

function Palette.Lighten(Color: Color3, Amount: number): Color3
    return Color:Lerp(Color3.new(1, 1, 1), Amount)
end

function Palette.ToHex(Color: Color3): string
    return string.format("#%02x%02x%02x", math.floor(Color.R * 255 + 0.5), math.floor(Color.G * 255 + 0.5), math.floor(Color.B * 255 + 0.5))
end

function Palette.ParseWithAlpha(Text: string): (Color3?, number?)
    local Clean = string.gsub(Text, "%s+", "")
    local Hex = string.match(Clean, "^#?([%da-fA-F]+)$")
    if Hex and (#Hex == 3 or #Hex == 6 or #Hex == 8) then
        local Alpha = nil
        if #Hex == 3 then
            Hex = string.sub(Hex, 1, 1) .. string.sub(Hex, 1, 1)
                .. string.sub(Hex, 2, 2) .. string.sub(Hex, 2, 2)
                .. string.sub(Hex, 3, 3) .. string.sub(Hex, 3, 3)
        elseif #Hex == 8 then
            Alpha = (tonumber(string.sub(Hex, 7, 8), 16) or 255) / 255
        end
        return Palette.Hex(string.sub(Hex, 1, 6)), Alpha
    end

    local Body = string.match(Clean, "^rgba?%((.+)%)$")
    if not Body then
        return nil, nil
    end

    local Values = {}
    for Value in string.gmatch(Body, "[%d%.]+") do
        table.insert(Values, tonumber(Value) or 0)
    end
    if #Values < 3 then
        return nil, nil
    end

    local Alpha = Values[4]
    if Alpha ~= nil and Alpha > 1 then
        Alpha = Alpha / 255
    end

    return Color3.fromRGB(
        math.clamp(math.floor(Values[1] + 0.5), 0, 255),
        math.clamp(math.floor(Values[2] + 0.5), 0, 255),
        math.clamp(math.floor(Values[3] + 0.5), 0, 255)
    ), Alpha and math.clamp(Alpha, 0, 1) or nil
end

function Palette.Parse(Text: string): Color3?
    local Color = Palette.ParseWithAlpha(Text)
    return Color
end

function Palette.ToRgba(Color: Color3, Alpha: number): string
    return string.format(
        "rgba(%d, %d, %d, %.2f)",
        math.floor(Color.R * 255 + 0.5),
        math.floor(Color.G * 255 + 0.5),
        math.floor(Color.B * 255 + 0.5),
        math.clamp(Alpha, 0, 1)
    )
end

return Palette
