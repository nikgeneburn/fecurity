--!strict

local Tokens = {
    WindowSize = Vector2.new(980, 520),
    SidebarWidth = 67,
    PanelTop = 17,
    PanelHeight = 485,
    PanelWidth = 281,
    PanelGap = 18,
    PanelLeft = 85,
    PanelRight = 16,
    PanelBottom = 18,
    Radius = 0,
}

function Tokens.PanelX(Index: number): number
    return Tokens.PanelLeft + (Index - 1) * (Tokens.PanelWidth + Tokens.PanelGap)
end

function Tokens.PanelHeightFor(WindowHeight: number?): number
    local Height = WindowHeight or Tokens.WindowSize.Y
    if Height == Tokens.WindowSize.Y then
        return Tokens.PanelHeight
    end

    return math.max(80, Height - Tokens.PanelTop - Tokens.PanelBottom)
end

function Tokens.PanelLayout(Index: number, Count: number, WindowWidth: number?): (number, number)
    local WidthTarget = WindowWidth or Tokens.WindowSize.X
    if Count == 3 and WidthTarget == Tokens.WindowSize.X then
        return Tokens.PanelX(Index), Tokens.PanelWidth
    end

    local AreaWidth = math.max(1, WidthTarget - Tokens.PanelLeft - Tokens.PanelRight)
    local TotalGap = Tokens.PanelGap * math.max(Count - 1, 0)
    local UsableWidth = math.max(1, AreaWidth - TotalGap)
    local BaseWidth = math.floor(UsableWidth / math.max(Count, 1))
    local Remainder = UsableWidth - BaseWidth * math.max(Count, 1)
    local Width = BaseWidth + (Index == Count and Remainder or 0)
    local X = Tokens.PanelLeft + (Index - 1) * (BaseWidth + Tokens.PanelGap)
    return X, Width
end

return Tokens
