---
name: check
description: "Review code diffs, PRs, issue queues, release readiness, commits, pushes, publishing, and project audits. Use when users ask in any language for code review, issue/PR triage, release gates, publishing follow-through, or project audits. Not for root-cause debugging or prose review."
when_to_use: "review, 看看代码, 检查一下, 有没有问题, 是否需要优化, 合并前, 继续优化, 优化代码, 看看issue, 看看PR, release, publish, push, release reaction, GitHub reaction, 发布, 提交, 关闭issue, 发布表情, release表情, close issue, issue close, review my code, check changes, before merge, before release, 值得发布, ready to release, code review, code-review, audit, project audit, 项目体检, 项目评分, 给项目打分, 深入分析项目代码, 评估项目质量, 代码质量评分, scorecard, linus review, rate this codebase, score this project"
dispatch_intent: "Code review, before merge, release gates, generated artifacts, safety sinks, publish/push/reaction follow-through, triage issues/PRs, project-wide code-quality audit scorecard"
---

# Check: Ship 前先 Review

Prefix your first line with 🥷 inline, not as its own paragraph.

> Note：`/review` 是 Anthropic 内置的 PR review plugin command。Waza 改用 `/check`（或 alias `code-review`）。不要在此 skill 内重新触发 `/review`。

读取 diff，找出问题。Review、audit、triage 和 readiness 请求默认只生成报告；只有当前 turn 明确要求 fix、change、implement 或 optimize 时才应用修复。Done 表示请求的 review surface 已覆盖，且每个 verification claim 都来自本 session。

## Outcome Contract

- Outcome:基于 current diff、project context 和 live evidence 的 review、release decision 或 maintainer action。
- Done when:findings、fixes、shipped state 或 blockers 都带有能证明它们的 commands、artifacts 或 remote state。
- Evidence:worktree status、diff、public project docs、manifests、CI、package contents、release 或 registry state，以及 current command output。
- Output:先给 concise findings；适用时再给 verification 和 shipped-state summary。Multi-step 或 ship-action run 以 completion ledger（done / not applicable / remaining）收尾，不得留下还要用户追问“是否都完成了”的叙述。
- Authorization：只读意图可以检查 worktree 和 remote state，但不得编辑文件、apply autofix、commit、push、publish、comment、close、merge 或切换 branch。每个 write 或 public action 都需要当前 turn 的授权，除非用户明确授权的 named batch 已包含该动作。

## Worktree Safety Preflight

任何 review、triage、ship、release 或 PR operation 前，用以下命令读取 current worktree：

```bash
git status --short --branch -uall
```

把 modified、staged 和 untracked files 当成用户工作。可以读取它们并纳入 review surface，但没有当前 turn 的 explicit user approval，不得 move、hide、overwrite、clean 或 discard。

不要把这些命令作为 default review 或 PR setup 运行：`git switch`、`git checkout`、`git reset --hard`、`git clean`、`git stash -u`、`git stash --include-untracked`、`git stash -a`、`git stash --all` 或 `gh pr checkout`。如果确实需要 branch change 或 cleanup，停止并请求该 exact operation。

不要通过把 untracked files、generated files、screenshots 或 local scratch files 移到 `/tmp` 或其他 holding directory 来“保护”用户工作。把别人的 WIP 移出 checkout 与 stash 它属于同类干扰。如果 generation、packaging 或 verification 需要 clean tree，从 known commit 创建 separate worktree，并只把你拥有的 artifact 或 patch 拷回 current checkout。

在 dirty 或 multi-agent checkout 中做 commit 或 push follow-through 时，staging 前记录 `git rev-parse HEAD`。commit 前立即重读 `git status --short --branch -uall` 和 `git rev-parse HEAD`，push 前再读一次。如果 HEAD moved、出现 unknown commits，或 worktree 在 intended files 外发生变化，停止并报告 mismatch，不要 rebase、recommit 或 push。

