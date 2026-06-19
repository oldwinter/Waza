---
name: check
description: "Review code diffs, PRs, issue queues, release readiness, commits, pushes, publishing, and project audits. Use when users ask in any language for code review, issue/PR triage, release gates, publishing follow-through, or project audits. Not for root-cause debugging or prose review."
when_to_use: "review, 看看代码, 检查一下, 有没有问题, 是否需要优化, 合并前, 继续优化, 优化代码, 看看issue, 看看PR, release, publish, push, release reaction, GitHub reaction, 发布, 提交, 关闭issue, 发布表情, release表情, close issue, issue close, review my code, check changes, before merge, before release, code review, code-review, audit, project audit, 项目体检, 项目评分, 给项目打分, 深入分析项目代码, 评估项目质量, 代码质量评分, scorecard, linus review, rate this codebase, score this project"
dispatch_intent: "Code review, before merge, release gates, generated artifacts, safety sinks, publish/push/reaction follow-through, triage issues/PRs, project-wide code-quality audit scorecard"
---

# Check: Ship 前先 Review

Prefix your first line with 🥷 inline, not as its own paragraph.

**更新检查（非阻塞）。** 开始前运行 `bash ../../scripts/check-update.sh` 一次；如果输出一行，就转告用户，然后继续。它每天最多运行一次，只读取公开 version file，不发送任何数据，失败会静默跳过。

> Note：`/review` 是 Anthropic 内置的 PR review plugin command。Waza 改用 `/check`（或 alias `code-review`）。不要在此 skill 内重新触发 `/review`。

读取 diff，找出问题，安全可修的直接修，其余询问。Done 表示 verification 已在本 session 中运行并通过。

## Outcome Contract

- Outcome:基于 current diff、project context 和 live evidence 的 review、release decision 或 maintainer action。
- Done when:findings、fixes、shipped state 或 blockers 都带有能证明它们的 commands、artifacts 或 remote state。
- Evidence:worktree status、diff、public project docs、manifests、CI、package contents、release 或 registry state，以及 current command output。
- Output:先给 concise findings；适用时再给 verification 和 shipped-state summary。

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

选择匹配用户 intent 的 mode，然后完整阅读该 section。Modes 会叠加到下方共享 review surface（Scope、Hard Stops、Autofix、Specialist Review、Verification、Sign-off）之上。

