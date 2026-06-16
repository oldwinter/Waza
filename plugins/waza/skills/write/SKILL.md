---
name: write
description: "重写并 polish 中文或英文 prose，移除 AI-like wording，并 review product localization copy；为 drafts、docs、release notes、launch copy 和 social posts 保留 intent。Use when users ask 帮我写/改稿/润色/去AI味/写一段/审稿/本地化文案/tweet/rewrite/proofread 时使用。Not for code comments, commit messages, or inline docs."
when_to_use: "帮我写, 改稿, 润色, 去AI味, 写一段, 审稿, 文档review, 本地化文案, 多语言文案, i18n copy, localization copy, check this document, 推特, twitter, X推文, tweet, social post, 连贯性, 段落连贯, draft, edit text, proofread, sound natural, polish, rewrite"
dispatch_intent: "Writing, editing prose, polish, release notes, launch/social copy, remove AI tone"
---

# Write: 去掉 AI 味

Prefix your first line with 🥷 inline, not as its own paragraph.

**更新检查（非阻塞）。** 开始前运行 `bash ../../scripts/check-update.sh` 一次；如果输出一行，就转告用户，然后继续。它每天最多运行一次，只读取公开 version file，不发送任何数据，失败会静默跳过。

从 prose 中剥掉 AI patterns，重写到像人写的。不要“提升词汇”，要移除表演式提升。

## Outcome Contract

- Outcome:prose 保留作者 intent，同时对目标 audience 和 surface 听起来自然。
- Done when:除非用户要求改变，否则 meaning、factual claims 和 structure 得到保留，AI-like wording 被移除。
- Evidence:supplied text、target audience、project style references、release 或 product state，以及 requested language。
- Output:只输出 edited prose，除非用户要求 notes、variants 或 review comments。

## Core Stance

This skill is a catalog of smells, not a checklist to run top to bottom. Use it to recognize AI taste, then make judgment calls. The reference files (especially `write-zh.md`) are long because they accumulated examples over many sessions; do not try to apply every rule to every text. Applying more rules is not doing a better job.

- **Over-editing is failure, equal to under-editing.** If a sentence is already natural, clear, and stable, leave it. Most polish is subtraction (cut repetition, summary-tone, restated conclusions), not phrase-by-phrase replacement.
- **The author's voice wins.** Keep the author's existing colloquial words, cadence, and stance. When a rule conflicts with a deliberate authorial or genre choice (a question title in a narrative piece, a list the author wants kept), the author wins. Rules are defaults, not laws.
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

## Durable Context Preflight

See [rules/durable-context.md](../../rules/durable-context.md) for when to read durable context, the read-order budget, and the memory-type mapping.

对于 `/write`，voice 和 format constraints 是 `decision`、`preference` 和 `principle` entries；editing checks 是 `pattern` 和 `learning`。Supplied text, audience, project docs, current release state, and source material override memory。Durable preferences 可以设定 brevity、tone 和 social-post shape，但不能覆盖 edit in place、keep meaning intact、avoid change lists 这些 hard rules，除非用户明确要求。

## Hard Rules

- **Meaning first, style second.** 如果移除 AI pattern 会改变作者 intended meaning，保留原文。
- **No silent restructuring.** 除非明确要求 structural changes，不要 reorganize headings、reorder paragraphs 或 merge sections。Edit in place。（例外：Long-form Article Mode 把 structural cuts 和 merges 视为 in-scope，因为 structure 才是核心问题；但它仍会先把它们作为 change-points 提出，而不是静默执行。）
- **Artifact-grounded claims.** 对 launch copy、release notes、social posts、product pages 和 public replies，factual claims 必须 grounded in real source material：current app behavior、runnable artifact、screenshot、product page、release page、changelog、issue/PR 或 user-provided draft。不要把 handoffs、plans、old memory 或 stale screenshots 当成 current product truth；也不要把 concrete product evidence 变成 generic marketing language。
- **No em-dash.** Chinese 或 English output 中绝不要产生 em-dash（U+2014 `—`）或 en-dash（U+2013 `–`）。Em-dash 是这种 writing style 中最强的 AI-tone fingerprint。用 commas、periods、colons、semicolons 或 parentheses 断开 clauses。compound words 内的 hyphen-minus（`-`）允许存在；可能时替换成 space 或 period。编辑包含 em-dashes 的 draft 时，返回 text 前替换每一个。
- **Stop after output.** 交付 rewritten text。不要追加 changes list、justification 或 closer。（例外：Long-form Article Mode 返回 change-points 供 review，而不是 rewritten blob；见该 mode。）

