---
name: health
description: "Run budget-aware, agent-assisted engineering health audits for instruction/config drift, hooks/MCP, verifier surfaces, and AI maintainability. Use when users ask in any language to audit Claude, Codex, Pi, agent instructions, MCP/hooks, verifier coverage, or AI-maintainability drift. Not for debugging application code or reviewing PRs."
when_to_use: "检查claude, 检查codex, 检查pi, Codex 配置, Pi 配置, AGENTS.md, config.toml, agent instructions, 健康度, 配置检查, 配置对不对, AI coding 腐化, 代码变烂, 维护性, 上下文混乱, 验证缺失, 验证命令失真, Claude ignoring instructions, Pi coding agent, check config, settings not working, audit config"
dispatch_intent: "Codex/Claude/Pi ignoring instructions, agent config audit, hooks/MCP broken, health token usage, AI coding code rot, hotspot ownership, unclear context, missing verification, stale verifier output"
---

# Health: Agent-Assisted Engineering Health

Prefix your first line with 🥷 inline, not as its own paragraph.

按这个 framework 审计当前项目的 agent setup 和 AI coding maintainability：
`agent config → instruction surfaces → tools/runtime → verifiers → maintainability`

找出 violations。识别 misaligned layer。只按 project complexity 校准。

## Outcome Contract

- Outcome:一份 budget-aware health report，区分 agent configuration risk 与 AI maintainability risk。
- Done when: 每个 finding 都命名 misaligned layer、concrete evidence，以及可 copy-paste 的 action 或 diagnostic command。
- Evidence: collected health script output、tracked project instructions、runtime config summaries、verifier logs、hooks/MCP surfaces，以及需要时的只读 live probes。
- Output: 带 status、impact 和 next action 的 prioritized findings，或带 residual risk 的 clear clean bill。

两条 lanes 共用一份 report：

- **Agent config health**：Codex/Claude/Pi instruction drift、permissions、hooks、MCP、skills 和 memory supply chain。
- **AI maintainability health**：project context surface、verifier wrapper、generated-artifact checks、hotspot ownership，以及 stale 或 misleading durable docs。

**Output language:** 按顺序检查：(1) project agent instructions（`AGENTS.md` before runtime-specific files）；(2) global agent instructions；(3) user recent language；(4) English。

**Budget posture:** Start with the summary audit. Escalate automatically when the user asks for a deep, full, complete, thorough, "深入", "完整", "彻底", or "继续跑完" audit, when the user explicitly mentions AI coding code rot, Codex/Claude config drift, unclear context, missing verification, verifier output that points at stale paths, or "代码变烂", when current project instructions or remembered user preference says to run deep health checks by default, when the project is Complex, or when the summary pass exposes a critical ambiguity that cannot be resolved locally. Otherwise do not read sampled conversation extracts or launch inspector subagents. Tell the user before escalating because deep health audits can consume significant token quota.

**Conversation scope:** Summary mode 会在存在本地历史时，从有界 candidate window 中扫描 Claude 和 Codex 最近最多三个当前项目的 previous sessions。Deep mode 会流式扫描当前项目的全部 previous sessions，只输出有界 extracts 和 coverage receipt。默认不扫描其他项目；只有用户明确要求 all conversations 或 cross-project capability distillation 时，才对该 runtime 发现的受支持本地 history roots 使用 bundled conversation audit 的 `--all-projects`，或交给已安装的 full-history retrospective workflow，例如 `ai-retro`。显式 global mode 会排除最近五分钟内修改的 files（视为可能仍在使用），并 redact 输出。只有 `coverage_status: complete` 且 `cross_project_full_history: yes` 时才声称 complete coverage；`no_data`、root unavailable、parse/read error、扫描期间发生变化的 files，以及被排除的 live sessions 都必须作为 coverage gap 明确报告。

## Durable Context Preflight

See [references/durable-context.md](references/durable-context.md) for when durable context is in scope and the redaction gate that applies before any of it becomes a durable rule.

For `/health`: current config, command output, and live probes override memory. Also flag durable memory problems when they affect behavior: oversized injected summaries, stale or contradictory entries, missing project entrypoint references, or private paths copied into public instructions. Keep these as context findings, not code-review findings.

