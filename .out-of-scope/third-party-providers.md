# 没有 gap 就不增加 search 或 fetch provider

[#92](https://github.com/tw93/Waza/issues/92) 提议：在 `/read` 中增加一个 third-party service，作为 DeepSeek 之外的另一层 search 和 fetch tier。

决定：not planned。`/read` 中每个 third-party tier 都是因为我本人需要才存在，每增加一个，就多一个会收到用户通过该 skill 发送的 URLs 和 queries 的服务。新 tier 必须填补当前 tiers 覆盖不了的 gap，并用一次真实 fetch 或 search 失败来证明。
