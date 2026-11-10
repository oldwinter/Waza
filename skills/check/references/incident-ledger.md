# Incident Ledger 与 Review Evals

当 fix 针对的是已经到达用户或已发布 build 的 defect，当 review prompt、skill、reviewer persona 或 model 发生变化，或用户询问 review 是否抓到了该抓的问题时，由 `check` 加载。项目自己的 ledger 和 layer 名称优先于这里的形状。

## Ledger

面向用户发布的项目维护一张表，惯例路径是 `docs/incidents.md`，每个到达用户或已发布 build 的 defect 一行。该行与 fix 落在同一个 change 中；在维护 ledger 的项目里，没有对应行的 fix 视为未完成。

```markdown
## Incidents

<!-- layers: write-time, unit, integration, review, e2e, release, field -->

| ID | Reported | Symptom | Introduced | Fixed | Layer | Caught by |
|---|---|---|---|---|---|---|
| I-01 | 2026-01-02 | What the user saw, in their words | unknown | 1a2b3c4d | unit | `test_name_that_fails_on_the_old_code` |
```

- `Symptom` 是观察到的 failure，不是 mechanism。
- `Introduced` 是引入 defect 的 commit，或 `unknown`；它衡量 defect 在代码中停留多久。
- `Layer` 是本来最早应该抓到它的 layer，取自项目的有序列表（最早在前）。复盘问的是哪个 layer 漏了它，绝不问是谁写的。
- `Caught by` 用反引号点名现在能在 pre-fix code 上失败的 test 或 gate：test function 或 test title，或 gate script 的 repository path。没有 live catcher 的行只是备注，不是 coverage。

用 `python3 <skill-base-dir>/scripts/incident_ledger.py --root <project>` 校验：IDs 唯一、dates、能 resolve 的 commits（shallow clone 中只做 shape check，脚本会说明）、来自 `<!-- layers: ... -->` 声明或 `--layers` 的 layers，以及 catchers 是现有 workspace files 或 Python、shell/Bats、JS/TS test files 中可识别的 declarations（包括未 ignored 的新文件）。其他语言和 declaration 形式需要显式 gate path；找到 declaration 不能证明它会执行或能抓到 defect。把它接入项目的 fast check，这样 test 被重命名或删除时，对应行会失败，而不是静默变成孤儿。项目可以保留自己的 checker 和更严格的 catcher resolver；contract 相同。

## Replay eval

Ledger 是 review 自身的 regression suite。review prompt、skill、persona 或 model 变化时，以及信任新 reviewer 之前，重新运行：

1. `incident_ledger.py --plan` 打印每行的 pre-fix revision（`<Fixed>^`）和 fix 触及的文件。
2. 在 detached worktree 中，用变化后的 reviewer 检查这些文件在该 revision 的状态，不要告诉它 symptom。
3. 统计 recovered rows：finding 在正确位置点名 defect，且 trigger 与 symptom 匹配，才算 recovered。按 layer 报告 recovered / total，并与上一次运行的数量并列。
4. 用同样的 reviewer 检查几个 known-clean changes（已合并、之后没有 fix 触及的 changes）。那里的每个 finding 都是 noise；把数量与 recovered rows 并列报告。靠同时制造双倍 noise 来提高 recovered rows 的 reviewer 并没有更好。

Recovered rows 下降会阻止采用该 change，直到给出解释。把运行计数记录在项目保存 review history 的地方，不要写进 ledger rows。

## Recurring classes

当两个 incidents 或两轮 review 共享同一个 bug class 时，下一次 fix 应落在源头：lint rule、枚举 call sites 的 source gate、type，或 routed project rule，并让更早的 rows 指向这个 catcher。在最后一个 per-site test 旁边再加一个，不是 fix。
