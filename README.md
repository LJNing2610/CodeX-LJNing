# 🧠 Codex 全局工作台 — Workspace 总览

> **版本**: v1.0  
> **创建日期**: 2026-07-16  
> **维护者**: Repository owner + Codex  
> **核心原则**: 所有知识沉淀下来，让每个新项目站在前人的肩膀上。

---

## 一、目录结构总览

> 这是面向外部分享的公开镜像，只包含脱敏后的 AI 工作规则和工具配置。私有主仓库仍是长期存储位置。

```
Workspace/
├── README.md                    # ← 本文件：全局工作台文档
├── PRIVACY.md                   # 仓库隐私边界与提交检查
├── PUBLIC_MIRROR.md             # 公开镜像范围与来源说明
├── ai-config/                   # AI 风格、规则、Skills、插件与恢复脚本
├── _global/                     # 全局共享知识库（所有项目通用）
│   ├── 复利日志.md               # 可复用的 AI 工作规则和工程规范
│   ├── 踩坑日志.md               # 常见错误、根因、解决方案
│   └── SOP.md                   # 标准操作流程
│
├── _template/                   # 新项目模板（拷贝此文件夹作为起点）
│   ├── 需求文档.md
│   ├── 技术栈.md
│   ├── 开发记录.md
│   ├── 踩坑记录.md
│   ├── SOP.md
│   └── 复盘.md
│
└── <项目名称>/                   # 项目目录按隐私审查结果决定是否同步
    ├── 需求文档.md
    ├── 技术栈.md
    ├── 开发记录.md
    ├── 踩坑记录.md
    ├── SOP.md
    └── 复盘.md
```

---

## 二、文档用途说明

| 文档 | 用途 | 谁维护 |
|------|------|--------|
| `README.md` | 全局工作台总入口，说明结构和使用规则 | 用户 + Codex |
| `复利日志.md` | 记录可复用的 AI 工作规则和工程规范 | Codex（主动沉淀） |
| `踩坑日志.md` | 记录已解决的错误/问题，根因与解决方案，避免重复踩坑 | Codex（主动沉淀） |
| `SOP.md` | 标准操作流程：发版、部署、代码审查等标准化步骤 | Codex + 用户 |
| `需求文档.md` | 项目需求描述、功能清单、验收标准 | 用户 / Codex |
| `技术栈.md` | 项目所用语言、框架、工具链及版本 | Codex |
| `开发记录.md` | 按时间顺序的开发日志，记录关键决策和进展 | Codex |
| `踩坑记录.md` | 项目专属的踩坑日志（全局通用问题归入 _global） | Codex（主动沉淀） |
| `复盘.md` | 项目结束后的复盘，总结做得好和可以改进的地方 | Codex |

---

## 三、命名规则

### 3.1 文件夹命名
- **项目文件夹**: 使用项目英文名称，`小写-中划线` 格式，如 `my-ai-app`、`data-pipeline`
- **特殊文件夹**: `_global`（全局知识库）、`_template`（项目模板）以下划线开头，排在目录最前

### 3.2 文件命名
- 统一使用中文命名，便于快速识别内容
- 格式: `文档名.md`，全部使用 Markdown 格式

### 3.3 文档内部规范
- 每个文档第一行为 `# 文档标题`（一级标题）
- 日期格式统一为 `YYYY-MM-DD`
- 代码块需标注语言（如 `python`、`javascript`、`bash`）
- 关键路径和文件使用反引号包裹

---

## 四、使用规则（Codex 必须遵守）

### 4.1 任务开始前（强制）
在开始 **任何新项目** 之前，Codex **必须**：

1. 阅读本文件（README.md），了解整体结构
2. 阅读 `_global/复利日志.md`，了解积累的经验和规范
3. 阅读 `_global/踩坑日志.md`，了解已知问题和避免方法
4. 阅读 `_global/SOP.md`，了解标准操作流程
5. 阅读目标项目文件夹下的所有文档（如有）

> ✅ 阅读确认后，在响应中声明 "已阅读全局工作台、复利日志、踩坑日志和SOP。"