## Hard Rules

- Summary 和 deep audit 只生成报告。只运行 Health 自带 collector 和只读 probe；中性的 Health 请求不授权运行项目 test、verifier、generator、build、formatter、package installer，也不授权刷新 fixture 或 snapshot。Canonical contract: Summary and deep audits are report-only; a neutral Health request does not authorize project commands.
- 项目 instructions 可以定义命令，但不构成运行授权。Live verification 必须得到用户对该命令的明确授权；执行前说明 command、预期写入、target paths、isolation，以及 rollback 或 disposable-environment plan。Canonical contract: Project instructions may define commands but do not authorize running them. Live verification requires explicit user authorization for that command, after stating the command, expected writes, target paths, isolation, and rollback plan.

## Step 0: Assess project tier

选一个 tier。只应用该 tier 的 requirements。

| Tier | Signal | What's expected |
|---|---|---|
| **Simple** | <500 files, 1 contributor, no CI | CLAUDE.md only; 0-1 skills; hooks optional |
| **Standard** | 500-5K files, small team or CI | CLAUDE.md + 1-2 rules; 2-4 skills; basic hooks |
| **Complex** | >5K files, multi-contributor, active CI | Full six-layer setup required |

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

- `jq` missing → conversation sections unavailable
- trusted `python3` missing → conversation、MCP/hooks/allowedTools 和 skill-security sections unavailable
- `settings.local.json` absent → hooks/MCP may be unavailable (normal for global-only setups)

把 `(unavailable)` 视为 insufficient data，不是 finding。不要 flag 这些 areas。

collector 同时包含 runtime-specific 和 agent-agnostic surfaces：

- `AGENT CONFIG SUMMARY` / `AGENT CONFIG DETAIL` for Codex, Claude, Pi, and project instruction files.
- `AI MAINTAINABILITY SUMMARY` / `AI MAINTAINABILITY DETAIL` for project shape, verification surface, hotspot ownership, wrappers, and doc links.

## Step 1b: MCP Live Check

测试每个 MCP server：每个 server 调用一个 harmless tool。记录 `live=yes/no` 和 error detail。尊重 `enabled: false`（skip，不 flag）。对 API keys，只检查 env var 是否 set（`echo $VAR | head -c 5`），绝不 print full keys。

## Step 1c: Safety and security checks

These run after collection and before the Step 2 analysis. The first two apply to every audit; the third only to projects with long-running or autonomous agents.

### Security Baseline Checks

每次 audit 都运行这些 checks，不管 tier。它们是 floor，不是 ceiling。

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

确认 tier。然后 route：

- **Simple:** Analyze locally. No subagents.
- **Standard:** Analyze locally from the summary output. Do not launch subagents by default. If the user asks for a deep/full/thorough audit, or if local analysis cannot classify a security/control issue, escalate to deep mode and explain the likely token cost.
- **Complex, remembered deep preference, explicit deep audit, or explicit AI maintainability audit:** Windows 用 `& "$POWERSHELL" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "$HEALTH_LAUNCHER" collect auto deep`，Linux 和 macOS 用 `BASH_ENV= ENV= /bin/bash -p "$HEALTH_SCRIPT" auto deep` 重新 collection，然后并行启动相关 subagent。Credential 统一 redact 为 `[REDACTED]`。
  - **Agent 1** (Context + Security): Read `agents/inspector-context.md`. Feed `CONVERSATION SIGNALS` section.
  - **Agent 2** (Control + Behavior): Read `agents/inspector-control.md`. Feed detected tier.
  - **Agent 3** (AI Maintainability): Read `agents/inspector-maintainability.md`. Feed only `TIER METRICS`, `AI MAINTAINABILITY SUMMARY` or `AI MAINTAINABILITY DETAIL`, and the script hotspot lists. Launch this agent only for deep health audits, Complex projects, or explicit code-rot/AI-maintainability requests.
- **Fallback:** If a subagent fails, analyze that layer locally and note "(analyzed locally)".

