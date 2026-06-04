# Design Traps and Anti-Patterns

## Common Default Traps

提交前检查以下内容是否无意滑入：

- 白底上的紫色或蓝色 gradient 作为 hero background
- 三段式 hero：large headline、one-line subtext、两个 side by side CTA buttons
- 一组 cards 拥有 identical rounded corners、identical drop shadows、identical padding
- top navigation bar：logo left、links center、primary action far right
- Sections 在 white 和 `#f9f9f9` 之间交替
- 居中的 icon 或 illustration 放在 heading 和 paragraph 上方
- equal-weight columns 的 four-column footer

如果它们有意服务 design，可以出现。不能默认出现。

Final test：如果换入完全不同的 content 后 layout 不改仍然说得通，你构建的是 template，不是 design。重做。

## Absolute Bans (CSS-Pattern Level)

| Pattern | Why | Rewrite |
|---|---|---|
| `border-left` 或 `border-right` 宽于 1px 作为 section accent | admin UIs 中最过度使用的 design touch | 使用 colored dot、short horizontal rule、background swatch 或 typographic weight shift |
| `background-clip: text` gradient text | 纯 decorative，且在 high-contrast mode 下 illegible | 使用 solid brand color 或 typographic weight 强调 |
| `backdrop-filter: blur` glassmorphism 作为 default card surface | 对低功耗设备昂贵，且过度使用 | 通过 background color steps 和 `box-shadow` 构建 elevated surfaces |
| Purple-to-blue gradients 或 cyan-on-dark accent systems | 典型 AI design palette，不传达任何 brand 信息 | 根据 brand words 通过 OKLCH rules 选择 palette |
| Generic rounded-rect card with `box-shadow` 作为 default container | Template thinking | 默认 cardless sections；只有 content type 需要时才添加 card treatment |
| Modals as lazy escape for overflow UI | 打断 flow，破坏 browser back navigation | Inline expand、detail panel 或 dedicated route；只有 action 真正需要 focus-lock 时才用 modals |
| `transition: all` 或 animate width/height/padding/margin | 强迫 browser 每帧 layout recalculation | 列出 exact properties；height reveals 使用 `grid-template-rows: 0fr to 1fr` |

## AI Slop Test

陌生人扫一眼 first viewport，会不会立刻说 "an AI made this"？如果会，committed direction 不够坚决。常见 culprits：reflex font、default purple accent、centered hero 下方接 generic card grid。修 typography、color system 或 layout，直到答案翻转。

## Content Authenticity

看似真实但并不真实的 placeholder copy 会打破 illusion。handoff 前应用这些 rules。

**Sample data:** 不用 generic names（John Doe、Jane Smith），不用 generic company names（Acme Corp、TechCorp），不用 Lorem Ipsum。使用 organic numbers：`99.94%` 而不是 `99.99%`，`$99.00` 而不是 `$100.00`。

**UI copy:** 所有 headings 使用 sentence case；success states 不用 exclamation marks；errors 里绝不使用 "Oops!"。Banned words：Elevate、Seamless、Unleash、Delve、Tapestry、Game-changer、Next-Gen。

**Placeholders:** component 不可用时，使用 labeled placeholder（grey rectangle、monogram wordmark、dashed border）。绝不用 inline SVG 绘制 illustrative imagery。
