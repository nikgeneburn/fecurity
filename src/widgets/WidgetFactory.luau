--!strict

local WidgetFactory = {}

WidgetFactory.Controls = {
    Toggle = require("@fec/widgets/controls/Toggle"),
    Slider = require("@fec/widgets/controls/Slider"),
    Dropdown = require("@fec/widgets/controls/Dropdown"),
    Button = require("@fec/widgets/controls/Button"),
    Textbox = require("@fec/widgets/controls/Textbox"),
    Keybind = require("@fec/widgets/controls/Keybind"),
    ColorPicker = require("@fec/widgets/controls/ColorPicker"),
    HitboxPreview = require("@fec/widgets/controls/HitboxPreview"),
    Countdown = require("@fec/widgets/controls/Countdown"),
    ConfigList = require("@fec/widgets/controls/ConfigList"),
    Label = require("@fec/widgets/controls/Label"),
}

function WidgetFactory.Create(Kind: string, Section: any, Options: { [string]: any })
    local Control = WidgetFactory.Controls[Kind]
    assert(Control, "Unknown Fecurity widget: " .. tostring(Kind))
    return Control.New(Section, Options)
end

return WidgetFactory
