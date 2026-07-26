# AI Maintainability Structural Findings

由 `health` Step 3 为 AI-maintainability lane 加载。Summary mode 读取 `AI MAINTAINABILITY SUMMARY`；deep audit、Complex 项目和明确的 code-rot 请求读取 `DETAIL`。Agent-config lane（instruction drift）仍保留在 `SKILL.md`。下方 `$HEALTH_SCRIPT` 与 `$HEALTH_LAUNCHER` 是 Step 1 已经解析的变量。

**AI-maintainability 缺口。** Summary mode 使用 `AI MAINTAINABILITY SUMMARY`，deep mode 使用 `AI MAINTAINABILITY DETAIL`。项目没有可执行验证命令、non-trivial repo 没有 agent instruction surface，或 doc reference 损坏时，报告 `FAIL`。以下情况报告 `WARN`：instructions 缺少 project map、verification guidance 或 boundary/non-goal language；TODO/HACK marker 过度集中；large source hotspot 缺少 ownership/boundary 和 verification guidance；durable docs 保存 raw one-off review report、scorecard、带日期的 line reference 或 diagnostic dump，而不是稳定 invariant；runtime 支持 path-scoped instruction loading（例如带 `paths` frontmatter 的 Claude Code `.claude/rules/*.md` 或 nested-directory `CLAUDE.md`），但大型 always-loaded instruction file 含有只适用于特定 path 的 domain/language rule，导致每个无关 session 都支付完整 context cost。最后一种情况应添加 `paths` frontmatter，或把 block 移到 nested `CLAUDE.md` / skill，不应删除 rule。缺少 `docs/`、`specs/`、`.specify/`、`HANDOFF.md`、`CHANGELOG`、issue template 或 PR template 默认只作 informational，除非项目复杂度使其成为 handoff 必需项。处理 stale report 时，先把稳定规则提取到公开 instructions、rules、references 或 verifier scripts，再移除或归档临时报告。

**从 conversation 提炼 guidance。** Health audit 读取近期 agent conversation 时，不要建议把 conversation 或 scorecard 直接复制进 docs。改为执行 candidate-matrix 筛选：

| Field | Question |
|---|---|
| Repeated failure | 是否在多次 fix、release、agent 或用户报告中复发？ |
| Durable invariant | 能否把教训写成稳定规则，而不是带日期的 incident summary？ |
| Target layer | 应放在项目 instructions、Waza skill、global rule 还是 private memory？ |
| Verifier | 是否有 deterministic command、script、artifact check 或 runtime smoke 可以强制执行？ |
| Redaction risk | 是否必须包含 local path、issue number、customer detail、machine state、secret 或未公开 release fact？ |

Layering rule：项目特有的 command、app name、artifact name 和 release ritual 留在项目中；cancelled-release review gate、native-freeze evidence ladder 等可复用工作流属于 Waza skill；通用的诚实与验证规则属于 global CLAUDE/AGENTS；私人偏好和单机事实留在 memory。无法通过 redaction-risk 字段的教训，不得进入公开 guidance。

Scope 不只按 layer，还按 load surface。规则即使保留在项目内，如果没有绑定适用位置，每个 session 仍会支付 context：language/framework rule 使用 file-type `paths` scope；project-domain rule 绑定 source directory（`paths` frontmatter 或 nested-directory `CLAUDE.md`）；只有真正 cross-cutting 的 constraint 才在 always-loaded root 无条件加载。只对一个 path 有意义的 rule 不属于 always-loaded file。

**集中的 fix chain。** 运行 `git -c core.fsmonitor=false log --oneline --since='2 weeks ago' | grep -i fix`，按 area（`:` 或 `(` 前的 prefix）分组。同一区域短期内出现 3 个以上 fix commit，表示缺少结构性 invariant：每次 fix 都是在猜一条尚未写下的规则。报告 Structural `WARN`，包含 area name 和 fix count，并建议在 `AGENTS.md` / `CLAUDE.md` / project rules 中加入明确规则，记录这些 fix 正在收敛的 invariant。同一文件被集中 fix 4 次以上，比不同文件上的分散 fix 信号更强。

