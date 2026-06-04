# Durable Context Preflight

每个会读取 optional memory 或 prior-decision context 的 skill 共用这段 preamble。每个 `SKILL.md` 会链接到此文件，再补充 skill-specific guidance。

## 何时读取 durable context

只有满足以下任一条件时，才运行 durable context steps：

- 用户提到 memory、preview、previous decisions 或 prior conclusion。
- 用户提供 memory path。
- 当前项目暴露明显的 local memory summary，例如 `MEMORY.md` 或有文档记录的 memory directory。

不要硬编码 machine-specific memory roots，也不要读取 raw transcripts。

## 读取顺序和预算

按这个顺序读取 durable context：user-provided path、current project scope、global preferences。先列 titles，再最多打开 1-2 份相关 summaries。把 cross-project entries 只当成 transferable patterns。

## Memory distillation redaction gate

把 prior chats、durable memory 或 cross-project notes 转成可复用 Waza guidance 时，只提升 workflow rules。移除 raw transcript text、screenshots、local paths、project-specific commands、issue 或 PR numbers、release tags、commit hashes、private product boundaries、paid 或 license details、support routing、user names 和 one-machine state。

如果必须给 example，使用中性 placeholders，例如 `ExampleCLI`、`ExampleApp`、`<issue>`、`<release>` 或 `<command>`。不要把 private answer、maintainer reply、screenshot observation 或 project-specific incident 复制成 durable rule。

## Memory type mapping

- `decision`、`preference` 和 `principle` 是当前任务的 constraints，具体可能是 planning、design、review、debugging、voice、audit expectations 等，取决于 skill。
- `pattern` 和 `learning` 是 reusable checks 或 hypotheses。
- `fact` 必须先对照 current state 验证，才能影响 output。

Current code、diff、screenshots、logs、tests、docs、CI、remote state 和 live probes 永远覆盖 memory。如果它们与 remembered claim 冲突，说明冲突并遵循 current state。

每个 skill 会在引用此 reference 后添加自己的 paragraph，说明 skill-specific overrides 和 constraints。
