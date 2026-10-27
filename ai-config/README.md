# AI 风格与规则恢复包

本目录只保存可迁移的 AI 工作方式和技术配置，用于在新电脑上恢复类似的 Codex 使用体验。

完整的安装、恢复、重新授权、验证和故障排查步骤见根目录 `README.md` 的“AI 配置迁移教程”章节。

## 备份内容

- 全局 `AGENTS.md`：语言、Ponytail、代码审查、验证和沉淀规则
- `core/AI_RULES.md`：省 Token、先思考再写代码、最小实现等风格
- `core/ENGINEERING_LESSONS.md`：去隐私后的通用工程踩坑结论
- `codex/skills/`：本机自定义 Skill 和随版本安装的系统 Skill 快照
- `codex/models.json`、`codex/model-catalogs/`：模型目录
- `plugins/ponytail/`：Ponytail 插件源码与版本信息
- Codex++ 用户脚本：公开镜像因第三方许可未确认而不附带
- `templates/config.portable.toml`：脱敏后的 Codex 配置模板

## 明确排除

- 个人画像、性格描述、硬件档案、网络与 IP 信息
- 微信账号、好友列表、聊天内容和配对状态
- Codex 会话、长期记忆、数据库、日志、崩溃转储和缓存
- API Key、OAuth Token、GitHub 凭据和 `auth.json`
- 主题图片、启动动画和其他纯视觉个性化内容
- 含个人路径的旧命令白名单、系统备份和项目私有数据

## 新电脑恢复

### 1. 安装前置软件

1. Codex 桌面版，并至少启动一次
2. PowerShell 7
3. Git for Windows
4. Python 3.11 和 Headroom（需要 Headroom MCP 时）
5. Codex++（需要 Token 用量、翻译脚本或 Codex++ 协作 MCP 时）

### 2. 克隆仓库

```powershell
git clone https://github.com/LJNing2610/CodeX-Public.git "$HOME\Desktop\Workspace"
Set-Location "$HOME\Desktop\Workspace"
```

### 3. 恢复规则与资源

先关闭 Codex 和 Codex++，然后运行：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\ai-config\restore.ps1
```

这会恢复全局 Agent 规则、自定义 Skill、模型目录和 Ponytail。新电脑上的原文件会先备份。

应用脱敏后的 Codex 配置模板：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\ai-config\restore.ps1 -ApplyConfig
```

该模板不含 Token，并会替换成新电脑的用户目录。安装路径和 MCP 可用性仍需核对。

### 4. 重新授权

- 在 Codex 中登录并配置模型 API Key
- 在 Git 中登录 GitHub
- 打开 Codex++，确认增强脚本已加载
- 确认 `headroom.exe` 和 Codex++ 路径存在
- MCP 如使用 OAuth，重新完成授权

## 更新快照

AI 规则、Skill 或插件变化后运行：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\ai-config\export.ps1
git add ai-config
git commit -m "chore: refresh AI rules and configuration snapshot"
git push origin main
```

导出脚本会重新复制规则、Skill、模型目录和 Ponytail，并执行密钥扫描。
