--!strict

local Fecurity = require(script.Parent.Parent.src)

local Window = Fecurity:CreateWindow({
    Title = "Fecurity",
    Subtitle = "Private UI Library",
    Size = UDim2.fromOffset(774, 481),
    Accent = Color3.fromRGB(106, 98, 198),
    Theme = "Dark",
})

local CurrentTheme = {
    Canvas = Color3.fromRGB(10, 10, 10),
    Surface = Color3.fromRGB(17, 17, 17),
    Selected = Color3.fromRGB(27, 27, 27),
    Border = Color3.fromRGB(44, 44, 44),
    Text = Color3.fromRGB(255, 255, 255),
    Muted = Color3.fromRGB(100, 100, 100),
    Hint = Color3.fromRGB(87, 87, 87),
    Accent = Color3.fromRGB(106, 98, 198),
    Control = Color3.fromRGB(33, 33, 33),
    ControlHover = Color3.fromRGB(37, 37, 37),
    ToggleOff = Color3.fromRGB(29, 29, 29),
    ToggleKnobOff = Color3.fromRGB(105, 105, 105),
    SliderTrack = Color3.fromRGB(35, 35, 35),
}

local function ApplyThemeColor(Key: string, Value: Color3)
    CurrentTheme[Key] = Value
    Fecurity:SetTheme(CurrentTheme)
end

local function AddThemeColor(Section: any, Key: string, Options: { [string]: any })
    Options.Callback = function(Value)
        ApplyThemeColor(Key, Value)
    end
    return Section:AddColor(Options)
end

local Assist = Window:AddTab("Assist", { Icon = "assist" })
local Visuals = Window:AddTab("Visuals", { Icon = "visuals" })
local Misc = Window:AddTab("Misc", { Icon = "misc" })
local Colors = Window:AddTab("Colors", { Icon = "colors" })
local Trial = Window:AddTab("Trial", { Icon = "trial" })

local AssistLeft = Assist:AddColumn()
local AssistMid = Assist:AddColumn()
local AssistRight = Assist:AddColumn()

local AssistGeneral = AssistLeft:AddSection("General")
AssistGeneral:AddToggle({ Text = "Enabled", Hint = "Enables aimbot", Flag = "assist.enabled", Default = true })
AssistGeneral:AddToggle({ Text = "Aim at Shoot", Hint = "Always aiming when shooting", Flag = "assist.aimAtShoot", Default = true })
AssistGeneral:AddDropdown({ Text = "Aimbot Type", Hint = "Select Aimbot Types", Flag = "assist.aimbotType", Default = "Silent", Values = { "Silent", "Memory", "Mouse" } })
AssistGeneral:AddToggle({ Text = "Visible Only", Hint = "Aim for Visible Bones Only", Flag = "assist.visibleOnly", Default = false })
AssistGeneral:AddToggle({ Text = "Enemy Only", Hint = "Aim for enemies Only", Flag = "assist.enemyOnly", Default = true })
AssistGeneral:AddSlider({ Text = "Aim Horizontal Speed", Flag = "assist.horizontalSpeed", Min = 0, Max = 100, Default = 30, Suffix = "%" })
AssistGeneral:AddSlider({ Text = "Aim Vertical Speed", Flag = "assist.verticalSpeed", Min = 0, Max = 100, Default = 40, Suffix = "%" })

local AssistSelect = AssistMid:AddSection("Select")
AssistSelect:AddSlider({ Text = "FOV", Flag = "assist.fov", Min = 0, Max = 16, Default = 4.36, Step = 0.01, Format = "fixed2" })
AssistSelect:AddSlider({ Text = "Target Switch Delay", Flag = "assist.switchDelay", Min = 0, Max = 3000, Default = 100, Step = 10, Format = "ms" })
AssistSelect:AddSlider({ Text = "Hitscan Coefficient", Flag = "assist.hitscanCoefficient", Min = 0.25, Max = 1, Default = 0.25, Step = 0.01, Format = "coefficient" })
AssistSelect:AddToggle({ Text = "In Vehicle", Hint = "Aim at turret", Flag = "assist.inVehicle", Default = true })
AssistSelect:AddToggle({ Text = "Magic Bullet", Hint = "HarryPoter Bullets", Flag = "assist.magicBullet", Default = false })
AssistSelect:AddDivider("Binds")
AssistSelect:AddKeybind({ Text = "Hitbox Priority", Hint = "Priority edit key", Flag = "assist.hitboxPriorityKey", Default = "Shift" })
AssistSelect:AddKeybind({ Text = "Aim Key", Hint = "Primary aim key", Flag = "assist.aimKey", Default = "M1" })
AssistSelect:AddKeybind({ Text = "Second Aim Key", Hint = "Secondary aim key", Flag = "assist.secondAimKey", Default = "M2" })

