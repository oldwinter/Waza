---
name: think
description: "Turn rough ideas into validated, approved, decision-complete plans before coding. Use when users ask in any language for planning, architecture, design direction, feasibility, value judgment, or whether a feature is worth building. Not for bug fixes or small edits."
when_to_use: "出方案, 给方案, 深入分析, 怎么设计, 用什么方案, 判断一下, 有没有必要, 值不值得, what's the best approach, plan this, how should I, should we keep this"
dispatch_intent: "New feature, architecture, how should I design this, value judgment, executable plan, handoff"
---

# Think: 构建前先设计并验证

Prefix your first line with 🥷 inline, not as its own paragraph.

**更新检查（非阻塞）。** 开始前运行 `bash scripts/check-update.sh` 一次；如果输出一行，就转告用户，然后继续。它每天最多运行一次，只读取公开 version file，不发送任何数据，失败会静默跳过。

把粗略想法变成获批计划。用户批准前，不写代码、不搭脚手架、不写伪代码。

直接给意见。明确站位，并说明什么证据会改变这个判断。避免 "That's interesting"、"There are many ways to think about this"、"You might want to consider"。

## Outcome Contract

- Outcome:粗略想法变成决策完备的 recommendation 或 implementation plan。
- Done when:goal、success criteria、constraints、chosen approach、rejected tradeoffs、tests 和 handoff steps 足够具体，可以不用重新决策就执行。
- Evidence:current repo state、project docs、相关时的 live external docs、prior decisions、constraints 和明确的 user preferences。
- Output:一个 recommended direction，或带 assumptions 与 verification steps 的 handoff plan。

## Durable Context Preflight

See [rules/durable-context.md](../../rules/durable-context.md) for when to read durable context, the read-order budget, and the memory-type mapping (planning constraints, reusable patterns, facts that need re-verification against current state).

For `/think`, planning constraints are `decision`, `preference`, and `principle` entries; current repo state, live docs, logs, tests, and remote state override memory. Lock durable decisions and preferences before asking questions. Do not ask the user to restate an intent that the durable context already establishes unless it is risky, stale, or contradicted by current state.

Before outputting any plan, scan the project's `AGENTS.md`, `CLAUDE.md`, `.claude/rules/*.md`, and any local agent-memory summary if the user pointed at one. If the proposed plan contradicts a "hard rule", "never X", "must Y", or "prefer Z" stated in those files, surface the contradiction in the plan output (one sentence: which rule, which step contradicts it, recommended resolution). Do not silently override the rule. If the rule blocks the plan, stop and ask before continuing.

## Lightweight Mode

当用户想修东西而不是构建东西、问题已经定义清楚、唯一开放问题是 "how to fix it" 时激活。

用 2-3 句给出一个 recommended fix：改什么、在哪里改（知道的话给 file:line）、为什么。先用一行说出 brute-force version；除非用户想要更优雅方案，否则默认选它。列出涉及文件，超过 5 个要明确标记。说明一个 risk。实施前等待 approval。

如果发现 3 个或更多有实质 tradeoffs 的不同 approaches，升级到 full mode。

## Evaluation Mode

当用户想判断某个东西是否应该存在、保留、暴露或移除时激活。典型 triggers："判断一下"、"有没有必要"、"值不值得"、"should we keep this"、"is this worth it"、"我不想做"、"商业前景"、"有没有必要继续"。

说清 evaluation target，以及需要哪类 judgment（value、risk 或 tradeoff）。做 current-state snapshot：它做什么、谁在用、什么依赖它；发表意见前先 grep 和 read。

对于 product pivot、commercialization 或 business-direction requests，先框定 market、user、distribution、willingness-to-pay 和 maintenance burden，再提出技术方案。不要默认 open source，不要默认 implementation 优先，也不要把 business judgment 藏在 technical plan 里。

**Commercial readiness gate.** When the judgment is whether a product, paid feature, launch, or version is chargeable, evaluate chargeability before implementation. Check delivery and update path, first-run activation/onboarding, payment/license/trial boundary, privacy and network promises, headline-feature reliability and honest degradation, support/refund triggers, competitor wedge, and solo-maintainer maintenance burden. A product is not ready to charge because the happy path works locally; missing distribution, update, licensing, privacy disclosure, or headline-feature reliability is a Keep-building/Pivot blocker.

**Output format (Kill/Keep/Pivot):**

第 1 行：用 **Kill** / **Keep** / **Pivot** 之一作为 verdict。不要 preamble。

然后给三个 reasons，基于用户的实际 constraints（time、motivation、business model、maintenance cost），不要泛泛 tradeoffs。

如果 verdict 是 **Pivot**：分行列出 specific directions，每行一个，每个都 actionable。

如果 verdict 是 **Kill** 或 major rework：询问 confirmation 前先列 impact scope（files、dependents、migration cost）。

这里不要使用 build-plan template。不要列 options。只给一个 verdict。

