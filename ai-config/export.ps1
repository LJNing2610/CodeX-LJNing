[CmdletBinding()]
param(
    [string]$WorkspaceRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

$OutputRoot = Join-Path $WorkspaceRoot 'ai-config'
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
$AgentsHome = Join-Path $HOME '.agents'
$CodexPlusAppData = Join-Path $env:APPDATA 'Codex++'
$PonytailSource = Join-Path $AgentsHome 'plugins\plugins\ponytail'

$secretPatterns = @(
    'sk-[A-Za-z0-9_-]{20,}',
    'ghp_[A-Za-z0-9]{36}',
    'github_pat_[A-Za-z0-9_]{20,}',
    'AKIA[0-9A-Z]{16}',
    'xox[baprs]-[A-Za-z0-9-]{10,}',
    '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----',
    'Authorization\s*[:=]\s*(Bearer|Basic)\s+\S{12,}'
)

function Reset-Directory {
    param([string]$Path)
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $safeRoot = [System.IO.Path]::GetFullPath($OutputRoot) + [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($safeRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "拒绝清理 ai-config 之外的目录: $fullPath"
    }
    if (Test-Path -LiteralPath $fullPath) {
        [System.IO.Directory]::Delete($fullPath, $true)
    }
    [System.IO.Directory]::CreateDirectory($fullPath) | Out-Null
}

function Copy-FilteredTree {
    param(
        [string]$Source,
        [string]$Destination,
        [string[]]$ExcludeDirectories = @('.git', 'node_modules', '__pycache__', '.venv', 'cache'),
        [string[]]$ExcludeFiles = @('*.bak', '*.bak-*', '*.log', '*.tmp', '*.dmp')
    )

    $sourceFull = [System.IO.Path]::GetFullPath($Source)
    if (-not (Test-Path -LiteralPath $sourceFull -PathType Container)) {
        throw "源目录不存在: $sourceFull"
    }
    [System.IO.Directory]::CreateDirectory($Destination) | Out-Null

    Get-ChildItem -LiteralPath $sourceFull -Recurse -Force | ForEach-Object {
        $relative = $_.FullName.Substring($sourceFull.Length).TrimStart('\', '/')
        $parts = $relative -split '[\\/]'
        $target = Join-Path $Destination $relative

        if ($_.PSIsContainer) {
            if ($parts | Where-Object { $_ -in $ExcludeDirectories }) {
                return
            }
            [System.IO.Directory]::CreateDirectory($target) | Out-Null
            return
        }

        if ($parts[0..([Math]::Max(0, $parts.Length - 2))] | Where-Object { $_ -in $ExcludeDirectories }) {
            return
        }
        foreach ($pattern in $ExcludeFiles) {
            if ($_.Name -like $pattern) {
                return
            }
        }

        [System.IO.Directory]::CreateDirectory((Split-Path -Parent $target)) | Out-Null
        Copy-Item -LiteralPath $_.FullName -Destination $target -Force
    }
}

function Assert-NoSecrets {
    param([string]$Root)
    $extensions = @('.json', '.toml', '.yaml', '.yml', '.md', '.txt', '.js', '.mjs', '.ps1', '.py', '.rules')
    $hits = @()
    Get-ChildItem -LiteralPath $Root -File -Recurse -Force | Where-Object { $_.Extension -in $extensions } | ForEach-Object {
        $content = Get-Content -LiteralPath $_.FullName -Raw -ErrorAction SilentlyContinue
        foreach ($pattern in $secretPatterns) {
            if ($content -match $pattern) {
                $hits += $_.FullName
                break
            }
        }
    }
    if ($hits.Count -gt 0) {
        throw "导出结果中发现疑似密钥: $($hits -join ', ')"
    }
}

$required = @(
    (Join-Path $CodexHome 'AGENTS.md'),
    (Join-Path $CodexHome 'models.json'),
    (Join-Path $CodexHome 'skills'),
    (Join-Path $PonytailSource '.codex-plugin\plugin.json')
)
foreach ($path in $required) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "缺少待导出的 AI 配置: $path"
    }
}

$codexOutput = Join-Path $OutputRoot 'codex'
$codexPlusOutput = Join-Path $OutputRoot 'codex-plus'
$pluginOutput = Join-Path $OutputRoot 'plugins'
Reset-Directory $codexOutput
Reset-Directory $codexPlusOutput
Reset-Directory $pluginOutput
$legacyMemoryOutput = Join-Path $OutputRoot 'memories'
if (Test-Path -LiteralPath $legacyMemoryOutput) {
    [System.IO.Directory]::Delete($legacyMemoryOutput, $true)
}

Copy-Item -LiteralPath (Join-Path $CodexHome 'AGENTS.md') -Destination (Join-Path $codexOutput 'AGENTS.md') -Force
Copy-Item -LiteralPath (Join-Path $CodexHome 'models.json') -Destination (Join-Path $codexOutput 'models.json') -Force
Copy-FilteredTree (Join-Path $CodexHome 'model-catalogs') (Join-Path $codexOutput 'model-catalogs')
Copy-FilteredTree (Join-Path $CodexHome 'skills') (Join-Path $codexOutput 'skills')

$userScriptsOutput = Join-Path $codexPlusOutput 'user_scripts'
[System.IO.Directory]::CreateDirectory($userScriptsOutput) | Out-Null
foreach ($script in @('market-codex-token-usage.js', 'market-codex-zhcn-translate.js')) {
    $sourceScript = Join-Path $CodexPlusAppData "user_scripts\$script"
    if (Test-Path -LiteralPath $sourceScript) {
        Copy-Item -LiteralPath $sourceScript -Destination (Join-Path $userScriptsOutput $script) -Force
    }
}

$ponytailExcludedDirectories = @(
    '.git',
    'node_modules',
    'benchmarks',
    'tests',
    'examples',
    '.claude-plugin',
    '.clinerules',
    '.cursor',
    '.devin-plugin',
    '.github',
    '.kiro',
    '.openclaw',
    '.opencode',
    '.qoder',
    '.qoder-plugin',
    '.windsurf'
)
Copy-FilteredTree $PonytailSource (Join-Path $pluginOutput 'ponytail') -ExcludeDirectories $ponytailExcludedDirectories
$ponytailInfo = [ordered]@{
    repository = (git -C $PonytailSource remote get-url origin)
    commit = (git -C $PonytailSource rev-parse HEAD)
    dirty = [bool](git -C $PonytailSource status --porcelain)
}
$ponytailInfo | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $pluginOutput 'ponytail-source.json') -Encoding utf8NoBOM

