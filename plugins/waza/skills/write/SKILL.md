---
name: write
description: "Rewrite and polish Chinese or English prose, remove AI-like wording, and review product localization copy while preserving intent for drafts, docs, release notes, launch copy, and social posts. Use when users ask in any language to draft, rewrite, proofread, localize, polish release notes, remove AI-like wording, or prepare launch/social copy. Not for code comments, commit messages, or inline docs."
when_to_use: "帮我写, 改稿, 润色, 去AI味, 写一段, 审稿, 文档review, 本地化文案, 多语言文案, i18n copy, localization copy, check this document, 推特, twitter, X推文, tweet, social post, 连贯性, 段落连贯, draft, edit text, proofread, sound natural, polish, rewrite"
dispatch_intent: "Writing, editing prose, polish, release notes, launch/social copy, remove AI tone"
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

This skill is a catalog of smells, not a checklist to run top to bottom. Use it to recognize AI taste, then make judgment calls. The reference files (especially `write-zh.md`) are long because they accumulated examples over many sessions; do not try to apply every rule to every text. Applying more rules is not doing a better job.

- **Over-editing is failure, equal to under-editing.** If a sentence is already natural, clear, and stable, leave it. Most polish is subtraction (cut repetition, summary-tone, restated conclusions), not phrase-by-phrase replacement.
- **一篇文章必须听得出是谁在说话。** 读者要判断的不是“有没有 banned words”，而是“能不能听出说话的人”。一段 prose 即使流畅，只要谁都可能写得出来，就已经失败；无法归属的流畅不是中性结果，而是 defect。让 speaker 清晰可辨，需要写出这个人知道的事、愿意维护的判断和明确不喜欢的东西。因此 author voice 优先：保留作者已有的口语词、cadence 和 stance；rule 与作者有意的表达或 genre choice 冲突时，例如叙事文章里的问句标题、作者要求保留的 list，以作者为准。Rules 是 defaults，不是 laws。只保留这个作者才会写的句子，删掉谁都能写的句子。
- **Banned-phrase lists and replacement tables are examples, not find-and-replace.** A flagged word that reads naturally in context stays. Match the smell, not the string.
- **Prefer fewer, stronger edits.** Three changes that matter beat thirty mechanical swaps that flatten the voice.

When distilling a new lesson into this skill, fold it into an existing principle instead of appending another banned phrase. This skill must not grow monotonically; collapsing specifics back into principles is part of maintaining it.

## Pre-flight

1. **Text present?** 如果用户只给 instruction，没有给 actual prose to edit，用一句话请用户提供 text。不要继续。
2. **Audience locked?** 如果 intended audience 不清楚，且不能从 text 推断（blog reader vs RFC vs email），编辑前先问。Junior engineer 和 senior architect prose 读起来应完全不同。
3. **Language detected from the text being edited**，不要根据用户 command 判断：
   - Contains Chinese characters + release notes or social post mode → load `references/write-zh-release-notes.md`
   - Contains Chinese characters + bilingual or translation review → load `references/write-zh-bilingual.md`
   - Product/site/app localization review across multiple locales → load `references/write-product-localization.md`; also load `references/write-zh-bilingual.md` when Chinese copy is present
   - Contains Chinese characters (default prose) → load `references/write-zh-prose.md` (quick rules); load `references/write-zh.md` for the full AI-taste pattern catalog
   - Otherwise → load `references/write-en.md`

读取 loaded reference file。然后编辑。除非明确要求，不要 summary、commentary 或 explanation of changes。

## Mode Picker

按交付物选择 mode；只加载匹配的 reference，其余请求继续使用本文件已有 section。

| User intent | Mode |
|---|---|
| release note、changelog、update-feed copy | 加载 `references/mode-release-notes.md` |
| 公开 issue / PR 的 maintainer reply | 加载 `references/mode-public-reply.md` |
| 约一万字以上、需要结构调整的 long draft | 加载 `references/mode-long-form.md` |
| bilingual review、localization、document review、paragraph、social post | 使用下方已有对应 section |

