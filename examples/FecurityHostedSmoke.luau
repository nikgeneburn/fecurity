--!strict

local RawBase = "https://raw.githubusercontent.com/nikgeneburn/fecurity/main/"

if getgenv then
    getgenv().FecurityAssetBaseUrl = RawBase
end

local function Expect(Condition: boolean, Message: string)
    assert(Condition, "[Fecurity smoke] " .. Message)
end

local function ExpectMethod(Target: any, Name: string)
    Expect(type(Target[Name]) == "function", "missing method " .. Name)
end

local Environment = getfenv()
if getgenv then
    local Ok, GlobalEnvironment = pcall(getgenv)
    if Ok and type(GlobalEnvironment) == "table" then
        Environment = GlobalEnvironment
    end
end

local function GetGlobal(Name: string): any
    return Environment[Name] or getfenv()[Name]
end

for _, Name in ipairs({ "isfolder", "makefolder", "isfile", "writefile", "readfile", "delfile" }) do
    Expect(type(GetGlobal(Name)) == "function", "missing executor file API " .. Name)
end

local Fecurity = loadstring(game:HttpGet(RawBase .. "dist/Fecurity.lua"))()
Expect(type(Fecurity) == "table", "hosted bundle did not return a table")

for _, Name in ipairs({
    "CreateWindow",
    "Notify",
    "AddWarning",
    "SaveConfig",
    "LoadConfig",
    "GetConfigs",
    "SetAccent",
    "SetTheme",
    "SetAssetBaseUrl",
    "Toggle",
    "Close",
    "Open",
    "Unload",
}) do
    ExpectMethod(Fecurity, Name)
end

for _, Folder in ipairs({
    "Fecurity",
    "Fecurity/Assets",
    "Fecurity/Assets/Fonts",
    "Fecurity/Assets/Icons",
    "Fecurity/Assets/Images",
    "Fecurity/Configs",
    "Fecurity/Logs",
}) do
    Expect(isfolder(Folder), "missing cache folder " .. Folder)
end

local CallbackCount = 0
local Window = Fecurity:CreateWindow({
    Title = "Fecurity",
    Subtitle = "Hosted Smoke",
    Size = UDim2.fromOffset(840, 480),
    Accent = Color3.fromRGB(106, 98, 198),
    Theme = "Dark",
})
ExpectMethod(Window, "SetMenuKey")
Window:SetMenuKey(Enum.KeyCode.Insert)
Expect(Window.MenuKey == "INS", "menu key did not normalize")

local Assist = Window:AddTab("Assist", { Icon = "assist" })
local Visuals = Window:AddTab("Visuals", { Icon = "visuals" })
local Misc = Window:AddTab("Misc", { Icon = "misc" })
local Colors = Window:AddTab("Colors", { Icon = "colors" })
Window:AddTab("Trial", { Icon = "trial" })

