# Screenshot Iteration Mode

当用户提供 rendered surface 的截图，并希望基于这份证据改进界面时，由 `ui` 加载。

当用户发送截图或图片，并附带“这里很丑”“这个不对”“fix this”“looks wrong”等反馈时激活。现有产品就是方向，跳过五问方向锁定。

**流程：**

1. 阅读截图。用一句话描述具体问题：spacing、contrast、alignment、typeface、color、density 或 hierarchy 哪里不对。用户的负面描述有诊断价值时保留原词，不要把“丑”“乱”“不清晰”“怪”稀释为模糊的“更现代”。
2. 修改代码前，等待用户确认诊断。
3. 用户提供 reference screenshot、旧版本或“这个是好的”示例时，先比较当前与 reference，指出视觉差异，再选择修复方案。
4. 若诊断属于已知 UX 问题（split-view sync、infinite scroll、virtualised list、sticky header），写代码前先用一轮调查同类产品中 2-3 个成熟实现，并引用各自做法。纯 cosmetic 修复（color、spacing、copy）可跳过。
5. 找到负责代码：grep component name 或 class，并阅读实际文件。不要依靠记忆或假设文件位置。
6. 应用最小修复。对现有产品，先尝试材质/透明度、几何、间距、排版或文字适配，再考虑重设计 surface。
7. 在 browser、native app、screenshot tool 或 rendered artifact 中验证结果；适用时检查 desktop width 和 375px mobile width。检查长单词、本地化字符串、button label 和 compact state 是否 overflow。host 无法渲染时明确说明，并给出用户需要检查的准确 view。
8. 请用户在 browser 中验证。不得省略此步骤直接交付。

**校准规则：**

- 用户截图是本轮最强的 design brief，在修复完成前始终把它作为判断依据。
- 真实运行产品是最终标准。产品页面、app screenshot、release page 和当前 UI state 优先于通用风格直觉。
- 不要把具体审美反馈压平为通用 UI 形容词。“More premium”不是诊断，“caption baseline 位于中文行上方”才是。
- 若截图显示的是 regression、broken render、timing issue 或 generated asset defect，而不是审美问题，转到 `/hunt` 并保留视觉证据。

**Native screenshot 交接。** 对 native app，一旦已证明 app 能 build、run 并到达目标 view，不要为了最终视觉证明反复与 focus、window ordering 或 coordinate-click automation 纠缠。只做一次边界明确的自动化尝试；若仍不稳定，指出准确 screen，并请用户提供截图继续迭代。这是 visual QA 边界，不能替代 build/run 验证。

**边界：** 若修复需要修改三个及以上 component，或揭示的是方向问题而非具体 bug，暂停并执行完整 direction lock 后再继续。

**重设计优先顺序**（重做现有 UI，而非从零构建）：font replacement -> color cleanup -> hover/active states -> layout and whitespace -> replace generic components -> add loading/empty/error states -> typographic polish。此顺序能在控制每轮 blast radius 的同时获得最大的视觉提升。完整规则、常见陷阱和 CSS absolute bans 见 `references/design-reference.md`。
