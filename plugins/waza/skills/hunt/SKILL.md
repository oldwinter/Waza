---
name: hunt
description: "Find the root cause before applying fixes for errors, crashes, regressions, failing tests, broken behavior, and screenshot-reported defects. Use when users report in any language that something is broken, regressed, failing, crashing, or no longer works. Not for code review or new features."
when_to_use: "排查, 查查, 报错, 崩溃, 不工作, 不对, 跑不通, 以前是好的, 回归, 截图回归, 判断错误原因, 判断为什么报错, 反复修不好, debug, regression, used to work, broke after update, why broken, not working, what's wrong, fix error, stack trace"
dispatch_intent: "Error, crash, regression, screenshot-reported defect, test failure, stale cache, runtime boundary, why broken"
---

# Hunt: 修复前先诊断

Prefix your first line with 🥷 inline, not as its own paragraph.

**更新检查（非阻塞）。** 开始前运行 `bash scripts/check-update.sh` 一次；如果输出一行，就转告用户，然后继续。它每天最多运行一次，只读取公开 version file，不发送任何数据，失败会静默跳过。

打在 symptom 上的 patch，会在别处制造新 bug。

## Outcome Contract

- Outcome:应用任何 fix 前，先识别 root cause。
- Done when:一句话能解释 cause，每个 observed symptom 都能被它解释，并且 fix 或 handoff 已通过 reproducible check 验证。
- Evidence:source trace、repro command 或 UI path、logs 或 state、targeted test/build output，以及 UI 或 native defects 的 runtime evidence。
- Output:root cause、fix 或 handoff、verification result，以及任何 unswept sibling risks。

**在能用一句话说清 root cause 前，不要碰代码：**
> "I believe the root cause is [X] because [evidence]."

命名 specific file、function、line 或 condition。"A state management issue" 不可测试。"Stale cache in `useUser` at `src/hooks/user.ts:42` because the dependency array is missing `userId`" 可测试。如果不能这么具体，就还没有 hypothesis。

## Diagnosis Signals

Good progress：log line 匹配 hypothesis；运行前就能预测 next error；理解 root cause 到 symptom 的 propagation path；能写出在 old code 上失败的 test。每出现一个信号，commit 前再找一条 independent evidence。

Hypothesis quality gate：对 hypothesis 采取行动前，列出所有 observable symptoms，而不只是用户最先报告的那个。Hypothesis 必须解释每个 symptom；如果只覆盖一部分，它只是 symptom-level guess，不是 root cause。对 timing-dependent issues（flicker、intermittent failure、race condition），诊断前先可靠复现。

Rationalization warning："I'll just try this" 表示没有 hypothesis，先写出来。"I'm confident" 表示运行 instrument 证明它。"Probably the same issue" 表示从头重读 execution path。"It works on my machine" 表示先枚举每个 env difference 再排除。"One more restart" 表示逐字读取 last error；没有 new evidence 时，绝不 restart 超过两次。

## Durable Context Preflight

See [rules/durable-context.md](../../rules/durable-context.md) for when to read durable context, the read-order budget, and the memory-type mapping.

对于 `/hunt`，diagnostic constraints 是 `decision`、`preference` 和 `principle` entries；`pattern` 和 `learning` 可以作为 hypotheses 的种子。Current code, logs, repro steps, tests, environment versions, and remote state override memory。Durable context 只是 hypothesis fuel。它永远不能替代 fresh root-cause sentence、reproducible symptom list 或 current state 的 evidence。

## Hard Rules

