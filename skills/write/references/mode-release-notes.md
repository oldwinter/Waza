# Release Note Template Mode

当请求是 release note、changelog entry 或 update-feed 文案时，由 `write` 加载。

激活条件："release"、"changelog"、"version"、"release notes"。

格式默认跟随目标项目风格。若项目没有既有风格，采用编号列表、加粗标签，并用一句话说明对用户的影响；只有项目本来就发布双语 release notes 时才输出双语。有 breaking change 或 deprecation 时明确指出。

### Release Notes Pre-flight

起草前收集风格参考：

1. 阅读目标项目 `CLAUDE.md` 中的 Release Convention / Release Flow section。
2. 阅读目标项目既有 release source，作为风格、长度和密度参考：changelog、release notes、registry page、update feed 或 platform release page。
3. 对 GitHub 项目，`gh` 可用时优先用 `gh release view --json body -R <owner>/<repo>` 读取最近一次 release。非 GitHub 项目使用项目文档或用户请求指定的 release source。
4. 用户提到要比较 sibling project 的 release 风格时，先索取目标 identifier 或 release URL，再获取内容。
5. 匹配参考 release 的 item count、句子长度和语气，不另造格式。
6. 除非参考项目明确采用其他方式，每条 release note 限一句。release 文案不用 emoji，除非目标 surface 明确是 reaction 或庆祝性质的 social surface。

### Release Notes Content Rules

- **按用户可感知 feature 分组，** 不按内部 taxonomy。"Polish"、“细节打磨”、"Misc improvements"、"Chores" 都不是用户可采取行动的类别。按产品 surface（Clean / Uninstall / Status / Settings）或用户可见动词（Faster startup / New keyboard shortcut / Fixed crash on M3）分组。
- **从 `git log <last-tag>..HEAD` 提取，** 不凭记忆。阅读每个 `feat:` 和 `fix:` commit；不要因为 commit 看似很小就省略，从用户视角看，iOS wrapper support、Dock cleanup、AV-vendor protection boundary 都不是“小项”。
- **每项一句话，说明用户可见变化，** 不写实现。"Use `CKDownloadQueue` observer for App Store updates" 不是 release note；"App Store updates now run inside the app instead of opening App Store" 才是。
- **双语结构：** 项目采用双语 release notes 时，在同一个 release item 内放置彼此平行的英文 block 和中文 block，不逐 bullet 交错。支持 HTML 的 update-feed CDATA 使用 heading 分隔语言 block，避免渲染后的 update window 把它们挤在一起。
- **标点：** 中文 block 使用中文全角标点，英文 block 使用 ASCII 标点。
