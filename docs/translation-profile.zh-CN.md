# Waza 中文本地化档案

同步上游后，先读本档案，再翻译新增内容并重建分发镜像。

## 项目定位

- 上游项目：`https://github.com/tw93/Waza`
- 中文 fork：`https://github.com/oldwinter/Waza`
- 主要安装面：skills CLI、Claude plugin marketplace 和 Codex plugin marketplace
- 目标用户：希望直接使用中文工程工作流 skills 的开发者
- 用户安装后实际读取的入口文件：`skills/*/SKILL.md`、相邻 `references/` 与 `rules/`，以及生成的 `plugins/waza/`
- 不应宣传为中文版安装的入口：`https://github.com/tw93/Waza/releases/latest/download/waza.zip`
- 当前同步上游 commit：`30bf563ccba94652081b53a0d574ef91c32516ee`

## 本地化目标

本 fork 是中文本地化发行版，不是逐句对照译文。中文用户安装后读取的 skill、reference、rule 和 plugin mirror 必须保持中文可用，同时保留上游的执行语义、验证约束和安全边界。

## 语气

- 使用直接、紧凑的中文，保留 agent、skill、plugin、workflow、prompt、runtime、frontmatter 等常用技术词。
- 规则先说明 outcome 或 hard stop，再给必要细节。
- 不把上游新增行为简化成宽泛摘要；每条约束都要保留原有强度。

## 术语表

| 英文 | 中文 | 备注 |
|---|---|---|
| skill | skill | 名称、slug 和命令中保留英文 |
| plugin | plugin | Marketplace 和 manifest 语境保留英文 |
| workflow | 工作流 | 固定 mode 名或文件名保留英文 |
| runtime | runtime | 指安装后实际加载环境时保留英文 |
| upstream | 上游 | 指 `tw93/Waza` |
| fork | fork | GitHub fork 语境保留英文 |

## 不翻译清单

- 命令、参数、环境变量、URL、文件路径、包名、skill slug 和 mode filename。
- YAML/JSON/TOML key、frontmatter 字段名和 generator 输入。
- Test fixture、golden string、精确 matcher、placeholder 和执行器依赖的固定字符串。
- `.claude-plugin/marketplace.json`、`.agents/plugins/marketplace.json` 和 `plugins/waza/` 中的生成结构；它们必须由 `make regenerate` 产生，不能手工维护。

## README 中文安装区块

README 必须说明这是社区维护的中文 fork、当前上游同步点和安装后实际读取的中文入口。中文版命令必须使用 `oldwinter/Waza`。上游 `waza.zip` 只可作为上游发行说明，不能描述成会安装本 fork 中文内容。

## 同步后检查

- `git diff --check`
- 精确冲突标记扫描：`rg -n '^(<<<<<<<|=======|>>>>>>>)$' .`
- `make regenerate`
- `make verify-generated`
- `make test`
- `make package`
- Source `skills/` 与 `plugins/waza/skills/` 镜像一致。
- README 中的中文版安装命令指向 `oldwinter/Waza`。

## 项目特殊规则

- `skills/` 是 source of truth；`plugins/waza/`、marketplace metadata 和 installer ref 由 generator 维护。
- 上游新增或修改 skill behavior 时，先改中文 source，再运行 `make regenerate` 更新镜像。
- Waza 固定为八个 skills；上游新增 capability 应落在既有 skill、reference、rule 或 script 中，不能新建第九个 skill。
- Commands、protocol terms、matchers 和 placeholders 保持原样，不能为了中文流畅度改变执行 contract。
