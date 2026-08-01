# Mode：生成 Image Asset

用于由模型生成而非代码排版的 diagram、architecture illustration、cover 和 social card。本 mode 要阻止一种 rejection loop：生成，收到“难看”的反馈，改一个颜色，再生成；七轮以后才发现分歧从来不在颜色，而在 subject。

## 先定 Spec，再出 Pixels

生成任何内容前，先写好 spec 并取得批准。只写六行，不得更多：

- **一句话说明图片表达什么。** 写 claim，不写 topic。“一个清理 Mac 的 terminal tool”是 claim；“architecture diagram”只是 topic。
- Frame 内每个 string 使用的**语言**。
- **Aspect 和展示位置**（README header、social preview、release body、docs inline）。最小展示位置上的 legibility 决定 type size。
- **Palette 数量**，用数字写明。Generated art 默认会使用超过 diagram 承载能力的颜色。
- **Reference**：用户已经接受的 existing image，或这张 asset 要与之并列的 named product style。
- **绝不能出现**：exclusion list。Version number 和 changelog content 默认放进这里。

跨 sibling repos 只复用已批准的 visual-system constraints。每个 repo 都要重新构建 claim、language、use 和 exclusions。

## 两次拒绝就是 Hard Stop

只统计对 look 的拒绝，不统计 content 修改。第二次拒绝后停止生成并重新对齐：重述那句 claim，询问应与哪张 existing image 并列，再确认 exclusion list。第三次盲目重新生成等于把 rejection 当作 parameter noise；如果新版反而比旧版更差，就证明整个过程没有 anchor。

某个 version 部分正确时，重新生成前先点名要保留的部分。“保留 composition，只改 palette”会收敛；“让它更好”不会。

## Decoration Debt

每一个 mark 都必须编码信息。展示 output 前检查：

- **对每条 rule、border、frame 和 divider 做 removable test。** 删除后不损失信息，它就只是 decoration。
- **Arrowhead 使用最小可辨尺寸，** 不使用 generator 默认值。Oversized arrow 看起来像 clip art，是最常见的 rejection 原因。
- **Logo 使用透明或匹配的背景。** Dark field 上的 logo 带 white halo，说明 source 自带 matte；修 source，不要涂盖。
- **保持 flat field。** Diagram 中的 gradient、glow 和 drop shadow 会制造没有信息意义的 depth，并弄脏 darkest region。
- **控制 line count。** Connector 和 separator 的增长速度比它们承载的信息更快；两个 box 已经相邻时，adjacency 本身就表达了关系。

## Scope 要描述产品本身

Evergreen asset 描述 product，不描述 release。默认把 version string、changelog entry 和 “new in” framing 放进旁边的 text。用户明确要求 release card 或其他 release-specific asset 时，才加入指定 release content，并把较短的有效期视为有意选择。