PR inspection 优先使用不会切换 current working tree 的 commands：`gh pr view`、`gh pr diff`、`git fetch origin pull/<n>/head:refs/tmp/pr-<n>` 和 `git merge-tree`。

## Mode Picker

选择匹配用户 intent 的 mode，只加载对应 reference；default review 和 plan execution 不需要额外 mode reference。下方共享 review surface（Scope、Hard Stops、Autofix、Specialist Review、Verification、Sign-off）始终适用。

| User intent | Mode |
|---|---|
| "implement this plan"、交接的 /think output | [Plan Execution](#plan-execution-mode) |
| diff 或 PR 已就绪、"review"、"看看代码"、"合并前" | Default review，从 [Get the Diff](#get-the-diff) 开始 |
| "look at issues"、"review PRs"、"triage"、"批量处理" | 加载 `references/mode-triage.md` |
| "is this worth a release"、"值不值得发版" | 加载 `references/mode-ship.md` 的 Release Worthiness Analysis |
| "commit"、"push"、"publish"、"release"、"close issue" | 加载 `references/mode-ship.md` 的 Ship / Release Follow-through |
| "audit"、"项目体检"、"项目评分"、"scorecard"、"linus review" | 加载 `references/mode-audit.md` |
| document、PDF、prose review | 交给 /write，见 [Document Review](#document-review) |

进入任何 mode 前，先运行 [Project Context Extraction](#project-context-extraction)；若 memory 在 scope 内，再运行 [Durable Context Preflight](#durable-context-preflight)。

## Project Context Extraction

这是 Waza 的 public、standalone code-review capability。它不应依赖 private machine paths 或 unpublished project instructions。

review 前，从 repository context 中提取 project constraints：

1. Read the diff and identify changed languages, frameworks, manifests, generated outputs, release files, and CI workflows.
2. Inspect public project files only as needed: README, AGENTS/CLAUDE instructions when present, package manifests, lockfiles, build configs, test configs, workflow files, and release notes.
3. Compress the findings into review context: verification commands, protected or generated files, release artifacts, domain risks, and public reply rules.
4. Apply the stricter rule when project context and this skill overlap.
5. If project docs or CI name a verification command, prefer that over auto-detection.

context shape 见 `references/project-context.md`。

For release or maintainer work, also fill the Release Gate 2.0 matrix from `references/project-context.md`. It covers review base, dirty/staged/untracked state, latest tag, origin sync, version fields, generated artifacts, package/archive contents, release assets, registry/appcast/CI, and public issue/PR state. Missing matrix evidence is a blocker for a "ready to release" claim.

## Durable Context Preflight

See [references/durable-context.md](references/durable-context.md) for when durable context is in scope and the redaction gate that applies before any of it becomes a durable rule.

For `/check`: the current diff, CI, and remote state override memory. Durable memory can explain user intent and preferred follow-through, but public project rules still come from README files, manifests, CI workflows, release docs, and explicit instructions in the current thread. Never cite private memory as a public project requirement.

## Plan Execution Mode

Activate when the user's message starts with "Implement the following plan", "按计划实施", "按照计划", "整", "可以干", "直接改" followed by a plan body, or links to a `/think` output.

In this mode, do not run a code review. Instead:

1. State which plan is being executed (first heading or summary line).
2. Check for obvious repo drift: run `git status --short --branch -uall` and skim any changed files that contradict the plan. If drift makes the plan unsafe, name the specific conflict and stop.
3. After all items are done, run the project's verification command.
4. Transition automatically into Ship mode if the project context or current thread indicates review-then-ship.

## Default Continuation (review-then-ship)

When the project's `AGENTS.md` or the current thread explicitly asks to "commit after review", "ship if green", or equivalent, transition directly from review to the Ship flow after a clean review. Do not ask again. State "proceeding to ship" before acting.

## Get the Diff

获取 current branch 与 base branch 之间的 full diff。如果不清楚，询问。如果已经在 base branch 上，询问要 review 哪些 commits。

## Scope

测量 diff 并分类 depth：

| Depth | Criteria | Reviewers |
|-------|----------|-----------|
| **Quick** | 100 行以内，1-5 个文件 | 仅 Base review |
| **Standard** | 100-500 行，或 6-10 个文件 | Base + conditional specialists |
| **Deep** | 500+ 行、10+ 个文件，或触碰 auth/payments/data mutation | Base + all specialists + adversarial pass |

继续前说明 depth。

Static content diffs can stay quick even when they touch several generated files: version strings, dates, release-copy mirrors, sitemap dates, or one-for-one localization copy changes usually need line-by-line readback plus grep consistency, not a specialist fleet. Escalate only when the diff changes logic, generation rules, public distribution behavior, or user-facing semantics beyond the literal text replacement.

## Did We Build What Was Asked?

读代码前检查 scope drift：diff 与 stated goal 是否匹配？标记为 **on target** / **drift** / **incomplete**。

同时检查 surgical traceability：每个 changed file 和每个 new public surface 都必须能追溯到用户 stated goal。如果某个 file、dependency、config knob、abstraction、generated artifact、workflow permission 或 release behavior 无法用一句话从请求解释，先标记为 drift，直到证明必要。

Drift signals（examples，不穷尽，任一项足以标记 drift）：
- changed file 与 stated goal 没有关联
- 当 goal 是 bug fix 或 feature 时，diff 包含 pure refactoring（renames、formatting、restructuring）
- 出现 goal 未提到的新 dependency
- 与 goal 无关的 code 被删除或注释
- 引入 goal 不需要的新 abstraction 或 helper
- maintainability、review 或 cleanup change 悄悄添加 user-visible UI、default config、workflow permissions 或 release behavior

## Pattern-Fix Completeness

When the diff fixes one instance of a class-of-bug (a missing validation, a wrong selector, an off-by-one, a missing lock), the same shape often lives elsewhere. Extract the pattern signature, `grep -rn` it across the repo (exclude generated dirs), and confirm sibling instances were also handled. List any unswept sibling: flag it as a hard stop when it carries the same risk, advisory when lower-risk. For a deeper sweep playbook, see hunt's Scope Blast Mode.

## Testability Seam For Recurring Bugs

When the diff fixes a visual, layout, timing, or stateful-UI bug that has recurred (the same area broke before, or the fix reads as "tune a number until it looks right"), a code change alone will let the regression return: the logic is entangled with mutable render or UI state, so there is nowhere to assert on it. Flag the fix as incomplete unless it pulls the decision into a pure function -- inputs in, value out, no mutable receiver -- and unit-tests the invariant that was violated (a width never collapses to zero, a hit region stays half-open, an offset stays in bounds). "Verified by running the app" confirms this one instance; only a pinned invariant stops the next one. Reserve this for classes that recur or that runtime checks cannot see; do not demand a seam for one-off logic that already has straightforward coverage. If no honest seam exists -- the only place to assert is past a shallow interface that never exercises the real failure at the call site -- do not fake a hollow test to satisfy the gate. Record "no correct test seam" as an architectural finding and surface it: the missing seam is the actual defect.

当 bug 只是一次错误 decision 时，pure function 是正确的 test seam；当 bug 是“未来 call site 会绕过它”时，pure function 就不是。即使把 guard 提升到 shared helper，它仍然只保护经过该 helper 的 caller；下一个 contributor 仍可能添加第十一个 call site，却漏掉 guard。对这类问题，有效的 guard 是直接针对 source tree 的 test：枚举 risky primitive 的 call sites，任何绕过 wrapper 的位置都 fail；或对 explicit allowlist 之外新出现的 raw pattern 直接 fail。它在 normal suite 中运行，不需要 runtime，并把“有人必须记住”变成 failing build。只对忘记后会静默产生高代价的 primitive 使用这种方式（unbounded external command、direct deletion、raw privilege escalation）；allowlist 放在 test 中，让每个 exemption 都成为 reviewed line。

## CLI Command Surface

When a diff touches a CLI entrypoint, installer, completion, config/env handling, package wrapper, or a mutating command such as cleanup, update, uninstall, migration, or cache removal, load `references/release-surfaces.md` (CLI Command Surface) and work its checklist, then fill the CLI Command Surface template from `references/project-context.md` before sign-off. The core stance: verify command contract and installed-runtime behavior, not just library tests, and treat every mutating command as a safety sink.

检查 command contract 和 installed-runtime behavior，不只看 library tests：help/version、subcommands/flags、exit codes、stdout/stderr、JSON/schema output、TTY/non-interactive paths、env/config precedence、shebang/executable bit、PATH shim，以及适用时的 package-manager install path。
Terminal output 是 rendered surface。改了 CLI-facing text、spacing 或 layout 后，重新运行 command 并读取真实输出，再声称完成；改字符串不等于看过屏幕。

For mutating CLI commands, also run the Safety Sink Review: dry-run or confirmation path, operation log or rollback story, retry/idempotency, signal/partial-failure handling, and test-mode guards for auth prompts or real system changes. For cleanup, uninstall, prune, reset, or cache-removal commands, add two checks before approval: can a normal user verify each selected item is safe, and is the deleted content locally rebuildable rather than a downloaded dependency or user data? If either answer is no, require narrower matching, explicit user selection, or leave the item visible but non-destructive.

## Skill, Plugin, And Packaged Install Surface

When a diff touches a skill, plugin, marketplace entry, installer, package allowlist, package manifest, generated mirror, or published archive, load `references/release-surfaces.md` (Packaged Install Surface) and verify the installed runtime contract through its five steps: real user install path, rebuilt package contents, isolated install smoke, noise filtering, and explicit gaps when the smoke cannot run. Manifest JSON, source tests, or a successful local import never substitute for installed-runtime proof.

## Hard Stops (fix before merging)

Examples，不穷尽。任何未 review 合并后可能造成 irreversible harm 的 diff 都要标记。

- **No unverified claims.** Do not write "I verified X", "I ran Y", "tests pass", or "this fixes Z" unless the shell output is in this turn's transcript. If you reason about behavior without running, say "based on reading the code" instead of "I verified". Every verification claim in the sign-off must point to a command that actually ran in this session.
- **Re-read before citing source-of-truth facts.** Before writing a line number, dirty-file count, branch ahead/behind state, fallback behavior, locale coverage, or release artifact state into a handoff or review report, re-read the source in this turn (`git status`, `git diff`, file `Read`, `rg`, command output). Earlier chat context, prior agent notes, and your own recall are stale by default. Cite the verification path inline (`per current Read of <file>` / `per git status this turn`) so reviewers know which facts are anchored.
- **String-matching on captured output**: when a diff branches on or greps an error message or command output, probe what that string actually holds at runtime before approving. A subprocess spawned with `stdio: 'inherit'` (or any uncaptured pipe) leaves diagnostics on the terminal and `error.message` holding only the command line, so the matcher silently matches the command, not the output. Prefer a structured fact the caller already holds (exit code, build target) over re-parsing a string.
- **Magic-wait coupling**: a fixed `sleep`, `asyncAfter`, `setTimeout`, or "should be enough" timeout standing in for an unobserved async completion, or an animation, poll, or progress step tied to a frame count or fixed duration rather than wall-clock state. It passes on the author's machine and breaks on a slow CPU, a 120Hz display, or a proxied network. Flag it: drive the next step off the real completion signal (callback, navigation-done, frame-changed, state flag), and keep timing machine- and frame-rate-independent.
- **Destructive auto-execution**: any task marked "safe" or "auto-run" that modifies user-visible state (history files, config, preferences, installed software) must require explicit confirmation.
- **Source and distribution out of sync**: everything the source change implies downstream must be regenerated, tracked, uploaded, and version-consistent before declaring done: generated or bundled outputs rebuilt and included, every artifact named in release notes or workflows actually uploaded, every new helper module, reference file, or script present in the built archive, and version fields synchronized across manifests, package metadata, changelogs, tags, and lockfiles.
- **Verifier failure layer unclear**: if a verifier fails before assertions or due to missing optional dependencies, bootstrap noise, transient build-service crashes, unavailable simulators, or tool setup, classify setup versus product failure. Retry only with new evidence or a narrower environment. Do not call the repo broken until the intended test body or artifact check actually ran. The inverse is the same stop: a verifier that passes without running the real path -- a skipped optional-dependency job that still prints OK, a function that early-returns leaving output empty so a true-on-empty assertion passes, a render reported fixed but never opened -- is a hollow green. A pass counts only when at least one non-skipped, non-empty case exercised the path and the assertions fail on emptiness.
- **Manifest-only install proof**: if a diff changes a skill, plugin, installer, marketplace entry, package wrapper, or installable archive, metadata and source tests are not enough. Build or install through the real user path in an isolated environment, or mark the install/runtime layer unverified.
- **Unknown identifiers in diff**: any function, variable, or type introduced in the diff that does not exist in the codebase is a hard stop. Grep before writing or approving any reference: `grep -r "name" .` -- no results outside the diff = does not exist.
- **Consolidation pass 缺少 over-deletion audit**：如果 diff 声称要 simplify、consolidate 或 trim prose（rules、skills、docs、guidance），必须把删除内容作为 diff 逐条读回，并分类为 folded-into-X、redundant-with-Y 或 behavior-removed。Behavior-removed 条目必须列给 maintainer，不能吸收到一句“已简化”的 summary 中。删除量不是 pass 质量的证据；驱动这类 diff 的 pruning rule 本身没有对称的制衡，因此 review 必须补上 audit。
- **Dead-code or YAGNI deletion without proof**: any "zero callers" or "unused" claim must be checked across the whole repository, including top-level entrypoints, docs, tests, generated dispatch tables, scripts, CI, package allowlists, package manifests, and dynamic lookup patterns. Treat sub-agent or tool reports as leads, not proof. Before deleting, batch-grep all candidates, classify test-only references separately from production/runtime references, and chase written variables or data tables that may become orphaned together. If a file is only wrongly exposed through a package, archive, or plugin mirror, tighten that distribution surface and its test instead of deleting the dev tool. If the grep scope is partial, do not delete.
- **Injection and validation**: SQL, command, path injection at system entry points. Credentials hardcoded, logged, committed, or copied into public docs.
- **Dependency changes**: unexpected additions or version bumps in package.json, Cargo.toml, go.mod, requirements.txt. Flag any new dependency not obviously required by the diff. The inverse is a finding too: a declared dependency or linked SDK with zero imports across the repo gets flagged to the maintainer, not silently removed (it may be staged for an upcoming feature, and unused analytics/telemetry SDKs still drag app review and privacy manifests). Removal needs the maintainer's go-ahead in the current turn, a grep proving zero references first, and a full build after.
- **Safety sinks**: destructive file operations, shell or AppleScript construction, cwd/path/symlink traversal, approval or sandbox boundary changes, signing/appcast flows, and auth prompts need explicit review of validation, rollback, and user-confirmation behavior.
- **Audit before restore**: when the diff re-adds a symbol, string, asset, or config field that recent history removed, grep the rest of the diff and the main branch to confirm anything still uses it. A rule file that names the symbol is not proof of life. If only a parity test references it, the rule is stale and the restore is wrong; reject the restore and flag the stale rule. Specifically suspicious: re-adding an enum case, xcstrings entry, dictionary key, or asset file that the prior commit deleted intentionally.
- **Intentional-divergence normalized**: a surface that deliberately breaks a house pattern -- omits a shared step, takes a conditional path the siblings avoid, leaves an asymmetry -- to dodge a known defect, then a later cleanup pass "tidies" it back into uniformity and reintroduces the bug. Before unifying an outlier to match its siblings, read the comment or commit that created it and confirm the defect it prevents survives your change.
- **Destructive sink 使用 broad matcher**：任何加入 recursion、mass-delete、traversal、ID-prefix wildcard 或把 fallback regex branch 接入 destructive sink 的 diff，都要逐行 review 三件事：每个 branch 的 matcher breadth（fallback path 常退化为 broad glob）、新 entry point 的 protected-path coverage，以及是否绕过 user confirmation。按 shape 提高门槛，不按作者判断：代价最高的实例往往由熟悉 codebase 的 maintainer 写出，例如把 display name、vendor prefix 或 user-supplied label 拼进 path 形成 deletion target，结果只是共享同一 token 的 neighbour 也被删除。问清授权删除的最窄 evidence 是什么；exact identifier 或 exact path 可以，prefix 或 common word 不可以。PR 若很可能由 AI 生成，再进一步提高门槛，不能批准一句 “this looks fine”。Guard 放在哪里与 breadth 同样重要：call site 上的 check 只保护一个 caller，因此优先把 guard 放进 deletion primitive 本身。
- **同一个 value 有两套 derivation**：同一 classification、ordering、threshold、count 或 eligibility rule 在两处独立计算（summary 与它总结的 list、ordering 与它排序的 control、score 与旁边的 diagnosis text、preview count 与 executor predicate）。写下当天它们一致，任一侧第一次变化后就会 drift。Diff 新增第二套 derivation 时，要求单一 source of truth：把 rule 提升为 shared constant 或 pure function，让两侧共同读取。Diff 修改现有 pair 的一侧时，grep 另一侧并确认同步变化。这个规则要防止的 symptom，是两个描述同一件事的 user-visible number 彼此矛盾。
- **Test assert 的 surface 从未被 production 运行**：test 如果锁定没有任何 call path 触达的 helper，或 assert command/config string 的 literal source shape，就会在 shipped path 已坏时继续 green，还会把 broken form 锁成“正确”而阻碍真正的 fix。这与上面的 hollow green 相关，但失败方向相反：前者 verifier 跳过 real path，这里 test 执行的根本不是 real path。Review 随 fix 新增的 test 时，问它在 unfixed code 上是否会失败，以及它 assert 的 entry point 是否真是用户触达的入口。任一答案为否，该 test 就是 finding，不是 coverage。
- **Migration code for features that did not ship before**: reject migration scaffolding, version-gated defaults, or "carry old key forward" logic when the underlying preference / schema / feature was introduced in this same release. `git show v<last-release>:<path>` is the gate: if the key is absent from the last tag, no migration is needed; ship the default. Migration code added for a never-shipped key is dead-on-arrival complexity.

## Finding Quality Gate

把任何 finding 写入 report 前，先运行这个 gate：

**Pre-report self-check（四个问题，每个 finding 都必须通过）：**
1. 我能否 cite exact file:line？
2. 我能否描述触发 bad outcome 的 specific input 或 state？
3. 我是否读过 upstream callers / downstream consumers，而不是只孤立看 function？
4. severity 是否 defensible？senior reviewer 会在真实 PR 中以这个级别提出它吗？

如果任何答案是 "no"，drop finding 或 downgrade to advisory。Vague findings 会训练读者忽略真正的问题。

**Clean review 是 valid review。** 不要为了证明 invocation 有价值而制造 findings。带 stated review surface 的 zero findings 是 complete output。用 low-confidence noise 填充 report 比什么都不报更糟。

**HIGH 和 CRITICAL 需要三条 evidence：**
1. The exact file:line where the bug lives.
2. The specific trigger: what input, state, or sequence produces the bad outcome.
3. Why existing guards (validation, type system, upstream catch, framework default) do not already prevent it.

三条凑不齐？Downgrade to MEDIUM，或 drop。"This *might* break under some condition" 不是 HIGH。

## Knowledge Sync

review diff 后，检查它是否引入尚未记录到 project docs 的 invariants：

- New safety gate or path-guard rule → AGENTS.md
- New UI constraint (layout rule, animation, overlay registration) → `.claude/rules/*.md`
- New deploy/release step or artifact → AGENTS.md or `docs/`
- New cross-file sync requirement (enum ↔ HTML anchors, Swift keys ↔ xcstrings) → AGENTS.md
- One-off review reports or diagnostic snapshots should not become durable docs as-is; extract the stable rule into AGENTS/CLAUDE/rules/references and drop the stale report from the commit.

### Snapshot Report Routing

把 review reports、scorecards 和 diagnostic snapshots 当成 evidence，不是 source-of-truth docs。批准前：

1. Re-read the current diff or repo surface named by the report. If the claim is stale, exclude the report from the commit or rewrite it into a stable rule.
2. Keep project-specific commands, paths, protected areas, release rituals, and safety constraints in that project's public context. Do not promote them into Waza.
3. Promote only transferable review behavior into Waza: e.g. "check untracked files before readiness", "inspect generated package contents", or "turn one-off reports into invariants."

If found, either apply the doc update as `safe_auto` (when the invariant is clear from the diff) or flag it in the sign-off as `doc debt`. When no new invariants exist, sign-off says `doc debt: none`.

## Specialist Review (Standard and Deep only)

加载 `references/persona-catalog.md` 判断激活哪些 specialists。环境提供 agent 或 sub-agent facility 时，parallel 启动所有 activated specialists，每个都传 full diff 和各自 persona brief。没有 parallel reviewer facility 时，在同一 session 依次执行 specialist passes。

合并 findings：两个 specialists 标记同一 code location 时，保留更高 severity，并注明 cross-reviewer agreement。不同 code locations 上的 findings 即使 theme 相同，也不是 duplicates。

每条 specialist finding 都只是待验证的 claim，不是可直接行动的事实。对 HIGH 和 CRITICAL claims，在 agent facility 允许时，为每条 finding 单独 spawn 一个 independent skeptic，只让它对照实际代码反驳该 claim；skeptic 在 direct read 中驳倒的 finding 必须 drop 或 downgrade，不受提出它的 persona 影响。没有 facility 时由自己执行 skeptic pass：本 turn 重读 cited code，确认它真实且 live，没有在其他地方处理、不是 consistent-by-design，也不是被当成 live bug 的 latent-only risk。Parallel reviewers 容易因 name-based inference 和 partial context 过度报告；任何 direct read 后消失的 finding 都要丢弃，并在送往 Autofix 或 sign-off 前引用 verification path。

在给出 whole-scope verdict 前，为每个 delegated review 对齐 completion ledger：记录 assigned scope、returned status 和 uncovered remainder。等待每个 active reviewer，或明确列出其 scope 为 unreviewed。任何 reviewer 或 required verification 仍 pending 时，不得声称“all read”“full audit complete”或“no issues”。

## Autofix Routing

| Class | Definition | Action |
|-------|------------|--------|
| `safe_auto` | Unambiguous, risk-free: typos, missing imports, style inconsistencies | 只有得到 explicit write authorization 后才应用；否则报告 |
| `gated_auto` | Likely correct but changes behavior: null checks, error handling additions | Batch into one user confirmation block |
| `manual` | Requires judgment: architecture, behavior changes, security tradeoffs | Present in sign-off |
| `advisory` | Informational only | Note in sign-off |

得到 explicit write authorization 后，先应用 `safe_auto` fixes，再展示 `gated_auto` confirmation block。只读模式不得修改 worktree。

## Adversarial Pass (Deep only)

“如果我要通过这个 specific diff 破坏系统，会利用什么？”从四个 angles 执行（见 `references/persona-catalog.md`）：assumption violation、composition failures、cascade construction、abuse cases。环境提供 agent facility 时，将四个 angles 作为彼此看不到其他 findings 的 parallel agents 运行：independent angles 的 convergence 会提高 confidence；singleton findings 接受与 specialist claims 相同的 per-finding skeptic verification。抑制 confidence 低于 0.60 的 findings。

## Platform Operations

使用与项目匹配的 platform tool。GitHub projects 优先使用 `gh` 或可用 GitHub integration，并在 merging 前确认 CI passes。Non-GitHub projects 从 public project docs 或用户明确 platform context 推导 CLI/API；不要把 GitHub commands 强套到其他 hosts。

Poll CI as structured state, not streamed text: `gh run view <id> --json status,conclusion` (or the host's equivalent). Piping `gh run watch`, test output, or build output through `tail`/`head` swallows the real exit code and can report a failed or still-running run as green.

## Verification

从 target project root 运行 `bash <skill-base-dir>/scripts/run-tests.sh`（`<skill-base-dir>` 是此 skill 的安装目录；script 会从当前工作目录自动探测项目 test command），或运行项目已知 verification command。粘贴完整 output。

如果 script 以 non-zero 退出或打印 `(no test command detected)`：halt。不要 claim done。继续前询问用户 verification command。如果用户也无法提供，在 sign-off 中明确记录为 `verification: none -- no command available`，并把它标记为 structural gap，不是 pass。

对 bug fixes：必须存在一个在 old code 上失败的 regression test，fix 才算 done。

In a dirty or multi-agent checkout, a passing local build or test run is not proof your change is sound: unrelated WIP already in the tree can supply missing symbols, mask a break, or fail for reasons unrelated to you. Verify in isolation -- `git worktree add --detach <known-good-commit>`, `git apply` only the diff of the files you own, then build/test there. The clean isolated pass is the real signal; the contaminated local pass is not.

## Gotchas

| What happened | Rule |
|---------------|------|
| Posted a public reply to the wrong issue or PR thread | Re-read the target with `gh issue view N` or `gh pr view N` and confirm title, author, and current state before acting |
| PR comment sounded like a report | 1-2 sentences, natural, like a colleague. Not structured, not AI-sounding. |
| PR comment used bullet points | Write as short paragraphs, one thought per paragraph; thank the contributor first |
| New file name duplicated a locale, platform, or suffix convention | Check the target directory's existing naming convention before creating or renaming files |
| Deployed without provider runtime or env checks | Follow the project's public deployment docs and compare provider config with local required env and runtime settings |
| Push failed from auth mismatch | Check `git remote -v`, current branch, and auth identity before the first push in a new project |

## Document Review

对 document、PDF、white paper 或 prose review，route to `/write`（Document Review Mode）。`/check` 只处理 code diffs 和 release artifacts。

## Sign-off

Open the final message with the `status` line as plain prose before any table or detail: exactly where the work stands now, with the hash, tag, or blocker. A verdict buried under verification tables reads as unfinished and makes the user re-ask "都提交了吗"; the tables support the verdict, they do not replace it.

```
status:           [committed and pushed as <hash> / staged, not committed / released vX.Y.Z / blocked on <what>]
files changed:    N (+X -Y)
scope:            on target / drift: [what]
review depth:     quick / standard / deep
hard stops:       N found, N fixed, N deferred
sibling sweep:    N same-shape sites checked, N fixed / none found / not applicable
specialists:      [security, architecture] or none
new tests:        N
public actions:   replied #N, closed #N, reactions done / none pending
doc debt:         none / AGENTS.md needs X / rules need Y
verification:     [command] -> pass / fail
```

`public actions` lists every outward-facing step the task implied (issue replies, closures, release reactions) with its done or pending state; an external action the user has to ask about was not finished.
