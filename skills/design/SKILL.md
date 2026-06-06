---
name: design
description: "为页面、组件、视觉界面、typography 和基于截图的 polish 产出有辨识度、production-grade 的 UI。Use when users ask 设计/做页面/做组件/UI/前端/截图，或说某个 screen 丑、不清晰、不一致、视觉不对时使用。Not for backend logic or data pipelines."
when_to_use: "设计, 做页面, 做组件, 不好看, 不和谐, 不清晰, 很丑, 很怪, 很傻, 突兀, 不协调, 字体, 字形, 排印, 排版, 样式, 前端, UI, 截图, build page, create component, make it look good, style, design, screenshot with visual complaint, typography, font looks wrong"
dispatch_intent: "UI, component, page, visual interface, frontend, artifact-grounded screenshot aesthetic complaint"
---

# Design: 带着观点构建

Prefix your first line with 🥷 inline, not as its own paragraph.

如果它像是 default prompt 生成的，就不够好。

## Outcome Contract

- Outcome:一个有清晰观点的 usable interface 或 visual fix，没有 incoherent layout、text 或 responsive breakage。
- Done when:真实 rendered surface 或 generated artifact 已对照用户 visual goal 和相关 viewport states 检查。
- Evidence:screenshots、rendered UI、source components、design tokens、accessibility constraints 和 user-provided references。
- Output:已实现的 visual change，或一份 precise visual review，并命名 remaining verification gap。

**Output language rule：** 此 skill 的任何 output 绝不使用 em-dash（—）。改用 commas、colons 或 periods。

**Chinese gut-feel complaints**：当用户用 "很傻"、"很怪"、"突兀"、"不协调"、"不和谐" 评价 visual 时，把它视为 aesthetic rejection，而不是 debugging symptom。Route to Screenshot Iteration Mode，不要 route to `/hunt`。

## Durable Context Preflight

See [rules/durable-context.md](../../rules/durable-context.md) for when to read durable context, the read-order budget, and the memory-type mapping.

对于 `/design`，visual constraints 是 `decision`、`preference` 和 `principle` entries；reusable product 和 UI patterns 是 `pattern` 和 `learning`。Current screenshots, rendered output, code, design tokens, and user feedback override memory。复用 durable visual preferences 和成熟 interaction patterns，但改代码前仍要基于 screenshot 或 source 命名当前 visual problem。

## Visual Quick-Fix Mode

当用户要求带具体 symptom 的窄 visual repair 时激活：overflow、clipped 或 wrapped text、misalignment、spacing imbalance、contrast/readability、localized text 不适配、compact responsive breakage。这用于修 existing surface，不用于 redesign。

Flow:

1. 读取 current UI evidence：screenshot、rendered page、native view 或 responsible component。
2. 用一句话命名 exact visual defect。
3. 做能修复该 defect 的最小 material、geometry、spacing、contrast、typography 或 text-fit change。
4. 验证真实 running surface 或 generated artifact。检查 long words、localized strings、compact states，以及适用时至少一个 narrow viewport。
5. 如果 fix 触碰三个或更多 components、改变 product behavior，或暴露 direction problem，停止并切换到 Screenshot Iteration Mode 或 Lock the Direction First。

**Spacing unification rule。** 如果某个 magic spacing 或 sizing value 调整三次后 layout 仍然不对，停止 tuning。把 N 个独立 padding / gap / margin / size values 替换成一个 shared named token（`Spacing.s4`、`--gap-content`、`gap-4`）。Outer container padding 默认等于 inner element gap。能熬过 tuning 的 asymmetry 是 structural，不是 numeric，继续加 magic numbers 不会收敛。先减少 independent values 数量，再讨论具体 value。

**Fixed-height action slot, uniform typography。** 任何会基于 state 替换 children 的 container（status bar、action slot、toolbar row、menu item）都必须在每个 state 使用同一个 font size。可以改变 fill、stroke、opacity、color 或 icon，绝不要改变 font size。`secondary 13px` 和 `primary 14px` 之间 1pt 的 height delta 会在 state transition 时变成可见 jitter。同一 slot 中的 CTA pill buttons 使用相同 size（通常 14px），用 background 和 border 区分，而不是 typography。

**Completion screen layout。** Operation-complete surfaces 只展示用户来这里要看的那个单一结果：actual reclaimed size / processed count / changed state。长解释属于从 summary row 打开的 details overlay，不属于 primary completion line。当点 summary row 已经能打开 details 时，不要在旁边添加单独的 "Review" button；不要展示空的 "0 skipped" entry point。如果没有 skipped 或 failed item，完全隐藏 details affordance。

