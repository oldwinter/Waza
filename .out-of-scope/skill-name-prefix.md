# 不给每个 skill 加 `waza-` 前缀

[#59](https://github.com/tw93/Waza/issues/59) 请求：把每个 skill 改名为 `waza-check`、`waza-think` 等，避免与其他已安装 skills 重名。

决定：not planned。`/check` 和 `/think` 每天要输入很多次，前缀会给每一次输入增加打字和视觉噪音，换来的 brand benefit 远小于成本。其他已安装 skill 与 Waza skill 重复时，删掉重复项，保持精简的 skill list。Plugin installs 已经用 `/waza:check` 给 skills 加了 namespace。

与 built-in command 的真实冲突是另一种情况，见 [harness-name-collisions.md](harness-name-collisions.md)。