| User intent | Mode |
|---|---|
| "implement this plan", `/think` output handed off | [Plan Execution](#plan-execution-mode) |
| Diff or PR ready, "review", "看看代码", "合并前" | Default review (start at [Get the Diff](#get-the-diff)) |
| "look at issues", "review PRs", "triage", "批量处理" | [Triage Mode](#triage-mode) |
| "is this worth a release", "值不值得发版" | [Release Worthiness Analysis](#release-worthiness-analysis) |
| "commit", "push", "publish", "release", "close issue", "发布表情" | [Ship / Release Follow-through](#ship--release-follow-through) |
| "audit", "项目体检", "项目评分", "给项目打分", "深入分析项目代码", "scorecard", "linus review" | [Project Audit](#project-audit-mode) |
| Document, PDF, prose review | Delegate to `/write` (see [Document Review](#document-review)) |

进入任何 mode 前，先运行 [Project Context Extraction](#project-context-extraction)，如果 memory 在 scope 内，再运行 [Durable Context Preflight](#durable-context-preflight)。

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

See [rules/durable-context.md](../../rules/durable-context.md) for when to read durable context, the read-order budget, and the memory-type mapping.

For `/check`, private task constraints are `decision`, `preference`, and `principle` entries; review checklists are `pattern` and `learning`. Current code, diff, public docs, CI, tests, and remote state override memory. Durable memory can explain user intent and preferred follow-through, but public project rules still come from README files, manifests, CI workflows, release docs, the diff, and explicit instructions in the current thread. Never cite private memory as a public project requirement.

## Plan Execution Mode

Activate when the user's message starts with "Implement the following plan", "按计划实施", "按照计划", "整", "可以干", "直接改" followed by a plan body, or links to a `/think` output.

In this mode, do not run a code review. Instead:

1. State which plan is being executed (first heading or summary line).
2. Check for obvious repo drift: run `git status --short --branch -uall` and skim any changed files that contradict the plan. If drift makes the plan unsafe, name the specific conflict and stop.
3. Work through each plan item as a to-do. Mark each complete as you go.
4. After all items are done, run the project's verification command.
5. Transition automatically into Ship mode if the project context or current thread indicates review-then-ship.

## Default Continuation (review-then-ship)

When the project's `AGENTS.md` or the current thread explicitly asks to "commit after review", "ship if green", or equivalent, transition directly from review to the Ship flow after a clean review. Do not ask again. State "proceeding to ship" before acting.

## Get the Diff

获取 current branch 与 base branch 之间的 full diff。如果不清楚，询问。如果已经在 base branch 上，询问要 review 哪些 commits。

## Triage Mode

当用户提到 issue、PR、"review all"、triage、"batch" 或 "批量处理" 时激活。跳过 diff flow，改运行此 mode。

**Action-first rule：** 有清晰 disposition 的 items（already fixed、duplicate、already released）直接行动，不写 analysis paragraphs。分析 screenshots 或 images 时，在一条消息里说明你看到什么和 suggested action。只有 disposition 真的 ambiguous 时才询问用户。

**Bundled request classification：** 当一个 issue、PR 或 support thread 包含多个 asks，行动前先拆分：core bug、existing affordance、cosmetic preference 和 out-of-scope request。只修复或关闭 validated core bug；用 current path 回答 existing affordances；defer 或 decline cosmetic 和 out-of-scope asks，不要把整份 report 当成 to-do list。

**Status answer order：** 对 "都解决了吗"、"is this fixed"、"is this ready" 或类似 status checks，按这个顺序回答：code 或 commit state、branch 或 CI state、release artifact 或 registry state、public issue 或 PR state。不要把 fixed-on-main、available in pre-release、next stable release 和 already shipped 混成一种状态。

**Flow:** First identify the project's issue/PR host from public context. For GitHub projects, pull open items with `gh issue list -R <repo> --state open --limit 20` and `gh pr list -R <repo> --state open`. For non-GitHub projects, use the platform CLI/API named by the project docs or user request; if none exists, stop and report the missing integration instead of pretending GitHub commands apply. For each item, check current state with the project's release boundary: latest public release, main branch, preview/nightly/beta channel, registry/appcast, and target issue/PR status. If the fix is already in the current public release or documented pre-release channel, close with that exact upgrade path. If fixed on `main` but unreleased, reply "已修复，等下一个版本 release" and close only when project convention or the current user request allows fixed-on-main closure; otherwise leave it open with the next-release note. If no fix exists, analyze and act. Fix now if possible (`fix: closes #N` commit); for valid-but-unreleased items acknowledge and leave open; for invalid items give one-two sentence reason and close.

在 live queue 中给 final conclusions 前，再 refresh 一次 issue/PR list，并重读 run 期间发生变化的 item。如果 evidence 不完整，hold 住 item，不要靠猜测关闭。

**PR handling:** If the PR direction is accepted but the patch needs changes, prefer pushing the maintainer's fixes to the contributor's PR branch and then merging the PR. Check `maintainerCanModify` first, then confirm the push remote, target branch, and current HEAD immediately before pushing so you do not overwrite contributor work or push maintainer fixes to the wrong repository. If branch edits are not allowed, ask the contributor to enable maintainer edits or push the needed revision; only fall back to a separate maintainer commit when timing or release safety requires it, and say so in the PR. Close without merging only when the direction is rejected, unsafe, no longer needed, or explicitly not part of the project's scope. Do not silently absorb an accepted PR into `main` and close it.

**Public reply shape：** 加载 `references/public-reply.md` 获取完整 template（mention、single thanks、factual paragraphs、next-release step、editing rules、closure criteria）。Ship Mode 使用同一 template；该文件是 single source。

**Sign-off line (append to standard sign-off):**
```
triage:           N reviewed, N closed, N deferred
```

## Release Worthiness Analysis

当用户询问 "深入分析 X 是不是值得发新版本"、"is this worth a new release"、"值不值得发版" 或类似问题时激活。

1. 运行 `git log <last-tag>..HEAD --oneline`，用 `git tag --sort=-version:refname | head -1` 找 last tag。
2. 统计并分类 commits：feat（new feature）、fix（bug fix）、chore/docs/refactor（internal）。
3. Output：
   - **Commit summary**：自 last release 以来 N feat、N fix、N chore
   - **Verdict**：release / skip（一行）
   - **Recommended version bump**：patch（fixes only）、minor（feat present）、major（breaking change）
   - **Key risk**：一句话说明这一批最大的 risk
4. 如果 verdict 是 "release"，提出可以 transition into Ship mode。

## Ship / Release Follow-through

当用户在 change ready 后要求 commit、tag、release、publish、push、reply on an issue/PR 或 close an issue 时激活。

这个 mode 扩展 review，不跳过 review。任何 public 或 irreversible action 前：

1. Extract release rules from public project context: README, manifests, CI workflows, release notes, package scripts, changelogs, and explicit user instructions in the current thread.
2. Fill the Release Gate 2.0 matrix from `references/project-context.md`: review base, dirty/staged/untracked state, latest tag, origin sync, version fields, generated artifacts, package/archive contents, release assets, registry/appcast/CI, and public issue/PR state.
3. Verify generated or bundled outputs, version fields, release notes, package contents, and required artifacts are in sync. Prefer dry-run commands when the ecosystem provides them.
   Generated deliverables include tracked archives, ignored dist files, appcasts, site/download copy, registry packages, checksums, and release assets. If project docs require them, regenerate, inspect, and stage or upload them explicitly even when they are ignored by git; do not infer readiness from source-only tests. For remote assets, prefer downloading or reading back the published artifact and comparing entries, checksums, or manifest contents; release page text, file size, or workflow success alone is not artifact proof.
   If the project has preview, beta, nightly, stable, or App Store lanes, name the lane explicitly. Do not use a preview or beta artifact to claim stable release readiness, and do not touch stable appcast, registry, or download surfaces when the requested lane is preview-only unless project docs require it.
4. Commit only intended files. Preserve unrelated dirty work, serialize git operations so index locks or overlapping adds do not corrupt the workflow, and re-check HEAD/status before pushing so concurrent agent or maintainer commits are not swept into your ship action.
5. Push, publish, tag, or create a release only when the user has explicitly approved that action. If auth, OTP, CI, registry, or network state blocks the operation, pause and report the exact blocker.
6. For issue/PR follow-through, confirm the item identity with the host's read command before posting. On GitHub, use `gh issue view` or `gh pr view`; on other hosts, use the CLI/API named by project docs or the current request. Use `references/public-reply.md` for the maintainer reply template (mention, single thanks, facts, explicit next release or verification step) and its closure criteria.
7. For GitHub release reaction follow-through, only do it when project context or the current thread asks for it. After the release exists and required assets are verified, resolve the release id from the tag, POST every positive release reaction to `repos/<owner>/<repo>/releases/<id>/reactions` with `gh api` or the available GitHub tool, and re-read reactions to confirm. Positive release reactions are `+1`, `laugh`, `heart`, `hooray`, `rocket`, and `eyes`.
8. After network or API failures, re-read the end state instead of assuming success or failure.

### Reworked Or Cancelled Release Gate

当 release candidate 被取消、preview 或 beta 反复 bug-fix churn，或用户询问 delayed release 是否终于 safe 时，激活此 gate。

1. Lock the review base to the last public stable tag or release artifact, then review through current `HEAD`. Do not limit the review to recent commits or the latest local diff.
2. Record the exact base, `HEAD`, dirty state, origin sync, version fields, generated artifacts, release notes, package contents, CI, and remote distribution state. If any state changes mid-review, refresh the range and rerun the fast gates.
3. Review by shipped risk surface: user-reported regressions, crash or hang paths, destructive operations, privilege or permission boundaries, background workers, startup or first-frame work, update feeds, package contents, and public support claims.
4. Output two release decisions, not one: whether the preview or beta can keep taking user testing, and whether stable release prep can start.
5. Every conclusion must name blockers, deferrable maintenance, commands that ran, and runtime or user-smoke coverage. Source tests alone cannot prove a reworked UI/native release ready.

以 concrete shipped state 结束：commit hash、tag、release URL、registry/version result、pushed branch、release asset state、release reaction state、issue/PR state，以及任何 remaining blockers。省略不适用字段。

## Project Audit Mode

当用户要求 project-wide code-quality scorecard 时激活："audit"、"项目体检"、"代码质量评分"、"scorecard"、"linus 风格 review"。它不同于 Default Review（PR/diff scoped）和 Triage（issue batching），是 single-pass project-wide quality assessment。

**Flow**

1. Run `python3 <waza>/skills/check/scripts/audit_signals.py --root <project>` from the target repo. The script emits labelled blocks (`=== FILE SIZE HOTSPOTS ===` ... `=== DENYLIST IN BUILD ===`) each ending with `status: PASS|WARN|FAIL|N/A`.
2. Skim the largest source files surfaced by `FILE SIZE HOTSPOTS` (typically 3-5; stop sooner if the architecture is already clear).
3. Read `CLAUDE.md` / `AGENTS.md` / `README.md` to learn the project's own stated conventions before judging it against generic ones.
4. Apply the four-axis rubric below. Each axis is independently scored 0-10. Overall = arithmetic mean.
5. Surface 3-7 concrete findings per axis. Each finding: file:line citation when possible, severity (CRIT/STRUCT/INCR), one-line fix.
6. Output to **terminal only**. Do not create files in the target repo. If the user follows up with "save it", offer `./docs/<project>-audit.md` then; default is ephemeral.

**Rubric**

| Axis | What it covers |
|---|---|
| Architecture | Module boundaries, coupling, abstraction layers vs flat duplication, single source of truth |
| Code Quality | File size discipline, dedup, readability, comments on non-obvious behavior |
| Engineering | Tests, CI gates, version coordination, install URL pinning, packaging posture |
| Perf and Risk | Hazards, scope creep, distribution risk, privacy posture, third-party blast radius |

**Scoring anchors**

- 9-10: exceptional discipline, polish-only items
- 7-8.5: solid with clear targeted improvements
- 5-7: working but with structural debt
- below 5: significant rework recommended

A WARN that the project has explicitly justified (in its own docs or a comment) is not a finding; cite the justification and skip. Do not mechanically convert WARN to CRIT. A block with `status: N/A` means the surface does not exist (e.g. no packaging script); treat as silence, not as a positive signal.

**Output template (terminal)**

```
Project: <name>
Overall: X.X / 10

Architecture: X / 10 -- one-line summary
Code Quality: X / 10 -- one-line summary
Engineering:  X / 10 -- one-line summary
Perf & Risk:  X / 10 -- one-line summary

Findings
[CRIT] <file:line> -- <issue>
       why: <reason grounded in signal or read>
       fix: <concrete action>
[STRUCT] ...
[INCR] ...

Top 3 highest-leverage moves
1. ...
2. ...
3. ...
```

除非用户要求 follow-up implementation，报告后停止。Audit mode 不修改 target repo 中的 files。

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

When the diff fixes a visual, layout, timing, or stateful-UI bug that has recurred (the same area broke before, or the fix reads as "tune a number until it looks right"), a code change alone will let the regression return: the logic is entangled with mutable render or UI state, so there is nowhere to assert on it. Flag the fix as incomplete unless it pulls the decision into a pure function -- inputs in, value out, no mutable receiver -- and unit-tests the invariant that was violated (a width never collapses to zero, a hit region stays half-open, an offset stays in bounds). "Verified by running the app" confirms this one instance; only a pinned invariant stops the next one. Reserve this for classes that recur or that runtime checks cannot see; do not demand a seam for one-off logic that already has straightforward coverage.

## CLI Command Surface

When a diff touches a CLI entrypoint, installer, completion, config/env handling, package wrapper, or a mutating command such as cleanup, update, uninstall, migration, or cache removal, fill the CLI Command Surface from `references/project-context.md` before sign-off.

检查 command contract 和 installed-runtime behavior，不只看 library tests：help/version、subcommands/flags、exit codes、stdout/stderr、JSON/schema output、TTY/non-interactive paths、env/config precedence、shebang/executable bit、PATH shim，以及适用时的 package-manager install path。

For mutating CLI commands, also run the Safety Sink Review: dry-run or confirmation path, operation log or rollback story, retry/idempotency, signal/partial-failure handling, and test-mode guards for auth prompts or real system changes. For cleanup, uninstall, prune, reset, or cache-removal commands, add two checks before approval: can a normal user verify each selected item is safe, and is the deleted content locally rebuildable rather than a downloaded dependency or user data? If either answer is no, require narrower matching, explicit user selection, or leave the item visible but non-destructive.

## Skill, Plugin, And Packaged Install Surface

When a diff touches a skill, plugin, marketplace entry, installer, package allowlist, package manifest, generated mirror, or published archive, verify the installed runtime contract, not just the source tree:

1. Identify the install path a real user will get: package manager, release archive, marketplace entry, plugin source path, or installer script default ref.
2. Build or regenerate the package exactly as project docs require, then inspect the archive or generated mirror for every new script, reference, template, rule, manifest, and executable bit.
3. Run an isolated install smoke when the surface is installable: fresh temp home/config/cache, add the marketplace or package, install the skill or plugin, list it, and invoke the smallest command or entrypoint that proves scripts and references resolve from the installed path.
4. Filter generated mirrors and archives for cache/noise files such as `__pycache__`, `*.pyc`, `.pytest_cache`, `.ruff_cache`, `.mypy_cache`, `.DS_Store`, local logs, and screenshots unless the project explicitly ships them.
5. If network, auth, or host tooling prevents the install smoke, state the missing layer as a blocker or gap. Do not replace installed-runtime proof with manifest JSON, source tests, or a successful local import.

## Hard Stops (fix before merging)

Examples，不穷尽。任何未 review 合并后可能造成 irreversible harm 的 diff 都要标记。

- **No unverified claims.** Do not write "I verified X", "I ran Y", "tests pass", or "this fixes Z" unless the shell output is in this turn's transcript. If you reason about behavior without running, say "based on reading the code" instead of "I verified". Every verification claim in the sign-off must point to a command that actually ran in this session.
- **Re-read before citing source-of-truth facts.** Before writing a line number, dirty-file count, branch ahead/behind state, fallback behavior, locale coverage, or release artifact state into a handoff or review report, re-read the source in this turn (`git status`, `git diff`, file `Read`, `rg`, command output). Earlier chat context, prior agent's notes, and your own recall from a hundred turns ago are stale by default; restating "the catalog uses en fallback" or "the file is at line 310" without checking has been the recurring failure mode in long sessions. Cite the verification path inline (`per current Read of <file>` / `per `git status` this turn`) so reviewers know which facts are anchored.
- **String-matching on captured output?** When a diff branches on, greps, or classifies an error message or command output, verify what that string actually holds at runtime before approving. A subprocess spawned with `stdio: 'inherit'` (or any uncaptured pipe) streams its diagnostics to the terminal, not into `error.message` -- which then contains only the command line. Such a matcher silently matches the command, not the output: it can pass tests, fire on the wrong token, or be dead in production while looking correct. Probe the real `error.message` (a one-line repro) instead of assuming, and prefer driving behavior off a structured fact the caller already holds (build target, exit code) over re-parsing a string.
- **Destructive auto-execution**: any task marked "safe" or "auto-run" that modifies user-visible state (history files, config, preferences, installed software) must require explicit confirmation.
- **Release artifacts missing**: verify every artifact listed in release notes, release templates, or project workflows exists and has been uploaded before declaring done.
- **Generated artifact drift**: if source changes require generated or bundled outputs, verify the output was regenerated and included.
- **Verifier failure layer unclear**: if a verifier fails before assertions or due to missing optional dependencies, bootstrap noise, transient build-service crashes, unavailable simulators, or tool setup, classify setup versus product failure. Retry only with new evidence or a narrower environment. Do not call the repo broken until the intended test body or artifact check actually ran.
- **Tracked package omissions**: if a package script builds from tracked files, allowlists, or generated manifests, verify every new helper module, reference file, template, or script used by the diff is tracked and present in the built archive before sign-off.
- **Manifest-only install proof**: if a diff changes a skill, plugin, installer, marketplace entry, package wrapper, or installable archive, metadata and source tests are not enough. Build or install through the real user path in an isolated environment, or mark the install/runtime layer unverified.
- **Version skew**: release version fields across manifests, package metadata, app configs, changelogs, tags, or lockfiles must stay synchronized.
- **Unknown identifiers in diff**: any function, variable, or type introduced in the diff that does not exist in the codebase is a hard stop. Grep before writing or approving any reference: `grep -r "name" .` -- no results outside the diff = does not exist.
- **Dead-code or YAGNI deletion without proof**: any "zero callers" or "unused" claim must be checked across the whole repository, including top-level entrypoints, docs, tests, generated dispatch tables, scripts, CI, and dynamic lookup patterns. Treat sub-agent or tool reports as leads, not proof. Before deleting, batch-grep all candidates, classify test-only references separately from production references, and chase written variables or data tables that may become orphaned together. If the grep scope is partial, do not delete.
- **Injection and validation**: SQL, command, path injection at system entry points. Credentials hardcoded, logged, committed, or copied into public docs.
- **Dependency changes**: unexpected additions or version bumps in package.json, Cargo.toml, go.mod, requirements.txt. Flag any new dependency not obviously required by the diff.
- **Safety sinks**: destructive file operations, shell or AppleScript construction, cwd/path/symlink traversal, approval or sandbox boundary changes, signing/appcast flows, and auth prompts need explicit review of validation, rollback, and user-confirmation behavior.
- **Audit before restore**: when the diff re-adds a symbol, string, asset, or config field that recent history removed, grep the rest of the diff and the main branch to confirm anything still uses it. A rule file that names the symbol is not proof of life. If only a parity test references it, the rule is stale and the restore is wrong; reject the restore and flag the stale rule. Specifically suspicious: re-adding an enum case, xcstrings entry, dictionary key, or asset file that the prior commit deleted intentionally.
- **AI-generated PR with broad matchers in destructive sinks**: any PR that introduces `find`-like recursion, mass-delete, sandbox/container traversal, ID-prefix wildcards, or fallback regex branches feeding a destructive sink, and was likely AI-generated, must be reviewed line-by-line for three things: matcher breadth in every branch (fallback paths often regress to broad globs even when the primary branch is correct), protected-path coverage (does the existing guard list include this new entry point?), and whether the change bypasses an existing user-confirmation step. Generic plausibility is not safety. When in doubt, ask the contributor to narrow the matcher to an exact constant (exact bundle ID, exact app name, exact path), not a prefix or wildcard; do not approve "this looks fine."
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

加载 `references/persona-catalog.md` 判断哪些 specialists 激活。有环境 agent 或 sub-agent facility 时，把 full diff 传入并并行启动所有 activated specialists。如果没有 parallel reviewer facility，在同一 session 中顺序运行 specialist passes。

合并 findings：两个 specialists 标记同一 code location 时，保留更高 severity，并注明 cross-reviewer agreement。不同 code locations 上的 findings 即使 theme 相同，也不是 duplicates。

Treat each specialist finding as a claim to verify, not a fact to act on. Before routing a finding to Autofix or sign-off, re-read the cited code this turn and confirm it is real and live: not already handled elsewhere, not consistent-by-design, not a latent-only risk labeled as a live bug. Parallel reviewers over-report from name-based inference and partial context; drop or downgrade what dissolves on direct read, and cite the verification path.

## Autofix Routing

| Class | Definition | Action |
|-------|------------|--------|
| `safe_auto` | Unambiguous, risk-free: typos, missing imports, style inconsistencies | Apply immediately |
| `gated_auto` | Likely correct but changes behavior: null checks, error handling additions | Batch into one user confirmation block |
| `manual` | Requires judgment: architecture, behavior changes, security tradeoffs | Present in sign-off |
| `advisory` | Informational only | Note in sign-off |

先应用所有 `safe_auto` fixes。把所有 `gated_auto` 合并成一个 confirmation block。绝不要逐个询问。

## Adversarial Pass (Deep only)

"If I were trying to break this system through this specific diff, what would I exploit?" Four angles (see `references/persona-catalog.md`): assumption violation, composition failures, cascade construction, abuse cases. Suppress findings below 0.60 confidence.

## Platform Operations

使用与项目匹配的 platform tool。GitHub projects 优先使用 `gh` 或可用 GitHub integration，并在 merging 前确认 CI passes。Non-GitHub projects 从 public project docs 或用户明确 platform context 推导 CLI/API；不要把 GitHub commands 强套到其他 hosts。

## Verification

从此 skill directory 运行 `bash scripts/run-tests.sh`，或在 target repository 中运行项目 known verification command。粘贴完整 output。

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

```
files changed:    N (+X -Y)
scope:            on target / drift: [what]
review depth:     quick / standard / deep
hard stops:       N found, N fixed, N deferred
specialists:      [security, architecture] or none
new tests:        N
doc debt:         none / AGENTS.md needs X / rules need Y
verification:     [command] -> pass / fail
```