**Safety-bound action design。** 对 cleanup、deletion、uninstall、reset 或 permission-changing surfaces，不要通过隐藏 recoverability 让 UI 显得更简单。只有当每行都能被 target user 理解，并携带足够 identity 让用户验证 safety（相关时包括 name、source、owner、path、preview 或 recovery implication）时，bulk select、auto-select、one-tap delete 或 "recommended" destructive defaults 才合适。如果 rows 是 opaque identifiers、inferred leftovers 或 machine-only paths，优先 review-first UI、current-target scoping、disabled destructive affordances 或 explanatory grouping，而不是更快的 batch controls。想减少点击的 feature request 不足以移除用户验证将发生什么变化的能力。

**Quiet product boundary。** 更少点击和更丰富 controls 不会自动更好。添加 alternate controls 前先移除 misleading affordances；diagnostics 和 alerts 优先 quiet defaults；改变速度或添加 new motion preference 前先修 unstable motion cadence。如果 current UI 暗示了它不能支持的 action、state 或 promise，先移除该暗示。

## Screenshot Iteration Mode

当用户发送 screenshot 或 image，并附带 complaint（"这里很丑"、"这个不对"、"fix this"、"looks wrong"）时激活。Existing product 就是 direction。跳过 five-question direction lock。

**Flow:**

1. 读取 screenshot。用一句话说明问题：具体哪里看起来不对（spacing、contrast、alignment、typeface、color、density、hierarchy）。当用户的负面标签有诊断意义时，保留它；不要把 "丑"、"乱"、"不清晰" 或 "怪" 翻译成模糊的 "make it modern"。
2. 触碰代码前，等待用户确认 diagnosis。
3. 如果用户提供 reference screenshot、older version 或 "this one is good" example，选择 fix 前先比较 current vs. reference，并命名 visual deltas。
4. 如果 diagnosis 是已知 UX problem（split-view sync、infinite scroll、virtualised list、sticky header），写代码前花一轮调研同类别 2-3 个 mature products 如何解决。引用每个产品做了什么。只有纯 cosmetic fix（color、spacing、copy）才跳过。
5. 找 responsible code：grep component name 或 class，读取实际文件。不要依赖记忆或关于 file location 的 assumptions。
6. 应用 minimal fix。对 existing products，redesign surface 前先尝试 material/opacity、geometry、spacing、typography 或 text-fit adjustments。
7. 在 browser、native app、screenshot tool 或 rendered artifact 中验证结果；适用时检查 desktop width 和 375px mobile width。检查 long words、localized strings、button labels 和 compact states 是否 overflow。如果 host 无法 render，明确说明，并 hand off 用户应检查的 exact view。
8. 请用户在 browser 中验证。没有这一步不要 hand off。

**Calibration rules:**
- 用户的 screenshot 是当前 turn 最强的 design brief。修完前，reasoning 中持续保留它。
- 真实 running product 是 oracle。Product pages、app screenshots、release pages 和 current UI state 覆盖 generic style instincts。
- 不要把具体 taste feedback 压平成 generic UI adjectives。"More premium" 不是 diagnosis；"caption baseline drifts above the Chinese line" 才是。
- 如果 screenshot 暴露的是 regression、broken render、timing issue 或 generated asset defect，而不是 taste，route to `/hunt`，并保留 visual evidence。

**Boundary**：如果 fix 需要改变 3 个或更多 components，或它暴露的是 direction problem 而不是 specific bug，暂停并运行完整 direction lock 后再继续。

**Redesign priority order**（重做 existing UI，而不是从零构建时）：font replacement → color cleanup → hover/active states → layout and whitespace → replace generic components → add loading/empty/error states → typographic polish。这个顺序在最大化 visual lift 的同时，最小化每一轮的 blast radius。完整规则在 `references/design-reference.md`。Common traps 和 absolute CSS bans 在 `references/design-traps.md`。

## Lock the Direction First

**开始任何 component、page 或 visual work 前**：列出同类别 2-3 个 mature products（例如 Notion、Linear、Typora、iA Writer、Raycast），并各写一句说明它们如何解决眼前 specific problem。然后再写代码。只有任务纯 cosmetic（color、spacing、copy）时才跳过。

写任何代码前，直接询问用户；如果环境有 native question 或 approval mechanism，使用它：

1. **Who uses this, and in what context?** Analyst dashboard 不同于 landing page 或 onboarding flow。如果答案是 sidebar + main workspace layout，见下方 "App shell exception"。
2. **What is the aesthetic direction?** 精确命名：dense editorial、raw terminal、ink-on-paper、brutalist grid、warm analog。"Clean and modern" 不是 direction。如果用户命名 reference site 或 product（"feels like Linear / Claude.ai / Vercel"），不要把它当 direction 接受，而是从中提取 3 个 concrete properties：button radius philosophy、surface depth treatment（shadow vs background step vs border）和 accent color family。改用这些命名。

   **Shortcut for well-known brands**：见 `references/design-reference.md` 中的 "Brand preset flow"。先询问，运行 preset，再对 generated file 做 decompose。
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

