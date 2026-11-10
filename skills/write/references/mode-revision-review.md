# Revision Review Mode

当输入是同一文本的 before/after 对（未提交的 diff、两份 draft、另一个 model 或 editor 的 polish pass），且问题是新版本是否更好时，由 `write` 加载。

Done when 每个 changed hunk 都有 verdict（keep、revert 或 blend），每个 revert 或 blend 都说明新措辞丢了什么，并且重复该文本的 surfaces 与之一致。要对照整篇文章读 word-level diff（`git diff --word-diff`），不要孤立看 hunks：多数损失只有在周围段落中才显现。

Polish pass 容易丢什么，以及保留 hunk 前要检查什么：

- **Raw reaction 被换成整洁的抽象。** 作者的感叹、俚语或身体意象变成中性名词短语（"friction"、"a knowing smile"、"the top priority is always"）。新句子更顺，却不属于任何人。恢复作者原话；blend 可以保留新版本的删减，但必须围绕原话。
- **Motif chain 断了一环。** Heading、mid-section line 和 closing paragraph 常常回指同一个意象。中和其中一处会让其余几处失去依托。把 chain 当成一个整体：要么全保留，要么全改。
- **Reasoning 被砍成 bare claim。** 为长度删掉 trade-off clause、"because" 或 closing stance，只留下读者自己也能写出的定义。如果被删的正是段落重点，更短并不更好。
- **具体数字或名字被模糊。** "All 850 are free to read" 变成 "click into any app to read it"。恢复具体信息。
- **新词与文章 thesis 矛盾。** 文章把某项工作描述为刻意、艰苦的努力，却在前面加一个随意的 "along the way"。逐个检查新增副词和 framing word 是否违背文章主 claim。
- **编辑引入重复措辞。** 同一句里同一个名词出现两次，或 closing call-to-action 重复上一段的请求。

更好的编辑要接受：typo 和 grammar fix、更真实的 opening motivation、确实读错的 run-on。按每个 hunk 本身判断，不要为任何一版辩护；如果每个编辑都丢失含义或让 prose 更差，全部 revert 也是有效的。

Titles 可以轻一点。作者刚选定 title 时，只有误读或误导才 flag。你提供的 alternative 必须比原题朗读更顺；仅仅更字面或更正确的 alternative 会被拒绝，而且理应如此。

Verdict 之后同步 surfaces：

- **Mirrors。** 只改一种语言（英文改了 figure，中文扩了 list）就是 drift。把每个保留的 change 带到另一版，或在两边都 revert。
- **Title echoes。** Title words 变化时，找出所有重复它们的地方：cover 或 social-card image text、image alt text、mirror 的 title、summary fields，以及其他 posts 的 cross-links。图片文字不再匹配 title 时，需要新 asset，而不只是新 alt text。

Output 跟随请求。"Is it better?" 得到按影响排序的 per-hunk verdicts，只读。"Fix it" 得到 edits，以及一份作者可以逐条否决的 restored 或 rewritten sentences 清单。