$portableMarketplace = [ordered]@{
    name = 'personal'
    interface = [ordered]@{ displayName = 'Personal' }
    plugins = @(
        [ordered]@{
            name = 'ponytail'
            source = [ordered]@{ source = 'local'; path = './plugins/ponytail' }
            policy = [ordered]@{ installation = 'INSTALLED_BY_DEFAULT'; authentication = 'ON_USE' }
            category = 'Productivity'
        }
    )
}
$portableMarketplace | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $pluginOutput 'marketplace.restore.json') -Encoding utf8NoBOM

Copy-Item -LiteralPath (Join-Path $OutputRoot 'templates\config.portable.toml') -Destination (Join-Path $codexOutput 'config.portable.toml') -Force
Assert-NoSecrets $OutputRoot

$files = @(Get-ChildItem -LiteralPath $OutputRoot -File -Recurse -Force)
$codexVersion = try { (& codex --version 2>$null) } catch { $null }
$manifest = [ordered]@{
    generatedAt = (Get-Date).ToString('o')
    codexVersion = $codexVersion
    powershellVersion = $PSVersionTable.PSVersion.ToString()
    gitVersion = (git --version)
    ponytail = $ponytailInfo
    fileCount = $files.Count
    sizeBytes = ($files | Measure-Object Length -Sum).Sum
    excluded = @(
        'personal profile',
        'memory content',
        'session history',
        'auth.json',
        'API keys',
        'OAuth credentials',
        'WeChat identity and pairing data',
        'logs and databases',
        'theme images and visual personalization'
    )
}
$manifest | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $OutputRoot 'manifest.json') -Encoding utf8NoBOM

Write-Host "AI 风格与规则快照已生成: $OutputRoot"
Write-Host "文件数: $($manifest.fileCount)，大小: $([math]::Round($manifest.sizeBytes / 1MB, 2)) MB"
