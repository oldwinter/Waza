# Long-Running Agent Stop Conditions

当项目使用 `/loop`、autonomous agent 或任何 long-running agent flow 时，由 `health` Step 1c 加载。项目不包含此类流程时完全跳过。

项目必须定义明确 stop conditions。永不停止的 agent 是尚未发生的 budget 和 safety incident。

审计以下四个 hard stop signal；每缺少一项都作为 Structural finding：

1. **连续两个 checkpoint 没有进展。** 触碰相同文件、记录相同错误，没有新 commit/test/output。建议终止 loop 并展示当前状态，而不是继续 retry。
2. **重复出现完全相同的失败。** 同一 stack trace、error message 或 failed assertion 连续出现三次，说明 hypothesis 错误；继续尝试无济于事。
3. **超过 cost 或 token budget。** 项目应声明单次运行 budget（token、API spend、wall-clock minute）。达到 budget 时退出 loop，而不是等到工作完成。
4. **外部 blocker。** 目标 branch 上的 merge conflict、agent 无法解决的 dependency lock、credential 缺失、network unreachable。任一情况都应停止 loop 并询问用户，而不是无限 retry。

Stop conditions 应保存在 tracked project docs（`AGENTS.md`、loop launch script 或专用 config）中，而不应只写在 agent prompt。Prompt 容易被忽略，tracked config 可以强制执行。项目支持时，优先建议 relevant tool 上的 hook（PostToolUse），而不是 prompt 指令：hook 无法被跳过，prompt 可以。提出建议前确认 host 的 hook coverage；某些 agent 只对部分 tool 触发 PostToolUse（例如 runtime 只匹配 shell/Bash），因此必须在文件编辑后运行的 fixup 应放在 Stop 或 session-end hook 中。
