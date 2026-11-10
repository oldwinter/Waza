# Prune Mode

当用户要求精简、修剪或收紧 agent guidance 时加载：全局规则、用户或项目 skills、`AGENTS.md` / `CLAUDE.md`、路径作用域规则、memory index。目标是减少每次 session 的 context，同时不丢失任何约束、不丢失任何能力。当这些目标相互拉扯时，优先级是：保住约束 > 放对层 > 减少字数。多数臃肿来自 guidance 在错误的时机被加载，而不是 guidance 本不该存在。

## Outcome

- 一份 ledger，每个 passage 或每组行占一行：`file:line`、动作（`fix`、`delete`、`move`、`edit`、`keep`）、move 的目标位置，以及原因。无法验证的使用情况、无法测试的行为和范围外的 surface 放进单独的 gaps 列表。
- 从 collector 的 `STARTUP CONTEXT ESTIMATE`（`local_agents_*`、`local_claude_*`、`rules_*`、`skill_desc_*`）和 `PATH-SCOPED CONTEXT`，加上 memory index，给出 always-loaded 变更前大小和变更后估算。项目级 prune 中，`global:` 规则和 machine-wide skills 只作为 out of scope 报告一次，不作为 ledger 行。
- 在用户确认 ledger 之前只报告。repair 阶段只应用已确认的行，并以 Moving and verifying 下的检查收尾。

## Inventory

- 区分每次 session 都会加载的内容和按需加载的内容。始终存在的文件，比更大但很少加载的文件成本更高。
- 依据真实 invocation 记录判断 skill 使用情况，绝不用名称 grep：注入的 skill 列表包含每一个名称。刚安装且零调用不等于未使用。没有记录是 gap，不是证据。

## Decide each passage

- `fix` 排在最前，风险最低：引用已不存在的文件、命令或选项，两段互相矛盾的文字，自称已过时的行，vendor 已改变的工具用法。对照当前代码和官方文档检查，不要凭记忆。
- 当删除不会改变行为时用 `delete`：有能力的模型本来就会遵循的默认行为（编辑前先读、运行测试、处理边界情况）。描述性句子内部常常携带约束（"never writes into `~/.config`"、"uploads no user content"、"stays silent on failure"）；描述可以删，子句必须保留，因为代码展示的是它做什么，而不是它绝不能做什么。不确定时保留，或者对比一个不带该 guidance 的干净 session。一步 quiz 只能证明知识，不能证明长 session 中的保持；任务永远触发不到的 probe 不是证据。
- `keep` 模型无法猜到的内容：用户偏好、被拒绝的方案及原因、产品取舍、机器与环境事实，以及静默陷阱（exit 0，但结果为空或错误）。有明显报错的响亮陷阱不需要 always-on 规则；最多在错误出现的位置给一个 fix 提示。
- 单向门永远不压缩：删除或移动用户数据、金钱、发布、权限、重写已推送的历史。整体移动，措辞不动，或者直接保留。
- 保留原因，丢掉故事。"Because this loses data" 保留；incident 叙述、日期和源 artifact 的大小删掉。带日期的 maintainer mark（`(maintainer 2026-11-08)`）或 decision id（`D281`）是规则所依赖的权威依据，不是故事，要保留。一次性报告、scorecard 或诊断快照是证据：提取出稳定规则，然后丢掉报告。

## Decide placement

| Content | Layer |
|---|---|
| 跨项目的硬约束 | global rules |
| 需要判断或追问的可复用工作流 | skill |
| 项目命令、路径、发布步骤 | project guide |
| 相同输入、相同输出：lookup、status、validation | script or hook |

- 低层只是复述高层时，仅对会加载那个高层的 runtime 算 `delete`；如果项目里还会用到 Cursor 或其他从不读取全局文件的 runtime，那么重复全局规则的项目规则要保留。同一事实存放在多个文件中时，要么由一个源生成，要么只保留一处。
- 同样出现在已发布 surface（站点页面、README、package listing、skill 的生成副本）上的句子属于面向用户的文案，不是 guidance：grep 整棵树，包括生成的镜像，措辞留给用户决定。
- 每个项目只保留一份 project guide。在 Claude Code 中，根目录的 `CLAUDE.md` 会让项目不再读取 `AGENTS.md`，嵌套 guide 也一样；需要 Claude 专属行时，使用以 `@AGENTS.md` 开头的 `CLAUDE.md`。这取决于版本：用下面的 load probe 确认。
- 根目录保留那些无需读取任何文件、一个 conversation 就可能触发的规则（commit、publish、reply、delete），因为路径规则只会在读取匹配文件时加载。发布场景中，red lines 和入口点留在根目录，参数跟随 scripts。
- move 需要一个能自行加载的目标：一条路径规则，或一个嵌套 `AGENTS.md`——Claude Code（没有根 `CLAUDE.md` 时）、Codex 和 Cursor 在该文件夹工作时会读取它。`docs/` 下的文件只有 agent 打开时才加载，所以把 guidance 移到那里后，根目录要留一行说明何时读取。
- 带 `paths:` 的 `.claude/rules` 只到达 Claude Code。使用 Codex、Cursor 或其他读取 `AGENTS.md` 的 runtime 时，必须遵守的规则要留在根 `AGENTS.md` 或嵌套 `AGENTS.md` 中；部署或打包文件夹内的嵌套 guide 必须随包发布。
- skill body 承载每次运行都需要的内容。互斥的 mode 和只有部分运行需要的细节移到 `references/`，由一行标明 trigger 的文字到达。description 说明做什么、何时使用和 `Not for`；近义词列表和多语言 trigger 不放在其中，因为每个 session 都要为它付费。

## Rewrite what stays

- 目标优先于路线：outcome、什么算完成、evidence、output。如果删掉某一步后，模型仍能用另一种方式达到同样结果，那这一步就是路线；只有当顺序本身是约束时（先验证再发布、先确认再删除），才保留它。
- 同一种品质被重复表述三次时，折叠成一个模型本来就会联想到的 leading word。
- 用 NO/OK 对照命名 smell，而不是声明 `be X` 目标。新的 catalog row 折叠进它所实例化的原则；一个概念只用一个名字。
- "read X before doing Y" 形式的文本指令会被不可靠地遵循；应改成在 Y 发生时注入 X 的 hook。注入的 context 可以随 tool result 到达，因此不可逆操作要在第一次尝试时就被拒绝，并把规则作为理由。

## Moving and verifying

- 先移动，再压缩。重写是约束最容易丢失、而所有机械门禁仍然全绿的地方；整行移动能保留原措辞。
- repair 之后，在项目根目录运行 `python3 <skill-base-dir>/scripts/check_moved_lines.py <base-rev>`（目标位于默认指令路径之外时用 `--include GLOB`）。每一条 missing line 都必须对应一条已确认的 `delete` 或 `edit` ledger 行。
- 重新运行 collector：`path_rules_matching_nothing` 必须为 0；每个会删除、移动或上传用户数据的源文件，仍必须匹配 `largest_effective_paths` 中治理它的规则，或通过直接 selector 检查。
- 新增或移动的文件要对照发布范围检查：部署的站点文件夹、package `files`、packaging allowlists。
- load probe 会启动 session，因此需要授权：在移动后的文件中放入一行 sentinel，读取一个匹配文件后向全新 session 询问它，再读取一个不匹配文件后询问一次。然后运行一个真实任务，以及这些规则本来要防的 past failures，并把 diff 交给没有参与写作的 reviewer。
