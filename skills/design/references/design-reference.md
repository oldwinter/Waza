# Design Reference

## Tech Stack Conflicts

这些组合会产生静默失败或不一致的输出。绝不要混用：

| Never combine | Why |
|---|---|
| Tailwind + CSS Modules on the same element | specificity 冲突，cascade 不可预测 |
| Framer Motion + CSS transitions on the same element | 同一属性被双重动画驱动会造成 jank |
| styled-components or emotion + Tailwind | 两套 class 系统争抢同一个 DOM node |
| Heroicons + Lucide + Font Awesome in one project | 视觉不一致、尺寸不匹配、bundle 膨胀 |
| Multiple Google Font families as display fonts | 多种字体个性彼此抵消 |
| Glassmorphism backdrop-filter + solid `border: 1px solid` | 实线边框会打碎 layered depth 的错觉 |
| Dark background + `#ffffff` text at full opacity | 太刺眼；使用 `rgba(255,255,255,0.85)` 或 `#f0f0f0` |
| Tailwind v4 `@theme` + dynamically constructed class names | `@theme` tokens 通过 JIT 生成 utility classes；如果 class names 由变量拼出或没有出现在 scanned source 中，class 会被 purge，样式会静默消失。Fix: 在 source files 中使用 static class names，加入 `safelist`，或在 `tailwind.config.js` 中用 `:root` + `extend.colors` 定义 custom colors，而不是用 `@theme` |

写第一个 component 前，先命名项目唯一 CSS strategy：Tailwind only、CSS Modules only 或 CSS-in-JS only。不要漂移。

## Common Traps

提交前，检查是否无意中混入了以下模式：

- 白底上的紫色或蓝色 gradient hero background
- 三段式 hero：大标题、一行 subtext、两个并排 CTA buttons
- 一组 cards：完全相同的 rounded corners、drop shadows 和 padding
- 顶部导航：logo 在左、links 居中、primary action 在最右
- sections 在白色和 `#f9f9f9` 之间来回交替
- 居中的 icon 或 illustration 位于 heading 上方，heading 又位于 paragraph 上方
- 四列 footer，所有 columns 权重相同

如果这些模式服务于明确的 design intent，可以出现。它们不能作为默认出现。

最终测试：如果换成完全不同的内容后，layout 不改也仍然成立，你做的是 template，不是 design。重做。

## Content Authenticity

看起来真实但并不真实的 placeholder copy，会在用户开始阅读的一瞬间破坏可信感。handoff 前应用这些规则。

**Sample data:**
- 不要 generic names：不要 John Doe、Jane Smith、Alex Johnson，也不要任何读起来像填充物的 first-name-last-name 组合。使用文化背景更丰富且具体的名字（例如 Priya Mehta、Lars Eriksson、Nia Okafor）。
- 不要 generic company names：不要 Acme Corp、Nexus、SmartFlow、TechCorp、Initech。选择带有 domain 感的名字（例如 Meridian Logistics、Hokkaido Ceramics、Vantage Bioworks）。
- 不要 Lorem Ipsum。写能匹配 layout 阅读层级的短真实文案。
- sample data 中不要 round numbers。`99.99%` uptime、`50%` conversion、`$100.00` MRR 看起来很假。使用更自然的值：`99.94%`、`47.2%`、`$99.00`。
- 多个 avatar instances 不得共用同一张 image。多个 blog post 或 event cards 不得共用同一个 date。

**UI copy:**
- 所有 headings 使用 sentence case。Title Case On Every Heading 是 body copy 中最常见的 AI tell。
- 从 success states 移除感叹号（"Saved!" -> "Saved"，"Done!" -> "Done"）。`!` 只留给真正紧急的场景。
- error message 不要以 "Oops!" 开头。它读起来像居高临下。
- error messages 不用 passive voice（"Something went wrong" -> "We couldn't load your data. Try refreshing."）。
- hero copy、CTAs 和 feature descriptions 中禁用 AI marketing words：Elevate、Seamless、Unleash、Delve、Tapestry、Game-changer、Next-Gen、"In the world of..."。这些词没有传达任何产品价值。改为命名具体价值。

## Placeholders Over Imitations

