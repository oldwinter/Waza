# Project Review Context Template

运行 Waza `/check` 前，用此 template 压缩 repository context。Context 必须来自 public project files、diff、CI configuration 或 explicit user instructions。不要依赖 private machine paths 或 unpublished project instructions。

## What Belongs In Project Context

下面的 template 已覆盖大部分内容。还要记录：

- Protected files and directories。
- Packaging source of truth：archives 是从 `git ls-files`、explicit allowlists、generated manifests 还是 source directories 构建。
- Delivery surfaces：generated outputs 是 tracked、ignored、external release assets、registry uploads、appcasts、installer metadata、checksums，还是 site/download copy；以及它们如何 regenerated、inspected、staged 或 uploaded。
- diff 引入的 runtime dependencies：CI/docs 中尚未声明的 Python packages、CLIs、network services、package managers 或 platform tools。
- Domain-specific safety rules。
- 项目文档记录的 known CI 或 test flakes，以及如何把它们和 real failures 区分开。

## What Does Not Belong In Public Context

- Credential paths、private key filenames、passwords、tokens 或 secret values。
- Maintainer-only machine paths。
- 不影响 project behavior 的 one-off personal preferences。
- 被复制成 guidance、而不是 distilled into stable project rules 的 one-off review reports、scorecards 或 diagnostic snapshots。
- 来自其他项目的 raw memory、chat excerpts、screenshots、private support details、local paths、project-specific commands、issue/PR numbers、release tags 或 commit hashes。
- Waza `/check` sections 的 full copies。

## Recommended Context Shape

```markdown
## Project Commands

- Format: `<command>`
- Fast check: `<command>`
- Full verification: `<command>`

## CLI Command Surface

- Entrypoints: `<command or bin>`.
- Command contract：help/version、subcommands、flags、exit codes、stdout/stderr、JSON/schema output。
- Runtime shape：TTY vs non-interactive behavior、env/config precedence、completion/manpage 或 shell integration。
- Install/run proof: built package, temp prefix, PATH shim, shebang/executable bit, or package-manager path checked with `<command>`.
- Mutating commands：dry-run/confirmation、operation log、rollback/retry behavior、signal/partial-failure handling。

## Skill Or Plugin Install Surface

- User install path: `<package manager / release archive / marketplace entry / plugin id / installer script>`.
- Source path and generated mirror: `<source dir>` -> `<installed dir>`.
- Package/archive inclusion: new scripts, references, templates, rules, manifests, and executable bits checked with `<command>`.
- Isolated install smoke: fresh temp home/config/cache plus `<install command>` and `<list or invoke command>`.
- Noise filtering: cache files, local logs, screenshots, and temp outputs excluded or intentionally shipped.

## Project Hard Stops

- Do not modify `<protected path>` unless explicitly requested.
- If `<artifact>` is generated from `<source>`, verify it was regenerated.
- If `<artifact>` is ignored by git but required for release, verify the regeneration and force-stage, upload, or registry publish path named by the project.
- If `<package script>` builds from tracked files or an allowlist, verify newly introduced helpers, references, templates, and scripts are included in `<archive>`.
- If an installer fetches remote content, verify the default ref is pinned to a release tag or checksum-protected; floating `main` must be an explicit override.
- 如果 helper 引入 non-stdlib package 或 external CLI，验证 CI 会安装它，或 helper 会以 clear setup path 失败。
- If `<artifact>` is listed in release notes, verify it exists before sign-off.

## Project-Specific Risks

- `<risk>`: `<how to inspect it>`

## Public Replies

发布、编辑或新评论、读回和关闭标准见 `public-reply.md`；reply 正文遵循 `/write` Public Reply Mode。不要在这里重复规则。

## Release Follow-through

- Version fields to check: `<manifest>`, `<app config>`, `<lockfile>`.
- Generated artifacts to check: `<artifact>` from `<source>`.
- Distribution lane: `<preview/beta/nightly/stable/etc.>` and which public surfaces it is allowed to touch.
- Dry-run command before publishing: `<command>`.
- Remote asset proof: `<download/readback command>` that checks content, manifest, digest, appcast, or registry state.
- GitHub release reactions to add after asset verification: `<+1/laugh/heart/hooray/rocket/eyes or none>`.
- Public state to re-read after publishing or closing: `<registry/release/issue URL or command>`.
```

保持 context 简短。它应 guide the review，而不是替代 review method。

## Release Gate 2.0 Matrix

声称 change release-ready 前填写此 matrix。只有当项目明确没有该 surface 时，才使用 "n/a"。

| Surface | Evidence |
|---|---|
| Review base | 已 review base branch、latest tag 和 commit range |
| Worktree state | Dirty、staged 和 untracked files 已 accounted for |
| Remote state | 已检查 `origin/main` 或 release branch sync |
| Version fields | Manifest、app config、changelog、appcast 和 lockfile versions 已 aligned |
| Distribution lane | 已命名 preview、beta、nightly、stable、registry 或 app-store lane，且 unrelated lanes 保持 untouched |
| Runtime dependencies | Newly introduced Python packages、CLIs、package managers 和 network tools 已声明，并在 CI 可用 |
| Generated artifacts | Tracked archives、ignored dist outputs、bundled/minified files、appcasts、installer metadata、checksums 和 site/download copy 已 regenerated 或证明不需要 |
| Package/archive contents | Built package 已 inspect required files、newly introduced helpers/references 和 missing extras |
| Installed runtime | 当 diff 改动 installable surfaces 时，已从 clean environment exercise package、skill、plugin、CLI 或 marketplace install |
| Release assets | GitHub release、appcast、download archive、checksum 或 installer assets 已 download 或 read back，并且验证超过页面文字或文件大小 |
| Registry/appcast | publish 后已 re-read npm/crates/Homebrew/appcast/App Store 或 equivalent state |
| CI status | Latest required checks passed，或已命名 blocker |
| Issue/PR state | commenting、closing、merging 或 saying shipped 前，已 re-read target issue 或 PR |

## Safety Sink Review

任何触碰以下 sinks 的 diff 都需要 explicit validation 和 rollback thinking：

- 删除、移动或覆盖 user files、caches、history、preferences 或 generated outputs。
- 从 user input 构建 shell、AppleScript、SQL、URL 或 filesystem paths。
- 改变 cwd handling、symlink resolution、path traversal guards、sandbox permissions、approval checks 或 auth prompts。
- 改变 signing、notarization、appcast、update、license、payment 或 release asset generation。
- 改变 CI workflows、release 或 publish scripts、installers，或任何以 elevated privilege 运行的内容。

先 review 到达 sink 的 smallest entry point，再 review downstream call。如果 validation 缺失或 rollback 不清楚，把它视为 hard stop。

### Risk tiers by path

Tier 由 change 触及的 paths 决定，而不是由大小或作者决定。对 workflow、updater、license check、installer、privilege helper 或 deletion path 的一行改动，也要走项目最重的 gate（完整或 native test run、security pass、human maintainer review），agent、bot 或 automated reviewer 的 approval 永远不能替代那位 human。从项目 docs 中提取 tiers；如果项目维护了按 changed paths 打印 gates 的 table-driven script，运行它并粘贴输出行。该 script 只是建议，不是 pass：它列出的 gates 可能在本 session 无法证明已运行的地方执行。处于某个 tier 的 commits 和 PRs 还要说明如何验证、如何回滚（`mode-ship.md` step 4）。
