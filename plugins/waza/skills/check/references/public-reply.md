# Public Reply Shape（maintainer, issue or PR）

Triage Mode 和 Ship / Release Follow-through 都复用此 shape。除非 target repo 中的 `AGENTS.md` 或 `CLAUDE.md` 与它冲突，否则默认使用此 shape。

1. posting 前，从 `gh issue view` / `gh pr view --json author` resolve `@<login>`。
2. **Language:** 当 opener 使用中文或英文时，匹配 **opener's** language。如果 opener 使用日文或韩文，除非 project docs override，否则 maintainer reply 使用英文。
3. 以 `@<login>` 开头，并且**最多一个**简短 thanks（`感谢反馈`、`thank you for the report` 等）。不要添加 closing thanks stacks（`再次感谢`、`Thanks again`、长 courtesy endings）。
4. 一到两个短 paragraphs：factual reason、what shipped 或 what is blocked，不要 ceremony。
5. 命名 exact boundary：already released、fixed on `main` but unreleased、available in nightly/beta/preview、next release、not planned、duplicate，或 still needs evidence。每句话在 posting 当下都必须为真：change 还没 commit 时不要写 "landed on main"；除非当前 turn 已检查该状态，不要写 "shipped"、"released" 或 "verified"；不要暗示未实际发生的 verification step（built a branch、ran an artifact）。
6. 始终给一个**绑定 releases 或 verification 的 next step**：next App Store 或 GitHub release、nightly upgrade command、只需 clear 一次的 cache path，或仍需要的 exact info。
7. 对 diagnostic bundles、logs、crash dumps、screenshots 或 local-state archives，不要要求 reporter 公开粘贴或上传 sensitive material。只索取最少 public facts；只有 public project context 提供 private support channel 时，才引导到该 channel。
8. 更新 wording 时，优先 **editing** existing maintainer comment（`PATCH /repos/{owner}/{repo}/issues/comments/{comment_id}`）；除非 old text 必须从 history 消失，否则避免 delete plus repost。

## When closing

只有当 fix 已 shipped、已在 latest release 可用、report invalid、report duplicate，或 maintainer 明确要求 closure 时，才 close。否则保持 open，并给 next-release acknowledgement。
