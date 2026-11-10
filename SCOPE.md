# 范围

Waza 是我每天使用的一小组 engineering skills。欢迎提出想法，但每个想法都要按下面的标准判断。开 issue 或 PR 前先读这份标准。

## 标准

一个 idea 或 feedback issue 只有同时满足两部分才会保持 open：

1. **Observed failure。** 真实 session 中出了什么问题：你运行了什么、skill 做了什么、你期望什么。假设性的改进（"it would be better if..."）不算满足这一部分。
2. **Fits Waza。** 它不匹配 [`.out-of-scope/`](.out-of-scope/) 中的任何内容，也不是 configuration option、某个 harness 的分支，或某个人 workflow 的 tweak。这些应放进你自己的 `CLAUDE.md` 或 `AGENTS.md`，或放进 fork。

大小不重要：一个词的 fix 和一次 rewrite 面对同一标准。Reactions 和 +1 comments 不算数。

## 保持小集合

八个 skills：五个负责 [AI coding rules](docs/ai-coding-rules.zh.md) 的阶段，`/read`、`/learn` 和 `/write` 支持任意阶段。新行为折叠进现有 skill，或由多个 skill 组合完成，不新增 skill。

## 已经决定

[`.out-of-scope/`](.out-of-scope/) 中每个文件记录一个已决定的问题及原因。提交前先读：

- [`skill-name-prefix.md`](.out-of-scope/skill-name-prefix.md)：不给每个 skill 加 `waza-` 前缀
- [`harness-name-collisions.md`](.out-of-scope/harness-name-collisions.md)：built-in command 保留原名，Waza 改名
- [`remember-skill.md`](.out-of-scope/remember-skill.md)：不设 memory skill
- [`third-party-providers.md`](.out-of-scope/third-party-providers.md)：除非当前 tiers 覆盖不了某个 gap，否则不在 `/read` 中增加新的 search 或 fetch provider
