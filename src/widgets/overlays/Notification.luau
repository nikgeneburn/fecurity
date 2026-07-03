--!strict

local Elements = require("@fec/render/Elements")
local Styling = require("@fec/render/Styling")
local FontLoader = require("@fec/assets/FontLoader")
local Tween = require("@fec/animation/Tween")

local Notification = {}

function Notification.New(Window: any, Options: { [string]: any })
    local Theme = Window.Theme
    local Root = Elements.New("Frame", {
        Name = "Notification",
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(250, 62),
        ZIndex = 401,
    }, Window.Notifications) :: Frame
    Elements.Stroke(Root, Theme.Border, 0, 1)
    Elements.Padding(Root, 12, 8, 12, 8)

    local Title = Elements.New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 18),
        Text = Options.Title or "Fecurity",
        ZIndex = 402,
    }, Root) :: TextLabel
    Styling.ApplyText(Title, Theme, 12, Theme.Text)
    FontLoader.Apply(Title, Window.Library.AssetCache)

    local Body = Elements.New("TextLabel", {
        Name = "Body",
        Position = UDim2.fromOffset(0, 20),
        Size = UDim2.new(1, 0, 0, 28),
        Text = Options.Text or Options.Message or "",
        TextWrapped = true,
        ZIndex = 402,
    }, Root) :: TextLabel
    Styling.ApplyText(Body, Theme, 11, Theme.Hint)
    FontLoader.Apply(Body, Window.Library.AssetCache)

    Root.BackgroundTransparency = 1
    Tween.Play(Root, 0.16, { BackgroundTransparency = 0 })
    task.delay(Options.Duration or 3, function()
        if Root and Root.Parent then
            local Created = Tween.Play(Root, 0.16, { BackgroundTransparency = 1 })
            Created.Completed:Once(function()
                if Root and Root.Parent then
                    Root:Destroy()
                end
            end)
        end
    end)

    return Root
end

return Notification