当 icon、image 或 component 不可用时：使用 placeholder。在 hi-fi design 中，一个带 label 的 placeholder 永远好过低质量仿制。例子：hero image 用灰色矩形，缺失 logo 用 monogram wordmark，未设计 component 用 dashed border。

不要用 inline SVG 画 illustrative imagery。SVG 用于 icons 和 geometric shapes。photography、illustrations 或 product shots 应使用 placeholder，并请用户提供真实 assets。

## Production Quality Baseline

handoff 前检查。这些不是 aesthetic choices，而是 non-negotiable。

> 把下面 sections 当成 craft details，而不是 defaults。只有在它们服务已锁定的 visual direction 时才应用。如果移除某个 detail 不会改变 interface 的感受，就不要加。

### Accessibility
- Icon-only buttons 需要 `aria-label`
- Actions 使用 `<button>`，navigation 使用 `<a>`（不要用 `<div onClick>`）
- Images 需要 `alt`（decorative 时用 `alt=""`）
- 可见 focus states：`focus-visible:ring-*` 或等价写法；不要 `outline: none` 后没有替代方案

### Animation
- 尊重 `prefers-reduced-motion`：设置时禁用或减少 animations
- 只 animate `transform`/`opacity`（compositor-friendly，避免 layout thrash）
- 永远不要 `transition: all`；明确列出 properties
- Interruptible animations：interactive state changes（hover、toggle、open/close）优先用 CSS transitions，因为它们能在 animation 中途 retarget；keyframe animations 只留给运行一次的 staged sequences（例如 staggered page enters）
- Staggered enter：把 content 拆成 semantic chunks，约 100ms delay；titles 拆成 words，约 80ms；典型 enter 使用 `opacity: 0 -> 1`、`translateY(12px) -> 0` 和 `blur(4px) -> 0`
- Subtle exit：使用小的 fixed `translateY(-12px)`，不要 full height；duration 保持约 150ms `ease-in`，比 enter 更短更柔和
- Contextual icon swaps：用 `scale: 0.25 -> 1`、`opacity: 0 -> 1` 和 `blur: 4px -> 0px`。有 spring library 时：`{ type: "spring", duration: 0.3, bounce: 0 }`。没有时：两个 icons 都保留在 DOM 中（一个 absolute），用 `cubic-bezier(0.2, 0, 0, 1)` 做 CSS cross-fade
- Scale on press：buttons 通过 CSS transitions 在 active/press 使用 `scale(0.96)`，这样 press 可以被打断；添加 `static` prop，在 motion 会分散注意力时禁用
- Page-load guard：对 toggles、tabs 和 icon swaps 的 animated presence wrappers 使用 `initial={false}`，防止首次 render 时出现 enter animations；不要把它用于刻意的 page-load entrance sequences

### Performance
- Transition specificity：永远不要 `transition: all`；列出精确 properties（例如 `transition-property: scale, opacity`）。Tailwind 的 `transition-transform` 覆盖 `transform, translate, scale, rotate`；混合 properties 用 `transition-[scale,opacity,filter]`
- GPU compositing：`will-change` 只用于 `transform`、`opacity` 或 `filter`。永远不要 `will-change: all`。只有看到 first-frame stutter 时才加；不要预防性加到每个 element
- Images：明确 `width` 和 `height`（防止 layout shift）
- Below-fold images：`loading="lazy"`
- Critical fonts：`font-display: swap`

### Touch and Mobile
- `touch-action: manipulation`（防止 double-tap zoom delay）
- Full-bleed layouts：对 notch devices 使用 `env(safe-area-inset-*)`
- Modals 和 drawers：`overscroll-behavior: contain`
- Hover guard：用 `@media(hover:hover)` 包住 interactive hover states，让它们只在 pointer devices 上生效，不作用于 touch screens。Tailwind：`[@media(hover:hover)]:hover:bg-...`。否则 mobile 上被 tap 的 element 会保持 permanent hover state，直到下次 tap 到别处

