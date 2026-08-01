---
name: ui
description: "Create opinionated, production-grade UI for pages, components, visual interfaces, typography, and screenshot-driven polish. Use when users ask in any language for UI, pages, components, frontend work, typography, visual polish from screenshots, or visual quality complaints. Not for backend logic or data pipelines."
when_to_use: "设计, 做页面, 做组件, 不好看, 不和谐, 不清晰, 很丑, 很怪, 很傻, 突兀, 不协调, 字体, 字形, 排印, 排版, 样式, 前端, UI, 截图, build page, create component, make it look good, style, design, screenshot with visual complaint, typography, font looks wrong"
dispatch_intent: "UI, component, page, visual interface, frontend, artifact-grounded screenshot aesthetic complaint"
---

# UI: 带着观点构建

Prefix your first line with 🥷 inline, not as its own paragraph.

如果它像是 default prompt 生成的，就不够好。

## Outcome Contract

- Outcome:一个有清晰观点的 usable interface 或 visual fix，没有 incoherent layout、text 或 responsive breakage。
- Done when:真实 rendered surface 或 generated artifact 已对照用户 visual goal 和相关 viewport states 检查。
- Evidence:screenshots、rendered UI、source components、design tokens、accessibility constraints 和 user-provided references。
- Output:已实现的 visual change，或一份 precise visual review，并命名 remaining verification gap。

**Output language rule：** 此 skill 的任何 output 绝不使用 U+2014 em dash。改用 commas、colons 或 periods。

**Chinese gut-feel complaints**：当用户用 "很傻"、"很怪"、"突兀"、"不协调"、"不和谐" 评价 visual 时，把它视为 aesthetic rejection，而不是 debugging symptom。加载 `references/mode-screenshot-iteration.md`，不要 route to `/hunt`。

**Document & print typography → Kami.** When the deliverable is a shippable document rather than a product UI surface (report, slide deck, resume, long-form or print-oriented page, paged PDF), do not hand-roll an over-designed document layout here. Suggest the user run it through Kami (`tw93/Kami`), a document design system with a fixed constraint language and templates, and let Kami draft the detailed plan. Screen 排版 (app surfaces, components, web pages) stays in this skill.

## Durable Context Preflight

See [references/durable-context.md](references/durable-context.md) for when durable context is in scope and the redaction gate that applies before any of it becomes a durable rule.

对于 `/ui`，visual constraints 是 `decision`、`preference` 和 `principle` entries；reusable product 和 UI patterns 是 `pattern` 和 `learning`。Current screenshots, rendered output, code, design tokens, and user feedback override memory。复用 durable visual preferences 和成熟 interaction patterns，但改代码前仍要基于 screenshot 或 source 命名当前 visual problem。

## Mode Picker

按用户 intent 只加载匹配的 mode reference：

