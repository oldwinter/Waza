# Waza Agent Guide

这个文件是 Waza 仓库的 canonical agent guide。`CLAUDE.md` 是指向它的 symlink，所以 Claude Code 和 Codex 会看到同一份内容。编辑此文件，不要编辑 `CLAUDE.md`。

## Project

Waza 是面向 engineering workflows 的 skill collection。仓库包含八个 skills：`think`、`design`、`check`、`hunt`、`write`、`learn`、`read` 和 `health`。

## Repository Map

- `VERSION` - lock-step version 的单一事实源。每个 `SKILL.md` frontmatter、marketplace entry、README install URL 和 installer `WAZA_REF` 默认值都必须与此文件一致。
- `skills/RESOLVER.md` - skill set 的 trigger 和 routing table。
- `skills/*/SKILL.md` - 单个 skill entrypoint。
- `skills/*/agents/` - specialist reviewer 或 inspector prompts。
- `skills/*/references/` - 只在需要时加载的 supporting references。
- `skills/*/scripts/` - 确定性的 helper scripts。
- `rules/` - install 和 validation flows 使用的共享 writing/behavior rules。`rules/durable-context.md` 是共享 Durable Context Preflight preamble；六个带 optional memory context 的 skills 会在自己的 preflight section 链接到它。
- `.claude-plugin/marketplace.json` - **generated**。编辑 `VERSION` 或每个 skill 的 `SKILL.md` frontmatter 后运行 `make regenerate`；不要手工编辑。
- `.agents/plugins/marketplace.json` - **generated** Codex repo marketplace。它让 Codex 在 plugin install 时指向 `plugins/waza`；不要手工编辑。
- `plugins/waza/` - **generated** Codex plugin tree。它镜像 `skills/`、`rules/` 和 `plugins/waza/.codex-plugin/plugin.json`；编辑 source files 后运行 `make regenerate`。
- `packaging.allowlist` - 打进 `waza.zip` 的路径 default-deny 清单。新的 shippable assets 必须显式加入这里；其他内容都会被排除。
- `.github/workflows/` - public test 和 release automation。`release.yml` 会先运行 `make test` 再运行 `make package`，让 tagged commit 经过与 PR 相同的 suite。
- `scripts/build_metadata.py` - Claude 和 Codex marketplace metadata、README install URLs、Codex plugin mirror files 以及 installer-script `WAZA_REF` 默认值的 codegen。通过 `make regenerate` 运行；CI 用 `make verify-generated` 检查 drift。
- `scripts/verify_skills.py` - 唯一的 validator entrypoint。覆盖 frontmatter、references、marketplace、resolver、links、table pipes、trigger overlap、rule-file presence、README install string、English coaching guard 和 AI-attribution leak detection。
- `scripts/package-skill.sh` + `scripts/packaging_filter.py` - 从 `packaging.allowlist` 构建 `dist/waza.zip`。
- `scripts/setup-rule.sh` + `scripts/setup-statusline.sh` - public install helpers；`WAZA_REF` 默认值由 codegen 固定到当前 release tag。
- `Makefile` - smoke discovery 和 packaging entrypoints。新增一个 `tests/test_<name>.sh` 文件就会自动创建对应的 `smoke-<name>` target。
- `tests/test_*.sh` - 每个 surface 一个 smoke；会 source `tests/test_helpers.sh` 来获取 tmpdir、repo-copy、stub-curl factories。

## Commands

```bash
make test             # verify-docs + verify-generated + verify-routing + verify-scripts + all smokes
make regenerate       # rewrite marketplace.json, README install URLs, installer WAZA_REF defaults
make verify-generated # drift check used by CI; non-zero if regenerate would change anything
make package          # build dist/waza.zip from packaging.allowlist
```

在对 skill behavior、packaging、scripts、marketplace metadata 或任何 generated 内容做有意义修改前，运行 `make test`。如果只编辑了 frontmatter 或 VERSION，也要运行 `make regenerate`，并把生成的 `.claude-plugin/marketplace.json` / `README.md` / installer 变更与 source edits 一起提交。

## Skill Design Rules

添加 capability 前，先有意识地决定它属于哪一层：

