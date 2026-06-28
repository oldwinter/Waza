---
name: learn
description: "Run a six-phase research workflow that turns unfamiliar domains, source bundles, or collected material into publish-ready output. Use when users ask in any language to research, study, deep-dive, compile sources, synthesize unfamiliar material, or turn source bundles into coherent references. Not for quick lookups or single-file reads."
when_to_use: "学习一下, 深入研究, 研究一下, 整理成文章, 把这批材料整理, 一站式参考, 一篇就够, 整理成长文, research, deep dive, help me understand, compile sources, unfamiliar domain"
dispatch_intent: "Deep research, unfamiliar domain, compile sources into output"
---

# Learn: 从原始材料到可发布产出

Prefix your first line with 🥷 inline, not as its own paragraph.

**更新检查（非阻塞）。** 开始前运行 `bash scripts/check-update.sh` 一次；如果输出一行，就转告用户，然后继续。它每天最多运行一次，只读取公开 version file，不发送任何数据，失败会静默跳过。

收集、组织、翻译、解释、结构化。支持用户思考，不替代用户思考。

## Outcome Contract

- Outcome:unfamiliar material 变成用户可用的 reliable mental model、reference、article 或 notes set。
- Done when:primary sources 已收集或由用户提供，contradictions 被明确处理，final structure 能教清 topic 且不隐藏 uncertainty。
- Evidence:source URLs 或 files、fetched content、digestion notes、outline decisions，以及针对 requested output 的 self-review。
- Output:research notes、outline、publish-ready draft 或 canonical reference，与 chosen mode 匹配。

**Boundary**: 只需要 fetch 的 single URL 属于 `/read`。需要 summary 或 analysis 的 single URL 可以把 `/read` 作为 fetch step，但 final answer 应满足用户要求的 summary 或 analysis。`/learn` 用于 multi-source research，并产出新的 structured output。

## Pre-check

检查 `/read` 和 `/write` skills 是否已安装（在 skills directories 中查找它们的 SKILL.md）。缺失时 warning，但不 block：
- `/read` missing -- Phase 1 fetch fallback 到 native `WebFetch` / `curl`；paywalled、JS-heavy 和 Chinese-platform pages 的 coverage 会下降。
- `/write` missing -- Phase 5 AI-pattern stripping fallback 到 manual scan。Phases 1-4 不受影响。

## Choose Mode

请用户确认 mode；如果环境有 native question 或 approval mechanism，使用它：

| Mode | Goal | Entry | Exit |
|------|------|-------|------|
| **Deep Research** | 充分理解一个 domain，达到能写作的程度 | Phase 1 | Phase 6: publish-ready draft |
| **Quick Reference** | 快速建立 working mental model，不计划写文章 | Phase 2 | Phase 2: notes only |
| **Write to Learn** | 已有 materials，通过写作强迫理解 | Phase 3 | Phase 6: publish-ready draft |
| **Canonical Article** | 一篇文章彻底覆盖 topic，让读者不需要其他资料 | Phase 1 | Phase 6: single authoritative reference |

如果不确定，建议 Quick Reference。

## Canonical Article Mode

当出现这些触发时激活："一篇就够"、"一站式参考"、"整理成长文"、"目的是大家只需要看这篇就好了"，或用户想要某个 topic 的 single authoritative reference。

Goal：读完文章后，没有人需要再搜索这个 topic 的其他内容。

在 standard Deep Research 之上的 additional requirements：
- 每个 major sub-topic 必须有自己的 section；不要把内容留成 footnote
- 包含 worked examples，不只是 principles
- 覆盖 common mistakes 以及如何避免
- 添加 "Further Reading" section，列 3-5 个最深入 sources，并标记哪些是 best starting points
- Phase 6 self-review must confirm: "Could a reader implement/understand this from this article alone?"

## Phase 1: Collect

只收集 primary sources：提出 key ideas 的 papers、official lab/product blogs、builders 写的 posts、canonical "build it from scratch" repositories。不要 summaries，不要 explainers。

每个 source 三个有序 steps，不 shortcut，不 merge：

1. **Discover** -- 使用已安装的 search plugin（例如 PipeLLM）map landscape，然后 deep-search 最有希望的 2-3 个 sub-topics。没有 plugin 时，使用 environment 的 native web search。Output 是 URL list；此处不要 fetch content。
2. **Fetch** -- 可用时，每个 URL 都通过 `/read`。`/read` 负责 proxy cascade、paywall detection 和 platform routing（WeChat、Feishu、PDF、GitHub）。Native fetch tools 和 raw `curl` 在 JS-heavy 或 paywalled sites 上会静默失败，并跳过这些机制。如果 `/read` 缺失（Pre-check 已 warning），fallback 到 native fetch，并接受 reduced coverage。
3. **File** -- research project 有 source directory 时，把它告诉 `/read`。如果没有指定 directory，让 `/read` 使用 per-session temp directory 并返回 saved path。fetch 返回后，把 saved files move 或 index 到 sub-topic directories。Move，不要 refetch。