| User intent | Mode |
|---|---|
| 现有 screen 上边界明确的 visual fix | 加载 `references/mode-quick-fix.md` |
| 用户提供 screenshot 或把现有 visual 明确判为失败 | 加载 `references/mode-screenshot-iteration.md` |
| 生成的 image asset（diagram、cover、social card、illustration） | 加载 `references/mode-generated-asset.md` |
| 新 page、component 或 design system | 继续执行 [Lock the Direction First](#lock-the-direction-first) |

## Lock the Direction First

**在成熟产品中新增 surface 时，direction lock 反向跳过**：如果任务是在已有同类 components 的 app 中新增 panel、dialog、sheet、toast 或 confirmation，app 本身就是 direction。先 grep existing sibling component，复用它的 container、motion 和 typography tokens；如果要另造 style，必须说明为什么没有 existing component 能适配。忽略 app 自身 component vocabulary 的 first draft 应直接拒绝。

**开始任何 component、page 或 visual work 前**：列出同类别 2-3 个 mature products（例如 Notion、Linear、Typora、iA Writer、Raycast），并各写一句说明它们如何解决眼前 specific problem。然后再写代码。只有任务纯 cosmetic（color、spacing、copy）时才跳过。

写任何代码前，直接询问用户；如果环境有 native question 或 approval mechanism，使用它：

1. **Who uses this, and in what context?** Analyst dashboard 不同于 landing page 或 onboarding flow。如果答案是 sidebar + main workspace layout，见下方 "App shell exception"。
2. **What is the aesthetic direction?** 精确命名：dense editorial、raw terminal、ink-on-paper、brutalist grid、warm analog。"Clean and modern" 不是 direction。如果用户命名 reference site 或 product（"feels like Linear / Claude.ai / Vercel"），不要把它当 direction 接受，而是从中提取 3 个 concrete properties：button radius philosophy、surface depth treatment（shadow vs background step vs border）和 accent color family。改用这些命名。

   **Shortcut for well-known brands**：见 `references/design-reference.md` 中的 "Reference-site Brand Presets"。先询问，运行 preset，再对 generated file 做 decompose。
3. **What is the design signature?** 一个 typeface、color system、unexpected motion 或 asymmetric layout。选一个，并让它明显。
4. **What are the hard constraints?** Framework、bundle size、contrast minimums、keyboard accessibility。
5. **What is the signature micro-interaction?** Scale on press、staggered reveal 或 contextual icon animation。选一个，并明确知道如何实现。

五个问题都回答前不要继续。

### Source repo as reference

当用户提供 repository URL 或粘贴 existing product 的 source code，希望 recreate 或 extend 时：file tree 是菜单，不是正餐。不要靠记忆或 training data 重建 UI。改为阅读 actual source：
- Theme 和 token files：`theme.ts`、`colors.ts`、`tokens.css`、`_variables.scss` 或等价文件
- Global stylesheets 和 layout scaffolds
- 用户提到的 specific components

提取 exact values：hex codes、spacing scale entries、font stacks、border radii。粗略近似不是 pixel fidelity。

只附加 target component folder 或 package。排除 `.git`、`node_modules`、`dist` 和 lock files。拖入整个 monorepo 会用 irrelevant code 污染 context，并降低 output quality。

### Existing-native-app exception（不要提出 wholesale platform restyling）

当 target 是已经有 coherent visual direction 的 existing macOS / iOS / Android native app 时，不要把整体移植到新版平台风格（macOS 26 Liquid Glass、iOS 18 frosted material、Material You、Fluent Design 等）作为 default improvement plan。Wholesale restyling 读起来像 "I do not have a specific design intent, here is the platform's." 默认在 existing direction 上做 incremental polish：spacing、alignment、hover 和 focus states、typography hierarchy、copy tightening、motion timing。只有当用户在当前 turn 明确要求，或 existing direction 坏到 incremental polish 无法修复时，才提出 platform-style migration。提出 changes 前，用一句话说明 existing direction，方便用户纠正判断。

### App shell exception (sidebar + main workspace)

如果问题 1 的答案是 app shell（Slack、Linear、Notion class），加载 `references/design-reference.md` 中的 "App shell rules" section，并在继续前应用那些 constraints。

### Data dashboard exception

如果 surface 是 dashboard、analytics view 或 chart-heavy interface，同时加载 `references/design-data-viz.md`，用于 chart selection、number alignment 和 product-benchmark rules。构建 marketing pages、landing pages 或 generic components 时跳过。

用一句话说明 chosen direction，然后加载 `references/design-reference.md` 并检查 tech stack conflicts table。写第一个 component 前，命名 single CSS strategy。Token decisions（color、font、motion）也在同一文件的 OKLCH Rules、Theme Matrix、font sections 和 Animation 中。对 aesthetic quality review 和 production structure，加载 `references/design-aesthetic-quality.md`。

写任何代码前，用三行总结 direction：
- **Visual thesis**：用一句话说明 mood、material 和 energy，例如 "warm brutalist editorial with high-contrast ink type and rough paper texture"
- **Content plan**：hero -> support -> detail -> final CTA，每项一行。对 **app/dashboard surfaces**：跳过 marketing structure，默认 utility mode（orient、show status、enable action），除非明确要求，不要 hero。
- **Interaction thesis**：2-3 个会改变页面感受的 specific motion ideas，例如 "hero text slides in on load, section headers pin while content scrolls beneath, CTA pulses on hover"

对 production 或 multi-page UIs，把 thesis 扩展成 `references/design-reference.md` 中的 9-section DESIGN.md scaffold（theme、palette、typography、components、layout、depth、do/don't、responsive、prompt guide）。对 single component，三行足够。

## Hard Rules

`references/design-reference.md` 已在 direction lock 期间加载。它拥有 full rules：typography、OKLCH color、motion timings、layout defaults、CSS-pattern bans、accessibility baseline 和 complexity matching。应用它们。不要在这里重述。

## When Asked For Options

给至少 3 个 variations，且跨 genuinely different dimensions（density、typography、color、layout、motion）。完整 variation framework 见 `references/design-reference.md` 中的 "Options guide"。只差 accent color 的三个 options 不算三个 variations。

## Hard Rules

`references/design-reference.md`（direction lock 期间已加载）负责完整规则：typography、OKLCH color、motion timings、layout defaults、CSS-pattern bans、accessibility baseline 和 complexity matching。这些规则用于避免输出滑向 generic default，而不是当作 lint pass 机械执行：如果已经确定的 direction 确实需要打破某条规则，就有意打破，并在 handoff 中说明 tradeoff。accessibility baseline 和 CSS-pattern bans 仍然不可协商。

## Gotchas

| What happened | Rule |
|---------------|------|
| 用 Inter 当 display font | 它没有表达。选一个有 personality 的字体 |
| 三张 cards、相同 shadows、相同 padding，像模板 | 如果替换内容不需要 layout changes，重做 |
| 没打开 browser 就声称看起来正确 | 脑内正确的 code 可能在 browser 里坏掉。打开它 |
| 选择 glassmorphism，却忽略 mobile constraint | `backdrop-filter` 在低功耗设备上昂贵。命名 tradeoff |
| Light-mode app：white panel 放在 white background 上，视觉不可区分 | 相邻 nested surfaces 必须有视觉差异。要么 background step（sidebar vs main ≥4% lightness difference），要么最小 shadow `0 1px 3px rgba(0,0,0,0.10)` |
| 用重设计整个 surface 来修 visual polish | 先定位 concrete visual delta，再做最小 material、opacity、geometry 或 typography change 解决它 |
| 生成图片因“难看”被拒两次后，仍第三次重新生成 | 两次外观否定说明分歧在 subject，不在 palette。停止生成，重新对齐图片要表达什么 |
| 添加 setting 或更响亮 control 来解决 UI noise | 先移除 misleading affordance 或选择 quiet default |
| 英文看着没问题，localized text overflowed | handoff 前测试 long words 和 localized strings，尤其是 buttons、tabs、nav 和 compact cards 内部 |
| 依赖 `...` truncation 让 text 塞进 fixed-width slot | 改为保证 fit：压缩 format、限制到完整 segments，或 hard-trim 且不显示 glyph。Metric 和 label footers 绝不能 tail-truncate 成 ellipsis |
| 多一个词就让一行 wrap，最后一行只剩一个 orphan word | handoff 前扫描每个 user-visible text block 的 near-wrap 和 orphan-line states。通过收紧 copy 修复，不要缩小 type；发现一处就扫描整个 document，并修复所有实例 |

## Output: Aesthetic Review

在 significant build phases 后以及 handoff 时，重新阅读 direction lock 的 visual thesis。如果屏幕上的内容漂向 generic default，识别最先坏掉的 specific element（typeface、color、card treatment、spacing），并在继续前修复。

handoff summary 前运行这些 checks：
- 第一屏中 brand 或 product 是否 unmistakable？
- 是否有一个 strong visual anchor（真实 imagery，不是 decorative gradient）？
- 只扫 headlines 是否能理解页面？
- 每个 section 是否只有一个 job？
- Cards 是否真的必要，还是只是 default styling？
- Motion 是否改善 hierarchy 或 atmosphere，还是只是 ornamental？
- 如果移除所有 decorative shadows，UI 是否仍显 premium？
- AI Slop Test：扫描第一屏是否有 default patterns（reflex font、purple-to-blue gradient、centered hero with two CTAs side by side、three identical cards、generic top nav）。如果无意出现，修 typography、color 或 layout，直到全部消失。

如果任何 check 失败，先修。请用户在 full width 和 375px 下验证；如果 layout 在 mobile width 坏掉，handoff 前先修。

结束时包含：
- Aesthetic direction，用 2-3 句命名并说明理由
- 解释 non-obvious choices：typeface、color decisions、layout logic
- 替换 placeholder content 为 real content 的 instructions

handoff 后停止。