| Question | Yes | No |
|---|---|---|
| 用户是否需要判断、适应场景或追问？ | Skill | Script or rule |
| 同样输入是否总会产生同样输出？ | Script or rule | Skill |
| 它是否只是 lookup、list、status check 或 invariant check？ | Script or rule | Skill |
| 行为是否会随 conversation context 改变？ | Skill | Script or rule |

例子：`verify_skills.py` 是 script；`rules/english.md` 和 `rules/chinese.md` 是 rules；`/think`、`/hunt`、`/check` 和 `/health` 是 skills。

- 把 adaptive、judgment-heavy workflows 放进 skills。
- 把 deterministic checks、lookups 和 table-driven validation 放进 scripts。
- `rules/anti-patterns.md` 负责跨 skill 的 always-on behavioral guardrails，也就是无论 active skill 是哪个都适用的 AI failure modes。每个 skill 自己的 gotchas 留在各自 `skills/*/SKILL.md` 的 Gotchas table；只有当某个 gotcha 对八个 skills 都完全适用时，才放进 `rules/anti-patterns.md`。
- Catalogs 的职责是合并，不是累积。这适用于 `rules/anti-patterns.md` rows，也适用于每个 reference example list、banned-phrase list 和 replacement table（`skills/write/references/*`、`skills/design/references/*` 等）。添加 row、pattern、banned phrase 或 example 前，先找到它实例化的现有 row 或 principle，并折叠进去；不要追加近义词，也不要为已经在上文表达过的 rule 加第三种编码。措辞要足够通用，可以发布到本仓库之外。Reference file 如果在 numbered pattern 下重复列出已经覆盖的 items，那是 drift，不是 coverage。
- skill description、trigger 或 scope 改变时，同步更新 `skills/RESOLVER.md`。
- 每个 `description` 都要足够具体，便于 automatic routing。
- 写 skill entrypoints 时 outcome-first：说清目标结果、什么算完成、哪些约束和证据重要、最终回答或 artifact 应该长什么样。详细流程放到 mode sections 和 references。
- 八个 `SKILL.md` 要保持同一套 skeleton，读起来像一个 set：第一行是 `🥷` 加一句 tagline，然后是 Outcome Contract；会读 memory 的 skills 紧接着放 Durable Context Preflight；再放 modes、must-obey list、Gotchas 和 Output。同一个概念在各 skills 中只用一个名字（skill 的 must-obey constraints 叫 `Hard Rules`；`Hard Stops` 是 check 里单独的 merge-blocker list）。Tables 保持紧凑的 `| a | b |`，不要手工对齐；numbered step sequence 要连续，side-checks 放在某一步下面，不要插在两个步骤之间。
- 避免把无关 workflows 混在一个宽泛 skill 里。
- 八个 skills 是硬上限。不要提出第 9 个 skill，也不要拆分现有 skill。Behavior additions 应落在 `references/`、`rules/`、`scripts/` 或 `rules/anti-patterns.md`，不要新增 skill。
- Waza 保留通用程序员能力。Project-specific constraints 应从公开 repository context 或用户提供的 task context 中提取。
- 把 `code-review` 视为 Waza `check` 的 invocation alias，不要当成另一个通用 skill。
- Waza `check` 必须保持 project-aware，但不能依赖未发布的本地文件。它从 target diff、public docs、manifests、CI config 和 user-provided context 中提取 commands、generated artifacts、risk areas 和 release rules。
- Distribution files 要对 Claude Desktop 和 plugin installs 自包含。release ZIP 可以把 sub-skill bodies inline 到 generated root `SKILL.md`；source-of-truth skill content 仍保留在 `skills/*/SKILL.md`。
- 如果添加 `templates/` 目录，把可复用 public scaffolds 放在那里，并有意识地纳入 packaging/validation rules。
- README 保持简短：新读者应能在 30 秒内理解 Waza。详细 rules 属于 `skills/<name>/SKILL.md`、`rules/*.md` 或本文件。不要在顶部堆 promotional sections。

## Adding Or Changing A Skill

任何 new skill 或 meaningful behavior change 都走这条路径：

