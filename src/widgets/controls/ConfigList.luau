--!strict

local Dropdown = require("@fec/widgets/controls/Dropdown")

local ConfigList = {}

function ConfigList.New(Section: any, Options: { [string]: any })
    local Library = Section.Window.Library
    local function ReadValues()
        local Values = Library:GetConfigs()
        if #Values == 0 then
            return { "None" }
        end
        return Values
    end

    Options.Text = Options.Text or "Config"
    Options.Hint = Options.Hint or "Select saved config"
    Options.Flag = Options.Flag or "config.selected"
    Options.Values = ReadValues()
    Options.Default = Options.Default or Options.Values[1] or "None"
    Options.GetValues = ReadValues

    local Widget = Dropdown.New(Section, Options)
    function Widget:RefreshConfigs(SelectedName: string?)
        local Values = ReadValues()
        self:SetValues(Values, SelectedName or self.Value)
    end
    Library:RegisterConfigList(Widget)
    return Widget
end

return ConfigList
