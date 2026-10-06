# Release Worthiness And Ship Follow-through

> **中文导读（下方英文为 canonical contract）：** Ship mode 会把 review、verify、commit、push 和 public follow-through 视为一个 delivery ledger；授权链未完成前不返回控制。不要用空 commit 伪造交付，也不要把 source、CI、package、部署渠道和公开 thread 压成一个 done。所有 generated artifact、release surface 和远端状态都要逐层读回。


Loaded from `check` Mode Picker for "is this worth a release" and for commit / push / publish / tag / issue-closure follow-through. Ship extends review; it does not replace it.

## Release Worthiness Analysis

Activate when the user asks "深入分析 X 是不是值得发新版本", "is this worth a new release", "值不值得发版", or similar.

Classify every commit since the last published tag (the tag is the baseline, not a local VERSION file), then output:

- **Commit summary**: N feat, N fix, N chore since last release
- **Verdict**: release / skip (one line)
- **Recommended version bump**: patch (fixes only), minor (feat present), major (breaking change)
- **Key risk**: one sentence on the biggest risk in this batch

If the verdict is "release", offer to transition into Ship mode.

## Ship / Release Follow-through

Activate when the user asks to commit, tag, release, publish, push, reply on an issue/PR, or close an issue after a change is ready.

Treat an explicitly authorized chain such as review, fix, verify, commit, push, and public follow-through as one delivery ledger. Do not return control between its internal stages while safe authorized work remains. A local commit is not completion when push was included, and a no-op push is not completion when intended local changes remain uncommitted. Do not create an empty commit when the intended scope is already clean; prove the clean/up-to-date state instead.

This mode extends review; it does not skip review. Before any public or irreversible action:

1. Extract release rules from public project context: README, manifests, CI workflows, release notes, package scripts, changelogs, and explicit user instructions in the current thread.
2. Fill the Release Gate 2.0 matrix from `references/project-context.md`. Seed the deterministic rows with `python3 <skill-base-dir>/scripts/release_gate.py --root <project>` (worktree state, remote sync, tag baseline, version field sync, changelog mention) and paste its status lines as evidence; the remaining rows (generated artifacts, package/archive contents, release assets, registry/appcast/CI, public issue/PR state) stay judgment calls with their own evidence.
3. Verify generated or bundled outputs, version fields, release notes, package contents, and required artifacts are in sync. Prefer dry-run commands when the ecosystem provides them. When drafting release notes or update-feed copy, follow `/write` and its release-note mode; for Chinese copy, load its zh release-notes rules before the first draft, not after a tone complaint -- translation-flavored Chinese notes are a defect, not a polish item.
   Before drafting release notes, read the repo's previous published release (`gh release view` the latest tag) and preserve its title convention, per-item length, and language layout. Treat its item count as history, not a target: use the smallest complete set of distinct user outcomes in the candidate artifact.
   Generated deliverables include tracked archives, ignored dist files, appcasts, site/download copy, registry packages, checksums, and release assets. If project docs require them, regenerate, inspect, and stage or upload them explicitly even when they are ignored by git; do not infer readiness from source-only tests. For remote assets, prefer downloading or reading back the published artifact and comparing entries, checksums, or manifest contents; release page text, file size, or workflow success alone is not artifact proof.
   If the project has preview, beta, nightly, stable, or App Store lanes, name the lane explicitly. Do not use a preview or beta artifact to claim stable release readiness, and do not touch stable appcast, registry, or download surfaces when the requested lane is preview-only unless project docs require it.
   Classify each change by deployment surface before concluding what is live: code that ships inside a packaged artifact (app binary, bundled CLI, release archive) reaches users only at the next release, while sites, serverless functions, CDN config, and infrastructure deploy automatically when the default branch updates. One batch of changes can be unreleased on the first surface and already in production on the second; state each surface separately instead of letting "not released yet" cover auto-deployed code.
4. 按 `SKILL.md` 中的 Worktree Safety Preflight 只提交预期文件，并串行执行 git 操作，避免 index lock 或重叠 add 破坏工作流。在脏工作区或多 agent checkout 中，stage 前记录 `git rev-parse HEAD`，commit 前以及 push 前再次读取 `git status --short --branch -uall` 和 `git rev-parse HEAD`。如果 HEAD 移动、出现未知 commit，或工作区在预期文件之外发生变化，停止并报告不匹配，不要 rebase、重新 commit 或 push。
5. 只有用户明确批准后，才能 push、publish、tag 或创建 release。在某项目首次 push 前，检查 `git remote -v`、当前 branch 和已认证 identity；用户指定 exact account 时，在首次 remote write 前立即验证已认证的 service identity，不匹配就停止，绝不静默替换为其他 account。若 auth、OTP、CI、registry 或 network 状态阻塞操作，暂停并报告 exact blocker。
6. 对 issue/PR follow-through，发布前先用 host 的 read command 确认 item identity。GitHub 使用 `gh issue view` 或 `gh pr view`；其他 host 使用项目文档或当前请求指定的 CLI/API。发布、编辑、读回和关闭标准使用 `references/public-reply.md`；reply 正文遵循 `/write` Public Reply Mode。
7. For GitHub release reaction follow-through, only do it when project context or the current thread asks for it. After the release exists and required assets are verified, resolve the release id from the tag, POST every positive release reaction to `repos/<owner>/<repo>/releases/<id>/reactions` with `gh api` or the available GitHub tool, and re-read reactions to confirm. Positive release reactions are `+1`, `laugh`, `heart`, `hooray`, `rocket`, and `eyes`.
8. After network or API failures, re-read the end state instead of assuming success or failure. For an at-most-once operation (publish, tag, release create, payment), a verification timeout is unknown, not failed: a registry can gate a successful upload behind a scan that delays visibility for tens of minutes. Keep re-reading until it resolves, and never re-run the publish to make the check pass.

Before handoff, reconcile every authorized item as `done`, `not applicable`, or `blocked`, then re-read the local `HEAD`, target remote ref/SHA, worktree status, CI or published artifact lane, and any public thread changed in this run. Never collapse source, CI, package, deployed channel, and public-thread state into one "done" claim.

### Reworked Or Cancelled Release Gate

Activate this gate when a release candidate was cancelled, a preview or beta had repeated bug-fix churn, or the user asks whether a delayed release is finally safe. Load `references/release-surfaces.md` (Reworked Or Cancelled Release Gate): review from the last public stable tag through `HEAD` by shipped risk surface, and output two decisions, whether the preview keeps taking user testing and whether stable release prep can start.

Lead the verdict with an explicit go / no-go (ship, or the named blockers), then the concrete shipped state: commit hash, tag, release URL, registry/version result, pushed branch, release asset state, release reaction state, issue/PR state, and any remaining blockers. Omit fields that do not apply.
