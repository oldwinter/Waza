# Visual Quick-Fix Mode

当请求是修正现有 screen 上边界清晰的视觉问题，而不是构建新界面时，由 `ui` 加载。

用户提出带具体症状的窄范围视觉修复时激活：overflow、文字被裁剪或异常换行、未对齐、间距失衡、对比度/可读性问题、本地化文字放不下，或紧凑响应式布局破损。本 mode 用于修复现有 surface，不用于重设计。

流程：

1. 阅读当前 UI 证据：截图、已渲染页面、native view 或负责该区域的 component。
2. 用一句话说清准确的视觉缺陷。
3. 进行能修复该缺陷的最小材质、几何、间距、对比度、排版或文字适配修改。
4. 验证真实运行 surface 或生成 artifact。检查长单词、本地化字符串、紧凑状态，并在适用时至少检查一个窄 viewport。Terminal 输出也算 rendered surface：修改 CLI 文本或布局后，重新运行命令并阅读实际输出，检查整个输出中的列对齐、block 间距和 icon 一致性，而不只看改动行。
5. 若修复涉及三个及以上 component、改变产品行为，或暴露出方向问题，停止并切换到 `references/mode-screenshot-iteration.md`，或 `SKILL.md` 的 Lock the Direction First section。

**间距统一规则。** 一个 spacing 或 sizing 值调了三次仍不对，问题就是结构而不是数值：把 N 个独立值合并为一个共享命名 token（`Spacing.s4`、`--gap-content`），outer container padding 默认等于 inner element gap。spacing system 细节见 `references/design-reference.md`。

**固定高度 action slot，统一 typography。** 任何根据状态替换 children 的 container（status bar、action slot、toolbar row、menu item）都必须在所有状态使用同一 font size。只改变 fill、stroke、opacity、color 或 icon，不改变字号。`secondary 13px` 与 `primary 14px` 的 1pt 高度差会在状态转换时形成可见抖动。同一 slot 中的 CTA pill button 使用相同字号，通常为 14px，通过 background 和 border 区分，而不是 typography。

**Loading 不是 empty。** 正在 loading、measuring、indexing、refreshing 或等待权限的 surface 必须呈现 pending state，不能显示最终空状态文案。只有请求完成且结果为空时才显示“nothing found”。刷新时若保留旧结果，应明确显示为 stale，或用 progress 替换；工作仍在进行时绝不能闪现最终 empty state。

**有安全边界的 action design。** 对 cleanup、delete、uninstall、reset 或 permission-changing surface，不能为了看起来更简单而隐藏可恢复性。只有 target user 能理解每一行，并拥有足够身份信息来验证安全性（按需包括 name、source、owner、path、preview、recovery implication）时，才适合 bulk select、auto-select、one-tap delete 或 destructive “recommended” default。若行内容是 opaque identifier、推断出的 leftover 或仅机器可读的 path，应优先采用 review-first UI、current-target scope、禁用 destructive affordance 或说明性分组，而不是更快的批量控制。减少点击次数的 feature request 不足以剥夺用户验证变更的能力。

**安静的产品边界。** 点击更少、control 更多，并不天然更好。先移除误导性 affordance，再添加替代 control；diagnostic 和 alert 使用安静的默认值；先修复不稳定的 motion cadence，再调整速度或新增 motion preference。当前 UI 暗示了无法支持的 action、state 或 promise 时，先移除这种暗示。完成 surface 也遵循同一原则：先突出用户要的唯一结果，解释放到 summary row 后的 details overlay；没有内容支撑的 affordance 必须隐藏，例如空的“0 skipped”入口或与点击整行重复的按钮。