local AssistPreview = AssistRight:AddSection("Hitscan Hitbox Priority")
AssistPreview:AddHitboxPreview({ Flag = "assist.hitboxPriority", SkipFlag = false })

local VisualsLeft = Visuals:AddColumn()
local VisualsMid = Visuals:AddColumn()
local VisualsRight = Visuals:AddColumn()

local VisualsGeneral = VisualsLeft:AddSection("General")
VisualsGeneral:AddToggle({ Text = "Enabled", Hint = "Enables visuals", Flag = "visuals.enabled", Default = true })
VisualsGeneral:AddToggle({ Text = "Enemy only", Hint = "Visuals for enemies only", Flag = "visuals.enemyOnly", Default = true })

local VisualsCharacter = VisualsLeft:AddSection("Character")
VisualsCharacter:AddToggle({ Text = "Box", Hint = "Draw player box", Flag = "visuals.box", Default = false })
VisualsCharacter:AddToggle({ Text = "Box Outline", Flag = "visuals.boxOutline", Default = true })
VisualsCharacter:AddToggle({ Text = "Health", Hint = "Draw health bar", Flag = "visuals.health", Default = false })
VisualsCharacter:AddToggle({ Text = "Skeleton", Hint = "Draw skeleton", Flag = "visuals.skeleton", Default = false })
VisualsCharacter:AddSlider({ Text = "Skeleton Thickness", Flag = "visuals.skeletonThickness", Min = 0, Max = 10, Step = 0.05, Default = 3, Decimals = 2, Suffix = "PPI", SuffixSpacing = false })
VisualsCharacter:AddSlider({ Text = "Maximum Distance", Flag = "visuals.maximumDistance", Min = 0, Max = 7000, Step = 50, Default = 2500, Suffix = "Feets" })

local VisualsBots = VisualsMid:AddSection("AI (Bots)")
VisualsBots:AddToggle({ Text = "Display AI(BOTS)", Hint = "Show bot player visuals", Flag = "visuals.displayBots", Default = true })
VisualsBots:AddToggle({ Text = "Display \"AI\" Name", Hint = "Show AI name label", Flag = "visuals.botName", Default = true })
VisualsBots:AddToggle({ Text = "Show Preffix", Hint = "Show bot name prefix", Flag = "visuals.botPrefix", Default = true })
VisualsBots:AddSlider({ Text = "Maximum Distance", Flag = "visuals.botMaximumDistance", Min = 0, Max = 600, Step = 10, Default = 300, Suffix = "Metrs" })

local VisualsLoot = VisualsRight:AddSection("Loot")
VisualsLoot:AddToggle({ Text = "Display Loot", Hint = "Show loot in world", Flag = "visuals.displayLoot", Default = true })
VisualsLoot:AddSlider({ Text = "Maximum Distance", Flag = "visuals.lootMaximumDistance", Min = 0, Max = 650, Step = 10, Default = 350, Suffix = "Metrs" })
VisualsLoot:AddDropdown({ Text = "Filter", Hint = "Select loot category", Flag = "visuals.lootFilter", Multi = true, Default = { "Weapon" }, Values = { "Weapon", "Ammo", "Armor", "Medical" } })
VisualsLoot:AddDropdown({ Text = "Player Info", Hint = "Select player info", Flag = "visuals.playerInfo", Multi = true, Default = { "Distance" }, Values = { "Distance", "Name", "Weapon", "Health" } })
VisualsLoot:AddColor({ Text = "Customization", Hint = "Open visual colors", Flag = "visuals.customization", Default = Color3.fromRGB(169, 22, 17) })

local VisualsMissile = VisualsRight:AddSection("Missle")
VisualsMissile:AddToggle({ Text = "Mines, Nades, etc", Hint = "Show explosive warnings", Flag = "visuals.missiles", Default = false })

local VisualsBinds = VisualsRight:AddSection("Binds")
VisualsBinds:AddKeybind({ Text = "Toggle Key", Hint = "Visuals toggle", Flag = "visuals.toggleKey", Default = "None" })
VisualsBinds:AddKeybind({ Text = "Disable Key", Hint = "Visuals disable", Flag = "visuals.disableKey", Default = "None" })

local MiscLeft = Misc:AddColumn()
local MiscMid = Misc:AddColumn()
local MiscRight = Misc:AddColumn()

