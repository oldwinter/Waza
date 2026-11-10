# Product Localization Copy Review

用于 review product pages、release notes、app strings、runtime notifications、appcast 或 update feeds、docs/help pages、legal/privacy copy，以及其他 localized product surfaces。

## Core Principles

1. **编辑前先拆分 surfaces。** Release feed、website page、runtime catalog、help article 和 legal page 可能有意支持不同的 locale sets。不要强迫每个 surface 都对齐最宽的那个。
2. **保留意图和已核实的事实。** 保持 versions、dates、links、placeholders、shortcuts、identifiers 和 legal obligations 稳定。Source language 不是事实权威：behavior claim 被证伪时，在 review 中指出，或在获授权的 surfaces 上统一更正。绝不要为了让句子更好听而发明新的 product policy。一个 fact、term、tagline 或 setting name 的变化，要在同一轮落到所有 copy：该 string 的每个 locale、命名它的 docs 和 site pages、share text，以及引用它的 sibling pages。只改一个 locale，正是各 locale 开始说不同内容的起点。
3. **把 source files 当作编辑目标，不要直接改 generated output。** 只有当项目明确把 generated pages 当 source 时，才 patch generated pages。否则先找到 template、locale JSON、string catalog 或 content partial，然后 rebuild。
4. **review 最终 rendered 或 generated surface。** 翻译在 source file 里可能看起来没问题，但在 button、menu、release feed、notification 或 generated HTML page 里会坏掉。
5. **不要 polish 成通用 marketing。** Native localization 是句子听起来像本地产品，而不是像流畅的销售页。

## High-Signal Failure Patterns

- **Chinese**：literal possessives，比如 plain "Mac" 或 "本机" 就够时却写成 "你的 Mac" 或 "你的设备"；modifier order 让名词产生两种读法（`原生 Mac 笔记本` 会被读成 MacBook 硬件；应写 `Mac 原生的 Markdown 笔记本`）；punctuation 混用；已经有稳定中文对应词的 English words。机器输出式动词、platform UI names 和直译的 developer primitives 见 [write-zh.md](write-zh.md)；只要出现中文 copy，就一并加载。字符级半角/全角 punctuation 和 CJK/Latin spacing 由 `check-punctuation.sh` 检查；本列表保留 locale voice 的判断。
- **Traditional Chinese**：把 Mainland phrasing 直接复制到 Traditional copy；stale locale URLs；对目标 audience 来说过于大陆化或过口语的词。
- **Japanese**：English noun compounds 翻得过紧；项目 style 需要时，product terms 周围缺少 spaces；UI strings 听起来像 manual 而不是 Mac app。
- **Korean**：platform terms 不一致，尤其是 menu bar / menu item wording；过于字面化的第二人称句子。
- **German**：ASCII fallbacks，例如 `fuer`、`Pruef`、`Eintraege`、`Menue`、`Luefter`；user-facing copy 中出现 English developer nouns，比如 "binary"。
- **Spanish**：missing accents，例如 `gestion`、`analisis`、`menus`、`suscripcion`；机械替换导致 invalid forms，比如 `actualizaciónes`。
- **French**：missing apostrophes 或 accents，例如 `L app`、`memoire`、`desinstallation`、`defaut`；当周围文本已使用 French conventions 时，标点前空格也应遵循。
- **Italian**：missing accents 和 articles，例如 `piu`、`non e`、`un app`；机械替换导致 invalid forms，比如 `puòi`。

## Surface Voice Defects

这些与语言无关的 shape 会逃过 translation review，因为单看每个 locale 都读得通。先检查 source string，再检查每个 locale。

