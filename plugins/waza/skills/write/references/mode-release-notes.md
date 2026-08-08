# Release Note Template Mode

> **中文导读（下方英文为 canonical contract）：** Release notes 先从最后一个 published release 到 HEAD 建立完整 user-visible inventory，再按目标项目既有格式和影响分组。每项只写用户可感知变化，双语项目才输出双语 block，中文 block 保持中文标点和自然语气。


Loaded from `write` when the ask is a release note, changelog entry, or update-feed copy.

Activate when: "release", "changelog", "version", "release notes"

Format: target-project style by default. If no project style is available, use numbered items with bold labels and one sentence on user effect; bilingual output only when the project already ships bilingual release notes. Call out breaking changes and deprecations explicitly when present.

### Release Notes Pre-flight

Before drafting, gather style references:

1. Read the target project's `CLAUDE.md` for its Release Convention / Release Flow section.
2. Read the target project's existing release source as a style, length, and density reference: changelog, release notes, registry page, update feed, or platform release page.
3. For GitHub projects, `gh release view --json body -R <owner>/<repo>` is the preferred way to read the most recent release when `gh` is available. If the project is not on GitHub, use the release source named by the project docs or user request.
4. If the user mentions comparing with a sibling project's release style, ask for the target identifier or release URL before fetching it.
5. Match the reference release's item count, sentence length, and tone. Do not invent a new format.
6. Keep each release-note item to one sentence unless the reference project clearly does otherwise. Do not add emoji to release prose unless the target surface is explicitly a reaction or celebratory social surface.

### Release Notes Content Rules

- **起草前建立完整的用户可见清单。** 从最后一个已发布 release 一直核对到 `HEAD`，纳入相关 dirty/generated delivery changes，把每项 change 映射到它改变的 user outcome，并明确说明 omissions。随后合并 outcome 相同的 items，按 user impact 排序。Commit title 的顺序不是 release-note priority。先写产品自身 domain，install、build 和 packaging plumbing 放在后面，即使 plumbing fix 是本次 release 风险最高的改动。
- **Group by user-perceivable feature**, not by internal taxonomy. "Polish", "细节打磨", "Misc improvements", "Chores" are not categories users can act on. Group by product surface (Clean / Uninstall / Status / Settings) or by user-visible verb (Faster startup / New keyboard shortcut / Fixed crash on M3).
- **Extract from `git log <last-tag>..HEAD`** rather than from memory. Read every `feat:` and `fix:` commit; do not omit small items just because they look minor in commit form (iOS wrapper support, Dock cleanup, AV-vendor protection boundary are not "minor" from a user point of view).
- **每项只用一句话，写清用户可见变化**，不要写 implementation。“Use `CKDownloadQueue` observer for App Store updates”不是 release note；“App Store updates now run inside the app instead of opening App Store”才是。即使完全不涉及代码，internal vocabulary 也有同样问题：你在自己的 rules 或 docs 中创造的术语，对从未打开过它们的读者就是 jargon。新增 rule 的名称永远不是 release item；工具现在对用户做了什么不同的事，才是。
- **Bilingual structure**: when the project ships bilingual release notes, put the English block and the Chinese block as two parallel sections inside the same release item; do not interleave per bullet. For HTML-capable update-feed CDATA, separate language blocks with headings so the rendered update window does not collapse them together.
- **Punctuation**: Chinese full-width in Chinese blocks, ASCII in English blocks.
