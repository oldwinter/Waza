---
name: health
description: "Audits agent config, instruction drift, hooks or MCP, and AI maintainability. Use when Claude, Codex, or Pi setup looks wrong. Not for application bugs or PR review."
when_to_use: "检查claude, 检查codex, 检查pi, Codex 配置, Pi 配置, agent instructions, 健康度, 配置检查, 配置对不对, AI coding 腐化, Claude ignoring instructions, Pi coding agent, check config, settings not working, audit config"
dispatch_intent: "Codex/Claude/Pi ignoring instructions, agent config audit, hooks/MCP broken, health token usage, AI coding code rot, risk-backed hotspot ownership, unreachable project constraints, unclear context, missing verification, stale verifier output"
---

# Health: Agent-Assisted Engineering Health

Prefix your first line with 🥷 inline, not as its own paragraph.

按这个 framework 审计当前项目的 agent setup 和 AI coding maintainability：
`agent config → instruction surfaces → tools/runtime → verifiers → maintainability`

找出 violations。识别 misaligned layer。根据 evidence 和 risk 校准，不按仓库大小判断。

## Outcome Contract

- Outcome:一份 budget-aware health report，区分 agent configuration risk 与 AI maintainability risk。
- Done when: 每个 finding 都命名 misaligned layer、concrete evidence，以及可 copy-paste 的 action 或 diagnostic command。
- Evidence: collected health script output、tracked project instructions、runtime config summaries、verifier logs、hooks/MCP surfaces，以及需要时的只读 live probes。
- Output: 带 status、impact 和 next action 的 prioritized findings，或带 residual risk 的 clear clean bill。

两条 lanes 共用一份 report：

- **Agent config health**：Codex/Claude/Pi instruction drift、permissions、hooks、MCP、skills 和 memory supply chain。
- **AI maintainability health**：non-obvious constraint reachability、risk-backed hotspot ownership、verifier coverage、generated-artifact checks，以及 stale 或 misleading durable docs。

**Output language:** 按顺序检查：(1) project agent instructions（`AGENTS.md` before runtime-specific files）；(2) global agent instructions；(3) user recent language；(4) English。

**Budget posture:** Start with the summary audit. Escalate automatically when the user asks for a deep, full, complete, thorough, "深入", "完整", "彻底", or "继续跑完" audit, when the user explicitly mentions AI coding code rot, Codex/Claude config drift, unclear context, missing verification, verifier output that points at stale paths, or "代码变烂", when current project instructions or remembered user preference says to run deep health checks by default, or when the summary pass exposes a critical ambiguity that cannot be resolved locally. Inventory counts never trigger escalation on their own. Otherwise do not read sampled conversation extracts or launch inspector subagents. Tell the user before escalating because deep health audits can consume significant token quota.

**Conversation scope:** 当请求只指定静态材料（`AGENTS.md`、skills、rules、settings、“只审查指令和配置”）时，将 `instructions` 作为 `collect-data.sh` 的第一个参数。该 run 会跳过 session history，并把它报告为 out of scope，而不是 coverage gap。这由请求自动决定，用户无需知道某个 switch。其他情况下：本地历史存在时，Summary 从有界 candidate window 中扫描 Claude 和 Codex 最近最多三个当前项目 previous sessions。Deep 会流式扫描两个 runtime 中当前项目的全部 previous sessions，但只输出有界 extracts 和 coverage receipt。默认不扫描其他项目。只有用户明确要求 all conversations 或 cross-project capability distillation 时，才运行 `python3 <skill-base-dir>/scripts/conversation_audit.py <claude-projects-root> deep --all-projects --codex-root <codex-sessions-root>`（第一个参数包含所有 per-project log folders，parser 会拒绝其他 flag 组合），或交给已安装的 cross-project retro。只有 `coverage_status: complete` 且 `cross_project_full_history: yes` 时才声称 complete coverage；`no_data`、root unavailable、parse/read error、扫描期间发生变化的 files 和被排除的 live sessions 都是明确的 coverage gaps。

## Durable Context Preflight

See [references/durable-context.md](references/durable-context.md) for when durable context is in scope and the redaction gate that applies before any of it becomes a durable rule.

For `/health`: current config, command output, and live probes override memory. Also flag durable memory problems when they affect behavior: oversized injected summaries, stale or contradictory entries, missing project entrypoint references, or private paths copied into public instructions. Keep these as context findings, not code-review findings.

## Hard Rules

