param(
    [switch]$SkipBuild,
    [switch]$RequirePublished
)

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot
$Failures = New-Object System.Collections.Generic.List[string]
$Warnings = New-Object System.Collections.Generic.List[string]

function Add-Failure([string]$Message) {
    $Failures.Add($Message) | Out-Null
}

function Add-Warning([string]$Message) {
    $Warnings.Add($Message) | Out-Null
}

function Require-File([string]$Path) {
    $Full = Join-Path $Root $Path
    if (-not (Test-Path -LiteralPath $Full -PathType Leaf)) {
        Add-Failure "missing file: $Path"
    }
}

function Require-Dir([string]$Path) {
    $Full = Join-Path $Root $Path
    if (-not (Test-Path -LiteralPath $Full -PathType Container)) {
        Add-Failure "missing directory: $Path"
    }
}

$RequiredFiles = @(
    ".darklua.json",
    ".darklua.dev.json",
    ".gitignore",
    "build.bat",
    "deploy.ps1",
    "publish-github.ps1",
    "verify-hosted.ps1",
    "verify.ps1",
    "README.md",
    "CLAUDE.md",
    "dist\Fecurity.lua",
    "dist\Fecurity.dev.lua",
    "include\Types.luau",
    "include\ThemeTypes.luau",
    "include\WidgetTypes.luau",
    "src\main.luau",
    "src\init.luau",
    "src\render\Gradients.luau",
    "examples\FecurityDemo.luau",
    "examples\FecurityHosted.luau",
    "examples\FecurityHostedRequire.luau",
    "examples\FecurityHostedSmoke.luau"
)

$RequiredDirs = @(
    "assets\fonts",
    "assets\icons",
    "assets\images",
    "src\core",
    "src\assets",
    "src\config",
    "src\input",
    "src\layout",
    "src\render",
    "src\theme",
    "src\animation",
    "src\widgets\window",
    "src\widgets\tab",
    "src\widgets\containers",
    "src\widgets\controls",
    "src\widgets\overlays"
)

$RequiredAssets = @(
    "assets\manifest.json",
    "assets\fonts\ProximaNova-Semibold.ttf",
    "assets\icons\assist.png",
    "assets\icons\visuals.png",
    "assets\icons\misc.png",
    "assets\icons\colors.png",
    "assets\icons\trial.png",
    "assets\icons\assist.svg",
    "assets\icons\visuals.svg",
    "assets\icons\misc.svg",
    "assets\icons\colors.svg",
    "assets\icons\trial.svg",
    "assets\images\logo.png",
    "assets\images\logo.svg",
    "assets\images\hitbox-preview.png"
)

foreach ($Dir in $RequiredDirs) { Require-Dir $Dir }
foreach ($File in $RequiredFiles + $RequiredAssets) { Require-File $File }