## Durable Context Preflight

See [references/durable-context.md](references/durable-context.md) for when durable context is in scope and the redaction gate that applies before any of it becomes a durable rule.

对于 `/write`，voice 和 format constraints 是 `decision`、`preference` 和 `principle` entries；editing checks 是 `pattern` 和 `learning`。Supplied text, audience, project docs, current release state, and source material override memory。Durable preferences 可以设定 brevity、tone 和 social-post shape，但不能覆盖 edit in place、keep meaning intact、avoid change lists 这些 hard rules，除非用户明确要求。

## Hard Rules

- **Meaning first, style second.** 如果移除 AI pattern 会改变作者 intended meaning，保留原文。
- **No silent restructuring.** 除非明确要求 structural changes，不要 reorganize headings、reorder paragraphs 或 merge sections。Edit in place。Structural assets 不是 cleanup noise：除非用户要求删除，否则保留 image placeholders、links、frontmatter 和 example blocks；任何 deletion 都要列出原因，不能等用户在 diff 中才发现。（例外：`references/mode-long-form.md` 把 structural cuts 和 merges 视为 in-scope，因为 structure 才是核心问题；但它仍会先把它们作为 change-points 提出，而不是静默执行。）
- **No invented first-person experience.** 以作者身份 ghostwrite 时，每段 personal anecdote、tool history、opinion 和 quote 都必须来自 supplied material 或作者已经 published 的 writing。Material 缺少 example 是需要追问的问题，不是可以自行填补的空白。以作者 voice 起草而非编辑 supplied text 前，先读一两篇作者 published pieces，作为 voice 和 length baseline。
- **Material gate before drafting long-form.** 当请求是写作而非编辑时，先清点实际掌握的材料再决定长度：用户提供的经历、数字、quote、action 和可验证的公开来源。Category name 不是材料，换一种说法重述同一观点也不是第二份材料。Reasoning 只能连接材料，不能制造材料。若无法为每个计划 section 指出一份独立材料，说明计划长度超过 evidence。先调研、一次最多询问三个问题，或交付更短的文章。目标字数不能成为用虚构 example 或第四种表述填充同一观点的理由。
- **Shorter than the first draft wants to be.** Outward copy（README paragraphs、tweets、release notes、maintainer replies）默认对齐用户以前 accepted pieces 的长度；存在 physical constraint（tweet fold line、single-line rendering）时，先从 constraint 推导 budget，再动笔，不要等用户删短。
- **Artifact-grounded claims.** 对 launch copy、release notes、social posts、product pages 和 public replies，factual claims 必须 grounded in real source material：current app behavior、runnable artifact、screenshot、product page、release page、changelog、issue/PR 或 user-provided draft。不要把 handoffs、plans、old memory 或 stale screenshots 当成 current product truth；也不要把 concrete product evidence 变成 generic marketing language。
- **No em-dash.** Chinese 或 English output 中绝不要产生 em-dash（U+2014 `—`）或 en-dash（U+2013 `–`）。Em-dash 是这种 writing style 中最强的 AI-tone fingerprint。用 commas、periods、colons、semicolons 或 parentheses 断开 clauses。compound words 内的 hyphen-minus（`-`）允许存在；可能时替换成 space 或 period。编辑包含 em-dashes 的 draft 时，返回 text 前替换每一个。
- **Stop after output.** 交付 rewritten text。不要追加 changes list、justification 或 closer。（例外：`references/mode-long-form.md` 返回 change-points 供 review，而不是 rewritten blob。）

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

## Bilingual Review Mode

当出现这些触发时激活：mixed Chinese/English、"Chinese copywriting"、"bilingual consistency"、"release notes"

加载 `references/write-zh-bilingual.md`。Character-level spacing 和 punctuation 属于 Punctuation Gate script；本 mode 负责 judgment：所有实例中的 terminology consistency、中文文档里未翻译且无解释的 English，以及 EN/CN pairs 的 meaning drift（标记 translation loss，不要静默重写其中一边）。

## Product Localization Review Mode

