[CmdletBinding()]
param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$CodexHome,
    [string]$AgentsHome,
    [string]$CodexPlusAppData,
    [string]$BackupRoot,
    [switch]$ApplyConfig,
    [switch]$IncludeSystemSkills
)

$ErrorActionPreference = 'Stop'

$ConfigRoot = Join-Path $RepoRoot 'ai-config'
if (-not $CodexHome) {
    $CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
}
if (-not $AgentsHome) {
    $AgentsHome = Join-Path $HOME '.agents'
}
if (-not $CodexPlusAppData) {
    $CodexPlusAppData = Join-Path $env:APPDATA 'Codex++'
}
if (-not $BackupRoot) {
    $BackupRoot = Join-Path $HOME ('.codex-restore-backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
}

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    [System.IO.Directory]::CreateDirectory((Split-Path -Parent $Path)) | Out-Null
    [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

function Backup-Path {
    param([string]$Path, [string]$Name)
    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }
    $destination = Join-Path $BackupRoot $Name
    [System.IO.Directory]::CreateDirectory((Split-Path -Parent $destination)) | Out-Null
    Copy-Item -LiteralPath $Path -Destination $destination -Recurse -Force
}

function Copy-Tree {
    param([string]$Source, [string]$Destination)
    $sourceFull = [System.IO.Path]::GetFullPath($Source)
    if (-not (Test-Path -LiteralPath $sourceFull -PathType Container)) {
        throw "备份目录不存在: $sourceFull"
    }
    Get-ChildItem -LiteralPath $sourceFull -Recurse -Force | ForEach-Object {
        $relative = $_.FullName.Substring($sourceFull.Length).TrimStart('\', '/')
        $target = Join-Path $Destination $relative
        if ($_.PSIsContainer) {
            [System.IO.Directory]::CreateDirectory($target) | Out-Null
        }
        else {
            [System.IO.Directory]::CreateDirectory((Split-Path -Parent $target)) | Out-Null
            Copy-Item -LiteralPath $_.FullName -Destination $target -Force
        }
    }
}

$required = @(
    (Join-Path $ConfigRoot 'core\AI_RULES.md'),
    (Join-Path $ConfigRoot 'core\ENGINEERING_LESSONS.md'),
    (Join-Path $ConfigRoot 'codex\AGENTS.md'),
    (Join-Path $ConfigRoot 'codex\config.portable.toml'),
    (Join-Path $ConfigRoot 'codex\skills\hatch-pet'),
    (Join-Path $ConfigRoot 'plugins\ponytail'),
    (Join-Path $ConfigRoot 'plugins\marketplace.restore.json')
)
foreach ($path in $required) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "AI 配置备份不完整，缺少: $path"
    }
}

if (Get-Process -Name ChatGPT, codex, codex-plus-plus, codex-plus-plus-manager -ErrorAction SilentlyContinue) {
    Write-Warning '检测到 Codex/Codex++ 正在运行。建议关闭后再恢复，避免程序覆盖配置。'
}

Backup-Path (Join-Path $CodexHome 'AGENTS.md') 'codex\AGENTS.md'
Backup-Path (Join-Path $CodexHome 'config.toml') 'codex\config.toml'
Backup-Path (Join-Path $CodexHome 'skills') 'codex\skills'
Backup-Path (Join-Path $CodexHome 'models.json') 'codex\models.json'
Backup-Path (Join-Path $CodexHome 'model-catalogs') 'codex\model-catalogs'
Backup-Path (Join-Path $AgentsHome 'plugins\marketplace.json') 'agents\plugins\marketplace.json'
Backup-Path (Join-Path $AgentsHome 'plugins\plugins\ponytail') 'agents\plugins\plugins\ponytail'
Backup-Path (Join-Path $CodexPlusAppData 'user_scripts') 'codex-plus\user_scripts'

Copy-Item -LiteralPath (Join-Path $ConfigRoot 'codex\AGENTS.md') -Destination (Join-Path $CodexHome 'AGENTS.md') -Force
Copy-Tree (Join-Path $ConfigRoot 'codex\skills\hatch-pet') (Join-Path $CodexHome 'skills\hatch-pet')
if ($IncludeSystemSkills) {
    Copy-Tree (Join-Path $ConfigRoot 'codex\skills\.system') (Join-Path $CodexHome 'skills\.system')
}
else {
    Write-Host '内置系统 Skills 未覆盖；Codex 安装包会提供当前版本。'
}

foreach ($relative in @('models.json', 'model-catalogs')) {
    $source = Join-Path $ConfigRoot "codex\$relative"
    if (Test-Path -LiteralPath $source -PathType Container) {
        Copy-Tree $source (Join-Path $CodexHome $relative)
    }
    else {
        Copy-Item -LiteralPath $source -Destination (Join-Path $CodexHome $relative) -Force
    }
}

Copy-Tree (Join-Path $ConfigRoot 'plugins\ponytail') (Join-Path $AgentsHome 'plugins\plugins\ponytail')
Copy-Item -LiteralPath (Join-Path $ConfigRoot 'plugins\marketplace.restore.json') -Destination (Join-Path $AgentsHome 'plugins\marketplace.json') -Force

$userScriptsSource = Join-Path $ConfigRoot 'codex-plus\user_scripts'
if (Test-Path -LiteralPath $userScriptsSource) {
    Copy-Tree $userScriptsSource (Join-Path $CodexPlusAppData 'user_scripts')
}
else {
    Write-Host '公开镜像不包含第三方 Codex++ 用户脚本，已跳过。'
}

if ($ApplyConfig) {
    $portableConfig = Get-Content -LiteralPath (Join-Path $ConfigRoot 'codex\config.portable.toml') -Raw
    $portableConfig = $portableConfig.Replace('__CODEX_HOME__', $CodexHome.Replace('\', '/'))
    $portableConfig = $portableConfig.Replace('__HOME__', $HOME)
    $portableConfig = $portableConfig.Replace('__WORKSPACE_ROOT__', $RepoRoot)
    Write-Utf8NoBom (Join-Path $CodexHome 'config.toml') $portableConfig
    Write-Host '已应用可移植 Codex 配置。必须重新填写模型 API Key。'
}
else {
    Copy-Item -LiteralPath (Join-Path $ConfigRoot 'codex\config.portable.toml') -Destination (Join-Path $CodexHome 'config.portable.toml') -Force
    Write-Host '未覆盖 Codex 主配置；模板已保存为 config.portable.toml。'
}

Write-Host "恢复完成。原配置备份目录: $BackupRoot"
Write-Host '下一步：登录 GitHub，配置模型 API Key，并重新授权 MCP/Codex++。'
