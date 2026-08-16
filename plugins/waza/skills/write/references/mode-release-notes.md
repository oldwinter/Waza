# Release Note Template Mode

> **中文导读（下方英文为 canonical contract）：** Release notes 先从最后一个 published release 到 HEAD 建立完整 user-visible inventory，再按目标项目既有格式和影响分组。每项只写用户可感知变化，双语项目才输出双语 block，中文 block 保持中文标点和自然语气。


Loaded from `write` when the ask is a release note, changelog entry, or update-feed copy.

Activate when: "release", "changelog", "version", "release notes"

Format: target-project style by default. If no project style is available, use numbered items with bold labels and one sentence on user effect; bilingual output only when the project already ships bilingual release notes. Call out breaking changes and deprecations explicitly when present.

### Release Notes Pre-flight

Before drafting, gather style references:

1. Read the target project's `CLAUDE.md` for its Release Convention / Release Flow section.
2. Read the target project's existing release source as a format, tone, sentence-length, and density reference: changelog, release notes, registry page, update feed, or platform release page.
3. For GitHub projects, `gh release view --json body -R <owner>/<repo>` is the preferred way to read the most recent release when `gh` is available. If the project is not on GitHub, use the release source named by the project docs or user request.
4. If the user mentions comparing with a sibling project's release style, ask for the target identifier or release URL before fetching it.
5. Match the reference release's format, sentence length, and tone. Treat its item count as history, not a quota: the current release may need fewer or more items.
6. Keep each release-note item to one sentence unless the reference project clearly does otherwise. Do not add emoji to release prose unless the target surface is explicitly a reaction or celebratory social surface.

### Release Notes Content Rules

- **起草前冻结 artifact 边界。** 确认最后一个 published release 和用户实际会收到的 candidate；只有 candidate 从 `HEAD` 构建时才使用 `HEAD`，只有会随该 artifact 发布的 dirty/generated changes 才纳入。后续提交不属于旧 artifact 的 release note。
- **建立完整的用户可见清单。** 对每项 change 写明目标读者、前后差异，以及读者能否直接看到或必须采取行动。除非改变可见结果或需要用户操作，否则省略 delivery、refactoring、observability 和 security mechanics；有意省略项写在工作记录，不写进已发布 prose。
- **由 outcome 决定条目数量。** 使用覆盖 candidate 的最小 distinct user outcomes 集合；服务同一目标的变更合并，不为模仿历史数量而拆分或保留内部细节。
- **按用户可感知 feature 分组**，而不是内部 taxonomy。"Polish"、"细节打磨"、"Misc improvements"、"Chores" 不是用户能据此行动的分类；按 product surface 或 user-visible verb 分组。
- **从 `git log <last-published>..<candidate>` 提取**，不要凭记忆。读取 artifact boundary 内每个 `feat:` 和 `fix:` commit，不因 commit 看起来细小就遗漏。
- **每项用一句话写用户可见变化**，不要写 implementation。label 和开头必须让读者无需阅读全文就知道变化；只有目标读者需要识别、配置或操作时才保留技术术语，内部 symbol 或 rule name 永远不是 release item。
- **Bilingual structure**: when the project ships bilingual release notes, put the English block and the Chinese block as two parallel sections inside the same release item; do not interleave per bullet. For HTML-capable update-feed CDATA, separate language blocks with headings so the rendered update window does not collapse them together.
- **Settle structure before localization.** Approve the source-language outcomes, order, and labels before translating. Every locale then preserves the same item count and order while using native register rather than mirroring source-language syntax.
- **Punctuation**: Chinese full-width in Chinese blocks, ASCII in English blocks.
