# 不设 memory skill

[#61](https://github.com/tw93/Waza/issues/61) 请求：增加 `/remember` skill，把学到的东西保存到 memory 或文件。

决定：not planned。记忆是 agent platform 的职责。Claude Code 已经通过 `CLAUDE.md` 和 auto memory 持久化 durable context，Waza skills 在 Durable Context Preflight 中读取这些 context，而不是自己拥有 storage。今天把笔记放在 `CLAUDE.md` 或 agent 的 memory feature 中，结果相同。
