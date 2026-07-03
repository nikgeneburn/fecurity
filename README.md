# Fecurity

Roblox Luau UI library ported from the Fecurity web menu. The source stays modular under `src/`; DarkLua bundles it into `dist/Fecurity.lua`.

## Hosted Loader

Replace `nikgeneburn/fecurity` after publishing this folder to GitHub:

```lua
local Fecurity = loadstring(game:HttpGet("https://raw.githubusercontent.com/nikgeneburn/fecurity/main/dist/Fecurity.lua"))()

local Window = Fecurity:CreateWindow({
    Title = "Fecurity",
    Subtitle = "Private UI Library",
    Size = UDim2.fromOffset(774, 481),
    Accent = Color3.fromRGB(106, 98, 198),
    Theme = "Dark",
})

local Assist = Window:AddTab("Assist", {
    Icon = "assist",
})

local Left = Assist:AddColumn()
local General = Left:AddSection("General")

General:AddToggle({
    Text = "Enabled",
    Hint = "Enables aimbot",
    Flag = "assist.enabled",
    Default = true,
})

General:AddSlider({
    Text = "Aim Horizontal Speed",
    Flag = "assist.horizontalSpeed",
    Min = 0,
    Max = 100,
    Default = 30,
    Suffix = "%",
})

Fecurity:SetTheme("Dark")
Fecurity:SetAccent(Color3.fromRGB(106, 98, 198))
```

If the target executor supports requiring a URL directly, the hosted bundle also returns the library table through `require`:

```lua
local Fecurity = require("https://raw.githubusercontent.com/nikgeneburn/fecurity/main/dist/Fecurity.lua")
```

`AddColor` callbacks receive `Color3` first and alpha second:

```lua
Section:AddColor({
    Text = "Accent",
    Flag = "colors.accent",
    Default = Color3.fromRGB(106, 98, 198),
    Callback = function(Color, Alpha)
        Fecurity:SetAccent(Color)
    end,
})
```

The bundled file returns the library table. Assets are expected beside it under `assets/` and are cached into:

```text
Fecurity/
  Assets/
    Fonts/
    Icons/
    Images/
  Configs/
  Logs/
```

Warnings and callback errors are also written to `Fecurity/Logs/fecurity.log` when executor file APIs are available.
The cache/config system expects the normal executor file APIs: `isfolder`, `makefolder`, `isfile`, `writefile`, `readfile`, and `delfile`.

The raw GitHub base URL is centralized in `src/assets/AssetRegistry.luau`.
The original SVG sidebar art is kept in `assets/icons/`; Roblox-facing PNG masks are generated beside those SVGs and used by the registry.
Asset integrity is recorded in `assets/manifest.json`; local and hosted verification compare asset sizes and SHA-256 hashes against it.

Before loading, consumers can override the asset base URL if needed:

```lua
getgenv().FecurityAssetBaseUrl = "https://raw.githubusercontent.com/nikgeneburn/fecurity/main/"
local Fecurity = loadstring(game:HttpGet(getgenv().FecurityAssetBaseUrl .. "dist/Fecurity.lua"))()
```

After loading, `Fecurity:SetAssetBaseUrl(url)` updates the centralized asset base URL and returns `true` only when the cache refresh validates the hosted assets.

## Build

```bat
build.bat
```

This writes:

- `dist/Fecurity.lua`
- `dist/Fecurity.dev.lua`

## Verify

```powershell
.\verify.ps1
```

Use `.\verify.ps1 -RequirePublished` after replacing `nikgeneburn/fecurity` with the real GitHub repository.

## Publish Without Git

If this machine does not have `git` or `gh`, publish through the GitHub API:

```powershell
$env:GITHUB_TOKEN = "github_token_with_repo_write_access"
.\publish-github.ps1 -Owner "OWNER" -Repo "REPO" -Branch "main" -CreateRepo
```

For an organization repository:

```powershell
$env:GITHUB_TOKEN = "github_token_with_repo_write_access"
.\publish-github.ps1 -Owner "ORG" -Repo "REPO" -Branch "main" -Organization -CreateRepo
```

The publisher stamps the raw asset base URL, rebuilds `dist/`, uploads `assets/`, `dist/`, `src/`, `include/`, `examples/`, and the root project files, then prints the hosted loader. Use `-DryRun` to preview the exact file list without changing local files or calling GitHub. If `-Branch` names a branch that does not exist, the publisher creates it from the repository default branch before uploading.

After publishing, verify the live raw GitHub files directly:

```powershell
.\verify-hosted.ps1 -Owner "OWNER" -Repo "REPO" -Branch "main"
```

The hosted verifier downloads `dist/Fecurity.lua`, the hosted demo, README, font, icons, logo, and hitbox preview from `raw.githubusercontent.com`, confirms they are reachable, and fails if any published text still contains `nikgeneburn/fecurity`.

## Demo

`examples/FecurityDemo.luau` recreates the current Fecurity menu using the public API only.

`examples/FecurityHostedRequire.luau` shows the optional hosted URL `require(...)` style for environments that support it.

`examples/FecurityHostedSmoke.luau` is the executor-side smoke test for the hosted bundle. After publishing, paste or execute it in the target Roblox executor; it loads the hosted library, confirms the public methods exist, checks cache folders, exercises widgets/config save/load/theme toggles, then unloads the UI.

