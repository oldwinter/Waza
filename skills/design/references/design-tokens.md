# Design Tokens: Color and Typography

Motion rules 位于 [design-reference.md](./design-reference.md) 的 Animation 和 Motion Specifics 中。本文件只负责 color 和 typography。

## Color System: OKLCH Rules

- 使用 OKLCH，不用 HSL。OKLCH 是 perceptually uniform：相同数值变化会在光谱各处产生相同的感知变化。
- 随 lightness 接近极端值而降低 chroma。85% lightness 时，chroma 约 0.08 已足够；推到 0.15 会显得刺眼。
- 用 0.005 到 0.01 的 chroma 把 neutrals 轻微 tint 到 brand hue。
- 60-30-10 指 visual weight，不是 pixel count：60% neutral/surface，30% secondary text 和 borders，10% accent。
- 绝不要在 colored background 上使用 gray text。改用 background hue 的较低 lightness shade。

## Theme Matrix

| Context | Direction | Reason |
|---|---|---|
| Trading or analytics dashboard, night-shift use | Dark | 高数据密度；长时间使用时减少眩光 |
| Children's reading or learning app | Light | 友好、低疲劳 |
| Enterprise SRE or observability tool | Dark | Operator context；dark surfaces 在低光环境中更易一眼扫读 |
| Weekend planning, recipes, journaling | Light | 白天 ambient use；light 感觉更随意 |
| Music player or media browser | Dark | Content-forward；dark surfaces 后退，让 media 更突出 |
| Hospital or clinical patient portal | Light | Trust 和 legibility 最重要 |
| Vintage or artisanal brand site | Cream/warm light | Dark 会和 analog material references 冲突 |

如果 context 不明显，默认 light。

## Reflex Fonts to Reject

这些 fonts 在 training data 中占比很高。使用它们会传达 no decision was made。禁令针对 reflex use as a display face；有理由的 product-UI use（例如 dense data table 中的 Inter）可以接受。

Reject: Inter, DM Sans, DM Serif Display, DM Serif Text, Outfit, Plus Jakarta Sans, Instrument Sans, Instrument Serif, Space Grotesk, Space Mono, IBM Plex Sans, IBM Plex Serif, IBM Plex Mono, Syne, Fraunces, Newsreader, Lora, Crimson Pro, Crimson Text, Playfair Display, Cormorant, Cormorant Garamond.

## Font Selection Procedure

1. 写三个描述 brand 的词（例如 "precise, minimal, fast"）。
2. 命名你会 reflexively 选择的三个 fonts。
3. 拒绝这三个。
4. 从 named foundry（Klim、Commercial Type、Colophon、Grilli Type、OH no Type、Village）或具有清晰个性的 open-source option 中选择 typeface。能用一句话解释原因。

## Typography Details

- headings 和 short text blocks 使用 `text-wrap: balance`；body paragraphs 使用 `text-wrap: pretty`
- 在 root layout 上统一应用一次 `-webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale`（macOS only）
- counters、timers、prices、number columns 使用 `font-variant-numeric: tabular-nums`
- Letter-spacing：display sizes（32px+）约 -0.022em，mid-range（20-28px）约 -0.012em，16px 及以下 normal
