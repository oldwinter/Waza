# Long-form Article Mode

当输入是约一万字或更长、必须先处理结构再逐行修改的长稿时，由 `write` 加载。

激活条件：编辑超过约 300 行的 Markdown 文章或文件，或包含多个 `##` section、table 和 image 的文章，例如技术长文、blog post、deep dive。

长文的主要问题通常是结构：相同 checklist 在多个 section 重复，正文复述紧邻的 table，list 膨胀，或整个 section 多余。句子层面的 AI 味只占较小部分。单次原地润色看不到也修不好结构问题，这就是普通 `/write` 处理长文时只换了说法却没有减轻赘余的原因。因此本 mode 覆盖两条 Hard Rules：允许结构性删减和合并，输出用于 review 的 change-points，而不是整篇改写 blob。

工作流：

1. **先建图，只读。** 编辑前读完整篇文章，列出所有 `##` section、table、list 和 image。标出三类结构问题：跨 section 重复（同一 checklist / judgment list / core claim 出现两次以上）、复述 table（某 section 的正文逐行重讲上方 table）以及整个多余的 section 或 paragraph。
2. **检验每个 paragraph 的贡献。** 经历、情绪、个人信念、限定条件和解释都可以支撑一个 paragraph。缺少新事实或新来源，不构成删掉它的理由。检查一次编辑是否同时丢失了作者立场或情绪强度，而不只是事实含义；更短、更中性的稿子可能更差。保留 maker 的一手视角：个人验证过的坑、具体成本和真实取舍，远比 AI 生成的穷举分类或复述既有概念有价值。刻意设计的系列标题或栏目名属于作者选择，不是 AI pattern flag。
3. **尊重编辑范围。** 只读请求只给 change-points。明确 rewrite 请求授权在该范围内编辑；常规句子删减不必再次询问。整段删除要在 diff summary 中点名；删除整个 section 或重排 headings 前先询问，除非用户明确要求这类结构工作。
4. **再逐段做 line-level 去 AI 味，** 每个 section 使用对应语言的 references。处理 mirror 时，同时检查含义和母语节奏。
5. **返回用户要求的 artifact。** Repository edits 要保留 frontmatter、code、media、links 和实质性解释，运行站点 build，并报告 scoped diff。Pasted-text rewrite 返回 prose。对编辑后的 prose 执行 Punctuation Gate，但不要为了满足风格规则而改动 technical examples。

不要单次重写四万字文章：这会无声覆盖作者手工打磨的措辞，也无法作为 diff review。对应内容规则见 `references/write-zh.md`“结构级重复与表格复读（长文专项）”。
