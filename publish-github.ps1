param(
    [Parameter(Mandatory = $true)]
    [string]$Owner,

    [Parameter(Mandatory = $true)]
    [string]$Repo,

    [string]$Branch = "main",
    [string]$Token = $env:GITHUB_TOKEN,
    [string]$RepoRawBase = "",
    [switch]$CreateRepo,
    [switch]$Organization,
    [switch]$Private,
    [switch]$SkipBuild,
    [switch]$SkipHostedVerify,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($RepoRawBase)) {
    $RepoRawBase = "https://raw.githubusercontent.com/$Owner/$Repo/$Branch/"
}
if (-not $RepoRawBase.EndsWith("/")) {
    $RepoRawBase += "/"
}

function Get-RepoPath([string]$FullPath) {
    return $FullPath.Substring($Root.Length + 1).Replace("\", "/")
}

function Get-PublishFiles {
    $LooseFiles = @(
        ".darklua.json",
        ".darklua.dev.json",
        ".gitignore",
        "build.bat",
        "deploy.ps1",
        "publish-github.ps1",
        "verify.ps1",
        "verify-hosted.ps1",
        "README.md",
        "CLAUDE.md"
    )
    $Folders = @("assets", "dist", "examples", "include", "src")

    foreach ($Relative in $LooseFiles) {
        $Path = Join-Path $Root $Relative
        if (Test-Path -LiteralPath $Path -PathType Leaf) {
            Get-Item -LiteralPath $Path
        }
    }

    foreach ($Folder in $Folders) {
        $Path = Join-Path $Root $Folder
        if (Test-Path -LiteralPath $Path -PathType Container) {
            Get-ChildItem -LiteralPath $Path -Recurse -File
        }
    }
}

function Get-EncodedContentPath([string]$RepoPath) {
    return (($RepoPath -split "/") | ForEach-Object {
        [System.Uri]::EscapeDataString($_)
    }) -join "/"
}

function Get-EncodedRefPath([string]$Ref) {
    return (($Ref -split "/") | ForEach-Object {
        [System.Uri]::EscapeDataString($_)
    }) -join "/"
}

function Invoke-GitHubJson([string]$Method, [string]$Path, $Body = $null) {
    $Headers = @{
        "Accept"               = "application/vnd.github+json"
        "Authorization"        = "Bearer $Token"
        "X-GitHub-Api-Version" = "2022-11-28"
        "User-Agent"           = "Fecurity-Publisher"
    }
    $Uri = "https://api.github.com$Path"

    if ($null -eq $Body) {
        return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers
    }

    $Json = $Body | ConvertTo-Json -Depth 8
    return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers -Body $Json -ContentType "application/json"
}

function Test-GitHubNotFound($ErrorRecord) {
    $Response = $ErrorRecord.Exception.Response
    if ($null -eq $Response -or $null -eq $Response.StatusCode) {
        return $false
    }
    return [int]$Response.StatusCode -eq 404
}

function Ensure-Repository {
    try {
        return Invoke-GitHubJson "Get" "/repos/$Owner/$Repo"
    } catch {
        if (-not (Test-GitHubNotFound $_)) {
            throw
        }
        if (-not $CreateRepo) {
            throw "GitHub repository $Owner/$Repo was not found. Re-run with -CreateRepo or create it first."
        }
    }

    $Body = @{
        name       = $Repo
        private    = [bool]$Private
        auto_init  = $true
        has_issues = $false
        has_wiki   = $false
    }
    if ($Organization) {
        return Invoke-GitHubJson "Post" "/orgs/$Owner/repos" $Body
    } else {
        return Invoke-GitHubJson "Post" "/user/repos" $Body
    }
}

function Get-GitRef([string]$Ref) {
    $EncodedRef = Get-EncodedRefPath $Ref
    try {
        return Invoke-GitHubJson "Get" "/repos/$Owner/$Repo/git/ref/$EncodedRef"
    } catch {
        if (Test-GitHubNotFound $_) {
            return $null
        }
        throw
    }
}

function Wait-GitRef([string]$Ref, [int]$RetryCount = 1, [int]$RetryDelaySeconds = 2) {
    for ($Attempt = 1; $Attempt -le $RetryCount; $Attempt += 1) {
        $Result = Get-GitRef $Ref
        if ($Result) {
            return $Result
        }
        if ($Attempt -lt $RetryCount) {
            Start-Sleep -Seconds $RetryDelaySeconds
        }
    }
    return $null
}

function Ensure-Branch($Repository) {
    if (Wait-GitRef "heads/$Branch") {
        return
    }

    $DefaultBranch = $Repository.default_branch
    if ([string]::IsNullOrWhiteSpace($DefaultBranch)) {
        $DefaultBranch = "main"
    }

    $SourceRef = Wait-GitRef "heads/$DefaultBranch" 8 2
    if (-not $SourceRef -or -not $SourceRef.object -or [string]::IsNullOrWhiteSpace($SourceRef.object.sha)) {
        throw "Could not find source branch '$DefaultBranch' to create '$Branch'."
    }

    Invoke-GitHubJson "Post" "/repos/$Owner/$Repo/git/refs" @{
        ref = "refs/heads/$Branch"
        sha = $SourceRef.object.sha
    } | Out-Null
    if (-not (Wait-GitRef "heads/$Branch" 8 2)) {
        throw "Created branch '$Branch' but GitHub did not expose it in time."
    }
    Write-Host "[publish] created branch $Branch from $DefaultBranch"
}

function Get-RemoteSha([string]$RepoPath) {
    $EncodedPath = Get-EncodedContentPath $RepoPath
    $EncodedBranch = [System.Uri]::EscapeDataString($Branch)
    try {
        $Existing = Invoke-GitHubJson "Get" "/repos/$Owner/$Repo/contents/$EncodedPath`?ref=$EncodedBranch"
        return $Existing.sha
    } catch {
        if (Test-GitHubNotFound $_) {
            return $null
        }
        throw
    }
}

function Publish-File($File) {
    $RepoPath = Get-RepoPath $File.FullName
    $Sha = Get-RemoteSha $RepoPath
    $Bytes = [System.IO.File]::ReadAllBytes($File.FullName)
    $Content = [System.Convert]::ToBase64String($Bytes)
    $Body = @{
        message = "Publish Fecurity $RepoPath"
        content = $Content
        branch  = $Branch
    }
    if ($Sha) {
        $Body.sha = $Sha
    }

    $EncodedPath = Get-EncodedContentPath $RepoPath
    Invoke-GitHubJson "Put" "/repos/$Owner/$Repo/contents/$EncodedPath" $Body | Out-Null
    Write-Host "[publish] $RepoPath"
}

$Files = @(Get-PublishFiles)
if ($Files.Count -eq 0) {
    throw "No files found to publish."
}

if ($DryRun) {
    Write-Host "[publish:dry-run] raw base: $RepoRawBase"
    foreach ($File in $Files) {
        Write-Host "[publish:dry-run] $(Get-RepoPath $File.FullName)"
    }
    exit 0
}

if ([string]::IsNullOrWhiteSpace($Token)) {
    throw "Set GITHUB_TOKEN or pass -Token with a token that can write to $Owner/$Repo."
}

& (Join-Path $Root "deploy.ps1") -Owner $Owner -Repo $Repo -Branch $Branch -RepoRawBase $RepoRawBase -SkipBuild:$SkipBuild
if ($LASTEXITCODE -ne 0) {
    throw "deploy.ps1 failed"
}

& (Join-Path $Root "verify.ps1") -RequirePublished -SkipBuild
if ($LASTEXITCODE -ne 0) {
    throw "published verification failed"
}

$Files = @(Get-PublishFiles)
$Repository = Ensure-Repository
Ensure-Branch $Repository

foreach ($File in $Files) {
    Publish-File $File
}

if (-not $SkipHostedVerify) {
    & (Join-Path $Root "verify-hosted.ps1") -Owner $Owner -Repo $Repo -Branch $Branch -RepoRawBase $RepoRawBase -RetryCount 8 -RetryDelaySeconds 2
}

Write-Host ""
Write-Host "[publish] done"
Write-Host "[publish] loader:"
Write-Host "local Fecurity = loadstring(game:HttpGet(`"$($RepoRawBase)dist/Fecurity.lua`"))()"