### Typography Details
- Text wrapping：headings 和短 text blocks（Chromium <=6 行，Firefox <=10 行）用 `text-wrap: balance`；body paragraphs 和较长 text 用 `text-wrap: pretty`；code blocks 和 pre-formatted text 保持默认
- Font smoothing：在 root layout 上统一应用一次 `-webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale`（macOS only）
- Tabular numbers：counters、timers、prices、number columns 或任何动态变化的 numbers 使用 `font-variant-numeric: tabular-nums`
- Letter-spacing 随 font size 调整：display type 需要 negative tracking 才显得精修而不是被拉伸。两档：display sizes（32px 及以上）约 -0.022em，mid-range（20-28px）约 -0.012em，16px 及以下 normal。适用于所有 display-weight typeface，不只是 geometric sans。大标题上的 positive letter-spacing 永远不对

### Surfaces
- Concentric border radius：计算 `outerRadius = innerRadius + padding`，让 nested rounded corners 看起来有意图而不是机械；如果 padding 超过 `24px`，把 layers 当成 separate surfaces，各自选择 radius
- Optical alignment：icons 用眼睛校准，不只靠数学，让 buttons 感觉居中；带 text 和 icon 的 buttons 在 icon 一侧用略小 padding（例如 `pl-4 pr-3.5`）；play triangles 和不对称 icons 应向视觉更重的一侧移动 `1px`-`2px`，或直接修 SVG
- Shadows over borders：cards、buttons 和 elevated elements 用 layered `box-shadow` 表达 depth，让 surface 感觉被抬起，而不是被围起来；真正的 `border` 保留给 dividers、table cells 和 layout separation（主要适用于 light mode；dark surfaces 见下方 dark-mode surface hierarchy rule）
- Image outlines：添加微妙 inset outline，让 images 保持 depth 且不改变 layout dimensions：`outline: 1px solid rgba(0,0,0,0.1); outline-offset: -1px`（light）或 `outline: 1px solid rgba(255,255,255,0.1); outline-offset: -1px`（dark）
- Minimum hit area：每个 interactive target 至少 40x40px，让小 controls 也足够宽容和精准；visible element 更小时用居中的 pseudo-element 扩展；永远不要让两个 interactive elements 的 hit areas 重叠
- Multi-card alignment：card group 中所有 CTA buttons 底部对齐，避免 cards 高度差造成参差不齐的 action row。pricing 或 comparison cards 中，feature list items 对齐到各 columns 共享的 Y origin。side-by-side panels（testimonials、plans、feature breakdowns）中，title、description、price 和 action button 必须共享 row baseline。section top 和 bottom padding 不必对称：optical balance 往往需要 bottom padding 比 top 大 20-25%。body paragraph width 限制在约 65 characters（ch），维持舒适阅读行长
- Light-mode app surface hierarchy：相邻 nested surfaces 必须能被视觉区分。最低要求：sidebar 和 main area 之间、main area 和 cards 之间，background-color 至少有 4% lightness step；或 elevated cards 至少有 `0 1px 3px rgba(0,0,0,0.10)` shadow。near-white background 上的 white card 配 `box-shadow: 0 1px 2px rgba(0,0,0,0.05)` 是看不见的，那不是 depth，是 noise
- Dark-mode surface hierarchy：page canvas 是 near-black solid（例如 `#08090a`）。Elevation 通过在 canvas 上叠加 semi-transparent white overlays 表达：cards 为 `rgba(255,255,255,0.02)`，elevated surfaces 为 `0.04`，prominent panels 为 `0.05`。Borders 遵循同样逻辑：subtle 用 `rgba(255,255,255,0.05)`，standard 用 `0.08`。传统 drop shadows（dark on dark）几乎不可见；在 dark surfaces 上，借 background opacity 做 luminance stepping 是主要 depth cue
- Border radius system：direction lock 阶段定义 named radius scale，不要临时挑值。minimal scale 是 3-4 档（例如 `{4px, 8px, 12px, pill}`）；更丰富的 system 可能有 6-8 档。重点是在第一个 component 前承诺一组 named values，让所有 surfaces 使用同一种空间语言，而不是覆盖每个可能的 radius 值

### Adding to Existing UI

扩展现有 interface 时，先花时间理解它的 visual vocabulary。写第一行新 code 前，匹配下面所有项：
- Copywriting tone 和 reading level（technical？casual？punchy？）
- Color palette 和 semantic color roles（哪些 tokens 表示 "danger"、"success"、"muted"）
- Hover 和 click states：scale、color shift、underline、background fill
- Animation style：duration、easing、interaction 是否 bounce，还是严格 ease-out
- Shadow 和 card treatment：哪些 surfaces elevated，哪些 flush
- Layout density 和 whitespace rhythm
- Border radius choices，以及 buttons 是 pill、square 还是某个 fixed value

