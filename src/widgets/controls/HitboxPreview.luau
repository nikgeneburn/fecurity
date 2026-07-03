--!strict

local BaseWidget = require("@fec/widgets/BaseWidget")
local Elements = require("@fec/render/Elements")
local Styling = require("@fec/render/Styling")
local FontLoader = require("@fec/assets/FontLoader")
local ImageLoader = require("@fec/assets/ImageLoader")
local Tween = require("@fec/animation/Tween")

local HitboxPreview = {}
HitboxPreview.__index = HitboxPreview
setmetatable(HitboxPreview, { __index = BaseWidget })

local Priorities = {
    { Id = "First", Color = Color3.fromRGB(72, 25, 20), Stroke = Color3.fromRGB(131, 53, 68) },
    { Id = "Second", Color = Color3.fromRGB(75, 54, 27), Stroke = Color3.fromRGB(162, 148, 112) },
    { Id = "Third", Color = Color3.fromRGB(35, 61, 23), Stroke = Color3.fromRGB(101, 149, 94) },
    { Id = "Fourth", Color = Color3.fromRGB(12, 62, 90), Stroke = Color3.fromRGB(50, 115, 145) },
    { Id = "Ignore", Color = Color3.fromRGB(29, 30, 36), Stroke = Color3.fromRGB(69, 71, 77) },
}

local Regions = {
    { Id = "Head", X = 73, Y = 12, W = 34, H = 48 },
    { Id = "Body", X = 52, Y = 60, W = 78, H = 116 },
    { Id = "LeftArm", X = 18, Y = 72, W = 42, H = 118 },
    { Id = "RightArm", X = 122, Y = 72, W = 42, H = 118 },
    { Id = "LeftLeg", X = 54, Y = 170, W = 38, H = 110 },
    { Id = "RightLeg", X = 91, Y = 170, W = 38, H = 110 },
}

local FallbackParts = {
    { Name = "Head", X = 75, Y = 14, W = 30, H = 38, Round = 18 },
    { Name = "Neck", X = 82, Y = 52, W = 16, H = 16, Round = 4 },
    { Name = "Torso", X = 56, Y = 66, W = 68, H = 104, Round = 4 },
    { Name = "LeftArm", X = 24, Y = 78, W = 24, H = 108, Round = 4 },
    { Name = "RightArm", X = 132, Y = 78, W = 24, H = 108, Round = 4 },
    { Name = "LeftLeg", X = 58, Y = 170, W = 28, H = 108, Round = 4 },
    { Name = "RightLeg", X = 94, Y = 170, W = 28, H = 108, Round = 4 },
}

function HitboxPreview:CreateImageFallback(Theme: { [string]: any })
    local Holder = Elements.New("Frame", {
        Name = "PreviewFallback",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(17, 8),
        Size = UDim2.fromOffset(178, 274),
        ZIndex = 30,
    }, self.Root) :: Frame
    self.FallbackParts = {}

    for _, Part in ipairs(FallbackParts) do
        local Frame = Elements.New("Frame", {
            Name = Part.Name,
            BackgroundColor3 = Theme.Muted,
            BackgroundTransparency = 0.52,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(Part.X, Part.Y),
            Size = UDim2.fromOffset(Part.W, Part.H),
            ZIndex = 30,
        }, Holder) :: Frame
        Elements.Corner(Frame, Part.Round)
        table.insert(self.FallbackParts, Frame)
    end

    self:BindTheme(function(NewTheme)
        for _, Part in ipairs(self.FallbackParts) do
            Part.BackgroundColor3 = NewTheme.Muted
        end
    end)
end

