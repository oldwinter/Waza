# Public Reply Mechanics (maintainer, issue or PR)

Triage Mode 和 Ship / Release Follow-through 用本文件处理 reply 周边动作。Reply 正文属于 `/write` Public Reply Mode；没有 `/write` 时，以 `@<login>` 开头，最多简短感谢一次，匹配发起人的语言，并用一到两句说明精确 ship state 和 reporter 的 next step，每句话都必须在发布当下为真。目标仓库的 `AGENTS.md` 或 `CLAUDE.md` 可以覆盖此格式。

1. Resolve `@<login>` from `gh issue view` / `gh pr view --json author` before posting, and re-read the live item there rather than replying from memory.
2. Edit your own comment in place (`PATCH /repos/{owner}/{repo}/issues/comments/{comment_id}`) only while nobody has replied after it. Once the reporter or anyone else has replied, post a new comment instead of rewriting history; never delete and repost unless the old text must disappear.
3. After posting or editing, re-read the comment body, author, target item, and issue/PR state. The public action is not complete without that receipt.
4. Close only when the fix is shipped, already available in the latest release, the report is invalid, the report is a duplicate, or the maintainer explicitly asked for closure. Otherwise leave it open with the next-release acknowledgement.
