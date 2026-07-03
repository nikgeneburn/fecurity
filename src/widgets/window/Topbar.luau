--!strict

local Elements = require("@fec/render/Elements")

local Topbar = {}
Topbar.__index = Topbar

Topbar.Height = 16

function Topbar.New(Window: any, Root: Frame, Options: { [string]: any })
    local self = setmetatable({
        Window = Window,
        Root = Root,
        Title = Options.Title or "Fecurity",
        Subtitle = Options.Subtitle or "",
    }, Topbar)

    self.Handle = Elements.New("Frame", {
        Name = "DragHandle",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = true,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, Topbar.Height),
        ZIndex = 15,
    }, Root) :: Frame

    self:Apply()
    return self
end

function Topbar:Apply()
    self.Root:SetAttribute("FecurityTitle", self.Title)
    self.Root:SetAttribute("FecuritySubtitle", self.Subtitle)
end

function Topbar:SetTitle(Title: string, Subtitle: string?)
    self.Title = Title
    if Subtitle ~= nil then
        self.Subtitle = Subtitle
    end
    self:Apply()
end

return Topbar