在报告 deep audit 完成前，等待每一个已启动的 inspector，并对齐其 assigned scope。如果某个 inspector 仍 pending，或失败且没有本地替代 pass，就把该 scope 列为 unreviewed，不得给出 whole-scope clean bill。

## Step 3: Report

**Health Report: {project} ({tier} tier, {file_count} files)**

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

Rules violated、dangerous allowedTools、MCP overhead >12.5%、security findings、leaked credentials。

Example:

- [!] `settings.local.json` committed to git (exposes MCP tokens)
Why: leaked token 会通过 installed MCP servers 启用 remote code execution
Action: `git rm --cached .claude/settings.local.json && echo '.claude/settings.local.json' >> .gitignore`

### [~] Structural -- fix soon

Agent instructions 位于 wrong layer、missing hooks、oversized descriptions、verifier gaps。

**Codex/Claude/Pi instruction drift.** Use `AGENT CONFIG SUMMARY` first. Report a Structural finding when `AGENTS.md` and runtime-specific files both contain substantial guidance without delegation, when Codex `config.toml` lacks trust for the current project, when Pi settings or package metadata point at missing skill roots, when project agent instructions are missing, or when runtime-specific instructions contradict the shared project source of truth. Also report when important rules live only in ignored or private local instruction overlays but the tracked/public docs lack them; those overlays are private context, not durable project source of truth. Do not print raw config values. Secrets, tokens, keys, and passwords must appear only as `[REDACTED]`.

从 project root 运行 quick check。Windows：

```powershell
& "$POWERSHELL" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "$HEALTH_LAUNCHER" agent-context . summary
```

Linux 和 macOS：

```bash
BASH_ENV= ENV= /bin/bash -p "${HEALTH_SCRIPT%/*}/check-agent-context.sh" . summary
```

**AI-maintainability findings.** 对 verification surface、conversation-derived guidance、集中的 fix chain、hotspot ownership、verifier wrapper、broken doc/Markdown reference 和 stale verifier cache output，加载 `references/maintainability-findings.md`，并结合 `AI MAINTAINABILITY SUMMARY` / `DETAIL` 执行。

### [-] Incremental -- nice to have

Outdated items、global vs local placement、context hygiene、stale allowedTools entries。

---

如果没有 issues：`All relevant checks passed. Nothing to fix.`

## Non-goals

- 没有 confirmation，绝不 auto-apply fixes。
- 绝不把 complex-tier checks 应用到 simple projects。
- 绝不充当 heavy lint、typecheck、duplication 或 architecture-rewrite substitute；`/health` 只报告 maintainability guardrails 和 concrete next actions。

## Gotchas

| What happened | Rule |
|---|---|
| Missed the local override | 也要读取 `settings.local.json`；它会 shadow committed file |
| Subagent timeout reported as MCP failure | MCP failures 来自 live probe，不来自 data collection |
| Reported issues in wrong language | 优先遵守 CLAUDE.md Communication rule |
| Flagged intentionally noisy hook as broken | 把 hook 称为 "broken" 前先询问 |
| Hook seemed not to fire, but it did -- a later UI element rendered above it | Hook firing order 不是 visual order。重新编辑 hook config 前：(a) 用 `--debug` 或 piping output 确认，(b) 检查 diff dialog、permission prompt 或其他 UI element 是否渲染在上层并把 hook output 推出屏幕，(c) 然后才怀疑 hook 本身。 |
| `/health` burned too much quota on first run | 先 stay in summary mode。Full conversation extracts 和 inspector subagents 是 deep-audit tools，不是 Standard projects 的 default path。 |
| Treated missing specs/docs as a failure | Decision artifacts 默认 optional。只有 tier、active handoff risk 或 user request 让它们必要时，才升级 missing docs/specs。 |
| Treated an ignored AGENTS/CLAUDE file as durable project truth | 报告 rule 是否 tracked 和 distributed。Local overlays 可以 inform audit，但 durable fixes 应放在 public repo docs 或 shipped skill/rule files。 |
| Treated a review scorecard as maintainability documentation | Scorecards 是 snapshots。提取 invariant 和 verification path，然后 remove 或 archive report，不要把 score 本身称为 durable rule。 |