### 4.2 执行过程中
Codex **必须主动沉淀**以下内容到对应文档：

- 发现新的开发规范、偏好、沟通风格 → 写入 `复利日志.md`
- 遇到并解决一个 bug 或问题 → 写入 `踩坑日志.md`
- 发现可复用的流程或步骤 → 写入 `SOP.md`
- 项目中做的重要决策、进展 → 写入项目的 `开发记录.md`
- 项目专属的坑 → 写入项目的 `踩坑记录.md`

### 4.3 文档更新格式
每次追加内容时，使用以下格式：

```markdown
### YYYY-MM-DD: [简短标题]

- **场景/任务**: xxx
- **内容**: xxx
- **原因/背景**: xxx
```

---

## 五、AI 协作约定

- 默认使用中文，先给结果，再补充必要证据
- 复杂操作前说明计划
- 需求含糊时采用最小可解释假设
- 代码变更使用可审查的 patch，并说明验证方式
- 不把个人画像、设备信息、账户、会话或使用历史写入仓库

---

## 六、技术支持与反馈

如有结构优化建议、文档模板改进意见，可以随时提出。工作台体系本身也是持续演进的。

---

## 七、GitHub 同步

- 远程仓库：`https://github.com/LJNing2610/CodeX-Public`（公开镜像）
- 分支：`main`
- 本仓库默认同步通用 AI 规则、模板和脱敏配置；项目目录须单独审查后再加入
- `.gitignore` 排除依赖、日志、转储、安装包、注册表快照和本机配置备份；提交前仍须检查敏感信息
- `ai-config/` 保存可迁移的 AI 工作风格、规则、Skills 和插件；运行 `ai-config/export.ps1` 刷新脱敏快照
- 新电脑的完整安装、恢复和验证步骤见下方迁移教程

---

## 八、AI 配置迁移教程

本节用于把仓库中的 AI 工作风格、规则、Skills、插件和相关配置迁移到新电脑。

### 8.1 先理解能恢复什么

本仓库不是 Codex 安装包，也不是系统镜像。克隆仓库后，还需要安装软件、执行恢复脚本并重新授权。

| 项目 | 恢复情况 |
|---|---|
| 中文回复、省 Token、先思考后编码、Ponytail | 可以恢复 |
| 代码规范、验证要求、问题定位和知识沉淀规则 | 可以恢复 |
| 自定义 Skill、模型目录、Ponytail 插件 | 可以恢复 |
| Token 用量显示、中文翻译脚本 | 公开镜像因许可未确认而不附带 |
| Codex 基础配置骨架 | 可以恢复，但需要检查路径和凭据 |
| Codex++ 全部 UI 设置、主题和启动动画 | 不恢复 |
| 聊天历史、长期记忆、会话和任务上下文 | 不恢复 |
| 个人画像、设备信息、网络地址和账户资料 | 不恢复 |
| GitHub、模型 API、MCP 和微信登录状态 | 必须重新授权 |
| 当前项目源码和未脱敏文档 | 默认不随仓库同步 |

新设备可以恢复**相似的工作方式和编码规矩**，但不会得到完全相同的账户、历史、界面和项目状态。

### 8.2 安装前置软件

按需安装：

1. Codex 桌面版，安装后至少启动一次
2. PowerShell 7
3. Git for Windows
4. Python 3.11 和 Headroom（使用 Headroom MCP 时需要）
5. Codex++（使用协作 MCP 或自行配置用户脚本时需要）

Codex 安装完成后，先确认它能正常创建会话，再执行恢复。

### 8.3 克隆公开仓库

```powershell
git clone https://github.com/LJNing2610/CodeX-Public.git "$HOME\Desktop\Workspace"
Set-Location "$HOME\Desktop\Workspace"
```

公开仓库无需登录即可读取。

### 8.4 恢复规则和资源

