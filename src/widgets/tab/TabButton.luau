--!strict

local Tween = require("@fec/animation/Tween")
local Elements = require("@fec/render/Elements")
local Styling = require("@fec/render/Styling")
local FontLoader = require("@fec/assets/FontLoader")
local IconLoader = require("@fec/assets/IconLoader")

local TabButton = {}
TabButton.__index = TabButton

local SlotY = { 72, 139, 206, 274, 340 }

function TabButton.New(Window: any, TabObject: any, Index: number)
    local self = setmetatable({
        Window = Window,
        Tab = TabObject,
        Active = false,
    }, TabButton)

    local Button = Elements.New("TextButton", {
        Name = TabObject.Name .. "Tab",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, SlotY[Index] or (72 + (Index - 1) * 67)),
        Size = UDim2.fromOffset(67, 64),
        Text = "",
        ZIndex = 25,
    }, Window.Sidebar.Root) :: TextButton
    self.Root = Button

    local Content = Elements.New("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 14),
        Size = UDim2.fromOffset(67, 34),
        ZIndex = 26,
    }, Button) :: Frame
    self.Content = Content

    local Icon = IconLoader.Apply(Content, TabObject.Icon, Window.Theme, Window.Library.AssetCache)
    local IconObject = Icon :: GuiObject
    IconObject.AnchorPoint = Vector2.new(0.5, 0)
    IconObject.Position = UDim2.new(0.5, 0, 0, 0)
    self.Icon = Icon

    local Label = Elements.New("TextLabel", {
        Name = "Label",
        Position = UDim2.fromOffset(0, 22),
        Size = UDim2.fromOffset(67, 12),
        Text = string.upper(TabObject.Name),
        ZIndex = 26,
    }, Content) :: TextLabel
    Styling.ApplyText(Label, Window.Theme, 14, Window.Theme.Muted)
    FontLoader.Apply(Label, Window.Library.AssetCache)
    Label.TextXAlignment = Enum.TextXAlignment.Center
    self.Label = Label

    Button.MouseButton1Click:Connect(function()
        Window:SetActiveTab(TabObject)
    end)

    return self
end

function TabButton:SetActive(Value: boolean)
    self.Active = Value
    self:RefreshTheme()
    if Value then
        local SelectedTab = self.Window.Sidebar.SelectedTab
        SelectedTab.BackgroundTransparency = 0
        Tween.Play(SelectedTab, 0.16, {
            Position = UDim2.fromOffset(0, self.Root.Position.Y.Offset),
        })
    end
end

function TabButton:RefreshTheme()
    local Theme = self.Window.Theme
    local ActiveColor = self.Active and Theme.Accent or Theme.Muted
    if self.Icon:IsA("ImageLabel") then
        self.Icon.ImageColor3 = ActiveColor
    elseif self.Icon:IsA("TextLabel") then
        self.Icon.TextColor3 = ActiveColor
    end
    self.Label.TextColor3 = ActiveColor
end

return TabButton