$Manifest = $null
$ManifestPath = Join-Path $Root "assets\manifest.json"
if (Test-Path -LiteralPath $ManifestPath -PathType Leaf) {
    $Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
    if ($Manifest.schema -ne 1 -or $null -eq $Manifest.assets) {
        Add-Failure "assets\manifest.json has an invalid schema"
    } else {
        $ManifestPaths = @{}
        foreach ($Asset in $Manifest.assets) {
            $ManifestPaths[$Asset.path] = $true
            $AssetPath = Join-Path $Root (($Asset.path -replace "/", "\"))
            if (-not (Test-Path -LiteralPath $AssetPath -PathType Leaf)) {
                Add-Failure "manifest asset is missing: $($Asset.path)"
                continue
            }
            $Item = Get-Item -LiteralPath $AssetPath
            if ($Item.Length -ne [int64]$Asset.bytes) {
                Add-Failure "manifest byte mismatch for $($Asset.path): expected $($Asset.bytes), got $($Item.Length)"
            }
            $Hash = (Get-FileHash -LiteralPath $AssetPath -Algorithm SHA256).Hash.ToLowerInvariant()
            if ($Hash -ne $Asset.sha256) {
                Add-Failure "manifest sha256 mismatch for $($Asset.path)"
            }
        }
        foreach ($AssetPath in $RequiredAssets) {
            if ($AssetPath -eq "assets\manifest.json") {
                continue
            }
            $Normalized = $AssetPath.Replace("\", "/")
            if (-not $ManifestPaths.ContainsKey($Normalized)) {
                Add-Failure "assets\manifest.json missing required asset: $Normalized"
            }
        }
    }
}

if (-not $SkipBuild) {
    & (Join-Path $Root "build.bat")
    if ($LASTEXITCODE -ne 0) {
        Add-Failure "build.bat failed"
    }
}

$SourceRoots = @("src", "include", "examples")
foreach ($SourceRoot in $SourceRoots) {
    Get-ChildItem -LiteralPath (Join-Path $Root $SourceRoot) -Recurse -File -Include *.lua,*.luau | ForEach-Object {
        $Relative = $_.FullName.Substring($Root.Length + 1)
        $Lines = (Get-Content -LiteralPath $_.FullName).Count
        if ($Lines -gt 1000) {
            Add-Failure "$Relative exceeds 1000 hard line limit ($Lines)"
        } elseif ($Lines -gt 500) {
            Add-Warning "$Relative exceeds 500 soft line target ($Lines)"
        }
    }
}

$Demo = Get-Content -LiteralPath (Join-Path $Root "examples\FecurityDemo.luau") -Raw
if ($Demo -match "Instance\.new") {
    Add-Failure "FecurityDemo.luau should only use the public widget API, but contains Instance.new"
}
if ($Demo -notmatch "AddThemeColor" -or $Demo -notmatch "Fecurity:SetTheme") {
    Add-Failure "FecurityDemo.luau menu color rows must update the live theme through the public API"
}
if ($Demo -notmatch "Window:SetMenuKey" -or $Demo -notmatch "Changed = function") {
    Add-Failure "FecurityDemo.luau menu key row must update the window menu key without double toggling"
}

$HostedDemo = Get-Content -LiteralPath (Join-Path $Root "examples\FecurityHosted.luau") -Raw
if ($HostedDemo -notmatch "loadstring\(game:HttpGet") {
    Add-Failure "FecurityHosted.luau does not use the hosted loadstring style"
}

$HostedRequire = Get-Content -LiteralPath (Join-Path $Root "examples\FecurityHostedRequire.luau") -Raw
if ($HostedRequire -notmatch 'require\(RawBase \.\. "dist/Fecurity\.lua"\)') {
    Add-Failure "FecurityHostedRequire.luau does not use the hosted require URL style"
}
if ($HostedRequire -match "Instance\.new") {
    Add-Failure "FecurityHostedRequire.luau should only use the public widget API, but contains Instance.new"
}

$HostedSmoke = Get-Content -LiteralPath (Join-Path $Root "examples\FecurityHostedSmoke.luau") -Raw
if ($HostedSmoke -notmatch "loadstring\(game:HttpGet") {
    Add-Failure "FecurityHostedSmoke.luau does not use the hosted loadstring style"
}
if ($HostedSmoke -match "Instance\.new") {
    Add-Failure "FecurityHostedSmoke.luau should only use the public widget API, but contains Instance.new"
}
foreach ($Needle in @("SaveConfig", "LoadConfig", "SetAssetBaseUrl", "AddHitboxPreview", "AddConfigList")) {
    if ($HostedSmoke -notlike "*$Needle*") {
        Add-Failure "FecurityHostedSmoke.luau does not exercise $Needle"
    }
}
if ($HostedSmoke -notlike "*asset base url refresh did not report ready*") {
    Add-Failure "FecurityHostedSmoke.luau does not assert SetAssetBaseUrl readiness reporting"
}
if ($HostedSmoke -notlike "*config list did not update after save*") {
    Add-Failure "FecurityHostedSmoke.luau does not assert automatic config-list refresh"
}
if ($HostedSmoke -notlike "*skip flag was saved*" -or $HostedSmoke -notlike "*smoke.skipColor*") {
    Add-Failure "FecurityHostedSmoke.luau does not assert SkipFlag config filtering"
}
if ($HostedSmoke -notlike "*enum keybind default did not normalize*" -or $HostedSmoke -notlike "*enum keybind set did not normalize*") {
    Add-Failure "FecurityHostedSmoke.luau does not assert Enum.KeyCode keybind normalization"
}
if ($HostedSmoke -notlike "*SetMenuKey*" -or $HostedSmoke -notlike "*menu key did not normalize*") {
    Add-Failure "FecurityHostedSmoke.luau does not assert configurable menu-key normalization"
}
if ($HostedSmoke -notlike "*destroyed toggle remained registered*" -or $HostedSmoke -notlike "*destroyed color alpha remained registered*") {
    Add-Failure "FecurityHostedSmoke.luau does not assert destroyed widgets unregister from FlagManager"
}
if ($HostedSmoke -notlike "*destroyed toggle retained theme binding*" -or $HostedSmoke -notlike "*Window.ThemeBindings*") {
    Add-Failure "FecurityHostedSmoke.luau does not assert destroyed widgets unbind theme callbacks"
}

$LibrarySource = Get-Content -LiteralPath (Join-Path $Root "src\core\Library.luau") -Raw
if ($LibrarySource -notmatch "RegisterConfigList" -or $LibrarySource -notmatch "RefreshConfigLists") {
    Add-Failure "Library.luau does not expose internal config-list refresh plumbing"
}
if ($LibrarySource -notmatch "function Library:SetAssetBaseUrl" -or $LibrarySource -notmatch "return self.AssetCache:EnsureAll\(\)") {
    Add-Failure "Library.luau must return asset-cache readiness from SetAssetBaseUrl"
}
if ($LibrarySource -notmatch "RegistryEntry" -or $LibrarySource -notmatch "Registry.Clear\(self.RegistryEntry\)") {
    Add-Failure "Library.luau must clear only its owned global registry entry on unload"
}

$RegistrySource = Get-Content -LiteralPath (Join-Path $Root "src\core\Registry.luau") -Raw
if ($RegistrySource -notmatch "pcall\(getgenv\)" -or $RegistrySource -notmatch "function Registry.Clear\(Owner" -or $RegistrySource -notmatch "Env\[Key\] == Owner" -or $RegistrySource -notmatch "return Entry") {
    Add-Failure "Registry.luau must guard getgenv and use owned registry entries"
}

$FlagManagerSource = Get-Content -LiteralPath (Join-Path $Root "src\config\FlagManager.luau") -Raw
if ($FlagManagerSource -notmatch "SkipFlags" -or $FlagManagerSource -notmatch "Export" -or $FlagManagerSource -notmatch "self.SkipFlags\[Flag\] ~= true") {
    Add-Failure "FlagManager.luau must track SkipFlag values and export only savable flags"
}
if ($FlagManagerSource -notmatch "function FlagManager:Unregister" -or $FlagManagerSource -notmatch "self.Widgets\[Flag\] = nil") {
    Add-Failure "FlagManager.luau must unregister destroyed widget references"
}

$BaseWidgetSource = Get-Content -LiteralPath (Join-Path $Root "src\widgets\BaseWidget.luau") -Raw
if ($BaseWidgetSource -notmatch "UnregisterFlag" -or $BaseWidgetSource -notmatch "FlagDestroyConnection" -or $BaseWidgetSource -notmatch "Root.Destroying") {
    Add-Failure "BaseWidget.luau must unregister flags when widgets are destroyed"
}
if ($BaseWidgetSource -notmatch "ThemeUnbinds" -or $BaseWidgetSource -notmatch "UnbindTheme" -or $BaseWidgetSource -notmatch "ThemeDestroyConnection") {
    Add-Failure "BaseWidget.luau must unregister theme callbacks when widgets are destroyed"
}

$ConfigManagerSource = Get-Content -LiteralPath (Join-Path $Root "src\config\ConfigManager.luau") -Raw
if ($ConfigManagerSource -notmatch "IndexFile" -or $ConfigManagerSource -notmatch "KnownConfigs") {
    Add-Failure "ConfigManager.luau must maintain a config index without requiring listfiles"
}
if ($ConfigManagerSource -notmatch ":Export\(\)") {
    Add-Failure "ConfigManager.luau must save the filtered FlagManager export"
}
if ($ConfigManagerSource -notmatch "FolderExists" -or $ConfigManagerSource -notmatch "FileExists" -or $ConfigManagerSource -notmatch "pcall\(writefile" -or $ConfigManagerSource -notmatch "pcall\(readfile" -or $ConfigManagerSource -notmatch "pcall\(listfiles") {
    Add-Failure "ConfigManager.luau must soft-fail executor config folder/file/read/write/list errors"
}

$KeybindManagerSource = Get-Content -LiteralPath (Join-Path $Root "src\input\KeybindManager.luau") -Raw
if ($KeybindManagerSource -notmatch "Normalize" -or $KeybindManagerSource -notmatch "Enum%.KeyCode" -or $KeybindManagerSource -notmatch "MouseButton1") {
    Add-Failure "KeybindManager.luau must normalize Enum.KeyCode and mouse button values"
}

$KeybindSource = Get-Content -LiteralPath (Join-Path $Root "src\widgets\controls\Keybind.luau") -Raw
if ($KeybindSource -notmatch "ActivationConnection" -or $KeybindSource -notmatch "IsActivation" -or $KeybindSource -notmatch "DisconnectInputs") {
    Add-Failure "Keybind.luau must listen for bound input activation and clean up connections"
}

$SliderSource = Get-Content -LiteralPath (Join-Path $Root "src\widgets\controls\Slider.luau") -Raw
if ($SliderSource -notmatch "DisconnectInputs" -or $SliderSource -notmatch "Destroying" -or $SliderSource -notmatch "self:Track\(UserInputService.InputChanged") {
    Add-Failure "Slider.luau must track and disconnect drag input connections on destroy"
}

$DropdownSource = Get-Content -LiteralPath (Join-Path $Root "src\widgets\controls\Dropdown.luau") -Raw
if ($DropdownSource -notmatch "function Dropdown:Destroy" -or $DropdownSource -notmatch "CloseMenu\(true\)" -or $DropdownSource -notmatch "Destroying") {
    Add-Failure "Dropdown.luau must close overlay menus immediately on destroy"
}

$ColorPickerSource = Get-Content -LiteralPath (Join-Path $Root "src\widgets\controls\ColorPicker.luau") -Raw
if ($ColorPickerSource -notmatch "Destroying" -or $ColorPickerSource -notmatch "ClosePicker" -or $ColorPickerSource -notmatch "function ColorPicker:Destroy") {
    Add-Failure "ColorPicker.luau must close popups and disconnect popup drag connections on destroy"
}
if ($ColorPickerSource -notmatch "AlphaFlag" -or $ColorPickerSource -notmatch "FlagManager:Unregister\(self.AlphaFlag") {
    Add-Failure "ColorPicker.luau must unregister its auxiliary alpha flag on destroy"
}

$HitboxPreviewSource = Get-Content -LiteralPath (Join-Path $Root "src\widgets\controls\HitboxPreview.luau") -Raw
if ($HitboxPreviewSource -notmatch "CreateImageFallback" -or $HitboxPreviewSource -notmatch "PreviewFallback") {
    Add-Failure "HitboxPreview.luau must draw a native fallback when the hosted preview image fails"
}

$LoggerSource = Get-Content -LiteralPath (Join-Path $Root "src\core\Logger.luau") -Raw
if ($LoggerSource -notmatch "Fecurity/Logs/fecurity.log" -or $LoggerSource -notmatch "writefile" -or $LoggerSource -notmatch "readfile") {
    Add-Failure "Logger.luau must write warnings/errors to Fecurity/Logs/fecurity.log when file APIs exist"
}
if ($LoggerSource -notmatch "FolderExists" -or $LoggerSource -notmatch "EnsureFolder" -or $LoggerSource -notmatch "pcall\(isfolder" -or $LoggerSource -notmatch "pcall\(makefolder" -or $LoggerSource -notmatch "pcall\(writefile") {
    Add-Failure "Logger.luau must soft-fail executor log folder and file write errors"
}

$RuntimeSource = Get-Content -LiteralPath (Join-Path $Root "src\core\Runtime.luau") -Raw
if ($RuntimeSource -notmatch "AttachGui" -or $RuntimeSource -notmatch "GetPlayerGui" -or $RuntimeSource -notmatch "pcall\(function\(\)\s*Gui.Parent") {
    Add-Failure "Runtime.luau must parent ScreenGui through a guarded CoreGui/PlayerGui fallback"
}
if ($RuntimeSource -notmatch "type\(delfile\) == `"function`"") {
    Add-Failure "Runtime.luau must include delfile in executor file API readiness checks"
}

$TopbarSource = Get-Content -LiteralPath (Join-Path $Root "src\widgets\window\Topbar.luau") -Raw
if ($TopbarSource -notmatch "Topbar.New" -or $TopbarSource -notmatch "FecurityTitle") {
    Add-Failure "Topbar.luau must manage window title/subtitle metadata"
}

$TabContainerSource = Get-Content -LiteralPath (Join-Path $Root "src\widgets\tab\TabContainer.luau") -Raw
if ($TabContainerSource -notmatch "TabContainer.New" -or $TabContainerSource -notmatch "Overlay") {
    Add-Failure "TabContainer.luau must build reusable content and overlay layers"
}

$TransitionsSource = Get-Content -LiteralPath (Join-Path $Root "src\animation\Transitions.luau") -Raw
if ($TransitionsSource -notmatch "PanelIn" -or $TransitionsSource -notmatch "PanelOut") {
    Add-Failure "Transitions.luau must provide animated panel transitions"
}

$TabSource = Get-Content -LiteralPath (Join-Path $Root "src\widgets\tab\Tab.luau") -Raw
if ($TabSource -notmatch "Transitions.PanelIn" -or $TabSource -notmatch "Transitions.PanelOut") {
    Add-Failure "Tab.luau must animate tab column visibility changes"
}

$WindowSource = Get-Content -LiteralPath (Join-Path $Root "src\widgets\window\Window.luau") -Raw
if ($WindowSource -notmatch "TargetSize" -or $WindowSource -notmatch "ScaleSize") {
    Add-Failure "Window.luau open/close animation must respect custom window sizes"
}
if ($WindowSource -notmatch "Runtime.AttachGui" -or $WindowSource -match "Gui.Parent = Runtime.GetGuiParent") {
    Add-Failure "Window.luau must use Runtime.AttachGui for robust ScreenGui parenting"
}
if ($WindowSource -notmatch "SetMenuKey" -or $WindowSource -notmatch "KeybindManager.IsActivation" -or $WindowSource -notmatch "Options.MenuKey") {
    Add-Failure "Window.luau must support a normalized configurable menu key"
}
if ($WindowSource -notmatch "RegisterThemeBinding" -or $WindowSource -notmatch "table.remove\(self.ThemeBindings" -or $WindowSource -notmatch "pcall\(Binding") {
    Add-Failure "Window.luau must support removable guarded theme bindings"
}
if ($WindowSource -notmatch "self.Destroyed" -or $WindowSource -notmatch "CloseMenu\(true\)" -or $WindowSource -notmatch "table.clear\(self.ThemeBindings\)" -or $WindowSource -notmatch "self.Gui = nil") {
    Add-Failure "Window.luau must destroy idempotently and clean transient UI state"
}
if ($WindowSource -notmatch "not self.Root" -or $WindowSource -notmatch "return false" -or $WindowSource -notmatch "self.Root = nil") {
    Add-Failure "Window.luau lifecycle methods must no-op cleanly after destroy"
}

$TokensSource = Get-Content -LiteralPath (Join-Path $Root "src\theme\Tokens.luau") -Raw
if ($TokensSource -notmatch "PanelHeightFor" -or $TokensSource -notmatch "WindowWidth" -or $TokensSource -notmatch "PanelBottom") {
    Add-Failure "Tokens.luau must support panel layout from custom window dimensions"
}

$ColumnSource = Get-Content -LiteralPath (Join-Path $Root "src\widgets\containers\Column.luau") -Raw
if ($ColumnSource -notmatch "TargetSize" -or $ColumnSource -notmatch "PanelHeightFor") {
    Add-Failure "Column.luau must size panels from the window target size"
}

$GradientsSource = Get-Content -LiteralPath (Join-Path $Root "src\render\Gradients.luau") -Raw
if ($GradientsSource -notmatch "UIGradient" -or $GradientsSource -notmatch "AccentVertical") {
    Add-Failure "Gradients.luau must provide reusable UIGradient helpers"
}

$StylingSource = Get-Content -LiteralPath (Join-Path $Root "src\render\Styling.luau") -Raw
if ($StylingSource -notmatch "TextService" -or $StylingSource -notmatch "FitText") {
    Add-Failure "Styling.luau must use TextService for compact text fitting"
}
foreach ($Path in @("src\widgets\controls\Button.luau", "src\widgets\controls\Keybind.luau", "src\widgets\controls\Dropdown.luau")) {
    $Text = Get-Content -LiteralPath (Join-Path $Root $Path) -Raw
    if ($Text -notmatch "FitText") {
        Add-Failure "$Path must use Styling.FitText for compact control text"
    }
}

$Readme = Get-Content -LiteralPath (Join-Path $Root "README.md") -Raw
if ($Readme -notmatch "loadstring\(game:HttpGet") {
    Add-Failure "README.md does not document hosted loadstring usage"
}
if ($Readme -notmatch "publish-github\.ps1") {
    Add-Failure "README.md does not document the GitHub API publisher"
}
if ($Readme -notmatch "verify-hosted\.ps1") {
    Add-Failure "README.md does not document hosted verification"
}

$Publisher = Get-Content -LiteralPath (Join-Path $Root "publish-github.ps1") -Raw
if ($Publisher -notmatch "Invoke-RestMethod" -or $Publisher -notmatch "GITHUB_TOKEN") {
    Add-Failure "publish-github.ps1 must publish through the GitHub API using GITHUB_TOKEN"
}
if ($Publisher -notmatch "verify-hosted\.ps1") {
    Add-Failure "publish-github.ps1 must run hosted verification after upload"
}
if ($Publisher -notmatch '"verify-hosted\.ps1"') {
    Add-Failure "publish-github.ps1 must upload verify-hosted.ps1 with the root project files"
}
if ($Publisher -notmatch 'auto_init\s*=\s*\$true') {
    Add-Failure "publish-github.ps1 should initialize created repos so first content uploads have a branch"
}
foreach ($Needle in @("function Ensure-Branch", "function Get-EncodedRefPath", "function Wait-GitRef", "git/ref", "git/refs", "default_branch", "refs/heads/", "Start-Sleep")) {
    if ($Publisher -notlike "*$Needle*") {
        Add-Failure "publish-github.ps1 must create or verify the requested branch before uploading: $Needle"
    }
}
if ($Publisher -like '*EscapeDataString($Ref)*') {
    Add-Failure "publish-github.ps1 must encode git refs by path segment, not as one escaped string"
}

$Deploy = Get-Content -LiteralPath (Join-Path $Root "deploy.ps1") -Raw
foreach ($Needle in @("FecurityHosted.luau", "FecurityHostedRequire.luau", "FecurityHostedSmoke.luau", 'OWNER/REPO')) {
    if ($Deploy -notlike "*$Needle*") {
        Add-Failure "deploy.ps1 must stamp hosted publish placeholder coverage for $Needle"
    }
}
foreach ($Needle in @("Fecurity.lua", "Fecurity.dev.lua", "Update-HostedTextFile", 'https://raw\.githubusercontent\.com/')) {
    if ($Deploy -notlike "*$Needle*") {
        Add-Failure "deploy.ps1 must stamp hosted URLs in bundled dist files and already-stamped text: $Needle"
    }
}
if ($Deploy -notmatch 'UTF8Encoding\(\$false\)' -or $Deploy -match "Set-Content.*Encoding UTF8") {
    Add-Failure "deploy.ps1 must stamp Luau/readme text as UTF-8 without BOM"
}

$HostedVerifier = Get-Content -LiteralPath (Join-Path $Root "verify-hosted.ps1") -Raw
if ($HostedVerifier -notmatch "Invoke-WebRequest" -or $HostedVerifier -notmatch "dist/Fecurity\.lua") {
    Add-Failure "verify-hosted.ps1 must fetch the hosted dist file and assets"
}
foreach ($Needle in @('"build.bat"', '"deploy.ps1"', '"publish-github.ps1"', '"verify.ps1"', '"verify-hosted.ps1"')) {
    if ($HostedVerifier -notlike "*$Needle*") {
        Add-Failure "verify-hosted.ps1 must verify root project file is reachable: $Needle"
    }
}
foreach ($Needle in @('".darklua.json"', '"include/Types.luau"', '"src/main.luau"', '"src/assets/AssetRegistry.luau"', '"src/core/Library.luau"')) {
    if ($HostedVerifier -notlike "*$Needle*") {
        Add-Failure "verify-hosted.ps1 must verify hosted project scaffold file is reachable: $Needle"
    }
}

$Registry = Get-Content -LiteralPath (Join-Path $Root "src\assets\AssetRegistry.luau") -Raw
foreach ($Needle in @("assets/fonts/ProximaNova-Semibold.ttf", "assets/icons/assist.png", "assets/images/logo.png", "assets/images/hitbox-preview.png")) {
    if ($Registry -notlike "*$Needle*") {
        Add-Failure "AssetRegistry.luau missing hosted asset path: $Needle"
    }
}
if ($Manifest -and $Manifest.assets) {
    foreach ($Asset in $Manifest.assets) {
        if ($Asset.path -notmatch "\.(png|ttf)$") {
            continue
        }
        if ($Registry -notlike "*$($Asset.path)*") {
            Add-Failure "AssetRegistry.luau missing runtime manifest asset: $($Asset.path)"
        }
        if ($Registry -notmatch "Bytes\s*=\s*$([int64]$Asset.bytes)") {
            Add-Failure "AssetRegistry.luau missing byte size $($Asset.bytes) for $($Asset.path)"
        }
    }
} else {
    Add-Failure "AssetRegistry.luau runtime byte validation needs assets\manifest.json"
}

$AssetCacheSource = Get-Content -LiteralPath (Join-Path $Root "src\assets\AssetCache.luau") -Raw
if ($AssetCacheSource -notmatch "IsValidBody" -or $AssetCacheSource -notmatch "Asset.Bytes") {
    Add-Failure "AssetCache.luau must validate cached asset bodies against expected byte sizes"
}
if ($AssetCacheSource -notmatch "FolderExists" -or $AssetCacheSource -notmatch "FileExists" -or $AssetCacheSource -notmatch "pcall\(writefile" -or $AssetCacheSource -notmatch "Asset cache write failed") {
    Add-Failure "AssetCache.luau must soft-fail executor folder/file/write errors"
}
if ($AssetCacheSource -notmatch "table.clear\(self.Failed\)" -or $AssetCacheSource -notmatch "self.Ready = Ready" -or $AssetCacheSource -notmatch "return Ready" -or $AssetCacheSource -notmatch "self.Failed\[Asset.File\] = nil") {
    Add-Failure "AssetCache.luau must report real readiness and clear stale asset failures"
}

foreach ($Dist in @("dist\Fecurity.lua", "dist\Fecurity.dev.lua")) {
    $Path = Join-Path $Root $Dist
    if ((Test-Path -LiteralPath $Path) -and ((Get-Item -LiteralPath $Path).Length -le 0)) {
        Add-Failure "$Dist is empty"
    }
}

$Release = Get-Content -LiteralPath (Join-Path $Root "dist\Fecurity.lua") -Raw
if ($Release -notmatch "return") {
    Add-Failure "dist\Fecurity.lua does not appear to return the library"
}

if ($RequirePublished) {
    foreach ($Path in @("src\assets\AssetRegistry.luau", "README.md", "examples\FecurityHosted.luau", "examples\FecurityHostedRequire.luau", "examples\FecurityHostedSmoke.luau", "dist\Fecurity.lua", "dist\Fecurity.dev.lua")) {
        $Text = Get-Content -LiteralPath (Join-Path $Root $Path) -Raw
        if ($Text -match "OWNER/REPO") {
            Add-Failure "$Path still contains OWNER/REPO placeholder"
        }
    }
} else {
    if ($Registry -match "OWNER/REPO") {
        Add-Warning "AssetRegistry.luau still uses OWNER/REPO placeholder, run deploy.ps1 with a real repo before publishing"
    }
}

if ($Warnings.Count -gt 0) {
    foreach ($Warning in $Warnings) {
        Write-Host "[verify:warn] $Warning"
    }
}

if ($Failures.Count -gt 0) {
    foreach ($Failure in $Failures) {
        Write-Host "[verify:fail] $Failure"
    }
    throw "verify failed with $($Failures.Count) failure(s)"
}

Write-Host "[verify] ok"