1. 创建或更新 `skills/<name>/SKILL.md`；description 保持具体、可触发，并包含 `Not for ...` exclusion。Frontmatter `metadata.version` 必须匹配顶层 `VERSION` 文件。
2. 更新 `skills/RESOLVER.md` routing rows，让新 skill 或变化后的 scope 可达；不要手工编辑 `.claude-plugin/marketplace.json`，改用 `make regenerate`。
3. 保持 Waza public：在 runtime 从 public repo context 中提取 project-specific details，不要硬编码 private paths、credentials 或 one-machine workflow。
4. 把 deterministic enforcement 放进 `scripts/` 或 `rules/`；skill body 只保留 adaptive judgment。
5. 如果 new skill 会发布新的 top-level asset，例如根目录下的新目录或用户需要的新 helper script，把路径加入 `packaging.allowlist`。默认行为是排除。
6. frontmatter / VERSION 编辑后运行 `make regenerate`，release handoff 前再运行 `make test` 和 `make package`。

## Maintainability Invariants

- 当同一 metadata 出现在多个 distribution files 中时，优先使用 generation，而不是 drift lint。`VERSION` 和 `skills/*/SKILL.md` frontmatter 是 generated marketplace 与 install metadata 的事实源。
- 可执行程序保持为真实文件，不要写成 shell scripts 或 Makefile recipes 里的 heredocs。Shell wrappers 可以委托给 Python helpers，但大逻辑应放在可 import 的 `.py` 文件里，并有 `py_compile` coverage。
- Smoke tests 放在 `tests/test_*.sh`；`Makefile` 应发现并运行它们，不要嵌入大段 test bodies。
- 避免 hidden runtime dependencies。如果某个 script 需要非 stdlib Python package、external CLI 或 network resolver，在 CI/docs 中声明，并添加一个缺失时会失败的 smoke test。
- Shipped skill scripts（`skills/*/scripts/`）必须保持 self-contained：只 import standard library，并能从任意 target project 运行。不要把看起来共享的 helpers（file walks、parsers）抽到 root `scripts/` module。那个 module 只用于 dev/CI，不在 `packaging.allowlist` 中；import 它会把 standalone shipped tool 绑定到 install layout，可能破坏 `npx skills add` installs。两个 shipped scripts 之间有良性重复是正确 tradeoff；如果 drift 重要，就在原地对齐副本，不要共享 module。
- 会 fetch remote content 的 installer scripts 必须默认指向 release tag。只有显式 bleeding-edge override 才使用 `WAZA_REF=main`。
- One-off review reports、scorecards 或 diagnostic snapshots 不属于 durable docs。把 stable rule 提取到 `AGENTS.md`、`CLAUDE.md`、`rules/`、`skills/*/references/` 或 verifier script，然后丢弃 report。
- Project case studies 是输入，不是 Waza policy。只提升可迁移 workflow rule；project-specific commands、paths、release rituals 和 safety constraints 留在该项目的 public context 中。
- 提炼 lesson 时去掉 provenance。Rule 之所以值得保留，是因为它能预防什么，而不是因为它来自哪个 incident。删掉 "this came from a 615-line / 40k-char article" 或 "from one real review round" 这类 framing；留下 rule，丢掉 origin story。Source artifact 的 metrics 永远不是 load-bearing。
- Self-governing files 必须 collapse，不只是 append。当文件自己的 header 禁止 monotonic growth（例如 `rules/anti-patterns.md` 和 `skills/write/references/write-zh.md`）时，要执行它：把 new specifics 折叠回 existing principles，并删除 re-indexes，不要把 header 当装饰。
- Local-only instruction overlays 不是 durable source of truth。如果某条 rule 必须指导未来 contributors 或 packaged agents，就放到 tracked public docs 或 shipped skill/rule files。
- Local review 和 health checks 必须覆盖 modified、staged 和 untracked files。New helpers、tests、references 和 packaging allowlists 在提交前都是 review surface 的一部分。
- Runtime install contracts 是 agent surfaces 的 source of truth 的一部分。Marketplace metadata、plugin manifests、generated mirrors 和 package archives 只有在 installed path 能在 clean environment 中工作后，才算完成。

## Distribution Rules