- **Parenthetical padding**：把补充 qualifier 追加在括号里。Title、label 和 metric name 不应携带这种内容；拆开句子，或删除 qualifier。
- **Hedged verdict**：给产品已经计算出的结果套上问号或 "maybe / possibly"。Verdict sentence 应直接陈述 verdict；不确定性属于 value，不属于 punctuation。
- **Untranslated domain noun**：把 implementation 借来的术语（ledger、buffer、daemon、quota）直接用作 metric name 或 label。改成用户描述同一事物时会说的词；如果没有这种说法，说明 metric 测量的不是用户要求的东西。
- **Alarming detail**：user-facing string 只报告 failure mechanism，却不说用户下一步做什么。Release notes、error banner 和 update prompt 保留 reader 要采取的动作；mechanism 写进 commit。
- **Glued inline tags**：HTML inline tag（`<b>`、`<span>`、`<code>`）或 markdown emphasis marker 紧贴前后单词，导致 plain text 或 copy-paste 中出现粘连词（`<b>Week</b>Which` -> `<b>Week</b> Which`）。
- **Unnatural translation register**：user policies 或 customer interactions 使用方言、古语或官僚措辞（例如 refund/support policy 里的 "不合用" -> 自然的 "不符合预期" / "觉得不好用"）。
- **Notice-board displacement**：把对话式 UI guidance 或 empty state 写成公告栏腔（`暂无应用` / `暂无数据` 而不是自然的 `还没有应用` / `还没有数据`；把标准平台偏好 `高级` / `Advanced` 改成书面化的 `进阶选项`）。
- **Command vagueness**：把具体可运行的 shell commands 或 navigation breadcrumbs 换成模糊概念（例如用 "运行压缩命令" 代替可运行的 `wsl --manage <distro> --set-sparse true`，或用 "在设置中迁移" 代替精确的 `Settings › Resources › Advanced › Disk image location`）。Troubleshooting copy 需要精确 commands 和 paths，不是抽象描述。
- **Metaphor flattening**：以标准化为名，把产品标志性的 design metaphor 或触感 identity 换成通用 corporate jargon（例如把 paper/layout metaphor 削成行政腔）。
- **Borrowed platform copy**：从另一个平台 catalog 导入的 string 仍带着该平台的 nouns（Mac、Finder、menu bar、Dock）、claims（目标平台没有的 feature）或 conventions（Windows 用 sentence case，却保留 macOS Title Case menu items）。可能只修好一个 locale，其他 locale 仍留着旧平台词，所以要扫描 imported key 的每个 locale。给目标平台单独的 key 和正确值，不要改 shared source，然后把 shared key 从目标平台的 import list 中移除。
- **One control, several names**：setting title、切换它的 shortcut chip 或 tray item、tooltip，以及发布它的 release note 各自漂移成不同名字（Settings 里是 `登录时自动启动`，chip 上是 `开机启动`）。每个 locale 只选一个名字；紧凑位置可以用短形式，但 tooltip 必须使用同一个名字。
- **Blanket fact scrubbing**：过度 polish 或去 AI 味时删掉真实技术事实、product scopes 或 destructive risk disclosures（例如删掉工具适用对象，或隐瞒 reset command 会删除 AI memory 和 backups）。

## Review Procedure

1. 识别 scope 内所有 source 和 generated surfaces。网站包括 templates、locale JSON、content partials、generated pages、language switchers、canonical links 和 route rewrites。App 包括 runtime catalogs、permission strings、update feeds 和 notification copy。
2. 按稳定的 content ID、locale 和 surface 冻结 reading ledger，覆盖 full bodies、titles、descriptions、tables、FAQs、alts 和 captions。分别跟踪 unread、fully read、open findings 和 closed findings。Keyword scans、changed-file counts 和截断阅读都不能证明 full coverage。每个 finding 以 verified、intentionally retained（附原因）或 blocked（点名缺失证据）结案。
3. 对照真实 operation、edition 和 version 核实 claims：product behavior 看 implementation 或 shipping artifact，第三方对比看 official documentation。Release page 只能证明宣布了什么，不能证明每条 implementation claim。区分历史陈述、假设示例和实测结果。检查流畅措辞掩盖的条件：synchronization 不是独立 backup，recovery 依赖保留的数据，symptom 不是唯一 diagnosis。
4. 检查 local voice 和 semantic drift。保留作者提供的故事和判断，不要加通用结论或 sales pitch。使用平台真实的 UI names；把 implementation metaphors 翻成 reader 实际执行的动作。区分 permission 和 feature toggle，区分 temporary mute 和 disabling a service。在每个受影响 locale 重查 all、only、always、because 等量词和因果词。缩短的 label 要保留操作的动词和范围：只做检查的任务不是 "clean"，启动 service 不是 "reset"，清理 stale 或 orphaned entries 不是清空全部。
5. 检查 mechanical artifacts 和 surrounding context：accents、plural forms、placeholders、links，以及误翻的 paths。然后对照修正后的 body 重读 metadata，避免 title 或 FAQ 又恢复已删除的保证。亲自检查 images；正确的 caption 无法修复错误的 diagram label、arrow，或把重叠类别做加成式拆分。
6. 最后一次编辑后 rebuild 并检查最终 generated surface。确认实际 routes、glyph coverage、wrapping，以及受影响处的 dynamic string composition。Acceptance 前对账所有 pending reviewer patches。分别报告 reading coverage、structural checks、rendered validation 和 deployment；不要把未测试的层说成完成。只读 review 只运行安全 diagnostics，并如实列出未执行的 checks。

