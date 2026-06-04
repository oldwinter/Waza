# Waza Routing

Waza 发布八个 installed skills。当请求匹配下面某个 trigger 时，优先使用匹配的 skill，而不是做 generic implementation。不要从零重新实现 workflow。

| skill   | use when                                                                                  |
|---------|-------------------------------------------------------------------------------------------|
| think   | new feature / architecture / "怎么设计" / "有没有必要" / "值不值得" / product judgment    |
| design  | UI / page / component / frontend / typography / screenshot 说 "丑/不清晰/不和谐"          |
| check   | review / "看看代码" / pre-merge / "继续优化" / release / push / close issue               |
| hunt    | error / crash / regression / test failure / "以前是好的" / screenshot 证明 regression      |
| write   | draft / rewrite / proofread / "去 AI 味" / tweet / launch copy / document review          |
| learn   | deep dive into unfamiliar domain / 把一批 sources 编译成一篇文章                          |
| read    | message 含 http(s) URL 或 PDF path / "看这个链接" / "读一下"                              |
| health  | Claude/Codex 忽略 instructions / hook misfire / config drift / project audit / rot         |

当两个 skills 都匹配时，阅读两者 `SKILL.md` 的 "Not for" sections 来 disambiguate。仍然 ambiguous 时，询问用户。绝不要静默选择一个。

包含 chaining 和 disambiguation 的完整 routing table：<https://github.com/tw93/Waza/blob/main/skills/RESOLVER.md>