如果换入不同内容会让新 component 显得格格不入，说明 vocabulary 没有匹配到位。

### Responsive & Screen Verification
- Verify the rendered surface, not a type check or CSS-balance read. Several regressions (early wraps, orphaned separator dots, table overflow) are invisible in source and only show in the render. Screenshot at phone (375px, plus 320px for buttons) and desktop (1280px), in every shipped locale.
- Line widows: eliminate 1-2 word last lines by trimming the copy so the block rebalances, not by adding a `max-width` cap (a cap narrower than its container wraps early and leaves empty space on the right, which reads as a premature break). Detect objectively: flag any text block whose last line is under ~13% of its widest line; eyeballing misses them, and nested `<code>` hides them from greps.
- Mobile CTA resting state: natural width, left-aligned to the surrounding text edge, height unchanged. Centering reads as floating; full-width `flex: 1` reads heavy; dropping button height to relieve a "too full" feel treats a width problem as a height one.
- Spacing is a system, not a per-gap value. Run section spacing as one responsive ladder; when a page reads too airy or too tight, scale the whole set by a single factor across all breakpoints rather than tuning one gap. Asymmetry that survives tuning is structural.
- Long-form and documentation surfaces stay light: a borderless prev/next text pager (not bordered cards), a sidebar active state as a thin rail rather than a filled block, and build-time zero-runtime-JS code highlighting (bake static spans, plain code stays the source) over a shipped highlighter.

## Data Visualization Surfaces

对于 dashboards、analytics views、chart-heavy interfaces 或 number-dense displays，加载 `references/design-data-viz.md`。它负责 dashboard defaults、chart selection、number alignment 和 product-benchmark extraction。

## Reflex Fonts to Reject

LLMs 默认选择这些字体，因为它们在训练数据中占比很高。使用它们等于发出 "no decision was made" 信号。应选择具有明确声音的 foundries。禁令针对 reflex use as a display face；有理由的 product-UI use（例如 dense data table 中的 Inter）可以接受。列表并不穷尽；任何没有 stated reason 的 reflexive font use 都算。

Reject: Inter, DM Sans, DM Serif Display, DM Serif Text, Outfit, Plus Jakarta Sans, Instrument Sans, Instrument Serif, Space Grotesk, Space Mono, IBM Plex Sans, IBM Plex Serif, IBM Plex Mono, Syne, Fraunces, Newsreader, Lora, Crimson Pro, Crimson Text, Playfair Display, Cormorant, Cormorant Garamond.

## Font Selection Procedure

1. 写三个描述 brand 的词（例如 "precise, minimal, fast"）。
2. 命名你会 reflexively 选择的三个 fonts。
3. 拒绝这三个。
4. 从 named foundry（Klim、Commercial Type、Colophon、Grilli Type、OH no Type、Village 等）或具有清晰个性且匹配 brand words 的 open-source option 中选择 typeface。能用一句话解释为什么是这款 typeface。

## CJK & Multilingual Type

When the interface mixes Chinese, Japanese, or Korean with Latin, Latin-only type rules silently break the CJK text. Apply these before handoff:

- **Latin face first, system CJK face after** in the stack, so each script renders with correct glyphs: `font-family: -apple-system, "SF Pro Text", "PingFang SC", "Noto Sans SC", sans-serif;`. Latin runs use the Latin face; Han characters fall through to the CJK face.
- **Give CJK body text more line-height than Latin**: roughly 1.7–1.8 for reading. Dense Hanzi needs more vertical room than the 1.4–1.5 that suits Latin body copy.
- **Tag runs with `lang="zh"` / `lang="ja"` / `lang="en"`** so the browser picks the right font and line-breaking. Mixed-language paragraphs break badly without it.
- **Serif reading modes need an explicit CJK serif fallback.** Most Latin "reading serif" webfonts carry no CJK glyphs, so a serif toggle silently drops Chinese back to a sans and looks broken. Pair them: `"Newsreader", "Songti SC", "Noto Serif SC", serif`.
- **Do not apply negative letter-spacing to CJK runs.** The display-type tracking rule above is Latin-only; tightening tracking on Hanzi cramps the glyphs and reads as a rendering bug. Scope tracking to `lang="en"` runs.