local AssistSection = Assist:AddColumn():AddSection("Smoke")
AssistSection:AddDivider("General")
local Toggle = AssistSection:AddToggle({
    Text = "Enabled",
    Flag = "smoke.enabled",
    Default = true,
    Callback = function()
        CallbackCount += 1
    end,
})
local Slider = AssistSection:AddSlider({ Text = "Amount", Flag = "smoke.amount", Min = 0, Max = 100, Default = 50, Suffix = "%" })
local Dropdown = AssistSection:AddDropdown({ Text = "Mode", Flag = "smoke.mode", Default = "Normal", Values = { "Normal", "Fast", "Smooth" } })
local Multi = AssistSection:AddList({ Text = "Tags", Flag = "smoke.tags", Multi = true, Default = { "Name" }, Values = { "Name", "Distance", "Weapon" } })
local Box = AssistSection:AddBox({ Text = "Name", Flag = "smoke.name", Default = "Fecurity" })
local Bind = AssistSection:AddBind({ Text = "Menu Key", Flag = "smoke.menuKey", Default = "INS" })
local EnumBind = AssistSection:AddBind({ Text = "Enum Key", Flag = "smoke.enumKey", Default = Enum.KeyCode.End })
local Color = AssistSection:AddColor({ Text = "Accent", Flag = "smoke.accent", Default = Color3.fromRGB(106, 98, 198) })
local SkipColor = AssistSection:AddColor({ Text = "Unsaved Color", Flag = "smoke.skipColor", Default = Color3.fromRGB(255, 255, 255), SkipFlag = true })
AssistSection:AddButton({ Text = "PING", Callback = function() CallbackCount += 1 end })
AssistSection:AddLabel({ Text = "Smoke label", Tone = "muted", Height = 28 })
Toggle:AddColor({ Text = "Attached Color", Flag = "smoke.attachedColor", Default = Color3.fromRGB(255, 255, 255) })
Toggle:AddBind({ Text = "Attached Bind", Flag = "smoke.attachedBind", Default = "M1" })
ExpectMethod(Slider, "Destroy")
ExpectMethod(Dropdown, "Destroy")
ExpectMethod(Color, "Destroy")
local TempToggle = AssistSection:AddToggle({ Text = "Temp Toggle", Flag = "smoke.tempToggle", Default = true })
Expect(Fecurity.FlagManager.Widgets["smoke.tempToggle"] ~= nil, "temp toggle did not register")
local ThemeBindingCount = #Window.ThemeBindings
TempToggle:Destroy()
Expect(Fecurity.FlagManager.Widgets["smoke.tempToggle"] == nil, "destroyed toggle remained registered")
Expect(Fecurity.Flags["smoke.tempToggle"] == true, "destroyed toggle lost its saved flag value")
Expect(#Window.ThemeBindings < ThemeBindingCount, "destroyed toggle retained theme binding")
local TempColor = AssistSection:AddColor({ Text = "Temp Color", Flag = "smoke.tempColor", Default = Color3.fromRGB(12, 34, 56) })
Expect(Fecurity.FlagManager.Widgets["smoke.tempColor.Alpha"] ~= nil, "temp color alpha did not register")
TempColor:Destroy()
Expect(Fecurity.FlagManager.Widgets["smoke.tempColor.Alpha"] == nil, "destroyed color alpha remained registered")
Fecurity:SetTheme("Dark")

local VisualSection = Visuals:AddColumn():AddSection("Preview")
VisualSection:AddHitboxPreview({ Flag = "smoke.hitboxPriority" })

local MiscSection = Misc:AddColumn():AddSection("Config")
MiscSection:AddCountdown({ Text = "00:00:05", Seconds = 5, Height = 28 })
local ConfigList = MiscSection:AddConfigList({ Text = "Configs", Flag = "smoke.config" })

local ThemeSection = Colors:AddColumn():AddSection("Theme")
ThemeSection:AddColor({
    Text = "Accent",
    Flag = "smoke.themeAccent",
    Default = Color3.fromRGB(106, 98, 198),
    Callback = function(Value)
        Fecurity:SetAccent(Value)
    end,
})

Toggle:SetValue(false)
Slider:SetValue(75)
Dropdown:SetValue("Fast")
Multi:SetValue({ "Name", "Weapon" })
Box:SetValue("Verified")
Bind:SetValue("F")
Expect(Fecurity.Flags["smoke.enumKey"] == "End", "enum keybind default did not normalize")
EnumBind:SetValue(Enum.KeyCode.Insert)
Color:SetValue(Color3.fromRGB(255, 20, 18))
SkipColor:SetValue(Color3.fromRGB(1, 2, 3))

Expect(Fecurity.Flags["smoke.enabled"] == false, "toggle flag did not update")
Expect(Fecurity.Flags["smoke.amount"] == 75, "slider flag did not update")
Expect(Fecurity.Flags["smoke.mode"] == "Fast", "dropdown flag did not update")
Expect(Fecurity.Flags["smoke.name"] == "Verified", "textbox flag did not update")
Expect(Fecurity.Flags["smoke.enumKey"] == "INS", "enum keybind set did not normalize")
Expect(Fecurity.Flags["smoke.skipColor"] ~= nil, "skip flag did not update in memory")
Expect(CallbackCount > 0, "callbacks did not run")

Expect(Fecurity:SaveConfig("FecuritySmoke") == true, "config did not save")
Expect(string.find(readfile("Fecurity/Configs/FecuritySmoke.json"), "smoke%.skipColor") == nil, "skip flag was saved")
Expect(Fecurity.Flags["smoke.config"] == "FecuritySmoke", "config list did not update after save")
Toggle:SetValue(true, false)
Expect(Fecurity:LoadConfig("FecuritySmoke", true) == true, "config did not load")
Expect(Fecurity.Flags["smoke.enabled"] == false, "config load did not restore flags")
Expect(ConfigList.Value == "FecuritySmoke", "config list widget did not keep saved config selected")

Fecurity:Notify({ Title = "Fecurity", Text = "Hosted smoke passed.", Duration = 2 })
Fecurity:AddWarning({ Title = "Fecurity", Text = "Smoke warning check.", Duration = 1 })
Fecurity:SetTheme("Dark")
Expect(Fecurity:SetAssetBaseUrl(RawBase) == true, "asset base url refresh did not report ready")
Fecurity:Close()
Fecurity:Open()
Fecurity:Toggle()
Fecurity:Toggle()
Fecurity:Unload()
Fecurity:Unload()

local LifecycleOk = pcall(function()
    Window:Open()
    Window:Close()
    Window:Toggle()
    Window:Destroy()
    Window:SetAccent(Color3.fromRGB(106, 98, 198))
    Window:SetTheme("Dark")
end)
Expect(LifecycleOk, "destroyed window lifecycle methods errored")

return true