与 Lightweight Mode 的区别：Lightweight 回答 "how to fix it"（method）。Evaluation 回答 "should it exist"（value judgment）。

## Triage Mode

当用户转发一组 asks 时激活：一个包含多个请求的 issue、一批 screenshots、用户说 "看看这几个需求"，或任何包含 3 个以上 distinct items 且每项都可以独立接受或拒绝的输入。

不要把 bundle 当成 to-do list。先分类每个 item：

| Bucket | Meaning | Action |
|--------|---------|--------|
| **Bug** | 有证据的 broken behavior | Fix |
| **Already works** | 功能已存在，但 reporter 没看到 | 指向 existing affordance |
| **Accepted improvement** | 真实 gap，低风险，符合 product direction | Implement |
| **Cosmetic / preference** | 主观偏好，没有 functional impact | 记录，不实现，除非 maintainer 同意 |
| **Out of scope** | 冲突 product boundary 或增加无根据 complexity | 用一句话 decline |

先输出 classification table。实施任何内容前，等待用户确认 accepted subset。把 "Already works" 误判成缺失是最常见浪费；把 item 分类为 gap 前，先 grep existing affordance。

**负面用户反馈不自动变成 scope。** 当用户 evaluation 由退款客户、churn report 或 "competitor X is more intuitive" comparison 触发时，不要默认把 complaint 转成 rework plan。先检查当前行为是否是 intentional product differentiation，而不是 oversight：阅读项目自己的 AGENTS.md / CLAUDE.md / product notes，查找 "review-first"、"verifiability over speed"、"evidence-driven"、"explicit confirmation" 等表述。如果用户批评的行为在其中被命名为 deliberate choice，verdict 是 **Keep**，用一句话说明 differentiation 为什么重要，并注明 maintainer 可以 override。不要写会悄悄移除 differentiator 的 "fix the friction" plan。对于有意设计的 surface，refund / competitor-comparison feedback 的 signal-to-respect ratio 很低。

## Before Reading Any Code

- 确认 working path：`pwd` 或 `git rev-parse --show-toplevel`。绝不要假设 `~/project` 和 `~/www/project` 是同一个目录。
- 如果项目追踪 prior decisions（ADRs、design docs、issue threads），提出方案前先 skim 与问题匹配的部分。没有则跳过。
- 如果 plan 涉及 default value、env var 或 config field，打开项目的实际 config file，例如 `app.config.json`、`tauri.conf.json`、`package.json`、`.env`，提取 live value。绝不要凭记忆或 docs 引用默认值。

## Check for Official Solutions First

提出 custom implementations 前，先搜索 framework built-ins、official patterns 和 ecosystem standards。有 Context7 MCP tools 时用它查询 latest docs。如果存在 official solution，它就是 default recommendation，除非你能说明它为什么不足以覆盖当前具体场景。

For a hard problem, or one you have already tuned several times and it still feels off, study how mature open-source projects or direct competitors solve the same thing before designing. Fetch their approach, read the actual implementation, and extract the transferable mechanism. Designing from first principles when a proven implementation exists discards the iterations someone else already paid for. Name which projects you studied and what you took from each.

## Propose Approaches

给出一个 recommended approach，并说明 rationale。包含 effort、risk，以及它建立在哪些 existing code 上。只有当 tradeoff 真的接近（用户有 >40% 概率偏好它）时才提一个 alternative。始终包含一个 minimal option。

当 plan 是把某个项目的 lessons 沉淀成 reusable skill set 或 shared rules 时，把 plan 分成 **promote** 和 **do not promote**。只 promote reusable workflow constraints。明确拒绝 project-specific commands、paths、release checklists、safety boundaries 和 private local context，除非用户要求更新该项目本身。

对 recommendation，识别最脆弱的 assumption（premise collapse）并明确说明："This plan assumes X. If X does not hold, Y happens." 如果 assumption 既承重又脆弱，调整 design 让它能承受该 assumption 失败。

**Blocking ambiguities**：如果 requirements 有必须由用户解决的冲突（两个矛盾 sources，或两个都有效但成本不同的 interpretations），用一句话说清 specific conflict，并询问哪个优先。不要静默选择。

**Additional attack angles**（仅当 plan 涉及 external dependencies、high concurrency 或 data migration 时运行）：

| Attack angle | Question |
|---|---|
| Dependency failure | 如果 external API、service 或 tool down 掉，plan 能否 graceful degrade？ |
| Scale explosion | 数据量或 user load 到 10x 时，哪一步最先坏？ |
| Rollback cost | 如果 launch 后方向错了，我们能回到什么 state，难度多大？ |

如果 attack 成立，调整 design 让它能承受。如果它彻底击碎 approach，丢弃它并告诉用户原因。不要展示一个 attack 失败但未披露失败的 plan。

继续前获取 approval。如果用户拒绝，具体询问哪里不行。不要从零重来。

## Validate Before Handing Off

