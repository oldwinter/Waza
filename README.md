<div align="center">
  <img src="https://gw.alipayobjects.com/zos/k/2h/waza.svg" width="120" />
  <h1>Waza</h1>
  <p><b>把你已经熟悉的工程习惯，变成 AI agents 可以执行的 skills。</b></p>
  <a href="https://github.com/tw93/Waza/actions/workflows/test.yml"><img src="https://img.shields.io/github/actions/workflow/status/tw93/Waza/test.yml?branch=main&style=flat-square&label=tests" alt="Tests"></a>
  <a href="https://github.com/tw93/Waza/stargazers"><img src="https://img.shields.io/github/stars/tw93/Waza?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/tw93/Waza/releases"><img src="https://img.shields.io/github/v/tag/tw93/Waza?label=version&style=flat-square" alt="Version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License"></a>
  <a href="https://twitter.com/HiTw93"><img src="https://img.shields.io/badge/follow-Tw93-red?style=flat-square&logo=Twitter" alt="Twitter"></a>
</div>

<br/>

## 为什么

Waza（技, わざ）是日本武术里的“技”：反复练习，直到动作变成本能。

好的工程师不只是写代码。他们会想清需求，审查自己的工作，系统性调试，设计有明确意图的界面，并阅读一手资料。他们写得清楚，也通过产出而不是消费内容来学习新领域。

AI 在原始产出能力上已经强过大多数工程师。但没有结构时，这种能力很容易滑向泛泛而谈和不精确的工作。Waza 把它收束到精确的工程习惯里：八个 skills 先设清目标和约束，再让模型做它最擅长的事。