## Long-form Article Mode

触发时机：编辑超过约 300 行的 Markdown article 或 file，或包含多个 `##` sections 加 tables 和 images 的文件（technical long-reads、blog posts、deep dives）。

长文里，主要问题通常是 structure：同一 checklist 跨 sections 重复、prose 复读刚刚出现的 table、list bloat、整段或整节冗余。Sentence-level AI taste 只是较小的一半。单次 in-place polish 看不到也修不好 structural half，所以普通 `/write` 跑在长文上会像是改了措辞，却保留了臃肿结构。因此这个 mode override 两条 Hard Rules：structural cuts 和 merges 是 in-scope，output 是供 review 的 change-points，而不是 rewritten blob。

Workflow:

1. **Map first, read-only.** 编辑任何内容前，读完整篇文章，列出每个 `##` section、table、list 和 image。标记三类 structural problems：cross-section repetition（同一 checklist / judgment list / core claim 出现在 2+ sections）、table re-reading（某节 prose 逐行复读上方 table）、整节或整段冗余。
2. **把 cuts 作为 change-points 提出。** 对每个 structural cut 或 merge 展示 before to after，让用户选择 subset。绝不静默删除整节或整段；先确认，因为里面可能有别处没有的 fact（见 `references/write-zh.md` 删段之前先确认信息量）。
3. **再做 line-level de-AI**，按 section 依据 `references/write-zh.md` 处理。
4. **Output 是 change-points，不是 blob。** 展示改了什么，方便用户 review 并保留自己的 hand-edits。只有用户说 直接改 / just rewrite 时，才返回完整 rewritten text。

不要 single-pass rewrite 一篇 40k-character article：它会静默覆盖作者手调的 phrasing，也无法作为 diff review。匹配的 content rules 见 `references/write-zh.md` 结构级重复与表格复读（长文专项）。

## Bilingual Review Mode

当出现这些触发时激活：mixed Chinese/English、"Chinese copywriting"、"bilingual consistency"、"release notes"

**Chinese rules**（来自 https://github.com/mzlogin/chinese-copywriting-guidelines）：
- 中文和英文字符之间加 space（CN文字EN -> CN 文字 EN）
- 不混用 punctuation（中文使用 、。？！；：，不用 commas/periods）
- 所有 instances 的 terminology 保持一致

**English in Chinese documents**: 标记 unexplained English，建议 translation 或补充 context。

**Bilingual pairs**: 确认 EN 和 CN versions 传达相同 meaning；标记 translation loss。

## Product Localization Review Mode

触发时机："本地化文案"、"多语言文案"、"localization copy"、"i18n copy"、product/site/app strings、release feed copy、runtime catalog，或用户询问 localized copy 是否 native。

加载 `references/write-product-localization.md`。如果 Chinese 是 locales 之一，也加载 `references/write-zh-bilingual.md`。

默认 workflow：

1. 先拆分 surfaces：release feed、website pages、docs/help、runtime strings、legal/privacy copy 和 generated pages 可能有不同的 locale coverage 和 source files。
2. 保留 factual structure：versions、dates、links、item order、placeholders 和 product behavior 固定不变，除非用户要求修改。
3. 按 locale artifacts review，不只按 English meaning review。Missing accents、ASCII fallbacks、literal possessives、stale locale paths，以及机械 plural 或 apostrophe errors 都是一等问题。
4. 大范围 cleanup 后，再做一轮 replacement damage 检查。generated output 检查前，不要信任 accent sweeps 或 glossary replacements。
5. 用户要求 implement 时，patch source localization files 并 rebuild generated pages。只要求 review 时，按 surface 和 severity 分组返回 findings。

## Release Note Template Mode

触发时机："release"、"changelog"、"version"、"release notes"

从 commit messages 生成：
- **Breaking Changes**
- **New Features**
- **Fixes & Improvements**
- **Deprecations**

Format：默认使用 target-project style。如果没有 project style，使用带 bold labels 的 numbered items，用一句话说明 user effect；只有 project 已使用 bilingual release notes 时才输出 bilingual。