触发时机："本地化文案"、"多语言文案"、"localization copy"、"i18n copy"、product/site/app strings、release feed copy、runtime catalog，或用户询问 localized copy 是否 native。

加载 `references/write-product-localization.md`。如果 Chinese 是 locales 之一，也加载 `references/write-zh-bilingual.md`。

默认 workflow：

1. 先拆分 surfaces：release feed、website pages、docs/help、runtime strings、legal/privacy copy 和 generated pages 可能有不同的 locale coverage 和 source files。
2. 保留 factual structure：versions、dates、links、item order、placeholders 和 product behavior 固定不变，除非用户要求修改。
3. 按 locale artifacts review，不只按 English meaning review。Missing accents、ASCII fallbacks、literal possessives、stale locale paths，以及机械 plural 或 apostrophe errors 都是一等问题。
4. 大范围 cleanup 后，再做一轮 replacement damage 检查。generated output 检查前，不要信任 accent sweeps 或 glossary replacements。
5. 用户要求 implement 时，patch source localization files 并 rebuild generated pages。只要求 review 时，按 surface 和 severity 分组返回 findings。

## Document Review Mode

Activate when: PDF, document, white paper, "review this document", "check this document", "审稿"

Review checklist:
- **Privacy scan**: Detect PII (names, companies, employment dates, salary hints, location details). Hard stop if any text implies job seeking, competitor info, or personal data leakage.
- **Tone consistency**: Flag voice shifts, register mismatches, formulaic phrasing. Check for AI patterns using the loaded `write-zh.md` or `write-en.md` rules.
- **Bilingual validation**: For CN/EN pairs, confirm translation accuracy and terminology consistency. Apply Bilingual Review Mode rules.
- **Rendering check**: Placeholder text remaining (`Lorem ipsum`, `TODO`, `[TBD]`), broken image links.
- **Durable-doc scan**: If the document is a review report, scorecard, or diagnostic snapshot, flag dated claims, stale line references, private paths, repo-specific commands, and current-score framing. Recommend extracting stable rules instead of preserving the snapshot as evergreen guidance.

Output format: same as prose rewrite, but append `privacy: clear / N issues found` after the reviewed text.

## Paragraph Coherence Mode

Activate when: "连贯性", "段落连贯", "可读性", "coherence", "flow check", "段落顺不顺"

不要 rewrite。改为按顺序处理每个 paragraph：
1. Flag transitions that abruptly shift topic without a signal.
2. Flag paragraphs where the opening sentence does not follow from the previous paragraph's close.
3. Flag rhythm issues: monotone sentence length (all short or all long across a whole paragraph).
4. Suggest the minimal fix for each: one word, one reordered clause, one bridging sentence.

Output：numbered list of issues，每项带 paragraph location 和 one-line fix suggestion。然后询问用户是否要 apply。

## Tweet / Social Post Mode

Activate when: "推特", "twitter", "X推文", "tweet", "social post", "折叠长度", "长文推特", "发文"

当 project context 或 prior artifact 显示这种 style 时，对 product-engineer projects 应用五条 announcement rules：
1. **Lead with community**: open with the social anchor (star count, user thanks, whose feedback drove the fix). Changes follow, not lead.
2. **Highlights over completeness**: pick 2 to 4 of the most interesting changes. Dropping whole items is fine.
3. **UX framing**: phrase each point as "你用它的时候..." or "有一种...的感觉", not "这个工具做了...".
4. **One stance**: include at least one opinionated sentence revealing why decisions were made.
5. **Native Chinese rhythm**: use idiomatic phrasing. Avoid translation-sounding terms.

Close casually with an invitation, not a CTA. End with one short sentence inviting readers to try, not "立即升级".

对其他 engineering projects 或 English posts，应用同样结构（community lead、highlights、UX framing、one stance、casual close），并适配 project voice。

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

## Output

只返回 edited prose。如果 text 被 truncated，或存在多个 possible versions，在 body 后用一句话说明。否则不要 wrapper、preamble 或 postscript。
