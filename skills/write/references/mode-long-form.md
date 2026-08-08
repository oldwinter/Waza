# Long-form Article Mode

当输入是约一万字或更长、必须先处理结构再逐行修改的长稿时，由 `write` 加载。

激活条件：编辑超过约 300 行的 Markdown 文章或文件，或包含多个 `##` section、table 和 image 的文章，例如技术长文、blog post、deep dive。

长文的主要问题通常是结构：相同 checklist 在多个 section 重复，正文复述紧邻的 table，list 膨胀，或整个 section 多余。句子层面的 AI 味只占较小部分。单次原地润色看不到也修不好结构问题，这就是普通 `/write` 处理长文时只换了说法却没有减轻赘余的原因。因此本 mode 覆盖两条 Hard Rules：允许结构性删减和合并，输出用于 review 的 change-points，而不是整篇改写 blob。

工作流：

1. **先建图，只读。** 编辑前读完整篇文章，列出所有 `##` section、table、list 和 image。标出三类结构问题：跨 section 重复（同一 checklist / judgment list / core claim 出现两次以上）、复述 table（某 section 的正文逐行重讲上方 table）以及整个多余的 section 或 paragraph。
2. **说明每个 paragraph 依靠什么。** 在内部为每段指出支撑它的材料：用户提供的经历、公开来源、可运行 artifact、数字或 quote。若诚实答案只是“进一步解释上一段”或“这是一种可能影响”，该段没有新材料，应作为删减候选。然后做 compression test：删掉三分之一再读。若 facts、actions、judgments 和阅读体验几乎没变，原稿就是 padding，更短的版本才是 draft。
3. **把删改建议写成 change-points。** 每次结构删减或合并都展示 before -> after，让用户选择要采用的子集。绝不默默删除整个 section 或 paragraph；它可能包含其他地方没有的事实，必须先确认（见 `references/write-zh.md`“删段之前先确认信息量”）。
4. **再逐段去 AI 味，** 每个 section 遵循 `references/write-zh.md`。
5. **输出 change-points，而不是 blob。** 展示改了什么，让用户可以 review 并保留自己的手工修改。只有用户明确说“直接改”或 “just rewrite”时，才返回完整改写文本；返回前先执行 Punctuation Gate。

不要单次重写四万字文章：这会无声覆盖作者手工打磨的措辞，也无法作为 diff review。对应内容规则见 `references/write-zh.md`“结构级重复与表格复读（长文专项）”。