- Summary 和 deep audit 只生成报告。只运行 Health 自带 collector 和只读 probe；中性的 Health 请求不授权运行项目 test、verifier、generator、build、formatter、package installer，也不授权刷新 fixture 或 snapshot。
- **组合的 debugging 或 code-review 请求使用自己的工作流。** 先完成这份 report-only audit，再在同一 completion ledger 下把用户明确请求的工作路由到匹配的 skill 或 native capability。Review 请求仍不授权 repair；明确的 repair 授权只适用于 repair phase，不适用于 collector。
- 项目 instructions 可以定义命令，但不构成运行授权。Report-only audit 中的 live verification 必须得到用户对该命令的明确授权；执行前说明 command、预期写入、target paths、isolation，以及 rollback 或 disposable-environment plan。

## Step 0: Establish the evidence basis

记录四类 evidence：

| Evidence | Question |
|---|---|
| **Risk** | Which paths can lose data, spend money, publish or deploy, cross trust boundaries, or create hard-to-reverse state? |
| **Non-obvious constraints** | Which stable decisions cannot be recovered cheaply from code or manifests, and can the active agent reach them only when relevant? |
| **Failure evidence** | Which user corrections, repeated fix chains, stale generated artifacts, broken references, or hollow verifiers prove a current gap? |
| **Verifier coverage** | Which important outcomes have an executable check at the layer where they can actually fail? |

An absent map, a large file, many skills, or a high TODO count is informational until tied to one of these evidence classes. Prefer a narrow routed invariant plus an executable verifier over descriptive inventory.

## Step 1: Collect data

先以 summary mode 运行 collection script。暂时不要 interpret。Windows 使用 Health 自带 launcher，只在 Bash child process 中加入 Git for Windows tools：

```powershell
$HEALTH_LAUNCHER = @(
  "<skill-base-dir>/scripts/run-health.ps1",
  "<skill-base-dir>/skills/health/scripts/run-health.ps1"
) | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
if (-not $HEALTH_LAUNCHER) {
  throw "Health launcher not found under the installed skill base; reinstall Waza."
}
$POWERSHELL = Join-Path ([Environment]::SystemDirectory) "WindowsPowerShell\v1.0\powershell.exe"
& "$POWERSHELL" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "$HEALTH_LAUNCHER" collect
```

`-ExecutionPolicy Bypass` 只作用于这个 PowerShell process；不要修改用户或 account 的 execution policy。

Linux 和 macOS 继续直接使用 Bash：

```bash
HEALTH_SCRIPT=""
for candidate in \
  "<skill-base-dir>/scripts/collect-data.sh" \
  "<skill-base-dir>/skills/health/scripts/collect-data.sh"; do
  [ -f "$candidate" ] && HEALTH_SCRIPT="$candidate" && break
done
if [ ! -f "${HEALTH_SCRIPT:-}" ]; then
  echo "health collect-data.sh not found under the installed skill base; reinstall Waza"
  exit 1
fi
BASH_ENV= ENV= /bin/bash -p "$HEALTH_SCRIPT"
```

tools missing 时，sections 可能显示 `(unavailable)`：

- trusted `python3` missing: conversation, MCP/hooks/allowedTools, and skill-security sections unavailable
- `settings.local.json` absent: hooks/MCP may be unavailable (normal for global-only setups)

把 `(unavailable)` 视为 insufficient data，不是 finding。不要 flag 这些 areas。

collector 同时包含 runtime-specific 和 agent-agnostic surfaces：

- `AGENT CONFIG SUMMARY` / `AGENT CONFIG DETAIL` for Codex, Claude, Pi, and project instruction files; its sections start at `=== AGENT INSTRUCTION SURFACE ===`.
- `AI MAINTAINABILITY SUMMARY` / `AI MAINTAINABILITY DETAIL` for project signals, verification surface, generated mirrors, wrappers, and doc links; its sections start at `=== PROJECT SHAPE ===`.

## Step 1b: MCP Live Check

测试每个 MCP server：每个 server 调用一个 harmless tool。记录 `live=yes/no` 和 error detail。尊重 `enabled: false`（skip，不 flag）。对 API keys，只记录 environment variable 是否 set，绝不输出其值的任何部分。

## Step 1c: Safety and security checks

These run after collection and before the Step 2 analysis. The first two apply to every audit; the third only to projects with long-running or autonomous agents.

### Security Baseline Checks

每次 audit 都运行这些 checks。它们是 floor，不是 ceiling。