Target：blog post 5-10 个 sources，deep technical survey 15-20 个 sources。

## Phase 2: Digest

逐份处理 materials。每一份：完整阅读，保留好的，剪掉不好的。本 phase 结束时，大约砍掉已收集内容的一半。

把 key claims 放入 outline 前，先问：
- Does this idea appear in at least two different contexts from the same source?
- Can this framework predict what the source would say about a new problem?
- Is this specific to this source, or would any expert in the field say the same thing?

Generic wisdom 不值得 distill。通过两到三项：属于 outline。通过一项：background material。零项：cut it。

当两个 sources 在 factual claim 上冲突，记录双方 positions 和各自 evidence。不要静默选择一个。

### Conversation Or Review Distillation

当 input 是 recent conversation、project review、scorecard 或 diagnostic report 时，把它当作 raw material：

- 优先使用 already-distilled summaries、memory entries 和 review outputs；只有为了 verify disputed detail 或恢复 repeated pattern 的 exact source，才打开 raw transcripts。
- 编辑 durable guidance 前，先构建 candidate matrix：source/project、repeated failure、transferable rule、target layer、evidence count 和 redaction risk。只提升具有 cross-source support，或在同一 project family 中 repeated failure 的 candidates。
- 提取 repeated workflow failures、invariants 和 verifier surfaces。
- 丢弃 dated line numbers、current-score framing、private paths、one-machine setup 和 repo-specific commands，除非 output 明确用于同一个 repo。
- 把每条 durable lesson 映射到 target layer：project docs、shared rules、skill references 或 deterministic scripts。
- adaptive workflow guidance 优先使用 references 或 existing skill sections；scripts 只用于能在没有 project-specific context 时可靠 fail 的 deterministic checks。
- evidence snippets 只作为自己的 notes；不要把 raw conversation history 粘进 final artifact。

## Phase 3: Outline

为文章写 outline。对每个 section：注明它 draws from 哪些 source materials。如果 section 没有 sources，要么它不该存在，要么需要先找 source。

outline solid 前不要开始 Phase 4。

## Phase 4: Fill In

逐个 section 推进 outline。如果某个 section 难写，说明这里的 mental model 仍然薄弱：回到该 sub-topic 的 Phase 2。outline 可以变化，这没问题。

Stall signals（任一项都表示该 section 的 mental model 不完整）：
- opening sentence 已重写三次或更多，仍无法定稿
- section 依赖 single source，且你无法 cross-check claim
- 需要 Phase 1 没有 collected 的 new source
- paragraph 提出的 claim 你无法对别人当场解释清楚

stalled 时：回到该 sub-topic 的 Phase 2，不是整篇文章。

## Phase 5: Refine

用 specific brief 处理 draft：
- 在不改变 meaning 或 voice 的前提下，移除 redundant 和 verbose passages
- 标出 argument 不顺的地方
- 识别 gaps：先使用后解释的 concepts、需要 sources 的 claims

不要 summarize 用户尚未写出的 sections。不要从零 draft new sections。只做 edits。

Then strip AI patterns from the draft. If `/write` is installed, invoke it. If not, do it manually: scan for filler phrases, binary contrasts, dramatic fragmentation, and overused adverbs. Cut them without changing meaning.

## Phase 6: Self-review and Publish Readiness

发布前，用户要线性读完整篇文章。不要用 AI 读。标出所有感觉不对的地方，修掉，再读。至少两遍。

当它从头到尾读起来 clean，draft 就 ready for the user to publish。

**用户确认 article ready to publish 后，停止。** 除非明确要求，不要 upload、post、distribute 或执行任何 publish action。

## Gotchas

| What happened | Rule |
|---------------|------|
| Collected 30 secondary explainers instead of primary sources | Phase 1 targets papers, official blogs, and repos by builders. Summaries are not sources. |
| Used native fetch tools or `curl` on URLs while `/read` was installed | Phase 1 fetch is not optional. `/read` owns the proxy cascade, paywall detection, and platform routing. Bypassing it silently loses coverage on paywalled, JS-heavy, or Chinese-platform pages. |
| Treated a convincing explainer as ground truth | Ask: does this appear in at least two different contexts from the same source? |
| Phase 2 wrote summaries instead of teaching the concept | Digest means building the mental model. Summarizing is not digesting. |
| AI offered to upload the article to a blog or social platform after the user said it was ready | Stop at confirmation. Publishing is the user's action, not yours. |
| Turned a project review into a generic Waza rule without filtering | Promote only repeated workflow behavior. Leave project-specific commands, paths, and safety constraints in that project |