## Color System: OKLCH Rules

- 使用 OKLCH，不用 HSL。OKLCH 是 perceptually uniform：相同数值变化会在光谱各处产生相同的感知变化。
- 随 lightness 接近极端值而降低 chroma。85% lightness 时 chroma 约 0.08 已足够；推到 0.15 会显得刺眼。15% lightness 时也同样收紧 chroma。
- 用 0.005 到 0.01 的 chroma 把 neutrals 轻微 tint 到 brand hue。即使这么微弱也能被感知，并创造潜意识 cohesion。
- 60-30-10 指 visual weight，不是 pixel count。60% neutral/surface，30% secondary text 和 borders，10% accent。
- 绝不要在 colored background 上使用 gray text。改用 background hue 的较低 lightness shade。

## Theme Matrix

根据 audience 和 context 有意识地选择 light 或 dark。两者都不是默认。

| Context | Direction | Reason |
|---|---|---|
| Trading or analytics dashboard, night-shift use | Dark | 高数据密度；长时间使用时减少眩光 |
| Children's reading or learning app | Light | 友好、低疲劳，适合仍在发展 contrast sensitivity 的眼睛 |
| Enterprise SRE or observability tool | Dark | Operator context；dark surfaces 在低光 NOC rooms 中更易一眼扫读 |
| Weekend planning, recipes, journaling | Light | 白天 ambient use；light 感觉更随意、更亲近 |
| Music player or media browser | Dark | Content-forward；dark surfaces 后退，让 media 更突出 |
| Hospital or clinical patient portal | Light | Trust 和 legibility 最重要；clinical associations 更偏向 light |
| Vintage or artisanal brand site | Cream/warm light | Dark 会和 analog material references 冲突 |

如果 context 不明显，默认 light。如果用户 context 同时暗示两种 mode，先 ship light，再在其上 layer dark-mode tokens。

## Absolute Bans (CSS-Pattern Level)

这些 patterns 出现在大多数 AI-generated interfaces 中。每一个都有具体 rewrite。列表并不穷尽；任何作为无脑默认而非有意选择的 CSS pattern 都属于同类。

| Pattern | Why | Rewrite |
|---|---|---|
| `border-left` or `border-right` wider than 1px as a section accent | admin 和 dashboard UIs 中最滥用的 "design touch"；超过 hairline divider 就像错误 | 改变 element structure：使用 colored dot、short horizontal rule、background swatch 或 typographic weight shift |
| `background-clip: text` gradient text | 只是装饰而非有意义；顶级 AI design tell 之一；打印或 high-contrast mode 下不可读 | 使用 solid brand color、tinted neutral 或 typographic weight 强调 |
| `backdrop-filter: blur` glassmorphism as the default card surface | 低功耗设备上昂贵；过度使用；配 solid border 会破坏 layered-depth illusion | 改用 background color steps 和 `box-shadow` 表达 elevated surfaces |
| Purple-to-blue gradients or cyan-on-dark accent systems | canonical "AI design" color palette；不传达任何 brand 信息 | 根据上方 OKLCH rules，从 brand words 选择 palette |
| Generic rounded-rect card with `box-shadow` as the default container | template thinking；不管 hierarchy，把同一种 container 套到所有 content type | 默认使用 cardless sections；只有 content type 需要时才添加 card treatment |
| Modals as a lazy escape for overflow UI | 打断 flow，破坏 browser back navigation；常被用来逃避本该 inline expansion、drawer 或 separate page 的场景 | Inline expand、detail panel 或 dedicated route；只有 action 真正需要 focus-lock 时才使用 modal |
| `transition: all` or animating width/height/padding/margin | 每一帧都强迫 browser 做 layout recalculation | 列出精确 properties（`transition-property: transform, opacity`）；height reveals 使用 `grid-template-rows: 0fr to 1fr` |

## Motion Specifics

补充 main SKILL.md constraints 中的 motion timing。