- **fix 后 same symptom 是 hard stop；"let me just try this" 也是。** 两者都表示 hypothesis 未完成。再次碰代码前，从头重读 execution path。
- **三个 failed hypotheses 后停止。** 使用下面的 Handoff format 暴露检查过什么、排除了什么、还不知道什么。询问如何继续。
- **claim 前先 verify。** 绝不凭记忆陈述 versions、function names 或 file locations。先运行 `sw_vers` / `node --version` / grep。没有结果 = 重新检查路径。
- **External tool failure：切换前先诊断。** 当 MCP tool 或 API 失败时，先确定原因（server 是否运行？API key 是否有效？Config 是否正确？），再尝试 alternative。
- **System/tooling symptoms 需要 lower-layer baseline。** 在责怪 visible app、generated file 或 top-level feature 前，先测量 raw lower layer：OS capture versus post-processing、runtime service versus UI、compiler/toolchain versus test assertion、network/API versus client handling。让 baseline 推翻的 hypotheses 退场，不要围着它们打转。
- **注意 deflection。** 当有人说 "that part doesn't matter" 时，把它当成 signal。一个人回避检查的区域，往往正是问题所在。
- **Visual/rendering bugs：static analysis first。** 添加 console.log 或 visual debug overlays 前，先在 DevTools 中 trace paint layers、stacking contexts 和 layer order。Logs 捕捉不到 compositor 做了什么。只有 static analysis 失败后才添加 instrumentation。
- **Behavioral / lifecycle / async bugs：instrument first，不要失败后才加。** Window lifecycle、event delivery、navigation、focus、timer、state-machine 和 async-ordering bugs 几乎无法只靠 static reading 解决。不要等 fix 失败后才加 logs。当 hypothesis 涉及 "this callback fires before/after that one"、"this state should be X when Y runs" 或 "this object should still be alive here" 时，**立即把 log 作为形成 hypothesis 的一部分加入**，再写任何 fix。没有 runtime evidence 的 hypothesis 是猜测；连续两次猜测就是 hard-stop signal。区分 visual-rendering bugs（compositor behavior 需要 DevTools，不是 logs）和 pure-logic bugs（wrong formula、off-by-one），后者 static analysis 足够。
- **Tuning magic numbers 超过三轮：停止，统一。** 当 spacing / sizing / threshold value 调整三次后仍然不对，bug 是 structural，不是 numeric。把 N 个 independent values 替换成一个 named token（`Spacing.s4`、`--gap-content` 等），并验证 asymmetry 是否掩盖了 missing constraint。能熬过 tuning 的 asymmetry 是 structural；继续 tuning 不会收敛。
- **修 cause，不修 symptom。** 如果 fix 触碰超过 5 个文件，暂停并向用户确认 scope。

## Fix Scope Discipline

如果 bug 真的需要先 refactor，例如不改变 shared interface 就无法处理 cause，暂停、明确命名该 refactor，并询问。不要静默打包进去。长成 refactor 的 bug fix 是 separate PR。

## Bisect Mode

当出现这些触发时激活："以前是好的"、"之前是好的"、"used to work"、"上一次提交还是对的"、"broke after update"，或用户记得 specific good commit 或 version。

0. 先保护用户 worktree：运行 `git status --short --branch -uall`。如果存在 modified、staged 或 untracked files，不要在 current checkout 里 bisect。从同一个 HEAD 创建 temporary detached worktree，在那里运行 bisect，完成后 `git bisect reset` 并移除 temporary worktree。如果无法创建 temporary worktree，停止并请求 explicit cleanup/stash approval。
1. 找 candidate good tag：`git tag --sort=-version:refname | head -10`，或询问用户 last known-good commit。
1b. 如果 last-good version 只落后一两个 release，先运行 `git diff <last-good-tag>..HEAD -- <suspect path>` 并直接阅读 delta。Regression 通常能在这个 diff 里看到，而且成本远低于完整 bisect。只有当 diff 太大或 culprit 不明显时，才继续 bisect。
2. 开始 bisect 前定义 non-interactive pass/fail test command。没有 reproducible check，Bisect 没价值。
3. 运行：`git bisect start && git bisect bad HEAD && git bisect good <tag-or-hash>`
4. 每一步 bisect 会 checkout 一个 commit。运行 test command。标记：`git bisect good` 或 `git bisect bad`。
5. 让 bisect 驱动流程。除非明确要求，不要 jump ahead 或 skip commits。
6. 当 bisect 命名 culprit commit，只读那个 diff。识别引入 regression 的 specific line。
7. 完成后运行 `git bisect reset`。

Large files 只读一次，并从 notes 引用，不要每个 bisect step 重读。

## Repeated Regression / Screenshot Reference Mode

当用户说同一个 issue 在 fix 后仍然不对，提供 "good" screenshot/version/file，或描述某个 visual result 以前是正确的时激活。

把 reference 当成 evidence，不是 decoration：

1. 列出每个 reported 和 visible symptom，必要时保留用户具体用词（"still slow"、"not clear"、"尖刺"、"先显示上一个内容"）。
2. 识别 reference oracle：last-good commit/tag、old build、fixture、screenshot、downloaded artifact，或用户描述中的 expected state。
3. 编辑前定义 pass/fail check。对 visual bugs，这可以是 narrow screenshot checklist 加上 render view 的 command；对 behavioral bugs，优先 automated regression test 或 deterministic repro。
4. 比较 current vs. reference，并命名 exact delta。当 evidence 指向 broken render、race、font pipeline 或 state path 时，不要把 visual defect 泛化成 "style polish"。
5. 如果一次 attempted fix 后 same symptom 仍存在，停止并基于 evidence 重建 hypothesis。不要在已被推翻的 explanation 上继续叠 patches。

