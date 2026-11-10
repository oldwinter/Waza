---
name: write
description: "Rewrites and polishes Chinese or English prose, technical instructions, and product copy. Use when drafting, editing, localizing, or cutting AI tone. Not for code comments or commit messages."
when_to_use: "改稿, 润色, 去AI味, 帮我写文案, 审稿, 文档review, 技术说明改写, 指令消歧, clarify instructions, technical writing, 本地化文案, 多语言文案, i18n copy, localization copy, check this document, 推特, twitter, X推文, tweet, social post, draft, edit text, proofread, sound natural, polish, rewrite"
dispatch_intent: "Writing, editing prose, clarify technical instructions, polish, release notes, launch/social copy, remove AI tone"
---

# Write: 去掉 AI 味

Prefix your first line with 🥷 inline, not as its own paragraph.

从 prose 中剥掉 AI patterns，重写到像人写的。不要“提升词汇”，要移除表演式提升。

## Outcome Contract

- Outcome:prose 保留作者 intent，同时对目标 audience 和 surface 听起来自然。
- Done when:除非用户要求改变，否则 meaning、factual claims 和 structure 得到保留，AI-like wording 被移除；输出语言的 punctuation 和 CJK/Latin mixing 通过 Punctuation Gate。
- Evidence:supplied text、target audience、project style references、release 或 product state，以及 requested language。
- Output:只输出 edited prose，除非用户要求 notes、variants 或 review comments。

## Core Stance

This skill 是一份 smell catalog，不是从上到下执行的 checklist。用它识别 AI taste，再做 judgment call。Reference files 都是 catalogs；不要试图把每条规则套到每篇文本上。套用更多规则不等于做得更好。

- **Over-editing is failure, equal to under-editing.** 如果一句话已经自然、清晰、稳定，就不要动。多数 polish 是 subtraction（删重复、summary-tone、重述结论），不是逐短语替换。输入是作者自己已完成的 draft 时，默认范围缩小到 typos、broken sentences 和明确的 AI tells：绝不按风格重写他们的句子，并返回逐句清单，列出每个被删除或改写的句子，让作者逐条否决。
- **A piece has a speaker.** 一段谁都可能写得出的流畅 prose，已经丢了东西。保留作者的口语词、cadence、知识和判断；作者有意的表达或 genre choice 优先于这些 defaults。作者的喜爱、挫败、自豪、感激和个人信念都是内容，即使抽象或写成结论。保留其强度；不要要求情绪提供外部证据，也不要换成中性观察。区分真实口语、情绪标记和刻意的系列 branding 与 AI corporate jargon、translationese：保护作者真实 voice（包括标志性的非正式用词或既有系列标题），移除合成的 PR buzzwords。读邻近段落和作者修订，区分真实 stance 和 stock rhetoric。拿不准时保留原句。不要发明情绪，也不要把 "what I did" 改成 "what you must do"。
- **Banned-phrase lists and replacement tables are examples, not find-and-replace.** 被 flag 的词在上下文中读起来自然，就保留。匹配 smell，不要匹配 string。有 source material 时，先核对再 flag 作者的措辞；恢复他们的原话，不要 paraphrase。恢复 copy 时，把该段落的 diffs 追到不想要的编辑之前最近的一版，精确比较恢复后的文本；不要选更旧、更短的版本，也不要重写无关段落。
- **Prefer fewer, stronger edits.** Three changes that matter beat thirty mechanical swaps that flatten the voice.

When distilling a new lesson into this skill, fold it into an existing principle instead of appending another banned phrase. This skill must not grow monotonically; collapsing specifics back into principles is part of maintaining it.

## Pre-flight

1. **Locate the text.** 先读用户点名的文件，或在提供的 repository 中找 posts，再决定是否请用户粘贴。处理 "latest N" 时，冻结带日期的 article set 及其语言 mirrors，然后逐篇记为 edited、unchanged with reason 或 unavailable。
2. **Audience locked?** 如果 intended audience 不清楚，且不能从 text 推断（blog reader vs RFC vs email），编辑前先问。Junior engineer 和 senior architect prose 读起来应完全不同。
3. **Language detected from the text being edited**，不要根据用户 command 判断：
   - 含中文字符 + release notes 或 social post mode：在 `references/write-zh.md` 之上加载 `references/write-zh-release-notes.md`
   - Bilingual 或 translation review：加载 `references/write-zh-bilingual.md`，以及两个版本各自的语言 reference
   - Product/site/app localization review（跨多个 locales）：加载 `references/write-product-localization.md`；出现中文 copy 时也加载 `references/write-zh-bilingual.md`
   - 含中文字符（默认 prose）：加载 `references/write-zh.md`
   - 其他情况：加载 `references/write-en.md`