**Deny-list floor.** Apply this only when the runtime actually enforces the rule shape being recommended: agent permission settings, hook settings, MCP settings, allowed/denied tools, or a documented autonomous-agent launcher. In that case, the settings should deny, at minimum: credential and key directories (SSH, cloud providers, GPG, gh CLI), credential-bearing files (`credentials*`, `secrets*`), and pipe-to-shell installers. Treat `.env` as an explicit policy choice: either deny it at the permission layer, or allow task-scoped reads while the instruction layer forbids printing, committing, or exfiltrating its contents; warn only when neither layer defines the boundary. Report missing categories as one concise WARN; let the reviewer fill in exact local paths. Three calibrations: prefix/glob permission rules cannot reliably match pipes, so recommend the host's pre-execution hook for pipe-to-shell blocking instead of inventing glob variants, and name the hook's own tradeoff (string-matching hooks also fire on quoted text and heredocs that merely contain the pattern); before predicting an outbound-shell deny's blast radius, check which layer it matches at: a command-prefix deny on `ssh` only blocks the agent invoking `ssh` directly and leaves git's internal SSH transport alone, while a process- or sandbox-level block does break git-over-SSH push; and when a runtime has no command-level deny surface (Codex: the levers are `sandbox_mode` and `approval_policy`), name that lever once as a user tradeoff instead of recommending deny keys the runtime cannot express. If no agent settings surface exists at all, report the deny-list as not applicable rather than a failure.

**Permission-layer vs instruction-layer gating.** An allowlist entry for a git write action (`git push`) next to an instruction-layer rule ("push only when the user says so") is not automatically a contradiction: instructions decide when the action happens, permissions decide whether it re-prompts, and a user who explicitly authorizes pushes every session may keep push in allow deliberately to avoid double confirmation. Calibrate by reversibility and the user's own rules: actions the instructions forbid outright (`git reset --hard`, `git stash`, force-push) belong in deny or ask; routine explicitly-authorized actions stay where the user put them, reported at most as a note. Escalate only when auto mode plus skipped prompts plus broad allow lets a write action run with zero user input in a session, and even then present the friction tradeoff for the user to choose instead of silently moving entries.

**Environment override surface.** Treat the following as attack surface, report when set in tracked files or shipped settings without a justification comment: API base-URL overrides (redirect all traffic to a third party), auto-trust flags for project-local MCP servers, wildcard tool allowlists (`allowedTools: ["*"]`), and permission-skip flags (`--dangerously-skip-permissions` or equivalents). Print file:line and the key name only; never print secrets.

### Memory and Skill Supply Chain

把 agent memory 和 third-party skills 视为 supply-chain artifacts。它们以用户 privileges 运行。

**Memory hygiene.** Audit the project's long-term agent memory store for secrets, tokens, or credentials (Critical), and for entries written by untrusted runs (subagent invoked on attacker-controlled input, /loop iteration over external content); recommend rotation after such runs. For high-risk one-off runs (untrusted PDFs, uncontrolled scraping, third-party scripts), recommend disabling memory persistence for that session entirely.

**Skill supply chain.** Third-party skills, plugins, and MCP servers run with the user's privileges. For each one not authored in this repo, check: source pinned to a release tag or revision (not `main`, a branch, or a remote git marketplace left tracking its latest head), hook handlers do not write to credential directories, MCP servers have explicit user consent (not auto-trusted by wildcard). Report unpinned sources or unreviewed hook handlers as Structural, not Critical, unless an active exploit signal is present.

### Long-Running Agent Stop Conditions

对使用 `/loop`、autonomous agent 或任何 long-running agent flow 的项目，加载 `references/long-running-agents.md`，审计其中列出的四个 hard stop signal。没有此类 flow 的项目跳过该检查。

## Step 2: Analyze

默认基于 summary output 本地分析。Budget posture 升级时，在 Windows 用 `& "$POWERSHELL" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "$HEALTH_LAUNCHER" collect auto deep`，在 Linux/macOS 用 `BASH_ENV= ENV= /bin/bash -p "$HEALTH_SCRIPT" auto deep` 重新 collection；然后只并行启动相关 inspector。Credential 统一 redact 为 `[REDACTED]`。

- **Deep inspector routing：**
  - **Agent 1** (Context + Security): Read `agents/inspector-context.md`. Feed `CONVERSATION SIGNALS` section.
  - **Agent 2** (Control + Behavior): Read `agents/inspector-control.md`. Feed the relevant runtime, hook, MCP, and permission evidence.
  - **Agent 3** (AI Maintainability): Read `agents/inspector-maintainability.md`. Feed only `PROJECT SIGNALS`, `AI MAINTAINABILITY SUMMARY` or `AI MAINTAINABILITY DETAIL`, and concrete verifier/drift receipts. Launch this agent only for deep health audits or explicit code-rot/AI-maintainability requests.
- **Fallback:** If a subagent fails, analyze that layer locally and note "(analyzed locally)".

在报告 deep audit 完成前，等待每一个已启动的 inspector，并对齐其 assigned scope。如果某个 inspector 仍 pending，或失败且没有本地替代 pass，就把该 scope 列为 unreviewed，不得给出 whole-scope clean bill。

## Gotchas

