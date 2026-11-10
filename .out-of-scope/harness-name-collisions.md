# Built-in command 保留原名

[#69](https://github.com/tw93/Waza/issues/69) 报告：`design` skill 遮蔽了 Claude Code 内置的 `/design`（Claude Design），而内置命令没有带 namespace 的 fallback。

决定：host 的 built-in command 与 Waza skill 共用短名时，Waza 让出该名字并重命名自己的 skill。`design` 在 v3.30.0 改为 `/ui`。自然语言请求仍会路由到改名后的 skill。

这不会重新打开 [skill-name-prefix.md](skill-name-prefix.md)：fix 是在真实冲突处做一次重命名，不是给每个 skill 加前缀。