### Release Notes Pre-flight

drafting 前，收集 style references：

1. Read the target project's `CLAUDE.md` for its Release Convention / Release Flow section.
2. Read the target project's existing release source as a style, length, and density reference: changelog, release notes, registry page, appcast, or platform release page.
3. For GitHub projects, `gh release view --json body -R <owner>/<repo>` is the preferred way to read the most recent release when `gh` is available. If the project is not on GitHub, use the release source named by the project docs or user request.
4. If the user mentions comparing with a sibling project's release style, ask for the target identifier or release URL before fetching it.
5. Match the reference release's item count, sentence length, and tone. Do not invent a new format.
6. Keep each release-note item to one sentence unless the reference project clearly does otherwise. Do not add emoji to release prose unless the target surface is explicitly a reaction or celebratory social surface.

### Release Notes Content Rules

- **Group by user-perceivable feature**, not by internal taxonomy. "Polish", "细节打磨", "Misc improvements", "Chores" are not categories users can act on. Group by product surface (Clean / Uninstall / Status / Settings) or by user-visible verb (Faster startup / New keyboard shortcut / Fixed crash on M3).
- **Extract from `git log <last-tag>..HEAD`** rather than from memory. Read every `feat:` and `fix:` commit; do not omit small items just because they look minor in commit form (iOS wrapper support, Dock cleanup, AV-vendor protection boundary are not "minor" from a user point of view).
- **One sentence per item, naming the user-visible change**, not the implementation. "Use `CKDownloadQueue` observer for App Store updates" is not a release note; "App Store updates now run inside the app instead of opening App Store" is.
- **Bilingual structure**: when the project ships bilingual release notes, put the English block and the Chinese block as two parallel sections inside the same release item; do not interleave per bullet. For Sparkle appcast CDATA, separate with `<h4>Changelog</h4>` and `<h4>更新日志</h4>` so the rendered update window shows both.
- **No em-dash** in release prose (covered by the Hard Rule). Use Chinese full-width punctuation in Chinese blocks, ASCII in English blocks.

## Public Reply Mode (GitHub issue / PR)

Activate when: "回复 issue", "reply to PR", "comment on #N", "回 issue", or the user asks for the text of a GitHub issue / PR comment.

reply body 的五条 hard rules：

1. **Open with `@<reporter>` + one thanks line.** Match the reporter's language (Chinese → "感谢反馈" / English → "thanks for the detailed report"). No exclamation mark. No emoji. No "🙏".
2. **Then state the cause in one sentence, the impact in one sentence.** No multi-paragraph background, no internal symbol names, no walk-through of the fix.
3. **Then state the ship state**, exactly one of: already shipped in v<X.Y.Z>, fixed on `main` and going out in the next release, planned for v<X.Y.Z>, not planned (with one-line reason and an alternative path). Do not write "already shipped" without release evidence in the current turn.
4. **Two paragraphs maximum**, separated by one blank line. No bullet lists, no section headers, no code blocks except a one-line command when actually needed.
5. **No em-dash.** Use commas, periods, colons. (Covered by the Hard Rule, surfaced again because issue replies attract this pattern.)

The reply is the final user-facing text, not an agent log. Do not write "刚才我判断错了", "前面回复有误", "I re-read it and changed the comment", or any meta narration about your own process. If editing an existing maintainer comment, replace it with the clean final wording as if it were the only comment the user will read.

Before posting, re-read the live issue / PR with `gh issue view <num>` or `gh pr view <num>`. Do not reply from memory; titles, states, and author languages change between sessions.

对 paid / subscribed users，用一个 phrase 承认 purchase relationship 和 inconvenience，然后 state the boundary。不要 over-explain。当 current product 无法支持其 setup 时，建议 safest practical path（upgrade macOS、wait for the next release、provide logs、refund route），不要争辩。

Closing rule: when closing as `completed`, the comment must independently explain what was fixed and the expected release. When closing as `not planned`, the comment must independently explain the current boundary and an alternative path. Do not rely on prior thread context as the explanation.

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

## Output

只返回 edited prose。如果 text 被 truncated，或存在多个 possible versions，在 body 后用一句话说明。否则不要 wrapper、preamble 或 postscript。