- 不用 bounce 或 elastic easing。真实物体平滑减速。使用 exponential ease-out（`ease-out-quart`、`ease-out-quint` 或 `cubic-bezier(0.16,1,0.3,1)`）获得自然、高质量的 deceleration。
- 只 animate `transform` 和 `opacity`。其他 property 都会触发 layout 或 paint。
- height reveals 使用 `grid-template-rows: 0fr` 到 `1fr` transitions，而不是直接 animate `height`。这能避开 `height: auto` animation trap。
- Icon swaps：使用 120ms cross-fade，配合 `opacity` 和轻微 `scale(0.9)` 到 `scale(1)`。除非 rotation 具有语义意义（例如 chevron 表示方向变化），不要旋转。
- 即使 quick prototype 也不要用 `transition: all`。它会同时 animate layout、color 和 font-size，造成可见 jank。

## Reference-site Brand Presets (awesome-design-md)

`VoltAgent/awesome-design-md` 维护了 66+ 个 curated DESIGN.md files，这些文件从真实 brand sites 提取而来。运行 `npx getdesign@latest add <brand>` 会把文件放到 project root，让 agent 分解 concrete token values，而不是靠记忆推理。

**Usage rule:** 绝不要 auto-run command。direction lock 阶段只把它作为选项提出，只有用户明确批准才运行，并把结果当作 seed decomposition material，而不是 finished direction。

**Brands in the catalog**（用户提到 reference 时识别这些）：

| Category | Brands |
|---|---|
| AI & LLM | Claude, Cohere, ElevenLabs, Mistral, Ollama, Replicate, RunwayML, Together AI, xAI |
| Dev Tools & IDEs | Cursor, Expo, Lovable, Raycast, Superhuman, Vercel, Warp |
| Backend / DB / DevOps | ClickHouse, Composio, HashiCorp, MongoDB, PostHog, Sanity, Sentry, Supabase |
| Productivity & SaaS | Cal.com, Intercom, Linear, Mintlify, Notion, Resend, Zapier |
| Design & Creative | Airtable, Clay, Figma, Framer, Miro, Webflow |
| Fintech & Crypto | Binance, Coinbase, Kraken, Revolut, Stripe, Wise |
| E-commerce & Retail | Airbnb, Meta, Nike, Shopify |
| Media & Consumer | Apple, IBM, NVIDIA, Pinterest, PlayStation, SpaceX, Spotify, Uber |
| Automotive | BMW, Bugatti, Ferrari, Lamborghini, Tesla |

**Conflict resolution:** 这个 skill 的 rules 永远获胜。如果 preset 推荐 Reflex Fonts blocklist 中的 font（例如把 Inter 用作 display face），丢弃它并应用 Font Selection Procedure。如果它提出 Absolute Bans table 中的 pattern（例如 purple-to-blue gradient），丢弃它。在 handoff summary 中说明 override。

Source: [github.com/VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)

## Reference Material Priority

当 reference UI 同时有 source code 和 screenshot：读 code。Source files 包含精确 token values；screenshots 需要猜。根据写出来的内容重建，不要根据看起来的内容猜。

当只提供 URL：fetching 只返回 extracted text，没有 layout information。对于 visual references（"make it look like X"），请用户提供 screenshot，不要从 stripped HTML 推断 visual design。

## DESIGN.md Scaffold (Optional, Production UIs)

对于 multi-page 或 production UI，写第一个 component 前，先输出简短 `DESIGN.md`-style summary。这会强迫枚举本来会被隐含处理的 decisions，让用户能早期纠正方向。九个 sections：

1. **Visual Theme and Atmosphere** - 2-3 句说明 mood、density、design philosophy
2. **Color Palette and Roles** - 每个 color token 的 semantic name + value + functional role
3. **Typography Rules** - font family、size scale、weight scale、line-height、letter-spacing；超过 4 个 levels 时用 table
4. **Component Stylings** - buttons（所有 states）、cards（如果使用）、inputs、navigation；每项描述 default、hover、active、disabled states
5. **Layout Principles** - spacing scale、grid columns、whitespace philosophy
6. **Depth and Elevation** - shadow system 或 background-color-step system；描述每个 level
7. **Do's and Don'ts** - 5 到 10 条本项目专属 guardrails，不要 generic rules
8. **Responsive Behavior** - breakpoints、navigation 如何 collapse、touch target minimums
9. **Agent Prompt Guide** - quick color reference（name: value pairs）+ 3 到 5 个可直接粘贴到 follow-up request 的 example component prompts。Prompts 必须具体到不需要再查资料：每个 value、radius、letter-spacing、weight 都 inline。示例标准（values 仅示意，使用项目自己的 tokens）："Create a hero on `{bg-canvas}`, headline at 48px weight 600, line-height 1.00, letter-spacing -0.022em, color `{text-primary}`, CTA at `{accent}` with `{btn-radius}` radius"；需要这种具体程度，而不是 "hero with primary color and CTA button"