如果 issue 是纯 subjective UI taste，route to `/ui`。如果是 rendering、state、timing、build output、font generation，或来自 known-good version 的 regression，留在 `/hunt`。

## Scope Blast Mode

在修复 root-cause pattern 后、声明 bug done 前激活；用户说 "举一反三"、"举一反三深入看看" 或 "其他地方有没有同样问题" 时也激活。同一 shape 往往藏在其他 N 个地方；忽略 blast 的 one local fix 会把 N - 1 个 bugs 留在 tree 里。

1. 提取 pattern signature：产生 bug 的 specific function name、regex、API call、CSS selector、lock acquisition、validation skip 或 input boundary。
2. 在 repo 中 `grep -rn <pattern>`，排除 generated dirs、build output、vendored deps。对 class-of-bug patterns（例如 "any handler missing the lock"），grep surrounding shape，不只 grep literal text。
3. 列出每个 match。对每个 match 用文字回答：这里是 same bug 吗？选择 fix / leave（解释为什么 safe）/ unsure（询问用户）。不要静默跳过 match。
4. 在 Outcome block 放入 blast report 前，不要声称 "fixed"。

Common triggers:
- 一个 page 上修了 visual bug：检查使用同一 component、layout 或 media-query breakpoint 的其他 page。
- 一个 handler 中修了 race：检查每个获取同一 lock 或触碰同一 shared state 的 handler。
- 一个 entry point 修了 validation skip：检查到达同一 downstream sink 的每个 entry point。
- 针对一个 input shape 修了 regex / parser：检查同一 regex / parser 的每个 caller。

如果 blast 暴露 unrelated bugs，列出来，但除非用户同意，不要在此 PR 中修；scope creep 本身就是 anti-pattern。

## Confirm or Discard

Instrument-first rule 已在上方 Hard Rules（behavioral/async bugs）中定义；这里说明如何处理它的结果。运行那个在 hypothesis 错误时会失败的 probe，然后读取结果。如果 evidence 与 hypothesis 矛盾，彻底丢弃它，并根据 probe 刚展示的事实重新定向。不要把 fix 叠在被推翻的 hypothesis 上，也不要因为代码 "looks like" 原因就继续保留它。

## Runtime Evidence Ladder

声称 bug fixed 前使用这条 ladder：

1. Source trace：命名能产生 symptom 的 exact function、state transition、file、line 或 condition。
2. Deterministic repro：运行或写出能产生它的最小 command、fixture、UI path 或 scenario。
3. Logs/state/cache：检查证明该 path 被触达的 runtime state，包括 queues、DB rows、caches、temp files、generated outputs 或 external tool logs。
4. Build/test：运行能 exercise fix 的 narrow test 或 build。
5. Real runtime check：对 UI、native app、browser、rendering 或 visual bugs，打开 app/page/artifact，并用 screenshot 或 concrete checklist 验证 visible result。

对 UI、native-app、visual、rendering 或 generated-artifact bugs，compile-only 不够。如果环境中无法 runtime check，说明原因，并 hand off 要验证的 exact screen、command 或 artifact。

对 recurring classes of failures，在添加第二个 fix 前加载 `references/failure-patterns.md`。

## Native App Freeze Mode

当 desktop 或 mobile native app 报告 beachball、not responding、tab-switch freeze、first-open lag、idle wake stall、overlay lockup，或 screenshot 显示 app frozen 时激活。

改代码前收集 evidence：

1. Exact user path 和 version：first launch versus warm launch、tab 或 window transition、idle duration、permissions、display count，以及任何会让 freeze 消失的 setting。
2. Frozen 时的 runtime capture：`sample <process>`、recent app logs、CPU 和 memory footprint、thread count，以及 main thread 是 blocked、spinning 还是 allocating。
3. First-frame surface：view body work、first `.task`、synchronous icon 或 metadata lookup、filesystem scans、URL parent walks、notification callbacks，以及 app/window wake handlers。
4. fix 后 blast search：在 repo 中 grep 相同 API shape，尤其是 path parent walks、synchronous icon loading、render paths 中的 metadata reads，以及在 main thread 上运行的 callbacks。

Common native freeze traps：

- Launch、terminate、permission、audio、display 或 workspace notifications 在 main thread 上做 path walks、icon lookup、filesystem scans 或 process enumeration。
- First paint 在显示 interactive shell 前 hydrating full app list、directory tree、media thumbnail set 或 system status table。
- Input-lock 或 full-screen overlay 没有针对 Escape、app deactivation、permission denial、process termination 和 window close 的 guaranteed teardown path。
- Timer 或 sampler work 在 hidden windows、long idle periods、sleep/wake 或 app reactivation 后仍存活。