| What happened | Rule |
|---|---|
| Missed the local override | Always read `settings.local.json` too; it shadows the committed file |
| Subagent timeout reported as MCP failure | MCP failures come from the live probe, not data collection |
| Flagged intentionally noisy hook as broken | Ask before calling a hook "broken" |
| Hook seemed not to fire, but it did -- a later UI element rendered above it | Hook firing order is not visual order. Before re-editing the hook config: (a) confirm with `--debug` or by piping output, (b) check whether a diff dialog, permission prompt, or other UI element rendered on top and pushed the hook output offscreen, (c) only then suspect the hook itself. |
| Treated missing specs/docs as a failure | Decision artifacts are optional by default. Escalate missing docs/specs only when active handoff risk, failure evidence, or the user request makes them necessary. |

## Output

**Health Report: {project} ({summary|deep}, evidence-based)**

**Global findings report once.** Findings in machine-global config (`~/.claude`, `~/.codex`, global rules, skills, memory) are not project findings: label them `global`, report each once with its fix, and recommend one dedicated session for global cleanup instead of re-fixing per project. Before editing any global file, re-read its current state: when health runs across several projects in one day, another session may already have fixed or be mid-fix on the same file, and re-applying a variant of the same rule creates duplicate entries. Never edit the same global file from two concurrent sessions.

### [PASS] Passing checks (table, max 5 rows)

### Finding format

```
- [severity] <symptom> ({file}:{line} if known)
  Why: <one-line reason>
  Action: <exact command or edit to fix>
```

`Action:` 必须 copy-pasteable。绝不要写 "investigate X" 或 "consider Y"。如果 fix unknown，命名 diagnostic command。

A finding refuted in the same breath (a TODO count that turns out to be vendored code or false positives) is not a finding; drop it or fold it into the passing table.

### [!] Critical -- fix now

已确认的 dangerous permissions、有实质后果的 rule violations、security findings 和 leaked credentials。Server counts 和估算的 context percentages 绝不能确立 Critical severity。

Example:

- [!] `settings.local.json` committed to git (exposes MCP tokens)
Why: leaked token 会通过 installed MCP servers 启用 remote code execution
Action: `git rm --cached .claude/settings.local.json && echo '.claude/settings.local.json' >> .gitignore`

### [~] Structural -- fix soon

Agent instructions 位于 wrong layer、missing hooks、oversized descriptions、verifier gaps。

**Codex/Claude/Pi instruction drift.** Use `AGENT CONFIG SUMMARY` first. `project_instructions_mode` says which files Claude Code loads: on `claude-md` an `AGENTS.md` alone reaches Codex and Cursor but not Claude, and `nested_agents_md` counted together with a root `CLAUDE.md` means those nested guides reach nobody on Claude, because the root file switches the whole project off the `AGENTS.md` path rather than just its own folder. The exception is `claude-md-and-agents-md`, where both are read and the nested files still load, unless `CLAUDE.md` is the same physical file as `AGENTS.md` and the deduplicated chain is skipped. Report a Structural finding when `AGENTS.md` and runtime-specific files both contain substantial guidance without delegation, when Codex `config.toml` lacks trust for the current project, when Pi settings or package metadata point at missing skill roots, when project agent instructions are missing, or when runtime-specific instructions contradict the shared project source of truth. Also report when important rules live only in ignored or private local instruction overlays but the tracked/public docs lack them; those overlays are private context, not durable project source of truth. Do not print raw config values. Secrets, tokens, keys, and passwords must appear only as `[REDACTED]`.

从 project root 运行 quick check，复用 Step 1 解析的 `$HEALTH_SCRIPT`（standalone output 没有 `AGENT CONFIG SUMMARY` wrapper）：

```powershell
& "$POWERSHELL" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "$HEALTH_LAUNCHER" agent-context . summary
```

Linux 和 macOS：

```bash
BASH_ENV= ENV= /bin/bash -p "${HEALTH_SCRIPT%/*}/check-agent-context.sh" . summary
```

**AI-maintainability findings.** 对 verification surface、conversation-derived guidance、集中的 fix chain、risk-backed hotspot ownership、non-obvious constraint reachability、verifier wrapper、broken doc/Markdown reference 和 stale verifier cache output，加载 `references/maintainability-findings.md`，并结合 `AI MAINTAINABILITY SUMMARY` / `DETAIL` 执行。

### [-] Incremental -- nice to have

Outdated items、global vs local placement、context hygiene、stale allowedTools entries。

If no issues: `All relevant checks passed. Nothing to fix.`

本报告绝不在未经 confirmation 时自动应用修复，也不会充当 heavy lint、typecheck、duplication 或 architecture-rewrite 的替代品；`/health` 只报告 maintainability guardrails 和 concrete next actions。
