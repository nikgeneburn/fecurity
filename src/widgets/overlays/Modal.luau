--!strict

local Elements = require("@fec/render/Elements")
local Styling = require("@fec/render/Styling")
local FontLoader = require("@fec/assets/FontLoader")

local Modal = {}

function Modal.New(Window: any, Options: { [string]: any })
    local Theme = Window.Theme
    local Root = Elements.New("Frame", {
        Name = "Modal",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(260, 130),
        ZIndex = 300,
    }, Window.Overlay) :: Frame
    Elements.Stroke(Root, Theme.Border, 0, 1)
    Elements.Padding(Root, 14, 14, 14, 14)

    local Title = Elements.New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 22),
        Text = Options.Title or "Fecurity",
        ZIndex = 301,
    }, Root) :: TextLabel
    Styling.ApplyText(Title, Theme, 17, Theme.Text)
    FontLoader.Apply(Title, Window.Library.AssetCache)

    local Body = Elements.New("TextLabel", {
        Name = "Body",
        Position = UDim2.fromOffset(0, 30),
        Size = UDim2.new(1, 0, 0, 54),
        Text = Options.Text or Options.Message or "",
        TextWrapped = true,
        ZIndex = 301,
    }, Root) :: TextLabel
    Styling.ApplyText(Body, Theme, 15, Theme.Hint)
    FontLoader.Apply(Body, Window.Library.AssetCache)

    return Root
end

return Modal

