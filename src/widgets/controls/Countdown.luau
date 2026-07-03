--!strict

local BaseWidget = require("@fec/widgets/BaseWidget")
local Elements = require("@fec/render/Elements")
local Styling = require("@fec/render/Styling")
local FontLoader = require("@fec/assets/FontLoader")

local Countdown = {}
Countdown.__index = Countdown
setmetatable(Countdown, { __index = BaseWidget })

local function Format(Seconds: number): string
    Seconds = math.max(0, math.floor(Seconds))
    local Days = math.floor(Seconds / 86400)
    local Hours = math.floor((Seconds % 86400) / 3600)
    local Minutes = math.floor((Seconds % 3600) / 60)
    local Left = Seconds % 60
    return string.format("%d DAYS %d HOURS %d MINS %d SECS", Days, Hours, Minutes, Left)
end

local function ToneColor(Theme: { [string]: any }, Tone: string?): Color3
    if Tone == "muted" then
        return Theme.Muted
    elseif Tone == "success" then
        return Theme.Success
    end
    return Theme.Text
end

function Countdown.New(Section: any, Options: { [string]: any })
    Options.Default = Options.Seconds or 0
    local self = BaseWidget.New(Section, Options, Options.Height or 49)
    setmetatable(self, Countdown)
    local Theme = self.Window.Theme
    self.EndsAt = os.clock() + (Options.Seconds or 0)
    self.Running = true

    local Label = Elements.New("TextLabel", {
        Name = "Countdown",
        Size = UDim2.fromScale(1, 1),
        Text = Options.Text or Format(Options.Seconds or 0),
        ZIndex = 31,
    }, self.Root) :: TextLabel
    Styling.ApplyText(Label, Theme, 14, ToneColor(Theme, Options.Tone))
    FontLoader.Apply(Label, self.Library.AssetCache)
    self.Label = Label
    self:BindTheme(function(NewTheme)
        Label.TextColor3 = ToneColor(NewTheme, Options.Tone)
    end)

    task.spawn(function()
        while self.Running and self.Root and self.Root.Parent do
            self:SetValue(math.max(0, self.EndsAt - os.clock()), false)
            task.wait(1)
        end
    end)

    return self
end

function Countdown:SetValue(Value: any, RunCallback: boolean?)
    local Seconds = tonumber(Value) or 0
    self:Commit(Seconds, RunCallback)
    self.Label.Text = Format(Seconds)
end

function Countdown:Destroy()
    self.Running = false
    BaseWidget.Destroy(self)
end

return Countdown