**Hotspot ownership 缺口。** Deep mode 读取 `HOTSPOT OWNERSHIP SURFACE`。若最大的 source file 超过 hotspot threshold，而 `AGENTS.md` / `CLAUDE.md` / shared instruction files 没有说明 owner、必须保持稳定的 boundary 和覆盖它的 verification command，报告 Structural `WARN`。不要仅凭大小把已有文档说明的大文件视为 code rot；部分 module 本来就有意保持较大。

**缺少稳定 verifier wrapper。** 若 repo 通过 CI、script 或 manifest 暴露多个 verification command，但 `Makefile` 没有 `check`、`test` 或 `verify` target，报告 Structural `WARN`。这是 AI-maintainability gap，因为 agent 需要一个稳定的默认入口，不代表项目本身已损坏。

在项目根目录执行 quick check，复用 Step 1 解析的 `$HEALTH_SCRIPT`：

```powershell
powershell.exe -NoLogo -NoProfile -File "$HEALTH_LAUNCHER" maintainability . summary
```

Linux 与 macOS：

```bash
bash "$(dirname "$HEALTH_SCRIPT")/check-maintainability.sh" . summary
```

Deep audit：

```powershell
powershell.exe -NoLogo -NoProfile -File "$HEALTH_LAUNCHER" maintainability . deep
```

Linux 与 macOS：

```bash
bash "$(dirname "$HEALTH_SCRIPT")/check-maintainability.sh" . deep
```

Action 要具体且 non-invasive：添加或修复最小有用 instruction surface，增加一条可执行 validation command，记录 hotspot ownership 和 tests，只在 boundary 已清晰时拆分，或修复 broken reference。不能只凭 script output 提议大范围 rewrite。

**Broken doc references。** 扫描 `AGENTS.md`、`CLAUDE.md`、`.claude/rules/*.md` 和所有 `.claude/skills/*/SKILL.md`，查找形如 `@<path>`、`~/.claude/rules/<name>.md`、`~/.claude/skills/<name>/`、`docs/<name>.md` 或 `references/<name>.md` 的 reference。逐一确认目标在磁盘上存在。报告每个“已引用但缺失”的 pointer，并附 source file 和 line。

常见问题：

- project-level rule 引用了从未创建的 global rule file，例如 `~/.claude/rules/swift.md`。
- `CLAUDE.md` 使用 `@AGENTS.md` placeholder，但实际 `AGENTS.md` 缺失或为空。
- skill body 引用 `references/<name>.md`，实际只有 `references/<name>-v2.md`。
- rule file 引用了已删除的 skill path。

在项目根目录执行 quick check，复用 Step 1 解析的 `$HEALTH_SCRIPT`：

```powershell
powershell.exe -NoLogo -NoProfile -File "$HEALTH_LAUNCHER" doc-refs .
```

Linux 与 macOS：

```bash
bash "$(dirname "$HEALTH_SCRIPT")/check-doc-refs.sh" .
```

Checker 会从 project root 解析 `@...` 和 `docs/...`，展开 `~`，从每个 `.claude/skills/<name>/SKILL.md` 目录解析 `references/...`，检查一行中的所有 reference，跳过 fenced code example，并在任一目标缺失时以非零状态退出。

缺失 reference 作为 Structural finding，而不是 Critical；只有该文件被声明为项目 hard dependency 时例外，例如项目 release skill 所需的 `release.md`。

**Broken Markdown references。** Deep mode 中，`check-maintainability.sh` 还会扫描 repository Markdown links。当它们指向缺失的 local file 时，报告为 Structural finding，尤其是 agent 后续工作可能遵循的 design、security、release 或 handoff doc。

**Stale verifier cache output。** 若 validation output 指向已删除的 temp worktree，或不存在的 `/tmp` / `/private/tmp` file，使用下列命令解析 captured log：

```powershell
powershell.exe -NoLogo -NoProfile -File "$HEALTH_LAUNCHER" verifier-output . <log-file>
```

Linux 与 macOS：

```bash
bash "$(dirname "$HEALTH_SCRIPT")/check-verifier-output.sh" . <log-file>
```

只对用户提供的既有 command output，或当前 audit 中生成的 output 使用此 script。不要为了给 checker 提供输入而运行项目测试。已知 action 包括 `golangci-lint cache clean`、`go clean -cache -testcache` 和 `npm cache verify`；未知 tool 使用 diagnostic rerun action。
