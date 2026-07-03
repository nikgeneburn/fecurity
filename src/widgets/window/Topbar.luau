--!strict

local Topbar = {}
Topbar.__index = Topbar

Topbar.Height = 0

function Topbar.New(Window: any, Root: Frame, Options: { [string]: any })
    local self = setmetatable({
        Window = Window,
        Root = Root,
        Title = Options.Title or "Fecurity",
        Subtitle = Options.Subtitle or "",
    }, Topbar)
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