读取 loaded reference file。然后编辑。除非明确要求，不要 summary、commentary 或 explanation of changes。

## Mode Picker

默认是对 supplied text 做 line-level rewrite。只有匹配某一行时才进入该 mode；只有该行指向 mode file 时才加载它。

| Ask | Mode |
|---|---|
| Release note、changelog entry、update-feed copy | 加载 `references/mode-release-notes.md` |
| 公开 issue 或 PR 上的 maintainer reply | 加载 `references/mode-public-reply.md` |
| 需要澄清的 installation steps、operating instructions、error text 或 tool descriptions；agent instructions 的纯措辞编辑 | 对这些段落加载 `references/write-technical.md`，与语言 reference 一起使用；prompt design 和 code behavior 不属于本 mode |
| 含多个 sections、tables 或 images，需要结构调整的 long draft | 加载 `references/mode-long-form.md` |
| 同一文本的 before/after 版本（diff、两份 draft、另一位编辑的 polish pass），以及 "is the new one better?" | 加载 `references/mode-revision-review.md` |
| EN/CN pair 或中英混合 copy，检查 drift | 加载 `references/write-zh-bilingual.md`，它负责 Punctuation Gate 不检查的判断 |
| 跨 locales 的 product、site 或 app copy（"本地化文案"、"多语言文案"、"localization copy"、"i18n copy"、runtime catalog、release feed copy） | 加载 `references/write-product-localization.md` 并遵循其 review procedure；中文是 locale 之一时，再加 `references/write-zh-bilingual.md` |
| 要 review 的 document、PDF 或 white paper | [Document Review](#document-review-mode) |
| 读起来不连贯的 paragraphs | [Paragraph Coherence](#paragraph-coherence-mode) |
| Tweet、thread 或 launch post | [Tweet / Social Post](#tweet--social-post-mode) |

## Durable Context Preflight

See [references/durable-context.md](references/durable-context.md) for when durable context is in scope and the redaction gate that applies before any of it becomes a durable rule.

对于 `/write`，supplied text 和 current release state override memory。Durable preferences 可以设定 brevity、tone 和 social-post shape，但不能 override edit in place、keep meaning intact、avoid change lists 这些 hard rules，除非用户明确要求，或输入是作者自己已完成的 draft。

## Hard Rules

- **Meaning first, style second.** 如果移除 AI pattern 会改变作者 intended meaning，保留原文。移除 promotion 不等于删除合法的 product descriptions、licensing information 或 related-product explanations。Broad copy cleanup 不授权改写有署名的 quotations 或 testimonials；除非明确纳入 edit scope，否则保留其措辞，并区分 paraphrase 和 verbatim quote。
- **No silent restructuring.** 除非明确要求 structural changes，不要 reorganize headings、reorder paragraphs 或 merge sections。Edit in place。Structural assets 不是 cleanup noise：除非用户要求删除，否则保留 image placeholders、links、frontmatter 和 example blocks；任何 deletion 都要列出原因，不能等用户在 diff 中才发现。（例外：`references/mode-long-form.md` 把 structural cuts 和 merges 视为 in-scope，因为 structure 才是核心问题；但它仍会先把它们作为 change-points 提出，而不是静默执行。）
- **No invented first-person experience.** 以作者身份 ghostwrite 时，每段 personal anecdote、tool history、opinion 和 quote 都必须来自 supplied material 或作者已经 published 的 writing；用来替换被 flag 短语的 color 也一样：用 subtraction 修复，不要新编 imagery。Material 缺少 example 是需要追问的问题，不是可以自行填补的空白。以作者 voice 起草而非编辑 supplied text 前，先读一两篇作者 published pieces，作为 voice 和 length baseline。
- **Material gate before drafting long-form.** 当请求是写作而非编辑时，先清点实际掌握的材料再决定长度：用户提供的经历、数字、quote、action 和可验证的公开来源。Category name 不是材料，换一种说法重述同一观点也不是第二份材料。目标读者本来就能预判的材料（常识、共识建议、该主题的标准论点）同样不算；如果没有任何 section 包含读者猜不到的内容，就向作者追问真正意外的部分，不要写出可预判的版本。Reasoning 只能连接材料，不能制造材料。若无法为每个计划 section 指出一份独立材料，说明计划长度超过 evidence。先调研、一轮最多询问三个问题，或交付更短的文章。目标字数不能成为用虚构 example 或第四种表述填充同一观点的理由。
- **Shorter than the first draft wants to be.** Outward copy（README paragraphs、tweets、release notes、maintainer replies）默认对齐用户以前 accepted pieces 的长度；存在 physical constraint（tweet fold line、single-line rendering）时，先从 constraint 推导 budget，再动笔，不要等用户删短。
- **Artifact-grounded claims.** 对 launch copy、release notes、social posts、product pages 和 public replies，factual claims 必须 grounded in real source material：current app behavior、runnable artifact、screenshot、product page、release page、changelog、issue/PR 或 user-provided draft。不要把 handoffs、plans、old memory 或 stale screenshots 当成 current product truth；也不要把 concrete product evidence 变成 generic marketing language。把 draft 与 shipping artifact 对照，收紧到两者一致。
- **No em-dash.** Chinese 或 English output 中绝不要产生 em-dash（U+2014 `—`）或 en-dash（U+2013 `–`）。Em-dash 是这种 writing style 中最强的 AI-tone fingerprint。用 commas、periods、colons、semicolons 或 parentheses 断开 clauses。compound words 内的 hyphen-minus（`-`）允许存在；可能时替换成 space 或 period。编辑包含 em-dashes 的 draft 时，返回 text 前替换每一个。
- **Route bundled work without dropping it.** Code comments 和 commit messages 不属于这个 prose skill。与写作一起被明确要求时，用对应 workflow 或 native capability 处理，并放进同一个 completion ledger；这个 skill 不授予额外的 write 或 publishing authority。
- **Match the requested handoff.** Pasted-text rewrites 不需要解释，作者自己已完成的 draft 除外，需给逐句 change list。Repository edits 需要 scoped diff 和 verification；在项目规则下完成明确授权的 commit/push 步骤。Prose-only output convention 不能掩盖未完成的 delivery。

## Punctuation Gate

Before returning any produced text (a rewrite, or generated release / reply / social copy), resolve the checker across install layouts and run it:

```bash
GATE=""
for candidate in \
  "<skill-base-dir>/scripts/check-punctuation.sh" \
  "<skill-base-dir>/skills/write/scripts/check-punctuation.sh"; do
  [ -f "$candidate" ] && GATE="$candidate" && break
done
[ -f "${GATE:-}" ] || { echo "punctuation gate not found under the installed skill base; reinstall Waza" >&2; exit 1; }
bash "$GATE" --lang <zh|en|ja|auto> <file>   # or pipe text via stdin
```

把 `<skill-base-dir>` 替换为已安装的 Write skill 或 Waza dispatcher 目录。第一个路径覆盖 direct/plugin installs，第二个覆盖 inlined-root release ZIP。

It enforces character-level punctuation by locale (half/full-width marks, CJK/Latin spacing, em/en dashes) and skips code, inline code, URLs, and markdown link targets, so it never fires on code; the script header documents the exact rule set. Fix every finding while preserving meaning; `--fix` rewrites only the zero-ambiguity zh cases to stdout. `--lang auto` classifies the whole input by fixed priority: any kana routes to ja, else any CJK to zh, else any Hangul to ko (reserved, skipped), else en, so a mostly-Chinese text that merely quotes a Korean glyph still routes to zh; pass an explicit `--lang` for mixed-locale or predominantly-English text. The checker owns character-level punctuation only; quote direction and other judgment calls stay with you and the reference files.

## Document Review Mode

Activate when: PDF, document, white paper, "review this document", "check this document", "审稿"

Review checklist:
- **Privacy scan**：flag 那些对目标 audience 未获授权披露的敏感信息。保留作者明确为本文提供或已经公开的身份与经历；仅凭求职、雇主名称和地点，不构成停止或删除内容的理由。披露与否不确定时，先解决再暴露。
- **Tone consistency**：flag voice shifts、register mismatches、formulaic phrasing。
- **Bilingual validation**：CN/EN pairs 用 `references/write-zh-bilingual.md` 确认翻译准确性和术语一致性。
- **Rendering check**: Placeholder text remaining (`Lorem ipsum`, `TODO`, `[TBD]`), broken image links.
- **Durable-doc scan**: If the document is a review report, scorecard, or diagnostic snapshot, flag dated claims, stale line references, private paths, repo-specific commands, and current-score framing. Recommend extracting stable rules instead of preserving the snapshot as evergreen guidance.

Output format：按用户要求的 review 或 rewrite 输出；只有仍存在可行动的披露顾虑时才提 privacy。

## Paragraph Coherence Mode

Activate when: "连贯性", "段落连贯", "可读性", "coherence", "flow check", "段落顺不顺"

检查没有 signal 的话题跳转、没有承接上一段结尾的开头，以及整段单调的句长。每个修复都取最小动作：一个词、一个调整顺序的 clause，或一句 bridging sentence。Review 请求返回带 paragraph 位置的编号列表；明确要求 rewrite 或 file edit 时，直接做获授权的最小编辑，不要再次询问。

## Tweet / Social Post Mode

Activate when: "推特", "twitter", "X推文", "tweet", "social post", "折叠长度", "长文推特", "发文"

加载 `references/write-zh-release-notes.md`，使用其中五条 announcement rules（community lead、highlights over completeness、UX framing、one stance、native rhythm）和 casual invitation close。English posts 或没有这种 community voice 的项目，用项目自己的 voice 保持同样结构。

## Gotchas

| What happened | Rule |
|---------------|------|
| Reorganized headings without being asked | Do not restructure; edit in place unless structure changes are explicitly requested |
| Appended a "changes made" list after the rewrite | Output is the edited text only. No changelog, no commentary. |
| Used formal register for a blog draft | Match the target audience's register. Blog is conversational, not academic. |
| Applied Chinese/English spacing rules to a pure-English text | Bilingual spacing rules (半角/全角) only apply when the text mixes Chinese and English |
| Polished the user's voice into generic launch copy | Preserve the author's cadence and stance. Use real product artifacts to sharpen facts, not to replace the voice. |
| Drafted release or social copy from memory or a handoff | Read the current release page, changelog, issue/PR, runnable artifact, product page, screenshot, or supplied source before making factual claims. |
| Wrote launch copy in one pass without checking the live screenshots | Iterate: draft, compare against the real product screenshot or page, tighten wording to match what ships, repeat until copy and artifact agree |
| Polished a review report until it sounded timeless | Keep snapshots labeled as snapshots, or distill them into stable rules. Do not make dated claims sound evergreen |
| 用户指出一个词 "not my voice"，只修了那一处 | 被指出的词代表一类 smell，不是一个 typo。返回前扫描全文中的同一类问题（相同 register、相同 template shape） |
| 为达到目标字数，从四个角度解释同样三个观点 | 先清点材料。调研、一次最多询问三个问题，或交付更短版本。Padding 不是长文，而是失败的 draft |
| 标记或改写了作者原本的措辞 | 有 source material 时，先 grep 再 flag 或修改；恢复原文，不要 paraphrase |
| 用新编的 imagery 修复 AI 味短语，作者又指出新增措辞 | 用 subtraction 修复：只保留材料中的事实，不新增 imagery |
| 一批 copy fix 通过了检查，却带出新缺陷：某行超出固定宽度槽位、某个边界丢了主语、某个名词有两种读法 | 重新 review fix diff 本身，先看整段重写或重译的 paragraphs。恢复的文本也会带着旧缺陷；要 flag 它们，不要静默再改一遍 |

## Output

只返回 edited prose。如果 text 被 truncated，或存在多个 possible versions，在 body 后用一句话说明。否则不要 wrapper、preamble 或 postscript。