local MiscGeneral = MiscLeft:AddSection("", { NoHeader = true })
MiscGeneral:AddToggle({ Text = "Auto Accept", Hint = "Auto Accepting Matchmaking", Flag = "misc.autoAccept", Default = true })
MiscGeneral:AddSlider({ Text = "Night Mode Factor", Flag = "misc.nightModeFactor", Min = 0, Max = 100, Default = 5, Suffix = "%" })
MiscGeneral:AddDropdown({ Text = "Spectators", Hint = "Select filters & settings", Flag = "misc.spectators", Default = "Enemies to", Values = { "Enemies to", "All", "Friends", "Hidden" } })

local MiscTools = MiscMid:AddSection("", { NoHeader = true })
MiscTools:AddToggle({ Text = "Recoil Crosshair", Flag = "misc.recoilCrosshair", Default = true })
MiscTools:AddButton({ Text = "REMOVE SKINS", Tone = "danger" })

local MiscEngine = MiscRight:AddSection("Expired In:")
MiscEngine:AddCountdown({ Seconds = 23 * 60 * 60 + 54 * 60 + 44, Tone = "success", Height = 28 })
MiscEngine:AddToggle({ Text = "Developer Mode", Flag = "misc.developerMode", Default = true })
MiscEngine:AddDivider("Engine")
MiscEngine:AddDropdown({ Text = "Distance Unit", Flag = "misc.distanceUnit", Default = "Feets", Values = { "Feets", "Meters", "Yards" } })
MiscEngine:AddSlider({ Text = "DPI", Flag = "misc.dpi", Min = 0, Max = 3000, Step = 25, Default = 100, Suffix = "Inch" })
MiscEngine:AddKeybind({ Text = "Menu Key", Hint = "Toggle key", Flag = "misc.menuKey", Default = "INS", Changed = function(Value) Window:SetMenuKey(Value) end })
MiscEngine:AddButton({ Text = "RELOAD MOUSE DRIVER", Tone = "warning" })

local ColorsLeft = Colors:AddColumn()
local ColorsMid = Colors:AddColumn()
local ColorsRight = Colors:AddColumn()

local VisualColors = ColorsLeft:AddSection("Visuals Colors")
VisualColors:AddColor({ Text = "Enemy Box Visible", Hint = "Player box when visible", Flag = "colors.enemyBoxVisible", Default = Color3.fromRGB(169, 22, 17) })
VisualColors:AddColor({ Text = "Enemy Box Hidden", Hint = "Player box when hidden", Flag = "colors.enemyBoxHidden", Default = Color3.fromRGB(99, 28, 27) })
VisualColors:AddColor({ Text = "Enemy Box Outline", Hint = "Outline around enemy box", Flag = "colors.enemyBoxOutline", Default = Color3.fromRGB(255, 255, 255) })
VisualColors:AddColor({ Text = "Enemy Box Fill", Hint = "Filled enemy box overlay", Flag = "colors.enemyBoxFill", Default = Color3.fromRGB(169, 22, 17), Alpha = 0.32 })
VisualColors:AddColor({ Text = "Team Box Visible", Hint = "Friendly box when visible", Flag = "colors.teamBoxVisible", Default = Color3.fromRGB(95, 144, 246) })
VisualColors:AddColor({ Text = "Team Box Hidden", Hint = "Friendly box when hidden", Flag = "colors.teamBoxHidden", Default = Color3.fromRGB(49, 84, 143) })
VisualColors:AddColor({ Text = "Skeleton", Hint = "Player skeleton bones", Flag = "colors.skeleton", Default = Color3.fromRGB(231, 231, 231) })
VisualColors:AddColor({ Text = "Snapline", Hint = "Line to player position", Flag = "colors.snapline", Default = Color3.fromRGB(216, 243, 104) })
VisualColors:AddColor({ Text = "Name Text", Hint = "Player name label", Flag = "colors.nameText", Default = Color3.fromRGB(255, 255, 255) })
VisualColors:AddColor({ Text = "Weapon Text", Hint = "Weapon name label", Flag = "colors.weaponText", Default = Color3.fromRGB(225, 174, 36) })
VisualColors:AddColor({ Text = "Health Bar", Hint = "Player health indicator", Flag = "colors.healthBar", Default = Color3.fromRGB(58, 212, 187) })
VisualColors:AddColor({ Text = "Distance Text", Hint = "Player distance label", Flag = "colors.distanceText", Default = Color3.fromRGB(254, 226, 235) })
VisualColors:AddColor({ Text = "Hitbox First", Hint = "First priority hitbox", Flag = "colors.hitboxFirst", Default = Color3.fromRGB(72, 25, 20) })
VisualColors:AddColor({ Text = "Hitbox Second", Hint = "Second priority hitbox", Flag = "colors.hitboxSecond", Default = Color3.fromRGB(75, 54, 27) })
VisualColors:AddColor({ Text = "Hitbox Third", Hint = "Third priority hitbox", Flag = "colors.hitboxThird", Default = Color3.fromRGB(35, 61, 23) })
VisualColors:AddColor({ Text = "Hitbox Fourth", Hint = "Fourth priority hitbox", Flag = "colors.hitboxFourth", Default = Color3.fromRGB(12, 62, 90) })
VisualColors:AddColor({ Text = "Hitbox Ignore", Hint = "Ignored hitbox", Flag = "colors.hitboxIgnore", Default = Color3.fromRGB(29, 30, 36) })