- `.claude-plugin/marketplace.json`、`.agents/plugins/marketplace.json`、`plugins/waza/.codex-plugin/plugin.json`、`skills/RESOLVER.md` 和每个 `skills/*/SKILL.md` 必须在 skill names、descriptions、versions 和 source paths 上一致。
- `npx skills add tw93/Waza` 默认应安装八个 direct coding skills。不要添加 source-root `SKILL.md`，它会阻止 nested skill discovery。
- Codex marketplace entries 必须 resolve 到 `plugins/waza`，不是 repository root。Codex marketplace、plugin manifest 或 plugin mirror changes 后，不只检查 JSON shape，还要验证 isolated install flow。
- Plugin mirror generation 必须在 generator 和 verifier paths 中过滤 local cache 和 noise files，包括 `__pycache__`、`*.pyc`、`.pytest_cache`、`.ruff_cache`、`.mypy_cache` 和 `.DS_Store`。
- Claude Desktop 使用 `scripts/package-skill.sh` 构建的 release ZIP。
- `scripts/package-skill.sh` 会构建一个 public archive，其中恰好有一个 generated root `SKILL.md`；nested `skills/*/SKILL.md` files 会为 packaged installs inline 进去。
- 不要让 packaged skills 通过个人 home-directory caches 或 machine paths 解析 scripts 或 references。应相对 installed Waza directory 解析。
- `rules/` 下的 rules 是 shared public behavior，不是 project-private memory。

## Verification

- Skill behavior changes：运行 `python3 scripts/verify_skills.py` 和相关 smoke target。
- Packaging changes：运行 `make package` 并检查 generated archive。
- Marketplace、resolver 或 root dispatcher changes：运行 `python3 scripts/verify_skills.py`，并确认每个 marketplace source 都指向存在的 skill directory。对于 Codex plugin changes，还要运行 clean install smoke，例如 `CODEX_HOME=$(mktemp -d) codex plugin marketplace add <repo>`，随后运行 `codex plugin add waza@waza` 和 `codex plugin list`。
- Non-trivial diffs：release handoff 前运行 review workflow。
- Documentation-only changes：检查 internal links 和 command names。

## Commit And Release

- Commit convention：`{type}: {description}`，type 是 `feat`、`fix`、`refactor`、`docs` 或 `chore`。
- 保持 commits atomic。除非每个文件都是 `make regenerate` 产生的同一批 codegen output，否则一个 commit 触碰超过约 20 个文件时，应拆成 packaging / docs / scripts / per-skill units。
- Release tags 使用小写 `v{version}`。
- 发布 release assets 前重建 packaged artifacts。发布前运行 `make package`；CI 应在 published releases 上上传 ZIP。
- 在说 Waza release ready 或 done 之前，分开证据层：source diff、CI、generated metadata、package contents、GitHub release assets、npm registry/dist-tag state 和 installed-runtime smoke。缺失层是 explicit gaps，不是 implied passes。
- GitHub release 发布且 assets 已验证后，用 `gh api` 添加所有正向 release reactions：`+1`、`laugh`、`heart`、`hooray`、`rocket` 和 `eyes`。从 tag 解析 release id，向 `repos/<owner>/<repo>/releases/<id>/reactions` POST 每个 reaction，然后重新读取 reactions 确认。
- **绝不要添加 `-1` 或 `confused` reactions**。这些是负向信号，给自己的 release 添加会显得自我贬低。只添加上面六个正向 reactions。

### Release title and body template

- Title：`V{version} {Codename} {emoji}`，例如 `V3.8.0 Forge 🔨`。
- Body：使用下面结构的 Markdown。

```markdown
<div align="center">
  <img src="..." width="120" />
  <h1>Waza V{version}</h1>
  <p><em>tagline</em></p>
</div>

### Changelog

1. **SkillName**: One sentence on what changed and its user effect.
2. ...

### 更新日志

1. **技能名**: 一句话说清楚改了什么以及对用户的影响。
2. ...

Update: `npx skills add tw93/Waza@latest` · [Claude Desktop](https://github.com/tw93/Waza/releases/latest/download/waza.zip) · ⭐ [tw93/Waza](https://github.com/tw93/Waza)
```

- 每个 item：`**Label**: one sentence`。加粗 label 是 skill 或 module name；description 先说清发生了什么变化。
- Style：面向工程师，不用营销语言。英文和中文 items 必须按编号一一对应，共 5 到 8 项，每项一句。
- Footer：update command + star + repo link，用 `·` 分隔。
