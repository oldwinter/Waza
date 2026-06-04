---
name: health
description: "针对 instruction/config drift、hooks/MCP、verifier surfaces 和 AI maintainability 运行 budget-aware agent-assisted engineering health audit。Use when users ask 检查claude/检查codex/检查pi/配置检查/健康度，或报告 agents 忽略 instructions、missing validation、code 变得难维护时使用。Not for debugging code or reviewing PRs."
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
- Evidence: collected health script output、tracked project instructions、runtime config summaries、verifier logs、hooks/MCP surfaces，以及需要时的 live probes。
- Output: 带 status、impact 和 next action 的 prioritized findings，或带 residual risk 的 clear clean bill。

两条 lanes 共用一份 report：

- **Agent config health**：Codex/Claude/Pi instruction drift、permissions、hooks、MCP、skills 和 memory supply chain。
- **AI maintainability health**：project context surface、verifier wrapper、generated-artifact checks、hotspot ownership，以及 stale 或 misleading durable docs。

**Output language:** 按顺序检查：(1) project agent instructions（`AGENTS.md` before runtime-specific files）；(2) global agent instructions；(3) user recent language；(4) English。

**Budget posture:** Start with the summary audit. Escalate automatically when the user asks for a deep, full, complete, thorough, "深入", "完整", "彻底", or "继续跑完" audit, when the user explicitly mentions AI coding code rot, Codex/Claude config drift, unclear context, missing verification, verifier output that points at stale paths, or "代码变烂", when current project instructions or remembered user preference says to run deep health checks by default, when the project is Complex, or when the summary pass exposes a critical ambiguity that cannot be resolved locally. Otherwise do not read full conversation extracts or launch inspector subagents. Tell the user before escalating because deep health audits can consume significant token quota.

## Durable Context Preflight

See [rules/durable-context.md](../../rules/durable-context.md) for when to read durable context, the read-order budget, and the memory-type mapping.

For `/health`, audit expectations are `decision`, `preference`, and `principle` entries; checks for repeated failures are `pattern` and `learning`. Current CLAUDE.md, installed skills, hooks, MCP config, command output, and live probes override memory. Also flag durable memory problems when they affect behavior: oversized injected summaries, stale or contradictory entries, missing project entrypoint references, or private paths copied into public instructions. Keep these as context findings, not code-review findings.

## Step 0: Assess project tier

选一个 tier。只应用该 tier 的 requirements。


| Tier         | Signal                                  | What's expected                                |
| ------------ | --------------------------------------- | ---------------------------------------------- |
| **Simple**   | <500 files, 1 contributor, no CI        | CLAUDE.md only; 0-1 skills; hooks optional     |
| **Standard** | 500-5K files, small team or CI          | CLAUDE.md + 1-2 rules; 2-4 skills; basic hooks |
| **Complex**  | >5K files, multi-contributor, active CI | Full six-layer setup required                  |


## Step 1: Collect data

先以 summary mode 运行 collection script。暂时不要 interpret。

```bash
# Resolve collect-data.sh from canonical locations (no personal home-dir paths).
HEALTH_SCRIPT="${CLAUDE_SKILL_DIR:+$CLAUDE_SKILL_DIR/scripts/collect-data.sh}"
if [ ! -f "${HEALTH_SCRIPT:-}" ]; then
  for candidate in \
    "./skills/health/scripts/collect-data.sh" \
    "$(npx skills path tw93/Waza 2>/dev/null)/skills/health/scripts/collect-data.sh"; do
    [ -f "$candidate" ] && HEALTH_SCRIPT="$candidate" && break
  done
fi
if [ ! -f "${HEALTH_SCRIPT:-}" ]; then
  echo "health collect-data.sh not found; set CLAUDE_SKILL_DIR or reinstall: npx skills add tw93/Waza -a claude-code -g -y"
  exit 1
fi
bash "$HEALTH_SCRIPT"
```

