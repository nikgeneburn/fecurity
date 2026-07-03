--!strict

local TextService = game:GetService("TextService")

local Styling = {}

function Styling.ApplyText(Object: TextLabel | TextButton | TextBox, Theme: { [string]: any }, Size: number?, Color: Color3?)
    Object.Font = Enum.Font.GothamBold
    Object.TextSize = Size or 12
    Object.TextColor3 = Color or Theme.Text
    Object.TextXAlignment = Enum.TextXAlignment.Left
    Object.TextYAlignment = Enum.TextYAlignment.Center
    Object.BackgroundTransparency = 1
    Object.TextTruncate = Enum.TextTruncate.AtEnd
end

function Styling.FitText(Object: TextLabel | TextButton | TextBox, MaxSize: number?, MinSize: number?)
    local TopSize = MaxSize or Object.TextSize
    local BottomSize = MinSize or 9

    local function Resize()
        local Width = math.max(Object.AbsoluteSize.X - 6, 4)
        local Best = BottomSize
        local MeasureFont = Object.Font
        if MeasureFont == Enum.Font.Unknown then
            MeasureFont = Enum.Font.GothamBold
        end
        for Size = TopSize, BottomSize, -1 do
            local Bounds = TextService:GetTextSize(Object.Text, Size, MeasureFont, Vector2.new(math.huge, math.huge))
            if Bounds.X <= Width then
                Best = Size
                break
            end
        end
        Object.TextSize = Best
    end

    task.defer(Resize)
    Object:GetPropertyChangedSignal("Text"):Connect(Resize)
    Object:GetPropertyChangedSignal("AbsoluteSize"):Connect(Resize)
    return Resize
end

return Styling
