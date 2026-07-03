param(
    [Parameter(Mandatory = $true)]
    [string]$Owner,

    [Parameter(Mandatory = $true)]
    [string]$Repo,

    [string]$Branch = "main",
    [string]$RepoRawBase = "",
    [int]$RetryCount = 3,
    [int]$RetryDelaySeconds = 2
)

$ErrorActionPreference = "Stop"
$Failures = New-Object System.Collections.Generic.List[string]
$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("fecurity-hosted-" + [guid]::NewGuid().ToString("N"))

if ([string]::IsNullOrWhiteSpace($RepoRawBase)) {
    $RepoRawBase = "https://raw.githubusercontent.com/$Owner/$Repo/$Branch/"
}
if (-not $RepoRawBase.EndsWith("/")) {
    $RepoRawBase += "/"
}

function Add-Failure([string]$Message) {
    $Failures.Add($Message) | Out-Null
}

function Get-HostedFile([string]$RelativePath) {
    $Uri = $RepoRawBase + $RelativePath
    $OutFile = Join-Path $TempRoot ($RelativePath -replace "/", "\")
    $OutDir = Split-Path -Parent $OutFile
    if (-not (Test-Path -LiteralPath $OutDir -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
    }

    for ($Attempt = 1; $Attempt -le $RetryCount; $Attempt += 1) {
        try {
            Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing | Out-Null
            if ((Test-Path -LiteralPath $OutFile -PathType Leaf) -and ((Get-Item -LiteralPath $OutFile).Length -gt 0)) {
                return $OutFile
            }
        } catch {
            if ($Attempt -eq $RetryCount) {
                Add-Failure "$RelativePath is not reachable from $Uri"
                return $null
            }
        }
        Start-Sleep -Seconds $RetryDelaySeconds
    }

    Add-Failure "$RelativePath downloaded as an empty file"
    return $null
}

$RequiredRemoteFiles = @(
    ".darklua.json",
    ".darklua.dev.json",
    ".gitignore",
    "CLAUDE.md",
    "dist/Fecurity.lua",
    "dist/Fecurity.dev.lua",
    "README.md",
    "build.bat",
    "deploy.ps1",
    "publish-github.ps1",
    "verify.ps1",
    "verify-hosted.ps1",
    "include/Types.luau",
    "include/ThemeTypes.luau",
    "include/WidgetTypes.luau",
    "src/main.luau",
    "src/init.luau",
    "src/assets/AssetRegistry.luau",
    "src/core/Library.luau",
    "examples/FecurityHosted.luau",
    "examples/FecurityHostedRequire.luau",
    "examples/FecurityHostedSmoke.luau",
    "assets/manifest.json",
    "assets/fonts/ProximaNova-Semibold.ttf",
    "assets/icons/assist.png",
    "assets/icons/visuals.png",
    "assets/icons/misc.png",
    "assets/icons/colors.png",
    "assets/icons/trial.png",
    "assets/icons/assist.svg",
    "assets/icons/visuals.svg",
    "assets/icons/misc.svg",
    "assets/icons/colors.svg",
    "assets/icons/trial.svg",
    "assets/images/logo.png",
    "assets/images/logo.svg",
    "assets/images/hitbox-preview.png"
)

try {
    New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null

    $Downloaded = @{}
    foreach ($Relative in $RequiredRemoteFiles) {
        $Downloaded[$Relative] = Get-HostedFile $Relative
    }

    $ManifestPath = $Downloaded["assets/manifest.json"]
    if ($ManifestPath) {
        $Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
        if ($Manifest.schema -ne 1 -or $null -eq $Manifest.assets) {
            Add-Failure "assets/manifest.json has an invalid schema"
        } else {
            foreach ($Asset in $Manifest.assets) {
                $Path = $Downloaded[$Asset.path]
                if (-not $Path) {
                    Add-Failure "manifest asset was not downloaded: $($Asset.path)"
                    continue
                }
                $Item = Get-Item -LiteralPath $Path
                if ($Item.Length -ne [int64]$Asset.bytes) {
                    Add-Failure "hosted byte mismatch for $($Asset.path): expected $($Asset.bytes), got $($Item.Length)"
                }
                $Hash = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
                if ($Hash -ne $Asset.sha256) {
                    Add-Failure "hosted sha256 mismatch for $($Asset.path)"
                }
            }
        }
    }

    foreach ($Relative in @("dist/Fecurity.lua", "dist/Fecurity.dev.lua", "README.md", "examples/FecurityHosted.luau", "examples/FecurityHostedRequire.luau", "examples/FecurityHostedSmoke.luau")) {
        $Path = $Downloaded[$Relative]
        if ($Path) {
            $Text = Get-Content -LiteralPath $Path -Raw
            if ($Text -match "OWNER/REPO") {
                Add-Failure "$Relative still contains OWNER/REPO"
            }
        }
    }

    $ReleasePath = $Downloaded["dist/Fecurity.lua"]
    if ($ReleasePath) {
        $Release = Get-Content -LiteralPath $ReleasePath -Raw
        if ($Release -notmatch "return") {
            Add-Failure "dist/Fecurity.lua does not appear to return the library"
        }
        if ($Release -notmatch [regex]::Escape($RepoRawBase)) {
            Add-Failure "dist/Fecurity.lua does not contain the expected raw asset base URL"
        }
    }

    $HostedDemoPath = $Downloaded["examples/FecurityHosted.luau"]
    if ($HostedDemoPath) {
        $HostedDemo = Get-Content -LiteralPath $HostedDemoPath -Raw
        if ($HostedDemo -notmatch [regex]::Escape($RepoRawBase + "dist/Fecurity.lua")) {
            Add-Failure "examples/FecurityHosted.luau does not load the hosted dist URL"
        }
    }

    $HostedRequirePath = $Downloaded["examples/FecurityHostedRequire.luau"]
    if ($HostedRequirePath) {
        $HostedRequire = Get-Content -LiteralPath $HostedRequirePath -Raw
        if ($HostedRequire -notmatch 'require\(RawBase \.\. "dist/Fecurity\.lua"\)') {
            Add-Failure "examples/FecurityHostedRequire.luau does not use the hosted require URL style"
        }
    }

    $HostedSmokePath = $Downloaded["examples/FecurityHostedSmoke.luau"]
    if ($HostedSmokePath) {
        $HostedSmoke = Get-Content -LiteralPath $HostedSmokePath -Raw
        if ($HostedSmoke -notmatch [regex]::Escape($RepoRawBase + "dist/Fecurity.lua")) {
            Add-Failure "examples/FecurityHostedSmoke.luau does not load the hosted dist URL"
        }
        foreach ($Needle in @("SaveConfig", "LoadConfig", "SetAssetBaseUrl", "AddHitboxPreview", "AddConfigList")) {
            if ($HostedSmoke -notlike "*$Needle*") {
                Add-Failure "examples/FecurityHostedSmoke.luau does not exercise $Needle"
            }
        }
    }
} finally {
    if (Test-Path -LiteralPath $TempRoot -PathType Container) {
        Remove-Item -LiteralPath $TempRoot -Recurse -Force
    }
}

if ($Failures.Count -gt 0) {
    foreach ($Failure in $Failures) {
        Write-Host "[verify-hosted:fail] $Failure"
    }
    throw "hosted verification failed with $($Failures.Count) failure(s)"
}

Write-Host "[verify-hosted] ok"
Write-Host "[verify-hosted] loader:"
Write-Host "local Fecurity = loadstring(game:HttpGet(`"$($RepoRawBase)dist/Fecurity.lua`"))()"