tools missing 时，sections 可能显示 `(unavailable)`：

- `jq` missing → conversation sections unavailable
- `python3` missing → MCP/hooks/allowedTools sections unavailable
- `settings.local.json` absent → hooks/MCP may be unavailable (normal for global-only setups)

把 `(unavailable)` 视为 insufficient data，不是 finding。不要 flag 这些 areas。

collector 同时包含 runtime-specific 和 agent-agnostic surfaces：

- `AGENT CONFIG SUMMARY` / `AGENT CONFIG DETAIL` for Codex, Claude, Pi, and project instruction files.
- `AI MAINTAINABILITY SUMMARY` / `AI MAINTAINABILITY DETAIL` for project shape, verification surface, hotspot ownership, wrappers, and doc links.

## Step 1b: MCP Live Check

测试每个 MCP server：每个 server 调用一个 harmless tool。记录 `live=yes/no` 和 error detail。尊重 `enabled: false`（skip，不 flag）。对 API keys，只检查 env var 是否 set（`echo $VAR | head -c 5`），绝不 print full keys。

## Security Baseline Checks

每次 audit 都运行这些 checks，不管 tier。它们是 floor，不是 ceiling。

**Deny-list floor.** Apply this only when the project or runtime exposes agent permission settings, hook settings, MCP settings, allowed/denied tools, or a documented autonomous-agent launcher. In that case, the settings should deny, at minimum: credential and key directories (SSH, cloud providers, GPG, gh CLI), secret files (`.env`, `credentials*`, `secrets*`), pipe-to-shell installers (`curl ... | bash`, `wget ... | sh`), and outbound shells (`ssh`, `scp`, `nc`). Report this as one concise WARN with the missing categories and suggested fix; let the reviewer fill in exact local paths from the environment. If no agent settings surface exists, report the deny-list as not applicable rather than a failure.

**Environment override surface.** Treat the following as attack surface, report when set in tracked files or shipped settings without a justification comment: API base-URL overrides (redirect all traffic to a third party), auto-trust flags for project-local MCP servers, wildcard tool allowlists (`allowedTools: ["*"]`), and permission-skip flags (`--dangerously-skip-permissions` or equivalents). Print file:line and the key name only; never print secrets.

## Memory and Skill Supply Chain

把 agent memory 和 third-party skills 视为 supply-chain artifacts。它们以用户 privileges 运行。

**Memory hygiene.** Audit the project's long-term agent memory store for secrets, tokens, or credentials (Critical), and for entries written by untrusted runs (subagent invoked on attacker-controlled input, /loop iteration over external content); recommend rotation after such runs. For high-risk one-off runs (untrusted PDFs, uncontrolled scraping, third-party scripts), recommend disabling memory persistence for that session entirely.

**Skill supply chain.** Third-party skills, plugins, and MCP servers run with the user's privileges. For each one not authored in this repo, check: source pinned to a release tag (not `main` or a branch), hook handlers do not write to credential directories, MCP servers have explicit user consent (not auto-trusted by wildcard). Report unpinned sources or unreviewed hook handlers as Structural, not Critical, unless an active exploit signal is present.

## Long-Running Agent Stop Conditions

对使用 `/loop`、autonomous agents 或任何 long-running agent flow 的项目，必须定义 explicit stop conditions。永不停止的 agent 是尚未发生的 budget 和 safety incident。

审计这四个 hard stop signals；缺少任一项都作为 Structural finding flag：

1. **No progress across two consecutive checkpoints.** Same files touched, same errors logged, no new commits/tests/output. Recommend killing the loop and surfacing the state, not retrying.
2. **Repeated identical failure.** Same stack trace, same error message, same failed assertion three times in a row means the hypothesis is wrong; more attempts will not help.
3. **Cost or token budget exceeded.** Project should declare a per-run budget (tokens, API spend, wall-clock minutes). Loop exits when the budget is hit, not when work is done.
4. **External blockers.** Merge conflict on the target branch, dependency lock the agent cannot resolve, missing credential, network unreachable. Any of these halt the loop and ask the user, not retry forever.

