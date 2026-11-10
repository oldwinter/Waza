# Technical Writing: 有歧义的指令

用于读者必须执行动作或区分系统状态的段落：installation steps、operating instructions、error text、tool descriptions，以及 agent instructions 的纯措辞编辑。在混合 README 或文章中，只把这些段落套用本 reference；其他部分继续使用语言 reference 和作者 voice。

目标是让读者能唯一还原含义，而不是写出最短句。`SKILL.md` 的 Core Stance 和 Hard Rules 仍然适用。清楚的指令不需要重写。Review 或重写指令，绝不授权执行它、改变 tool behavior，或重新设计 prompt 的 authority 和 workflow。

## 歧义目录

只使用能解释真实误读的行。这些是语义检查，不是 word ban，也不是要套到每句话上的 checklist。

| Smell | 判断边界 | 示例 |
|---|---|---|
| Name drift | 同一 scope 内，同一 entity 或 action 使用既定名称。不同概念保留不同名称，并保留精确的 UI labels、API identifiers、flags、paths 和 placeholders。相似动词不能证明动作相同。 | 如果两个名字指同一对象，把 "Select the workspace. Delete the project." 改成 "Select the workspace. Delete the workspace."。不要动 "Check the address. Confirm delivery."：这两个动作不同。系统区分 `cancel`、`timeout` 和 `fail` 时，保持区分。 |
| Missing actor or referent | 有两个可能 actor/object 时点名。actor 无关或未知时保留 passive voice；绝不为了把句子改成 active 而编造 actor。 | "After the worker notifies the scheduler, it retries" 需要证据说明哪个 component 重试。source 无法解决时，询问或 flag 歧义。无主语的边界句会被读成 product guarantee："Renders only trusted local HTML" 承诺了工具可能不执行的检查，而 "Render only HTML you trust" 说明读者的义务。 |
| Buried condition or negation | 每个 condition、exception 和 prohibition 都要贴近它约束的动作。保留条件是 sufficient 还是 necessary，以及 limit 是否 inclusive。不要把 qualifier 移到它不约束的动作上。 | "Restart only if validation passes" 不能变成 "If validation passes, restart"：前者把通过设为必要条件，后者要求只要通过就重启。 |
| Flattened logic | 保留 all/any、and/or、not/except，以及每个 list item 的 scope。拆句不能把 alternatives 变成必须按顺序执行的步骤。弄清 "otherwise" 分支测试什么：允许尝试动作和成功完成是不同的条件。 | "Requires an owner or an editor with approval" 对 owner 是否需要 approval 有歧义。先解决这个事实，再写 permissions list。"If automatic recovery does not succeed, notify the operator" 不能变成 "If automatic recovery is disabled, notify the operator"：enabled recovery 也可能失败。 |
| Lost sequence or dependency | 分开动作能让顺序更清楚时，就分开，并保留 prerequisite 或 completion condition。紧凑且无歧义的 action pair 可以放在一起。只给真正的 sequence 编号；不要为 alternatives 制造顺序。 | "After the upload completes, delete the local copy" 必须保留 "completes"。"Start the upload. Delete the local copy" 允许过早删除。 |
| Compressed grammar or noun stack | 恢复名词之间的关系，保留理解它们所需的句子成分。短 UI labels 和既定 technical terms 不是 defective sentences。 | "worker task cancellation policy" 需要上下文：取消 worker tasks 的 policy，与 workers 用来取消 tasks 的 policy 不同。没有证据时，不要选更顺的那个解释。 |
| Changed obligation or state | 区分 requirement、permission、capability、confidence 和 time。去掉 nominalization 只有在这些含义都保留时才有用。写给 agent 的 instruction 不会把 recommendation 变成 mandatory。 | "The client must perform validation" 可以改成 "The client must validate."。保留 "You should inspect the report" 和 "The request may have failed"："Inspect the report" 加重了义务，"The request failed" 加重了确定性。已完成的工作要与 queued 或 started 的工作区分。 |
| Remedy without evidence | 把观察到的 error 与可能原因、建议的下一步分开。纯措辞重写不增加 remedy 或 requirement，即使它很合理。要求实质性新增时，要 grounded in source 或 implementation，并与保留文本区分。 | "Connection timed out" 不能证明 credentials 无效。不要改成 "Your password is wrong. Sign in again."。"The export can be incomplete" 本身不指示 retry 或 integrity check。 |

## Controlled-English 外溢

STE 启发的清晰原则在这里有用；通用的 controlled-English grammar 不适合。只要自然时态、`sign in` 这类 phrasal verbs、领域词汇和句子节奏承载了正确含义，就保留它们。没有固定的 sentence、paragraph 或 noun-count 上限。英文词数限制不适用于中文。项目既有的 punctuation conventions 仍然适用。

术语一致性以文档及其 product model 为 scope，不是全局的一词一义字典。只有 audience 需要且 source 确立了含义时，才定义陌生术语；不要给每份 output 追加 glossary。优先使用真实 interface term，而不是用户在屏幕上找不到的简单同义词。UI navigation paths 遵循 [write-product-localization.md](write-product-localization.md) 的 breadcrumb rule。

## Meaning Check

按读者能做的决定，把编辑后的段落与 source 对比：谁对什么动作、在什么条件下、按什么顺序、有什么 permission 或 obligation、得到什么明确结果。保留 values、units、ranges、exceptions、uncertainty 和字面 interface strings。如果任一版本允许另一版本排除的动作或解释，交付前解决差异。不要为了填满这些类别而添加缺失事实："supports multiple providers" 不意味着 "keeps all data on your device"，warning 也不是未写明的 recovery procedure。

Punctuation 和 pattern checks 只覆盖它们实现的语法；clean result 不能证明含义被保留。Synonym match 或长句是读上下文的理由，不是编辑命令。评估本 mode 时，在同一 request 和 runtime 下，把一个有缺陷的段落与附近正确的段落配对，检查实际 output 是否同时修正了歧义、且没有禁止的改动。加入 no-edit cases，例如 "Select Sign in"、动词相似但动作不同、清楚的长句，以及作者自己已完成的 draft。用具体情境评估 permissions 和 failure branches，包括允许但未成功的动作；只保留关键词不能证明这些情境仍产生相同指令。

遇到未解决的歧义，review 要列出 competing readings；rewrite 要问一个聚焦问题，或保留并 flag 受影响短语。不要静默选择最容易编辑的解释。按 `SKILL.md` 处理请求的 output shape 和 author-draft change lists；默认不要追加 rule score 或 compliance report。

## 来源与边界

这是原创改编，参考了 [asd-ste100-skill 的 writing-rule 摘要](https://github.com/danyuchn/asd-ste100-skill/blob/master/references/writing-rules.md) 及其 [scope 与 preservation 指南](https://github.com/danyuchn/asd-ste100-skill/blob/master/SKILL.md)。它使用选定的 clarity principles，不是该项目的 strict 或 STE-flavored modes。Waza 不复制 approved dictionary，也不认证 ASD-STE100 compliance。

被明确要求评估对某项 writing standard 的 compliance 时，查阅适用版本的主文本，并在评估中写明版本。报告实际检查的要求和 coverage gaps。Partial checks 只能支持 partial conclusions；缺少 source text 或 evidence 就不能声称整体合规。STE 使用 [ASD-STE100 官方来源](https://www.asd-ste100.org/)。[STEMG 关于 STE 与 AI 的白皮书](https://www.asd-ste100.org/assets/files/WhitePaper-ASD-STE100_and_AI.pdf) 讨论了 AI 辅助技术写作与 review 的局限。