对于 single component 或 quick prototype，跳过它。SKILL.md 中的 three-line thesis 已足够。

## Pre-Handoff Checklist: Strategic Omissions

这些是 AI-generated UIs 最常缺失的 items，因为它们需要 intentional product thinking，而不仅是 visual judgment。每次 handoff 前检查：

- [ ] **Custom 404 page**：generic framework 404 是破损体验。构建 branded page，并提供清晰返回路径（home link、search 或 most-used nav items）。
- [ ] **Back navigation**：每个由 user action 到达的 page，都必须有清晰且可用的返回路径。dead-end pages（detail views、confirmation screens、modal-only flows）是 UX failures。
- [ ] **Form client-side validation**：email fields submit 前验证 format；required fields 显示 inline errors；error messages 靠近 field 出现，不只在 form top。
- [ ] **Skip-to-content link**：document 中第一个 focusable element 是 visually hidden `<a href="#main-content">Skip to main content</a>`。这是 keyboard accessibility 的必需项。
- [ ] **Cookie consent**：如果 product 在 EU 或 California 运营，cookie consent UI 不是可选项。按 jurisdiction 限定 implementation scope。
- [ ] **Footer Privacy and Terms links**：每个 product page 都需要这些。缺失会传达 "demo"，不是 "product"。

这些不是 visual polish。它们区分 demo 和 shippable product。

## AI Slop Test

陌生人看一眼 first viewport，会不会立刻说 "an AI made this"？如果会，说明 committed direction 不够 committed。常见罪魁祸首：reflex font、default purple accent、centered hero 和下方 generic card grid。修 typography、color system 或 layout，直到答案翻转。

## Brand Preset Flow

对于 well-known brands（Linear、Stripe、Claude、Vercel、Apple、Tesla、Notion、Figma、Airbnb、Spotify，以及 `awesome-design-md` 中收录的约 56 个其他品牌）：询问用户是否通过 `npx getdesign@latest add <brand>` 拉取 curated preset。如果用户批准，运行它，读取 project root 中生成的 `DESIGN.md`，再基于该文件做 3-property decomposition，而不是从记忆出发。preset 是 starting point，不是 direction：用户仍需要精确命名 aesthetic；reflex-font blocklist 和 absolute bans 在任何冲突中仍然获胜。

## App Shell Rules

When building a sidebar + main workspace layout (Slack, Linear, Notion class):
- Decorative backgrounds 默认 off
- Surface hierarchy 只使用 background-color steps 和 shadow
- All interactive elements get `active:scale-95`
- Button radius 在每个 component type 内保持一致（从 pill、square 或一个 fixed value 中选一个，不要混用）
- 第一个 component 前先 commit to a named radius scale（见上方 Border radius system）

## Options Guide

当用户要求 design options 时，至少给 3 个 variations，并且它们要分布在真正不同的 dimensions 上：

- **Dimensions to vary**：visual density、typographic personality、color temperature、layout structure、motion character、decoration amount、abstraction level
- **Mix approaches**：一个 option 严格跟随 existing conventions；一个用新方式 remix brand DNA；一个 deliberately unexpected
- **Progress from basic to bold**：第一个 option safe 且易懂；后面的 options 推得更远
- 只在 accent color 上不同的三个 options，不是三个 variations。要变化 layout、typeface、motion、surface treatment。

---

*Rules in Reflex Fonts, Font Selection, OKLCH, Theme Matrix, Absolute Bans, Motion Specifics, and AI Slop Test adapted from [pbakaus/impeccable](https://github.com/pbakaus/impeccable) (Apache 2.0). DESIGN.md Scaffold adapted from [getdesign.md](https://getdesign.md) (MIT); concept credited to Google Stitch. Brand preset catalog from [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) (MIT). Content Authenticity, Multi-Card Alignment, and Strategic Omissions inspired by [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill).*
