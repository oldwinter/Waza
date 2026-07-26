# Project Audit Mode（全项目 scorecard）

当请求是全项目质量 scorecard 时，由 `check` 的 Mode Picker 加载。它不同于按 diff 范围工作的 default review，也不同于批量处理 issue 的 triage。

本 mode 进行单次、全项目质量评估。

**流程**

1. 在目标仓库运行 `python3 <skill-base-dir>/scripts/audit_signals.py --root <project>`，把 `<skill-base-dir>` 替换为本 skill 的 base directory。脚本输出带标签的 block（从 `=== FILE SIZE HOTSPOTS ===` 到 `=== DENYLIST IN BUILD ===`），每个 block 以 `status: PASS|WARN|FAIL|N/A` 结尾。
2. 浏览 `FILE SIZE HOTSPOTS` 中最大的 source files，通常 3-5 个；若架构已经清晰可提前停止。
3. 阅读 `CLAUDE.md` / `AGENTS.md` / `README.md`，先理解项目自身 conventions，再按通用规则判断。仓库的 agent guidance 也是审计 surface：确认其中命令和路径仍存在，把 stale、冲突或可删除的规则作为 finding 报告。
4. 应用下方四轴 rubric。每轴独立评分 0-10，总分为算术平均值。
5. 报告每一项影响 axis score 的 finding；尽可能附 `file:line`、severity（CRIT/STRUCT/INCR）和一行修复。某轴没有 finding 是有效结果，不要为凑数填充。
6. 只输出到 **terminal**，不要在目标仓库创建文件。用户后续要求“保存”时，再提供 `./docs/<project>-audit.md`；默认结果是临时的。

**Rubric**

| Axis | 覆盖内容 |
|---|---|
| Architecture | 模块边界、耦合、抽象层与平铺重复、single source of truth |
| Code Quality | 文件大小约束、去重、可读性、非显然行为的注释 |
| Engineering | 测试、CI gate、版本协调、安装 URL pinning、打包状态 |
| Perf and Risk | hazard、scope creep、分发风险、隐私策略、第三方 blast radius |

**评分锚点**

- 9-10：纪律极佳，只剩 polish 项
- 7-8.5：整体扎实，有清晰的定向改进
- 5-7：可以工作，但存在结构性债务
- 低于 5：建议进行显著返工

项目在自身文档或注释中已有合理解释的 WARN 不算 finding；引用该解释并跳过。不要机械地把 WARN 转为 CRIT。`status: N/A` 表示该 surface 不存在，例如没有 packaging script；保持不评价，不把它当作正面信号。

**输出模板（terminal）**

```
Project: <name>
Overall: X.X / 10

Architecture: X / 10 -- one-line summary
Code Quality: X / 10 -- one-line summary
Engineering:  X / 10 -- one-line summary
Perf & Risk:  X / 10 -- one-line summary

Findings
[CRIT] <file:line> -- <issue>
       why: <reason grounded in signal or read>
       fix: <concrete action>
[STRUCT] ...
[INCR] ...

Top 3 highest-leverage moves
1. ...
2. ...
3. ...
```

除非用户要求后续实施，否则报告完成后停止。Audit mode 不修改目标仓库中的文件。
