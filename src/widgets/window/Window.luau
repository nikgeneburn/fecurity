--!strict

local UserInputService = game:GetService("UserInputService")
local Tween = require("@fec/animation/Tween")
local Runtime = require("@fec/core/Runtime")
local ThemeModule = require("@fec/theme/Theme")
local Tokens = require("@fec/theme/Tokens")
local Elements = require("@fec/render/Elements")
local DragController = require("@fec/input/DragController")
local KeybindManager = require("@fec/input/KeybindManager")
local Sidebar = require("@fec/widgets/window/Sidebar")
local SnowLayer = require("@fec/widgets/window/SnowLayer")
local Topbar = require("@fec/widgets/window/Topbar")
local Tab = require("@fec/widgets/tab/Tab")
local TabContainer = require("@fec/widgets/tab/TabContainer")
local Notification = require("@fec/widgets/overlays/Notification")
local Warning = require("@fec/widgets/overlays/Warning")
local FOVCircle = require("@fec/widgets/overlays/FOVCircle")

local Window = {}
Window.__index = Window

local function ScaleSize(Size: UDim2, Factor: number): UDim2
    return UDim2.new(
        Size.X.Scale * Factor,
        math.floor(Size.X.Offset * Factor),
        Size.Y.Scale * Factor,
        math.floor(Size.Y.Offset * Factor)
    )
end

function Window.New(Library: any, Options: { [string]: any })
    local self = setmetatable({
        Library = Library,
        Options = Options,
        TargetSize = Options.Size or UDim2.fromOffset(Tokens.WindowSize.X, Tokens.WindowSize.Y),
        Theme = ThemeModule.Resolve(Options.Theme or "Dark", Options.Accent),
        Tabs = {},
        ActiveTab = nil,
        Visible = true,
        MenuKey = KeybindManager.Normalize(Options.MenuKey or Options.ToggleKey or Enum.KeyCode.Insert),
        Dropdown = nil,
        ThemeBindings = {},
        FOVCircles = {},
    }, Window)

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "Fecurity"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Runtime.AttachGui(Gui)
    self.Gui = Gui

    local Canvas = Elements.New("Frame", {
        Name = "Canvas",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 1,
    }, Gui) :: Frame
    self.Canvas = Canvas
    self.SnowLayer = SnowLayer.New(self, Canvas)

    local Root = Elements.New("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = self.TargetSize,
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 10,
    }, Canvas) :: Frame
    self.RootStroke = Elements.Stroke(Root, self.Theme.Border, 0, 1)
    self.Root = Root
    self.Topbar = Topbar.New(self, Root, Options)

    self.TabContainer = TabContainer.New(Root)
    self.Content = self.TabContainer.Content
    self.Overlay = self.TabContainer.Overlay

    self.Notifications = Elements.New("Frame", {
        Name = "Notifications",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 16),
        Size = UDim2.fromOffset(250, 400),
        ZIndex = 400,
    }, Canvas) :: Frame
    Elements.List(self.Notifications, Enum.FillDirection.Vertical, 8)

    self.Sidebar = Sidebar.New(self)
    self.UnbindDrag = DragController.Attach(self.Topbar.Handle, Root)

    self.InsertConnection = UserInputService.InputBegan:Connect(function(Input, Processed)
        if Processed then
            return
        end
        if KeybindManager.IsActivation(Input, self.MenuKey) then
            self:Toggle()
        end
    end)

    self:RegisterThemeBinding(function(Theme)
        Root.BackgroundColor3 = Theme.Surface
        self.RootStroke.Color = Theme.Border
    end)

    return self
end