## Structural Checks Are Not Editorial Authority

- 保留独有 facts、caveats、figures、commands 和 table rows。比较稳定锚点和含义，不要比较翻译后的行数或 heading 列表位置；不同的换行和新增 section 会让这些测量失真。新 locale 是当前 source 的翻译，不是摘要：逐 section 对比是否漏掉 install steps、flags、limits 和 warnings。既有 locale 也会这样漂移：source 后来新增 example block、qualifier（"or a specific mount path"）或 condition（"when Alfred preferences are present"）时，译文可能几个月都不更新，所以要把每个 locale 的 paragraphs 和 code blocks 对照当前 source，而不是它们翻译时的版本。
- 有用的新增内容不是 missing-content failure。如果某个 gate 要求删除正确材料或复制损坏的 source structure，先调查该 gate。Citation 放错位置时，先读懂它支持的 claim，再移动或复制 link。
- 保持 executable command bytes 不变，但要把它们与应本地化的 field templates 区分开。Placeholder 或 key 数量相等，无法发现拼接句、locale-specific separators 或错误复数；要渲染代表性输出。
- 批量编辑前，先用一个已知缺陷和一个正常样例校准 automated findings，并检查强命中和弱命中。English fallback 不是其他语言的 grammar check；保留它们的 punctuation conventions、literal file extensions 和 technical abbreviations。Clean result 只证明 checker 覆盖的规则通过，不证明 natural voice 或 factual accuracy。

## Rewrite Rules

- Placeholders 必须原样保留，包括顺序和类型：`%@`、`%d`、`%1$@`、`{name}` 以及类似 tokens。
- 不要在 code 或 copy 中用 punctuation 拼接 translated fragments。每个 locale 使用完整 sentence 或 format string 更安全。
- 避免 broad find-and-replace，除非随后做 residual scan。大范围 accent fixes 可能产生 broken words。
- 当产品本身这样使用时，product names 和 established UI names 保留英文。
- 共用 README 或 page header 的 sibling products，每个 locale 的语言切换标签和 tagline 句末标点只保留一种约定。确认 outlier 不是既定版本后，再把它对齐到 family form。
- 全项目 UI navigation 和 menu paths 只用一个 breadcrumb separator。项目尚无约定时，使用带空格的 ` › `（U+203A，例如 `Settings › General › Storage` 或 `设置 › 通用 › 存储空间`），不要用 ASCII `>` 或箭头。
- 只 patch 目标字段，不要重新序列化整个 catalog。保留相邻标点和无关编辑；exact-text patch 失败可能只是逗号不匹配，不能证明有并发修改。
- 把 command examples 当作惰性文本。通过只读来源验证行为，不要执行 cleanup 或 troubleshooting examples。直接 patch 文件，不要用可能执行 prose 中反引号或美元表达式的 shell interpolation。

## Output Guidance

Rewrite requests 返回编辑后的 localized copy。Review requests 先按 surface 分组，再按 locale 分组。当 copy 误述 product behavior、privacy、legal terms、version history 或 update availability 时，明确标为 blocker。