三部曲的一部分：[Kaku](https://github.com/tw93/Kaku)（書く）写代码，[Waza](https://github.com/tw93/Waza)（技）训练习惯，[Kami](https://github.com/tw93/Kami)（紙）交付文档。可以把它们想成一家人：Kaku 是爸爸，Waza 是姐姐，Kami 是妹妹。

<div align="center">
  <img src="https://gw.alipayobjects.com/zos/k/qa/waza_repaired_v4.svg" width="1000" />
</div>

## Skills

每个工程习惯都对应一个安装好的 skill。在 Claude Code 里输入 slash command。在 Codex 里按名称调用已安装的 skill，并沿用同一套 playbook。

| Skill | 何时使用 | 作用 |
| :--- | :--- | :--- |
| [`/think`](skills/think/SKILL.md) | 构建任何新东西之前 | 挑战问题、压力测试设计，并产出另一个 agent 可以直接执行的决策完备计划。 |
| [`/design`](skills/design/SKILL.md) | 构建前端界面 | 产出有辨识度的 UI，包括基于截图的审美迭代，方向明确，而不是套用泛化默认值。 |
| [`/check`](skills/check/SKILL.md) | 任务完成后、合并或发布前 | 审查 diff，提炼项目特定约束，处理已批准的 release/publish/push/reaction 收尾，并用证据验证。 |
| [`/hunt`](skills/hunt/SKILL.md) | 任何 bug、回归或异常行为 | 系统性调试。先确认 root cause，再应用任何 fix，尤其适用于以前能工作的东西。 |
| [`/write`](skills/write/SKILL.md) | 写作或编辑 prose | 重写中文和英文 prose，使其自然，删掉僵硬、模板化的表达。 |
| [`/learn`](skills/learn/SKILL.md) | 深入陌生领域 | 六阶段研究 workflow：收集、消化、拟提纲、填充、精修，然后自审并准备发布。 |
| [`/read`](skills/read/SKILL.md) | 任何 URL 或 PDF | 按平台特性路由读取 URL 和 PDF。普通读取返回简洁总结；当用户要求转换、引用、保存或供下游工作使用时输出 Markdown。 |
| [`/health`](skills/health/SKILL.md) | 审计 Agent Health | 检查 Codex、Claude Code、项目指令、verifier 输出和 AI maintainability，在深度检查前做预算感知的摘要扫描。 |

每个 skill 都是一个文件夹，里面有 reference docs、helper scripts，以及来自真实失败的 gotchas。

## 安装和更新

大多数用户应该全局安装 Waza，这样每个项目都能使用同一组 skills。

**Claude Code**

```bash
npx skills add tw93/Waza -a claude-code -g -y
```

这会安装 `/think`、`/design`、`/check`、`/hunt`、`/write`、`/learn`、`/read` 和 `/health`。只安装单个 skill 可使用 `npx skills add tw93/Waza --skill think -a claude-code -g -y`。

**Codex**

```bash
npx skills add tw93/Waza -a codex -g -y
```

只安装单个 skill 可使用 `npx skills add tw93/Waza --skill think -a codex -g -y`。Codex sessions 可以按名称调用已安装的 skills，也可以链接到 `npx skills path tw93/Waza` 显示的已安装 `SKILL.md` 路径。

**Antigravity**

```bash
npx skills add tw93/Waza -a antigravity -g -y
npx skills add tw93/Waza -a antigravity-cli -g -y
```

桌面应用使用 `antigravity`，终端 agent 使用 `antigravity-cli`。两者都会通过 skills installer 使用 Waza 标准的 `skills/<name>/SKILL.md` 布局。

**OpenCode**

```bash
npx skills add tw93/Waza -a opencode -g -y
```

安装后，OpenCode 会通过原生 skill tool 加载 Waza。当任务匹配 `think`、`design`、`check`、`hunt`、`write`、`learn`、`read` 或 `health` 时，按名称调用对应 skill。

**Claude Code plugin marketplace**（单 skill 条目需要 Claude Code v2.1.143+）

```bash
/plugin marketplace add tw93/Waza
/plugin install waza@waza
```

这会安装全部八个 skills。在 Claude Code v2.1.143 或更新版本里，可用 `/plugin install waza-<name>@waza` 只安装单个 skill，例如 `waza-think@waza`。

**Claude Desktop**

下载 [waza.zip](https://github.com/tw93/Waza/releases/latest/download/waza.zip)，打开 Customize > Skills > "+" > Create skill，然后上传 ZIP。

**Pi coding agent**

```bash
pi install npm:@tw93/waza
```

Pi 可以从仓库或已发布的 `@tw93/waza` npm package 加载 Waza 标准的 `skills/<name>/SKILL.md` 布局；该 package 暴露了指向 `./skills` 的 `pi.skills` metadata。`/health` 会把 Pi settings、configured packages 和 local skill roots 与 Claude Code、Codex 一起审计。

**更新**

```bash
npx skills update -g -y
```

Marketplace 安装使用 `claude plugin update <skill>`。Claude Desktop 用户可以用最新的 [waza.zip](https://github.com/tw93/Waza/releases/latest/download/waza.zip) 替换旧 skill。
Pi 用户可以运行 `pi update npm:@tw93/waza`，或用 `pi update --extensions` 更新全部已安装的 Pi packages。

## Project Context

Waza 把通用程序员习惯保留在公开 skill 内。`/check` 通过读取目标仓库的公开上下文和用户任务约束，变得 project-aware。

- Project commands 来自 README、package manifests、Makefiles、CI workflows 和用户明确指令。
- Project hard stops 包括 generated artifacts、protected files、version synchronization、release assets 和领域特定 safety risks。
- Public docs 和示例不得包含 credentials、certificate paths、private key filenames、tokens 或个人机器细节。

review context template 见 [`skills/check/references/project-context.md`](skills/check/references/project-context.md)。

## 串联 Skills

Skills 被设计成可以串联，但切换是手动的。每个 skill 完成自己的任务后都会停下，等待你决定下一步。

**常见 workflows：**

- **设计一个功能**：`/think` → approve → 说 "implement X" → `/check` → merge
- **交付一个 fix**：`/hunt` → fix → `/check` → release/publish/push/issue follow-through
- **研究并写作**：`/read`（fetch sources）→ `/learn`（synthesize）→ `/write`（polish）
- **调试并验证**：`/hunt`（find root cause）→ fix → `/check`（review changes）

每个箭头都代表一次手动用户动作。Skills 不会自动互相触发。

## 额外功能

### Statusline

Claude Code 的极简 statusline：context window、5-hour quota 和 7-day quota。按使用量着色，没有进度条，没有噪音。

<div align="center">
  <img src="https://gw.alipayobjects.com/zos/k/y9/RUgevg.png" width="1000" />
</div>

```bash
curl -sL https://raw.githubusercontent.com/tw93/Waza/v3.27.0/scripts/setup-statusline.sh | bash
```

**Codex** 有原生 statusline items。添加到 `~/.codex/config.toml`：

```toml
[tui]
status_line = ["model-with-reasoning", "current-dir", "context-used", "five-hour-limit", "weekly-limit"]
status_line_use_colors = true
```

Codex 显示剩余额度；上面的 Claude Code statusline 显示已用百分比（upstream 还没有暴露 `five-hour-used` / `weekly-used`）。

### English Coaching

用于英语练习的可选 rule。当你的 prompt 包含英文错误时，agent 会追加一条简短的 😇 correction；纯中文 prompts 不会被改动。

<div align="center">
  <img src="https://gw.alipayobjects.com/zos/k/24/vfkGOi.png" width="1000" />
</div>

```bash
# Claude Code
curl -sL https://raw.githubusercontent.com/tw93/Waza/v3.27.0/scripts/setup-rule.sh | bash -s -- english claude-code

# Codex
curl -sL https://raw.githubusercontent.com/tw93/Waza/v3.27.0/scripts/setup-rule.sh | bash -s -- english codex
```

### Anti-Patterns

可选的 always-on guardrails，用于跨 skill 行为：读完再行动，不幻觉路径，不 scope creep，不主动追加总结。它不绑定具体 skill，适用于每个 session。

```bash
curl -sL https://raw.githubusercontent.com/tw93/Waza/v3.27.0/scripts/setup-rule.sh | bash -s -- anti-patterns claude-code
```

Codex 用户把 `claude-code` 换成 `codex`。Curl URLs 固定到当前 release tag，便于复现；如果想使用 bleeding-edge scripts，可把 `v3.27.0` 换成 `main`。

### Routing Hint

可选 pointer，用来告诉 host：当请求匹配触发条件时优先使用 Waza skills。它对 Codex、Pi 和其他不会根据 skill `description` 自动路由的 agents 很有用。Claude Code 已经会通过 descriptions 路由，所以这里同样是 opt-in。

```bash
curl -sL https://raw.githubusercontent.com/tw93/Waza/v3.27.0/scripts/setup-rule.sh | bash -s -- waza-routing claude-code
```

Codex 用户把 `claude-code` 换成 `codex`。

## Uninstall

```bash
npx skills remove tw93/Waza -g
rm -f ~/.claude/statusline.sh
rm -f ~/.claude/rules/english.md
rm -f ~/.claude/rules/anti-patterns.md
rm -f ~/.claude/rules/waza-routing.md
```

Claude Desktop 用户从 Customize > Skills 删除 Waza。Codex rule installs 则从 `~/.codex/AGENTS.md` 中删除带标记的 Waza blocks。

## 背景

Superpowers 和 gstack 这样的工具很厉害，但也很重：skills 太多、配置太多、学习曲线太陡。

作者写下的每条 rule 也是一个上限。模型只能做指令允许它做的事。Waza 反过来：每个 skill 只设清目标和真正重要的约束，然后退后一步。随着模型变强，这种克制会产生复利。

八个 skills，对应真正重要的习惯。每个只做一件事，有清晰 trigger，并且不挡路。它们来自真实项目，在 7 个项目的 300+ sessions 中打磨。每个 gotcha 都能追溯到一次真实失败。

`/health` skill 源自 [这篇文章](https://tw93.fun/en/2026-03-12/claude.html) 描述的六层 Claude Code framework，现在覆盖 Codex、Claude Code、Pi、verifier surfaces 和 AI maintainability。

## Support

- 如果 Waza 帮到了你，可以[分享给朋友](https://twitter.com/intent/tweet?url=https://github.com/tw93/Waza&text=Waza%20-%20AI%20coding%20skills%20for%20the%20complete%20engineer.)，或给它一个 star。
- 有想法或 bug？欢迎开 issue 或 PR，也欢迎贡献你最喜欢的 AI model。
- 我有两只猫，TangYuan 和 Coke。如果你觉得 Waza 让生活更开心，可以给它们投喂<a href="https://cats.tw93.fun?name=Waza" target="_blank">罐头 🥩</a>。

<div align="center">
  <a href="https://cats.tw93.fun?name=Waza"><img src="https://cdn.jsdelivr.net/gh/tw93/sponsors@main/assets/sponsors.svg" width="1000" loading="lazy" /></a>
</div>

## License

MIT License。欢迎使用 Waza，也欢迎贡献。