function Window:AddTab(Name: string, Options: { [string]: any }?)
    local NewTab = Tab.New(self, Name, Options or {}, #self.Tabs + 1)
    table.insert(self.Tabs, NewTab)
    if not self.ActiveTab then
        self:SetActiveTab(NewTab)
    else
        NewTab:SetActive(false)
    end
    return NewTab
end

function Window:SetActiveTab(TabObject: any)
    if self.Destroyed then
        return
    end
    if self.ActiveTab == TabObject then
        return
    end
    if self.ActiveTab then
        self.ActiveTab:SetActive(false)
    end
    self.ActiveTab = TabObject
    self.ActiveTab:SetActive(true)
end

function Window:SetAccent(Color: Color3)
    if self.Destroyed then
        return false
    end
    self.Theme.Accent = Color
    self:RefreshTheme()
    return true
end

function Window:SetTheme(ThemeValue: any)
    if self.Destroyed then
        return false
    end
    local Accent = self.Theme.Accent
    if type(ThemeValue) == "table" and ThemeValue.Accent then
        Accent = ThemeValue.Accent
    end
    local NextTheme = ThemeModule.Resolve(ThemeValue, Accent)
    ThemeModule.Apply(self.Theme, NextTheme)
    self:RefreshTheme()
    return true
end

function Window:RefreshTheme()
    if self.Destroyed then
        return
    end
    if self.Sidebar then
        self.Sidebar:RefreshTheme()
    end
    for _, TabObject in ipairs(self.Tabs) do
        TabObject:RefreshTheme()
    end
    for _, Binding in ipairs(self.ThemeBindings) do
        pcall(Binding, self.Theme)
    end
end

function Window:RegisterThemeBinding(Binding: (any) -> ())
    table.insert(self.ThemeBindings, Binding)
    Binding(self.Theme)
    local Active = true
    return function()
        if not Active then
            return
        end
        Active = false
        for Index = #self.ThemeBindings, 1, -1 do
            if self.ThemeBindings[Index] == Binding then
                table.remove(self.ThemeBindings, Index)
                return
            end
        end
    end
end

function Window:SetMenuKey(Value: any)
    if self.Destroyed then
        return self
    end
    self.MenuKey = KeybindManager.Normalize(Value or Enum.KeyCode.Insert)
    return self
end

function Window:Open()
    if self.Destroyed or not self.Root then
        return false
    end
    self.Visible = true
    if self.SnowLayer then
        self.SnowLayer:SetVisible(true)
    end
    self.Root.Visible = true
    self.Root.Size = ScaleSize(self.TargetSize, 0.94)
    Tween.Play(self.Root, 0.18, { Size = self.TargetSize })
    return true
end

function Window:Close()
    if self.Destroyed or not self.Root then
        return false
    end
    self.Visible = false
    if self.SnowLayer then
        self.SnowLayer:SetVisible(false)
    end
    local Created = Tween.Play(self.Root, 0.18, { Size = ScaleSize(self.TargetSize, 0.94) })
    Created.Completed:Once(function()
        if not self.Visible and self.Root then
            self.Root.Visible = false
        end
    end)
    return true
end

function Window:Toggle()
    if self.Visible then
        return self:Close()
    else
        return self:Open()
    end
end

function Window:Notify(Options: { [string]: any })
    return Notification.New(self, Options)
end

function Window:AddWarning(Options: { [string]: any })
    return Warning.New(self, Options)
end

function Window:CreateFOVCircle()
    local Circle = FOVCircle.New(self.Canvas)
    table.insert(self.FOVCircles, Circle)
    return Circle
end

function Window:Destroy()
    if self.Destroyed then
        return
    end
    self.Destroyed = true
    if self.Dropdown and self.Dropdown.CloseMenu then
        pcall(function()
            self.Dropdown:CloseMenu(true)
        end)
        self.Dropdown = nil
    end
    if self.InsertConnection then
        self.InsertConnection:Disconnect()
        self.InsertConnection = nil
    end
    if self.UnbindDrag then
        pcall(self.UnbindDrag)
        self.UnbindDrag = nil
    end
    if self.SnowLayer then
        self.SnowLayer:Destroy()
        self.SnowLayer = nil
    end
    for _, Circle in ipairs(self.FOVCircles) do
        pcall(function()
            Circle:Destroy()
        end)
    end
    table.clear(self.FOVCircles)
    if self.Gui then
        self.Gui:Destroy()
        self.Gui = nil
    end
    table.clear(self.ThemeBindings)
    table.clear(self.Tabs)
    self.ActiveTab = nil
    self.Sidebar = nil
    self.Root = nil
    self.Canvas = nil
    self.Content = nil
    self.Overlay = nil
    self.Notifications = nil
    self.Topbar = nil
end

return Window
