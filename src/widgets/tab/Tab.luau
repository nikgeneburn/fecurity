--!strict

local Transitions = require("@fec/animation/Transitions")
local Column = require("@fec/widgets/containers/Column")

local Tab = {}
Tab.__index = Tab

function Tab.New(Window: any, Name: string, Options: { [string]: any }, Index: number)
    local self = setmetatable({
        Window = Window,
        Name = Name,
        Icon = Options.Icon or string.lower(Name),
        Index = Index,
        Columns = {},
        Active = false,
    }, Tab)
    self.Button = Window.Sidebar:AddButton(self)
    return self
end

function Tab:AddColumn()
    local NewColumn = Column.New(self, #self.Columns + 1)
    table.insert(self.Columns, NewColumn)
    self:RelayoutColumns()
    NewColumn.Root.Visible = self.Active
    return NewColumn
end

function Tab:RelayoutColumns()
    local Count = #self.Columns
    for Index, ColumnObject in ipairs(self.Columns) do
        ColumnObject:ApplyLayout(Index, Count)
    end
end

function Tab:SetActive(Value: boolean)
    self.Active = Value
    if self.Button then
        self.Button:SetActive(Value)
    end
    for Index, ColumnObject in ipairs(self.Columns) do
        if Value then
            Transitions.PanelIn(ColumnObject.Root, (Index - 1) * 0.025)
        else
            Transitions.PanelOut(ColumnObject.Root, (Index - 1) * 0.012)
        end
    end
end

function Tab:RefreshTheme()
    if self.Button then
        self.Button:RefreshTheme()
    end
end

return Tab
