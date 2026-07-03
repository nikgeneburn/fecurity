--!strict

local RawBase = "https://raw.githubusercontent.com/nikgeneburn/fecurity/main/"

if getgenv then
    getgenv().FecurityAssetBaseUrl = RawBase
end

local Fecurity = loadstring(game:HttpGet(RawBase .. "dist/Fecurity.lua"))()

local Window = Fecurity:CreateWindow({
    Title = "Fecurity",
    Subtitle = "Hosted Demo",
    Size = UDim2.fromOffset(840, 480),
    Accent = Color3.fromRGB(106, 98, 198),
    Theme = "Dark",
})

local Assist = Window:AddTab("Assist", { Icon = "assist" })
local Visuals = Window:AddTab("Visuals", { Icon = "visuals" })
local Misc = Window:AddTab("Misc", { Icon = "misc" })
local Colors = Window:AddTab("Colors", { Icon = "colors" })
Window:AddTab("Trial", { Icon = "trial" })

local Main = Assist:AddColumn():AddSection("General")
Main:AddToggle({ Text = "Enabled", Hint = "Enables aimbot", Flag = "assist.enabled", Default = true })
Main:AddDropdown({ Text = "Aimbot Type", Hint = "Select Aimbot Types", Flag = "assist.aimbotType", Default = "Silent", Values = { "Silent", "Memory", "Mouse" } })
Main:AddSlider({ Text = "Aim Horizontal Speed", Flag = "assist.horizontalSpeed", Min = 0, Max = 100, Default = 30, Suffix = "%" })
Main:AddKeybind({ Text = "Aim Key", Hint = "Primary aim key", Flag = "assist.aimKey", Default = "M1" })

local VisualMain = Visuals:AddColumn():AddSection("General")
VisualMain:AddToggle({ Text = "Enabled", Hint = "Enables visuals", Flag = "visuals.enabled", Default = true })
VisualMain:AddDropdown({ Text = "Player Info", Hint = "Select player info", Flag = "visuals.playerInfo", Multi = true, Default = { "Distance" }, Values = { "Distance", "Name", "Weapon", "Health" } })

local Settings = Misc:AddColumn():AddSection("Config")
Settings:AddConfigList({ Text = "Config", Hint = "Saved configs", Flag = "config.selected" })
Settings:AddButton({ Text = "SAVE CONFIG", Callback = function() Fecurity:SaveConfig("Default") end })
Settings:AddButton({ Text = "LOAD CONFIG", Callback = function() Fecurity:LoadConfig(Fecurity.Flags["config.selected"] or "Default", true) end })

local Theme = Colors:AddColumn():AddSection("Menu Colors")
Theme:AddColor({ Text = "Accent", Flag = "colors.accent", Default = Color3.fromRGB(106, 98, 198), Callback = function(Value) Fecurity:SetAccent(Value) end })

return Fecurity