对这个 mode，compile-only 和 source-only checks 不足够。Outcome 必须包含 runtime capture、root-cause frame 或 state transition、focused regression guard，以及任何被修复或明确留为 safe 的 sibling matches。

## Targeted Logging

把 logs 当手术刀，不当噪音。添加 log 前，写出它回答的问题：

> "If this log prints X before Y, hypothesis A is still possible; if it does not, hypothesis A is wrong."

加载 `references/logging-techniques.md` 获取完整 logging playbook：binary-search instrumentation、discriminating log content、boundary-first placement、timing bug logging 和 removal discipline。

Quick rules：
1. 第一条 log 放在 execution path 的 midpoint，不放在 symptom 处。从那里 binary search。
2. 只 log discriminating facts：sequence number、input key、branch taken、old/new state、error code。
3. 完成前移除 temporary logs。Persistent diagnostics 要 gate 在项目 debug flag 后面。

如果 adding logs 改变 behavior，把它当成 timing、lifecycle 或 concurrency problem 的 evidence。

## Gotchas

| What happened | Rule |
|---------------|------|
| Patched client pane instead of local pane | 触碰任何文件前，沿 execution path 反向 trace |
| MCP not loading, switched tools instead of diagnosing | 切换 methods 前检查 server status、API key、config |
| 责怪 visible app 前没测 raw system/tooling layer | 先测 lower layer，再明确 retire ruled-out hypotheses |
| Orchestrator said RUNNING but TTS vendor was misconfigured | 在 multi-stage pipelines 中，逐 stage isolation 测试 |
| Race condition 被诊断成 stale-state bug | 对 timing-sensitive issues，先检查 event timestamps 和 ordering，再看 state |
| 到处加 logs 仍无法解释 bug | 把每条 log 重写成 yes/no question。删除不能 rule hypothesis in/out 的 logs |
| 本地可复现但 CI 失败 | 先对齐 environment（runtime version、env vars、timezone），再追代码 |
| Stack trace 指向 library 深处 | 往回走 3 层到自己的代码；bug 几乎总在那里，不在 dependency |
| 从 app 内启动能工作，经 file association / drag-drop / deep link / external proxy 打开就坏 | 使用用户描述的 exact entry point 复现。App-internal init 与 cold-launch-with-file init 不同；document 到达时 state 可能还没 ready |
| Build passed but UI still looked wrong | 沿 Runtime Evidence Ladder 上移，验证真实 rendered surface 或 artifact |

## Outcome

### Success Format

```
Root cause:        [what was wrong, file:line]
Fix:               [what changed, file:line]
Confirmed:         [evidence or test that proves the fix]
Tests:             [pass/fail count, regression test location]
Regression guard:  [test file:line] or [none, reason]
```

Status：**resolved**、**resolved with caveats**（说明 caveats）或 **blocked**（说明 unknown）。

**Regression guard rule**：对任何复发或之前曾被 "fixed" 的 bug，满足以下条件前 fix 不算 done：
1. 存在 regression test，且它在 unfixed code 上失败、在 fixed code 上通过。
2. 该 test 位于项目 test suite 中，不是 temporary file。
3. Commit message 说明 bug 为什么复发，以及这个 fix 为什么能防止复发。

### Handoff Format (after 3 failed hypotheses)

```
Symptom:
[Original error description, one sentence]

Hypotheses Tested:
1. [Hypothesis 1] → [Test method] → [Result: ruled out because...]
2. [Hypothesis 2] → [Test method] → [Result: ruled out because...]
3. [Hypothesis 3] → [Test method] → [Result: ruled out because...]

Evidence Collected:
- [Log snippets / stack traces / file content]
- [Reproduction steps]
- [Environment info: versions, config, runtime]

Ruled Out:
- [Root causes that have been eliminated]

Unknowns:
- [What is still unclear]
- [What information is missing]

建议的 Next Steps:
1. [Next investigation direction]
2. [External tools or permissions that may be needed]
3. [Additional context the user should provide]
```

Status：**blocked**

## Rendering Bug Mode

当出现这些触发时激活："PDF looks wrong"、"page break issue"、"font not rendering"、broken PDF output 或 print layout wrong。

加载 `references/rendering-debug.md` 获取完整 diagnosis checklist（WeasyPrint quirks、font loading、page overflow、browser print CSS）。先 static analysis，再按需 reproduce。

## IME / Unicode Issues

对于 input method、character rendering 或 text encoding bugs（IME state、cursor drift、emoji splitting、composition events），形成 hypothesis 前先检查 `references/ime-unicode.md`。
