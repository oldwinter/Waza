# Rendering Bug Debug Reference

## Rendering Bug Mode

触发时机："PDF looks wrong"、"page break issue"、"font not rendering"、PDF output 损坏、print layout 异常。

先做 static analysis（CSS review），必要时再 reproduce。

### WeasyPrint

- `rgba()` 会导致 double-rectangle bug：改用 solid hex colors
- `page-break-inside: avoid` 经常被忽略：使用 explicit breaks
- Float-based layouts 经常在 page boundaries 处破裂：优先使用 flexbox 或 block
- External font URLs 可能在 render time 被阻止：把 fonts 作为 base64 embed，或本地 host

### Font Loading

- 检查 `@font-face` src paths（relative vs. absolute）
- external fonts 的 CORS headers 必须允许 render origin
- Format support：WeasyPrint 偏好 WOFF/TTF；WOFF2 support 取决于 version
- Missing font fallback = invisible text 或 system fallback glyph

### Page Overflow

- 逐行 debug 前，先计算 content height vs. page height
- 减少 `line-height`、`padding` 或 `margin` 来回收空间
- Orphan/widow control：在 `@page` body rule 中设置 `orphans: 3; widows: 3`

### Browser Print CSS

- 确认 `@media print` rules 存在且没有被 overridden
- `@page` margin 必须考虑 printer unprintable area（最少约 6mm）
- section dividers 使用 `break-before: page` / `break-after: page`
- 在 browser DevTools 中用 `window.print()` 测试，不只看 visual preview
