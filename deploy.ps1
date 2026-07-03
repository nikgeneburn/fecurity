param(
    [string]$Owner = "OWNER",
    [string]$Repo = "REPO",
    [string]$Branch = "main",
    [string]$RepoRawBase = "",
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($RepoRawBase)) {
    $RepoRawBase = "https://raw.githubusercontent.com/$Owner/$Repo/$Branch/"
}
if (-not $RepoRawBase.EndsWith("/")) {
    $RepoRawBase += "/"
}

function Set-TextFileUtf8NoBom([string]$Path, [string]$Text) {
    $Encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $Encoding)
}

function Update-HostedTextFile([string]$Path, [string]$RepoSlug, [string]$RawBase) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return
    }
    $Text = Get-Content -LiteralPath $Path -Raw
    $Text = $Text -replace 'https://raw\.githubusercontent\.com/OWNER/REPO/main/', $RawBase
    $Text = $Text -replace 'https://raw\.githubusercontent\.com/[^/]+/[^/]+/[^/]+/', $RawBase
    $Text = $Text -replace 'OWNER/REPO', $RepoSlug
    Set-TextFileUtf8NoBom $Path $Text
}

$RegistryPath = Join-Path $Root "src\assets\AssetRegistry.luau"
$ReadmePath = Join-Path $Root "README.md"
$HostedDemoPath = Join-Path $Root "examples\FecurityHosted.luau"
$HostedRequirePath = Join-Path $Root "examples\FecurityHostedRequire.luau"
$HostedSmokePath = Join-Path $Root "examples\FecurityHostedSmoke.luau"
$DistReleasePath = Join-Path $Root "dist\Fecurity.lua"
$DistDevPath = Join-Path $Root "dist\Fecurity.dev.lua"

$Registry = Get-Content -LiteralPath $RegistryPath -Raw
$Registry = [regex]::Replace(
    $Registry,
    'local DefaultBaseUrl = ".*?"',
    'local DefaultBaseUrl = "' + $RepoRawBase + '"'
)
Set-TextFileUtf8NoBom $RegistryPath $Registry

$RepoSlug = "$Owner/$Repo"
foreach ($Path in @($ReadmePath, $HostedDemoPath, $HostedRequirePath, $HostedSmokePath)) {
    Update-HostedTextFile $Path $RepoSlug $RepoRawBase
}

if (-not $SkipBuild) {
    & (Join-Path $Root "build.bat")
    if ($LASTEXITCODE -ne 0) { throw "build.bat failed" }
}

foreach ($Path in @($DistReleasePath, $DistDevPath)) {
    Update-HostedTextFile $Path $RepoSlug $RepoRawBase
}

Write-Host "[deploy] raw base stamped:"
Write-Host "         $RepoRawBase"
Write-Host "[deploy] push these paths to GitHub:"
Write-Host "         assets/ dist/ examples/ include/ src/ and root project files"
Write-Host ""
Write-Host "[deploy] loader:"
Write-Host "loadstring(game:HttpGet('$($RepoRawBase)dist/Fecurity.lua'))()"
