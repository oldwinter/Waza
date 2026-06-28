# Design Aesthetic Quality and Production Structure

## App Shell Rules

构建 sidebar + main workspace layout（Slack、Linear、Notion class）时：
- Decorative backgrounds 默认 off
- Surface hierarchy 只使用 background-color steps 和 shadow
- 所有 interactive elements 使用 `active:scale-95`
- Button radius 在每个 component type 内保持一致（从 pill、square 或一个 fixed value 中选一个，不要混用）
- 第一个 component 前先 commit to a named radius scale

## Options Guide

当被要求给 design options 时，至少给 3 个 variations，并分布在 genuinely different dimensions：

- **Dimensions to vary**：visual density、typographic personality、color temperature、layout structure、motion character、amount of decoration、level of abstraction
- **Mix approaches**：一个 option 紧贴 existing conventions，一个 remix brand DNA，一个 deliberately unexpected
- **Progress from basic to bold**：第一个 option safe 且 understandable；后面的 options 逐步 push further
- 只差 accent color 的三个 options 不算三个 variations。要变化 layout、typeface、motion、surface treatment。

## DESIGN.md Scaffold (Optional, Production UIs)

对 multi-page 或 production UI，写第一个 component 前输出一份简短的 `DESIGN.md`-style summary。九个 sections：

1. **Visual Theme and Atmosphere**：用 2-3 句说明 mood、density、design philosophy
2. **Color Palette and Roles**：每个 color token 的 semantic name + value + functional role
3. **Typography Rules**：font family、size scale、weight scale、line-height、letter-spacing
4. **Component Stylings**：buttons（all states）、cards（if used）、inputs、navigation
5. **Layout Principles**：spacing scale、grid columns、whitespace philosophy
6. **Depth and Elevation**：shadow system 或 background-color-step system；描述每个 level
7. **Do's and Don'ts**：5 到 10 条 specific to this project 的 guardrails
8. **Responsive Behavior**：breakpoints、navigation 如何 collapse、touch target minimums
9. **Agent Prompt Guide**：color reference（name: value pairs）+ 3-5 个 inlined all values 的 example component prompts

对 single component 或 quick prototype，跳过此项。Three-line thesis 足够。

## Pre-Handoff Checklist: Strategic Omissions

AI-generated UIs 中最常缺失的 items：

- [ ] **Custom 404 page**：带 clear path back 的 branded page
- [ ] **Back navigation**：每个用户 action 可达的 page 都必须有 path back
- [ ] **Form client-side validation**：inline errors 紧邻每个 field
- [ ] **Skip-to-content link**：作为第一个 focusable element 的 visually hidden `<a href="#main-content">Skip to main content</a>`
- [ ] **Cookie consent**：适用于 EU 或 California jurisdictions
- [ ] **Footer Privacy and Terms links**

这些不是 polish items。它们是 demo 和 shippable product 的区别。

## Reference Material Priority

当 source code 和 screenshot 都可用时：读 code。Source files 包含 exact token values；screenshots 需要猜。

当只提供 URL 时：fetching 只返回 extracted text，没有 layout information。对 visual references，请用户提供 screenshot，不要从 stripped HTML 推断。

## Adding to Existing UI

扩展 existing interface 时，先理解它的 visual vocabulary。写第一行 new code 前匹配以下全部：
- Copywriting tone 和 reading level
- Color palette 和 semantic color roles
- Hover 和 click states：scale、color shift、underline、background fill
- Animation style：duration、easing、interactions 是否 bounce 或 ease-out
- Shadow 和 card treatment
- Layout density 和 whitespace rhythm
- Border radius choices（边角半径选择）

如果换入不同 content 会让 new component 显得 out of place，说明 vocabulary 匹配得还不够。
