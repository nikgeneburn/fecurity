--!strict

local RawBase = "https://raw.githubusercontent.com/nikgeneburn/fecurity/main/"

if getgenv then
    getgenv().FecurityAssetBaseUrl = RawBase
end

local Fecurity = require(RawBase .. "dist/Fecurity.lua")

local Window = Fecurity:CreateWindow({
    Title = "Fecurity",
    Subtitle = "Hosted Require",
    Size = UDim2.fromOffset(840, 720),
    Accent = Color3.fromRGB(106, 98, 198),
    Theme = "Dark",
})

local Assist = Window:AddTab("Assist", { Icon = "assist" })
local Visuals = Window:AddTab("Visuals", { Icon = "visuals" })
local Misc = Window:AddTab("Misc", { Icon = "misc" })
Window:AddTab("Colors", { Icon = "colors" })
Window:AddTab("Trial", { Icon = "trial" })

local General = Assist:AddColumn():AddSection("General")
General:AddToggle({ Text = "Enabled", Hint = "Enables aimbot", Flag = "require.assist.enabled", Default = true })
General:AddSlider({ Text = "Aim Horizontal Speed", Flag = "require.assist.speed", Min = 0, Max = 100, Default = 30, Suffix = "%" })
General:AddDropdown({ Text = "Aimbot Type", Flag = "require.assist.type", Default = "Silent", Values = { "Silent", "Memory", "Mouse" } })

local VisualSection = Visuals:AddColumn():AddSection("Visuals")
VisualSection:AddToggle({ Text = "Enabled", Flag = "require.visuals.enabled", Default = true })
VisualSection:AddList({ Text = "Player Info", Flag = "require.visuals.info", Multi = true, Default = { "Distance" }, Values = { "Distance", "Name", "Weapon", "Health" } })

local Config = Misc:AddColumn():AddSection("Config")
Config:AddConfigList({ Text = "Config", Flag = "require.config.selected" })
Config:AddButton({ Text = "SAVE CONFIG", Callback = function() Fecurity:SaveConfig("RequireDemo") end })
Config:AddButton({ Text = "LOAD CONFIG", Callback = function() Fecurity:LoadConfig(Fecurity.Flags["require.config.selected"] or "RequireDemo", true) end })

Fecurity:Notify({
    Title = "Fecurity",
    Text = "Hosted require demo loaded.",
    Duration = 3,
})

return Fecurity