local MenuColors = ColorsMid:AddSection("Menu Colors")
AddThemeColor(MenuColors, "Text", { Text = "Menu Text", Hint = "Control labels and values", Flag = "colors.menuText", Default = Color3.fromRGB(255, 255, 255) })
AddThemeColor(MenuColors, "Accent", { Text = "Accent", Hint = "Controls, logo, and active states", Flag = "colors.accent", Default = Color3.fromRGB(106, 98, 198) })
AddThemeColor(MenuColors, "Muted", { Text = "Muted Text", Hint = "Group headers and inactive tabs", Flag = "colors.mutedText", Default = Color3.fromRGB(100, 100, 100) })
AddThemeColor(MenuColors, "Hint", { Text = "Hint Text", Hint = "Descriptions under labels", Flag = "colors.hintText", Default = Color3.fromRGB(87, 87, 87) })
AddThemeColor(MenuColors, "Surface", { Text = "Panel Background", Hint = "Menu and group surfaces", Flag = "colors.panelBackground", Default = Color3.fromRGB(17, 17, 17) })
AddThemeColor(MenuColors, "Border", { Text = "Panel Border", Hint = "Menu panel outlines", Flag = "colors.panelBorder", Default = Color3.fromRGB(44, 44, 44) })
AddThemeColor(MenuColors, "Selected", { Text = "Selected Tab", Hint = "Active sidebar tab", Flag = "colors.selectedTab", Default = Color3.fromRGB(27, 27, 27) })
AddThemeColor(MenuColors, "Control", { Text = "Control Background", Hint = "Dropdowns and key boxes", Flag = "colors.controlBackground", Default = Color3.fromRGB(33, 33, 33) })
AddThemeColor(MenuColors, "ControlHover", { Text = "Control Hover", Hint = "Open and focused controls", Flag = "colors.controlHover", Default = Color3.fromRGB(37, 37, 37) })
AddThemeColor(MenuColors, "ToggleOff", { Text = "Toggle Off", Hint = "Disabled toggle track", Flag = "colors.toggleOff", Default = Color3.fromRGB(29, 29, 29) })
AddThemeColor(MenuColors, "ToggleKnobOff", { Text = "Toggle Knob Off", Hint = "Disabled toggle handle", Flag = "colors.toggleKnobOff", Default = Color3.fromRGB(105, 105, 105) })
AddThemeColor(MenuColors, "SliderTrack", { Text = "Slider Track", Hint = "Inactive slider rail", Flag = "colors.sliderTrack", Default = Color3.fromRGB(35, 35, 35) })

local ColorTools = ColorsRight:AddSection("Color")
ColorTools:AddLabel({ Text = "Select any color row to edit it.", Tone = "muted", Height = 28 })
ColorTools:AddButton({ Text = "COPY" })
ColorTools:AddButton({ Text = "PASTE" })
ColorTools:AddDivider("Color templates")
ColorTools:AddColor({ Text = "Template Red", Flag = "templates.red", Default = Color3.fromRGB(255, 20, 18), SkipFlag = true })
ColorTools:AddColor({ Text = "Template Blue", Flag = "templates.blue", Default = Color3.fromRGB(81, 132, 236), SkipFlag = true })
ColorTools:AddColor({ Text = "Template Lime", Flag = "templates.lime", Default = Color3.fromRGB(223, 248, 82), SkipFlag = true })
ColorTools:AddColor({ Text = "Template Gold", Flag = "templates.gold", Default = Color3.fromRGB(234, 180, 35), SkipFlag = true })

local TrialLeft = Trial:AddColumn()
Trial:AddColumn()
Trial:AddColumn()
TrialLeft:AddSection("Trial")

Fecurity:Notify({
    Title = "Fecurity",
    Text = "UI library loaded.",
    Duration = 3,
})

return Fecurity
