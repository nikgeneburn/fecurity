--!strict

local Elements = require("@fec/render/Elements")

local TabContainer = {}
TabContainer.__index = TabContainer

function TabContainer.New(Root: Frame)
    local self = setmetatable({}, TabContainer)

    self.Content = Elements.New("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromScale(1, 1),
        ZIndex = 20,
    }, Root) :: Frame

    self.Overlay = Elements.New("Frame", {
        Name = "Overlay",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromScale(1, 1),
        ZIndex = 200,
    }, Root) :: Frame

    return self
end

return TabContainer
