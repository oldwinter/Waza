只基于 pasted data 工作。

Input bundle：settings.local.json、GITIGNORE、CLAUDE.md（global）、CLAUDE.md（local）、hooks、MCP FILESYSTEM、MCP ACCESS DENIALS、allowedTools count、skill descriptions、CONVERSATION EXTRACT

Tier: [SIMPLE / STANDARD / COMPLEX]。只使用匹配 tier。

## Part A: Control + Verification Layer

Hooks checks：
- SIMPLE：Hooks optional。只 flag broken ones，例如 wrong file types。
- STANDARD+：项目 primary languages 预期有 PostToolUse hooks。
- COMPLEX：conversations 中 frequently-edited file types 都预期有 hooks。
- ALL tiers：如果 hooks 存在，verify schema：
  - 每个 entry 需要 `matcher` 和 `hooks` array
  - 每个 hook 需要 `type: "command"` 和 `command`
  - File path 可能通过 `$CLAUDE_TOOL_INPUT_FILE_PATH` 可用
  - 缺少 `matcher` 会在所有 tool calls 上 fire
- ALL tiers：flag 每次 edit 都跑 full test suites；优先 fast checks 以获得 immediate feedback。
- ALL tiers：flag 没有 output truncation 的 commands，unbounded output 会 flood context。
- ALL tiers：flag 没有 explicit failure surfacing 的 commands。

allowedTools hygiene, ALL tiers：
- 只 flag genuinely dangerous operations：sudo *、force-delete root paths、*>* 和 git push --force origin main
- Do NOT flag：path-hardcoded commands、debug/test commands、brew/launchctl/maintenance commands，这些是 normal personal workflow entries

Credential exposure, ALL tiers：
- Project-scoped secrets 只有在 committed、shared 或存储于 non-gitignored project files 时才是 [!]
- GITIGNORE section 中的 `ignored only by non-project rule (...)` 视为不足；推荐 repo-local ignore rule。
- 不要仅因为 credentials 有意存放在那里就 flag `~/.mcp.json` 这类 user-scoped files

MCP configuration, STANDARD+：
- 检查 enabledMcpjsonServers count，>6 可能影响 performance
- 检查 filesystem MCP 是否 configured allowedDirectories
- 如果 `~/.claude/projects/.../tool-results/*` denials 显示 breakage，输出一个会 append narrowest missing path 的 `python3` one-liner

Model name validation, ALL tiers：
- 检查 settings.local.json 中的 `model` fields。Valid model IDs 遵循 `claude-*` pattern（例如 `claude-opus-4-6`、`claude-sonnet-4-6`、`claude-haiku-4-5-20251001`）。任何 non-`claude-*` model ID（例如 provider-specific alias 或 outdated name）都是 [!]，wrong model name 会静默浪费整个 session 且没有 output。
- 如果 model name 看起来像 third-party alias 或包含 unusual characters，flag for manual verification。

Prompt cache hygiene, ALL tiers：
- 检查 CLAUDE.md 或 hooks 中 system context 的 dynamic timestamps/dates，它们会 break prompt cache
- 检查 hooks 或 skills 是否 non-deterministically reorder tool definitions
- Flag mid-session model switches，例如 Opus→Haiku→Opus，它们会 rebuild cache 且可能 cost more
- 如果 detect model switching，推荐改用 subagents

Three-layer defense consistency, STANDARD+：
- 对 CLAUDE.md NEVER/ALWAYS items 中每条 critical rule，检查：
  1. CLAUDE.md declares the rule：intent layer
  2. Skill teaches 该 rule 的 method/workflow：knowledge layer
  3. Hook deterministically enforce 它：control layer
- Flag 只存在于一层的 rules，single-layer rules 很脆弱：
  - CLAUDE.md-only rules：Claude 在 context pressure 下可能忽略
  - Hook-only rules：edge cases 没有 flexibility，也没有 teaching
  - Skill-only rules：没有 enforcement，也没有 always-on awareness
- Priority：聚焦 safety-critical rules：file protection、test requirements、deploy gates

Verification checks：
- SIMPLE：不要求 formal verification section。只有 Claude 未运行任何 check 就 declared done 时才 flag。
- STANDARD+：CLAUDE.md 应有 Verification section，包含 per-task done-conditions。
- COMPLEX：conversations 中每类 task type 都应 map 到 verification command 或 skill。

Subagent hygiene, STANDARD+：
- Flag hooks 中缺少 explicit tool restrictions 或 isolation mode 的 Agent tool calls。
- Flag hooks 中没有 output format constraint 的 subagent prompts，free-form output 会污染 parent context。

## Part B: Behavior Pattern Audit

Data source：最多 3 个 recent conversation files。只 flag clear evidence。每个 finding 标记 [HIGH CONFIDENCE] 或 [LOW CONFIDENCE]。

本 section 负责 repeated corrections、missing patterns 和 observable rule violations。不要在这里 duplicate Agent 1 的 rule-design 或 context-budget recommendations。

1. Rules violated：quote NEVER/ALWAYS rule 和 observed violation。不要 inference。
2. Repeated corrections：同一 issue 在至少 2 个 conversations 中被 corrected。
3. Missing local patterns：conversation 中反复强化但 local CLAUDE.md 缺失的 project-specific behaviors。
4. Missing global patterns：~/.claude/CLAUDE.md 缺失的 cross-project behaviors。
5. Skill frequency, STANDARD+：只报告 directly observed usage。少于 3 sessions 时标记 [INSUFFICIENT DATA]。对 verified <1/month skills，retire them to AGENTS.md docs。
6. Anti-patterns：只 flag directly observable 内容：
   - Claude 未运行 verification 就 declaring done
   - 用户跨 sessions 反复解释相同 context，missing HANDOFF.md 或 memory
   - 超过 20 turns 的 long sessions 没有 /compact 或 /clear

在两个 sections 下返回 bullet points：
[CONTROL LAYER: hooks issues | allowedTools to remove | cache hygiene | three-layer gaps | verification gaps | subagents issues]
[BEHAVIOR: rules violated | repeated corrections | add to local CLAUDE.md | add to global CLAUDE.md | skill frequency | anti-patterns (tag each with confidence level)]
