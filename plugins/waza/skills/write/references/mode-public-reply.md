# Public Reply Mode（GitHub issue / PR）

当交付物是维护者在公开 issue 或 PR thread 中的回复时，由 `write` 加载。

激活条件：“回复 issue”“reply to PR”“comment on #N”“回 issue”，或用户要求 GitHub issue / PR comment 文案。

回复正文遵循五条硬规则：

1. **以 `@<reporter>` 和一句感谢开头。** 匹配 reporter 的语言：中文用“感谢反馈”，英文用 “thanks for the detailed report”。不用感叹号，不用 emoji，不用“🙏”。
2. **然后一句话说明原因，一句话说明影响。** 不写多段背景，不使用内部 symbol name，不逐步讲解修复过程。
3. **然后准确说明 ship state，** 且只能选一种：已随 v<X.Y.Z> 发布；已在 `main` 修复并将在下次 release 发布；计划用于 v<X.Y.Z>；不计划支持（附一行理由和替代路径）。每句话在发布当下都必须为真：本轮没有 release evidence 就不能说“已发布”，change 尚未 commit 就不能说“已落到 main”，没有实际发生的 branch build 或 artifact run 不能被暗示为已验证。
4. **最多两个段落，** 中间空一行。不用 bullet list、section header 或 code block，确有需要时可以放一行命令。

5. **批量回复是 N 条独立回复，不是同一 skeleton 填 N 次。** 一次关闭或回答多个 thread 时，posting 前把 drafts 并排阅读：三条以上回复使用相同 opening clause、相同 paragraph order 和相同 closing move，无论每条事实多准确，都会显得像模板。只能共享事实；尤其 opening sentence 必须来自该 thread 自己的 report。

回复是最终用户文案，不是 agent log。不要写“刚才我判断错了”“前面回复有误”“I re-read it and changed the comment”等关于自身过程的元叙事。编辑既有 maintainer comment 时，直接替换为干净的最终文案，就像它是用户唯一会读到的 comment。

发布前使用 `gh issue view <num>` 或 `gh pr view <num>` 重新读取 live issue / PR。不要凭记忆回复；title、state 和 author language 可能在 session 之间变化。

对付费或订阅用户，用一个短语承认购买关系和造成的不便，然后说明边界，不要过度解释。当前产品无法支持其环境时，给出最安全的实际路径，例如升级 macOS、等待下次 release、提供 logs 或退款方式，不要争辩。

对私有 support channel（DM、in-app reply、support email），完全去掉报告体：使用维护者自身语气的简短口语句，先说用户能得到什么，而不是工作原理，句号比文档更少。

关闭规则：以 `completed` 关闭时，comment 必须能独立说明修复内容和预计 release；以 `not planned` 关闭时，comment 必须能独立说明当前边界和替代路径。不能依赖 thread 中更早的上下文作为解释。