先完全退出 Codex 和 Codex++，再运行：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\ai-config\restore.ps1
```

恢复脚本会：

- 安装全局 `AGENTS.md`
- 安装自定义 Skill `hatch-pet`
- 恢复模型目录
- 安装 Ponytail 和个人 marketplace
- 恢复可用的 Codex++ 用户脚本（公开镜像不附带许可未确认的第三方脚本）
- 在执行前备份新电脑上的同名文件
- 默认不覆盖 Codex 主配置

备份目录位于用户主目录下，名称形如 `.codex-restore-backup-YYYYMMDD-HHMMSS`。

### 8.5 应用 Codex 配置骨架

确认 Codex 已正常启动一次后，运行：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\ai-config\restore.ps1 -ApplyConfig
```

该命令会用 `ai-config/templates/config.portable.toml` 生成新的 Codex 配置，并自动替换当前用户目录。

注意：

- 模型 API Key 使用 `<REDACTED>` 占位，必须在本机配置。
- MCP 和第三方工具路径可能不同，需要逐项检查。
- 如果新设备已有大量自定义配置，建议先不带 `-ApplyConfig` 恢复，再手动合并模板。

### 8.6 重新授权

启动 Codex 和 Codex++，重新完成：

- GitHub 登录
- 模型服务 API Key 配置
- Codex++ 模型路由配置
- Headroom MCP 路径检查
- Codex++ 协作 MCP 路径检查
- MCP OAuth 或第三方服务授权
- 微信连接等需要账户配对的功能

凭据不会进入仓库。这是迁移设计的固定安全边界。

### 8.7 验证恢复结果

```powershell
Test-Path "$HOME\.codex\AGENTS.md"
Test-Path "$HOME\.codex\skills\hatch-pet\SKILL.md"
Test-Path "$HOME\.agents\plugins\plugins\ponytail\.codex-plugin\plugin.json"
```

在 Codex 中新建会话，验证：

- 回复默认使用中文
- 编写代码前会分析调用链和边界条件
- 会优先选择最小实现、标准库和平台原生能力
- 会执行实际验证并报告证据
- Ponytail 命令或 Skill 可用
- `hatch-pet` Skill 可被发现

### 8.8 只克隆但不运行恢复脚本

如果只在 Codex 中打开克隆后的目录：

- 根目录 `AGENTS.md` 会对该工作区生效
- 新项目会遵循仓库中的文档和协作规则
- `ai-config` 中的恢复包可以被阅读
- 但全局规则、自定义 Skill 和 Ponytail 不会自动安装

克隆仓库和恢复 AI 环境是两个步骤。

### 8.9 更新仓库中的 AI 快照

修改 AI 规则、Skill、插件或模型配置后运行：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\ai-config\export.ps1
```

检查结果后：

```powershell
git status
git add ai-config _global README.md AGENTS.md PRIVACY.md
git commit -m "docs: refresh AI snapshot"
git push origin main
```

提交前必须确认没有以下内容：

- 姓名、学号、联系方式或账户标识
- 本机用户名、网络地址或设备序列号
- API Key、Token、Cookie 或登录状态
- 聊天、长期记忆、会话、数据库和运行日志
- 未经审查的项目源码或个人文档

### 8.10 常见问题

**Codex 没有读取全局规则**

确认文件位于 `$HOME\.codex\AGENTS.md`，并新建会话。当前会话可能仍在使用旧上下文。

**Ponytail 没有出现**

确认插件目录和个人 marketplace 已恢复，完全退出并重新启动 Codex。

**Codex 启动时报 MCP 路径错误**

检查 Headroom 和 Codex++ 是否安装；不需要对应 MCP 时，从新配置中删除失效条目。

**模型返回认证错误**

配置文件中的 `<REDACTED>` 不是可用凭据。重新登录或填写本机 API Key。

**恢复后配置异常**

使用恢复脚本生成的 `.codex-restore-backup-*` 目录恢复原文件，或重新启动 Codex 让程序重建机器专属配置。

### 8.11 隐私说明

仓库只同步可迁移的 AI 风格、技术规则和工具配置。个人历史、账户状态、记忆、聊天和可视化个性化资源均在仓库之外，需要单独决定是否迁移。

更多边界见 [PRIVACY.md](PRIVACY.md)。