用一句话说明 chosen direction，然后加载 `references/design-reference.md` 并检查 tech stack conflicts table。写第一个 component 前，命名 single CSS strategy。对 token decisions（color、font、motion），加载 `references/design-tokens.md`。对 aesthetic quality review 和 production structure，加载 `references/design-aesthetic-quality.md`。

写任何代码前，用三行总结 direction：
- **Visual thesis**：用一句话说明 mood、material 和 energy，例如 "warm brutalist editorial with high-contrast ink type and rough paper texture"
- **Content plan**：hero -> support -> detail -> final CTA，每项一行。对 **app/dashboard surfaces**：跳过 marketing structure，默认 utility mode（orient、show status、enable action），除非明确要求，不要 hero。
- **Interaction thesis**：2-3 个会改变页面感受的 specific motion ideas，例如 "hero text slides in on load, section headers pin while content scrolls beneath, CTA pulses on hover"

对 production 或 multi-page UIs，把 thesis 扩展成 `references/design-reference.md` 中的 9-section DESIGN.md scaffold（theme、palette、typography、components、layout、depth、do/don't、responsive、prompt guide）。对 single component，三行足够。

## Non-Negotiable Constraints

`references/design-reference.md` 已在 direction lock 期间加载。它拥有 full rules：typography、OKLCH color、motion timings、layout defaults、CSS-pattern bans、accessibility baseline 和 complexity matching。应用它们。不要在这里重述。

## When Asked For Options

给至少 3 个 variations，且跨 genuinely different dimensions（density、typography、color、layout、motion）。完整 variation framework 见 `references/design-reference.md` 中的 "Options guide"。只差 accent color 的三个 options 不算三个 variations。

## Gotchas

| What happened | Rule |
|---------------|------|
| 用 Inter 当 display font | 它没有表达。选一个有 personality 的字体 |
| 三张 cards、相同 shadows、相同 padding，像模板 | 如果替换内容不需要 layout changes，重做 |
| 没打开 browser 就声称看起来正确 | 脑内正确的 code 可能在 browser 里坏掉。打开它 |
| 选择 glassmorphism，却忽略 mobile constraint | `backdrop-filter` 在低功耗设备上昂贵。命名 tradeoff |
| Light-mode app：white panel 放在 white background 上，视觉不可区分 | 相邻 nested surfaces 必须有视觉差异。要么 background step（sidebar vs main ≥4% lightness difference），要么最小 shadow `0 1px 3px rgba(0,0,0,0.10)` |
| 用重设计整个 surface 来修 visual polish | 先定位 concrete visual delta，再做最小 material、opacity、geometry 或 typography change 解决它 |
| 添加 setting 或更响亮 control 来解决 UI noise | 先移除 misleading affordance 或选择 quiet default |
| 英文看着没问题，localized text overflowed | handoff 前测试 long words 和 localized strings，尤其是 buttons、tabs、nav 和 compact cards 内部 |
| 依赖 `...` truncation 让 text 塞进 fixed-width slot | 改为保证 fit：压缩 format、限制到完整 segments，或 hard-trim 且不显示 glyph。Metric 和 label footers 绝不能 tail-truncate 成 ellipsis |

## Aesthetic Review

在 significant build phases 后以及 handoff 时，重新阅读 direction lock 的 visual thesis。如果屏幕上的内容漂向 generic default，识别最先坏掉的 specific element（typeface、color、card treatment、spacing），并在继续前修复。

handoff summary 前运行这些 checks：
- 第一屏中 brand 或 product 是否 unmistakable？
- 是否有一个 strong visual anchor（真实 imagery，不是 decorative gradient）？
- 只扫 headlines 是否能理解页面？
- 每个 section 是否只有一个 job？
- Cards 是否真的必要，还是只是 default styling？
- Motion 是否改善 hierarchy 或 atmosphere，还是只是 ornamental？
- 如果移除所有 decorative shadows，design 是否仍显 premium？
- AI Slop Test：扫描第一屏是否有 default patterns（reflex font、purple-to-blue gradient、centered hero with two CTAs side by side、three identical cards、generic top nav）。如果无意出现，修 typography、color 或 layout，直到全部消失。

如果任何 check 失败，先修。请用户在 full width 和 375px 下验证；如果 layout 在 mobile width 坏掉，handoff 前先修。

结束时包含：
- Aesthetic direction，用 2-3 句命名并说明理由
- 解释 non-obvious choices：typeface、color decisions、layout logic
- 替换 placeholder content 为 real content 的 instructions

handoff 后停止。