The stop conditions should live in tracked project docs (`AGENTS.md`, the loop's launch script, or a dedicated config), not only in the agent's prompt. Prompts are forgettable; tracked config is enforceable. Recommend hooks (PostToolUse on the relevant tools) over prompt instructions when the project supports them: a hook physically cannot be skipped, a prompt instruction can.

## Step 2: Analyze

确认 tier。然后 route：

- **Simple:** Analyze locally. No subagents.
- **Standard:** Analyze locally from the summary output. Do not launch subagents by default. If the user asks for a deep/full/thorough audit, or if local analysis cannot classify a security/control issue, escalate to deep mode and explain the likely token cost.
- **Complex, remembered deep preference, explicit deep audit, or explicit AI maintainability audit:** Re-run collection with `bash "$HEALTH_SCRIPT" auto deep`, then launch the relevant subagents in parallel. Redact credentials to `[REDACTED]`.
  - **Agent 1** (Context + Security): Read `agents/inspector-context.md`. Feed `CONVERSATION SIGNALS` section.
  - **Agent 2** (Control + Behavior): Read `agents/inspector-control.md`. Feed detected tier.
  - **Agent 3** (AI Maintainability): Read `agents/inspector-maintainability.md`. Feed only `TIER METRICS`, `AI MAINTAINABILITY SUMMARY` or `AI MAINTAINABILITY DETAIL`, and the script hotspot lists. Launch this agent only for deep health audits, Complex projects, or explicit code-rot/AI-maintainability requests.
- **Fallback:** If a subagent fails, analyze that layer locally and note "(analyzed locally)".

## Step 3: Report

**Health Report: {project} ({tier} tier, {file_count} files)**

### [PASS] Passing checks (table, max 5 rows)

### Finding format

```
- [severity] <symptom> ({file}:{line} if known)
  Why: <one-line reason>
  Action: <exact command or edit to fix>
```

`Action:` 必须 copy-pasteable。绝不要写 "investigate X" 或 "consider Y"。如果 fix unknown，命名 diagnostic command。

### [!] Critical -- fix now

Rules violated、dangerous allowedTools、MCP overhead >12.5%、security findings、leaked credentials。

Example:

- [!] `settings.local.json` committed to git (exposes MCP tokens)
Why: leaked token 会通过 installed MCP servers 启用 remote code execution
Action: `git rm --cached .claude/settings.local.json && echo '.claude/settings.local.json' >> .gitignore`

### [~] Structural -- fix soon

Agent instructions 位于 wrong layer、missing hooks、oversized descriptions、verifier gaps。

**Codex/Claude/Pi instruction drift.** Use `AGENT CONFIG SUMMARY` first. Report a Structural finding when `AGENTS.md` and runtime-specific files both contain substantial guidance without delegation, when Codex `config.toml` lacks trust for the current project, when Pi settings or package metadata point at missing skill roots, when project agent instructions are missing, or when runtime-specific instructions contradict the shared project source of truth. Also report when important rules live only in ignored or private local instruction overlays but the tracked/public docs lack them; those overlays are private context, not durable project source of truth. Do not print raw config values. Secrets, tokens, keys, and passwords must appear only as `[REDACTED]`.

从 project root 运行 quick check：

```bash
bash skills/health/scripts/check-agent-context.sh . summary
```

**AI-maintainability gaps.** Use `AI MAINTAINABILITY SUMMARY` in summary mode and `AI MAINTAINABILITY DETAIL` in deep mode. Report `FAIL` when the project has no executable verification command, no agent instruction surface for a non-trivial repo, or broken doc references. Report `WARN` when instructions exist but lack a project map, verification guidance, boundary/non-goal language, when TODO/HACK markers are concentrated, when large source hotspots lack ownership/boundary and verification guidance, or when durable docs contain raw one-off review reports, scorecards, dated line references, or diagnostic dumps instead of stable invariants. Treat missing `docs/`, `specs/`, `.specify/`, `HANDOFF.md`, `CHANGELOG`, issue templates, and PR templates as informational unless project complexity makes them necessary for handoff. The action for stale reports is to extract stable rules into public instructions, rules, references, or verifier scripts, then remove or archive the transient report.

**Conversation-derived guidance.** When a health audit reads recent agent conversations, do not recommend copying the conversation or a scorecard into docs. Recommend a candidate-matrix pass instead:

| Field | Question |
|---|---|
| Repeated failure | Did this recur across fixes, releases, agents, or user reports? |
| Durable invariant | Can the lesson be stated as a stable rule, not a dated incident summary? |
| Target layer | Should it live in project instructions, a Waza skill, a global rule, or private memory? |
| Verifier | Is there a deterministic command, script, artifact check, or runtime smoke that can enforce it? |
| Redaction risk | Does the lesson require local paths, issue numbers, customer details, machine state, secrets, or unpublished release facts? |

Layering rule: project-specific commands, app names, artifact names, and release rituals stay in the project; reusable workflows such as cancelled-release review gates or native-freeze evidence ladders belong in Waza skills; universal honesty and verification rules belong in global CLAUDE/AGENTS; private user preferences and one-machine facts stay in memory. If the lesson cannot pass the redaction-risk field, keep it out of public guidance.

**Concentrated fix chains.** Run `git log --oneline --since='2 weeks ago' | grep -i fix` and group by area (the prefix before `:` or `(`). When the same area has 3+ fix commits in a short window, it signals a missing structural invariant: each fix is a guess at a rule that was never written down. Report a Structural `WARN` with the area name, fix count, and recommend adding an explicit rule to `AGENTS.md` / `CLAUDE.md` / project rules that captures the invariant those fixes were converging toward. A concentrated fix chain that touches the same file 4+ times is a stronger signal than scattered fixes across different files.

**Hotspot ownership gaps.** In deep mode, read `HOTSPOT OWNERSHIP SURFACE`. If a largest source file exceeds the hotspot threshold and `AGENTS.md` / `CLAUDE.md` / shared instruction files do not name who owns the hotspot, what boundary should stay stable, and which verification command covers it, report a Structural `WARN`. Do not treat documented large files as code rot by size alone; some modules are intentionally large.

**Missing stable verifier wrapper.** If the repo exposes multiple verification commands through CI, scripts, or manifests but `Makefile` has no `check`, `test`, or `verify` target, report a Structural `WARN`. This is an AI-maintainability gap because agents need one stable default entrypoint, not because the project is broken.

从 project root 运行 quick check：

```bash
bash skills/health/scripts/check-maintainability.sh . summary
```

For deep audits:

```bash
bash skills/health/scripts/check-maintainability.sh . deep
```

保持 actions concrete 且 non-invasive：添加或修复 smallest useful instruction surface，添加一个 executable validation command，记录 hotspot ownership 和 tests，只在 boundary 已清晰时 split，或 repair broken reference。不要仅凭 script output 提出 broad rewrites。

**Broken doc references.** Scan `AGENTS.md`, `CLAUDE.md`, `.claude/rules/*.md`, and every `.claude/skills/*/SKILL.md` for references shaped like `@<path>`, `~/.claude/rules/<name>.md`, `~/.claude/skills/<name>/`, `docs/<name>.md`, or `references/<name>.md`. For each match, check that the target exists on disk. Report every "referenced but missing" pointer with the source file and line.

Common offenders:
- A project-level rule references a global rule file that was never created (e.g. `~/.claude/rules/swift.md`).
- A `CLAUDE.md` uses an `@AGENTS.md` placeholder but the actual `AGENTS.md` is missing or empty.
- A skill body references `references/<name>.md` but only `references/<name>-v2.md` exists.
- rule file 引用了 deleted skill path。

从 project root 运行 quick check：

```bash
bash skills/health/scripts/check-doc-refs.sh .
```

The checker resolves `@...` and `docs/...` from the project root, expands `~`, resolves `references/...` from each `.claude/skills/<name>/SKILL.md` directory, checks every reference on a line, skips fenced code examples, and exits non-zero when any target is missing.

Report missing references as Structural findings, not Critical, unless the missing file is named as a hard dependency (e.g. `release.md` for the project's release skill).

**Broken Markdown references。** 在 deep mode 中，`check-maintainability.sh` 也会扫描 repository Markdown links。当它们指向 missing local files 时，报告为 Structural findings，尤其是 agents 未来工作中可能遵循的 design、security、release 或 handoff docs。

**Stale verifier cache output。** 如果 validation output 指向已删除 temp worktree 或不存在的 `/tmp` / `/private/tmp` 文件，用以下命令解析 captured log：

```bash
bash skills/health/scripts/check-verifier-output.sh . <log-file>
```

只对用户提供的 existing command output，或当前 audit 期间生成的 output 使用此 script。不要为了 feed this checker 而运行 project tests。Known actions 包括 `golangci-lint cache clean`、`go clean -cache -testcache` 和 `npm cache verify`；unknown tools 给 diagnostic rerun action。

### [-] Incremental -- nice to have

Outdated items、global vs local placement、context hygiene、stale allowedTools entries。

---

如果没有 issues：`All relevant checks passed. Nothing to fix.`

## Non-goals

- 没有 confirmation，绝不 auto-apply fixes。
- 绝不把 complex-tier checks 应用到 simple projects。
- 绝不充当 heavy lint、typecheck、duplication 或 architecture-rewrite substitute；`/health` 只报告 maintainability guardrails 和 concrete next actions。

## Gotchas


| What happened                                                               | Rule                                                                                                                                                                                                                                                                                           |
| --------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Missed the local override                                                   | 也要读取 `settings.local.json`；它会 shadow committed file                                                                                                                                                                                                                                      |
| Subagent timeout reported as MCP failure                                    | MCP failures 来自 live probe，不来自 data collection                                                                                                                                                                                                                                            |
| Reported issues in wrong language                                           | 优先遵守 CLAUDE.md Communication rule                                                                                                                                                                                                                                                           |
| Flagged intentionally noisy hook as broken                                  | 把 hook 称为 "broken" 前先询问                                                                                                                                                                                                                                                                   |
| Hook seemed not to fire, but it did -- a later UI element rendered above it | Hook firing order 不是 visual order。重新编辑 hook config 前：(a) 用 `--debug` 或 piping output 确认，(b) 检查 diff dialog、permission prompt 或其他 UI element 是否渲染在上层并把 hook output 推出屏幕，(c) 然后才怀疑 hook 本身。 |
| `/health` burned too much quota on first run                                | 先 stay in summary mode。Full conversation extracts 和 inspector subagents 是 deep-audit tools，不是 Standard projects 的 default path。                                                                                                                                                         |
| Treated missing specs/docs as a failure                                     | Decision artifacts 默认 optional。只有 tier、active handoff risk 或 user request 让它们必要时，才升级 missing docs/specs。                                                                                                                                                                      |
| Treated an ignored AGENTS/CLAUDE file as durable project truth              | 报告 rule 是否 tracked 和 distributed。Local overlays 可以 inform audit，但 durable fixes 应放在 public repo docs 或 shipped skill/rule files。                                                                                                                                                  |
| Treated a review scorecard as maintainability documentation                 | Scorecards 是 snapshots。提取 invariant 和 verification path，然后 remove 或 archive report，不要把 score 本身称为 durable rule。                                                                                                                                                               |