function HitboxPreview.New(Section: any, Options: { [string]: any })
    Options.Default = Options.Default or {}
    local self = BaseWidget.New(Section, Options, 681)
    setmetatable(self, HitboxPreview)
    local Theme = self.Window.Theme
    self.RegionState = table.clone(self.Value)
    self.Overlays = {}

    local Image = Elements.New("ImageLabel", {
        Name = "PreviewImage",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(17, 8),
        Size = UDim2.fromOffset(178, 274),
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 31,
    }, self.Root) :: ImageLabel
    if not ImageLoader.Apply(Image, self.Library.AssetCache, "HitboxPreview") then
        Image.Visible = false
        self:CreateImageFallback(Theme)
    end
    self.Image = Image

    for _, Region in ipairs(Regions) do
        local Overlay = Elements.New("TextButton", {
            Name = Region.Id,
            AutoButtonColor = false,
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(17 + Region.X, 8 + Region.Y),
            Size = UDim2.fromOffset(Region.W, Region.H),
            Text = "",
            ZIndex = 34,
        }, self.Root) :: TextButton
        self.Overlays[Region.Id] = Overlay
        Overlay.MouseButton1Click:Connect(function()
            self:Cycle(Region.Id)
        end)
        Overlay.MouseEnter:Connect(function()
            local Priority = self:PriorityFor(Region.Id)
            if Priority then
                Tween.Play(Overlay, 0.12, { BackgroundColor3 = Priority.Color, BackgroundTransparency = 0.32 })
            else
                Tween.Play(Overlay, 0.12, { BackgroundColor3 = self.Window.Theme.Accent, BackgroundTransparency = 0.84 })
            end
        end)
        Overlay.MouseLeave:Connect(function()
            self:Refresh()
        end)
    end

    local LegendLayout = {
        [1] = { Row = 0, Col = 0 }, -- First
        [2] = { Row = 1, Col = 0 }, -- Second
        [3] = { Row = 2, Col = 0 }, -- Third
        [4] = { Row = 0, Col = 1 }, -- Fourth
        [5] = { Row = 1, Col = 1 }, -- Ignore
    }

    for Index, Priority in ipairs(Priorities) do
        local Slot = LegendLayout[Index]
        local Row = Slot.Row
        local Col = Slot.Col
        local Dot = Elements.New("Frame", {
            Name = Priority.Id .. "Dot",
            BackgroundColor3 = Priority.Color,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(2 + Col * 94, 304 + Row * 22),
            Size = UDim2.fromOffset(10, 10),
            ZIndex = 31,
        }, self.Root) :: Frame
        Elements.Corner(Dot, 5)
        Elements.Stroke(Dot, Priority.Stroke, 0, 1)
        local Label = Elements.New("TextLabel", {
            Name = Priority.Id,
            Position = UDim2.fromOffset(19 + Col * 94, 300 + Row * 22),
            Size = UDim2.fromOffset(70, 20),
            Text = Priority.Id,
            ZIndex = 31,
        }, self.Root) :: TextLabel
        Styling.ApplyText(Label, Theme, 14, Theme.Muted)
        FontLoader.Apply(Label, self.Library.AssetCache)
    end

    local Help = Elements.New("TextLabel", {
        Name = "Help",
        Position = UDim2.fromOffset(2, 358),
        Size = UDim2.new(1, 0, 0, 18),
        Text = "Edit hitboxes by clicking on a body part.",
        ZIndex = 31,
    }, self.Root) :: TextLabel
    Styling.ApplyText(Help, Theme, 15, Theme.Hint)
    FontLoader.Apply(Help, self.Library.AssetCache)

    self:Refresh()
    return self
end

function HitboxPreview:PriorityFor(Region: string)
    local Index = self.RegionState[Region]
    if not Index then
        return nil
    end
    return Priorities[Index]
end

function HitboxPreview:Cycle(Region: string)
    local Next = (self.RegionState[Region] or 0) + 1
    if Next > #Priorities then
        Next = nil
    end
    self.RegionState[Region] = Next
    self:SetValue(self.RegionState)
end

function HitboxPreview:Refresh()
    for Region, Overlay in pairs(self.Overlays) do
        local Priority = self:PriorityFor(Region)
        if Priority then
            Overlay.BackgroundColor3 = Priority.Color
            Overlay.BackgroundTransparency = 0.46
        else
            Overlay.BackgroundTransparency = 1
        end
    end
end

function HitboxPreview:SetValue(Value: any, RunCallback: boolean?)
    if type(Value) ~= "table" then
        Value = {}
    end
    self.RegionState = table.clone(Value)
    self:Commit(self.RegionState, RunCallback)
    self:Refresh()
end

return HitboxPreview