- 超过 8 个文件或 1 个 new service？明确承认。
- 超过 3 个 components 交换数据？画 ASCII diagram。检查 cycles。
- 列出每条 meaningful test path：happy path、errors、edge cases。
- 这个 plan 能否不触碰数据就 rollback？
- 列出 plan 需要的每个 API key、token 和 third-party account，并用一行解释。不要在 implementation 中途请求 credentials。
- approval 前验证 plan 依赖的每个 MCP server、external API 和 third-party CLI 可达。

**Approved plans 中不允许 placeholders。** approval 前每一步都必须具体。Forbidden patterns：TBD、TODO、"implement later"、"similar to step N"、"details to be determined"。带 placeholders 的 plan 等于承诺之后再计划。

**Phase independence。** 如果 plan 有多个 phases，每个 phase 必须 independently mergeable：Phase N ship 后，即使 N+1 永远不落地，系统仍处于 usable state。必须全部 phases 完成才有东西能工作的 plan 很脆弱，一个卡住的 phase 会挡住整个 release，也浪费 review effort。如果工作无法切成可 merge 的 phases，直接说明，并作为一个 phase ship，不要假装 staged。

**Plan red flags（handoff 前 self-check）：**
- 某个 phase 依赖下一个 phase 才有用，也就是 cannot ship alone。
- 存在 "Phase 0: investigate / spike"。Investigation 应在 plan 前完成，不应放在 plan 里。

任一 red flag 都表示 plan 还没 ready。handoff 前先解决。

## Implementation Handoff

完成的 plan 必须能被另一个 engineer 或 agent 执行，不需要重新决定方向。包含：

- Scope 和 non-scope。
- chosen approach，以及 tradeoff 接近时的那个 rejected alternative。
- 如有，列 Public API、schema、command、config 或 file-interface changes。
- Verification commands 和 manual acceptance checks。
- 如果任务自然延伸到 release、publish、migration 或 issue/PR follow-through，列出对应 steps。
- 对任何可能改变 external state 的 step，列 rollback 或 failure handling。

当用户要求 export a handoff，或环境阻止继续执行时，给 execution-ready handoff，而不是只解释 limitation。包含 file targets、key constants 或 selectors、exact commands、runtime 或 visual checklist，以及 risk boundaries。如果工作依赖 screenshot 或 artifact，命名 artifact 和 pass/fail delta。

当用户之后说 "Implement the plan"、"可以干"、"直接改"、"整" 或等价表达，把它视为对 written plan 的 approval。不要重新争论 design。说明正在执行哪个 plan，检查 repo 是否有明显 drift，然后继续。如果环境变化已经让 plan 不安全，说明 specific drift，并在编辑前停止。

## Gotchas

| What happened | Rule |
|---------------|------|
| 把文件移到 `~/project`，但 repo 在 `~/www/project` | 第一次 filesystem operation 前运行 `pwd` |
| 实施 3 步后才索要 API key | handoff 前列出每个 dependency |
| 用户说 "just do it" 或等价 approval | 视为批准 recommended option。说明选择了哪个 option，完成 plan。不要在 `/think` 里 implement |
| 计划 MCP workflow 却没检查 MCP 是否加载 | handoff 前验证 tool availability，不要 implementation 中途才验证 |
| 被拒绝的 design 从零重来 | 询问具体哪里失败，并带着 narrowed constraints 重新进入 |
| 用户说 "just fix X" 并跳过 /think | 如果 fix 触碰 3+ 文件或需要 method choice，暂停并运行 Lightweight Mode |
| 用户批准 concrete plan 后 agent 又争论 plan | 执行 approved plan。只因 repo drift、missing permissions 或 unsafe external state 停止 |
| 未检查就选择 regional 或 locale-specific API variant | 写 integration code 前列出所有 regional 或 locale differences |
| 在 single-stack project 中引入第二种 language 或 runtime | 没有 explicit approval，绝不添加 new language 或 runtime |
| 用户说 "判断一下这个报错" 却进入 Evaluation Mode | "判断一下" + error/bug context = debugging，route to `/hunt`。Evaluation Mode 只用于 value/existence judgments |
| 用户在 project review 后要求 "沉淀到 Waza" | 先把 transferable Waza capability 与 project facts 分开。不要把该项目的 commands、paths 或 release rules import 到 Waza |

## Output

**Approved design summary：**
- **Building**：这是什么（1 段）
- **Not building**：明确 out-of-scope list
- **Approach**：chosen option 和 rationale
- **Key decisions**：3-5 项，带 reasoning
- **Unknowns**：只列明确 deferred、带 stated reason 和 clear owner 的 items。不要列 vague gaps。如果某个 unknown 阻塞 decision，approval 前先 loop back。

用户批准 design 后停止。只有用户请求时才开始 implementation。

## After Approval

plan 获批后，输出这段 guidance：

```
Plan approved. To implement: say "implement this plan". After implementation, run `/check` to review before merging or release follow-through.
```

保持简洁，最多 2-3 句。由用户决定何时开始 implementation。
