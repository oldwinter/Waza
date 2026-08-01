---
name: hunt
description: "Find the root cause before applying fixes for errors, crashes, regressions, failing tests, broken behavior, and screenshot-reported defects. Use when users report in any language that something is broken, regressed, failing, crashing, or no longer works. Not for code review or new features."
when_to_use: "排查, 查查, 报错, 崩溃, 不工作, 不对, 跑不通, 以前是好的, 回归, 截图回归, 判断错误原因, 判断为什么报错, 反复修不好, debug, regression, used to work, broke after update, why broken, not working, what's wrong, fix error, stack trace"
dispatch_intent: "Error, crash, regression, screenshot-reported defect, test failure, stale cache, runtime boundary, why broken"
---

# Hunt: 修复前先诊断

Prefix your first line with 🥷 inline, not as its own paragraph.

打在 symptom 上的 patch，会在别处制造新 bug。

## Outcome Contract

- Outcome:应用任何 fix 前，先识别 root cause。
- Done when:一句话能解释 cause，每个 observed symptom 都能被它解释，并且 fix 或 handoff 已通过 reproducible check 验证。
- Evidence:source trace、repro command 或 UI path、logs 或 state、targeted test/build output，以及 UI 或 native defects 的 runtime evidence。
- Output:root cause、fix 或 handoff、verification result，以及任何 unswept sibling risks。
- Authorization：“diagnose”“investigate”“why”“look into”“排查”“看看”或同义表达都只授权报告。只有当前 turn 明确要求 fix、change、implement 或 optimize 时才应用 fix；仍必须先证明 root cause。

**在能用一句话说清 root cause 前，不要碰代码：**
> "I believe the root cause is [X] because [evidence]."

命名 specific file、function、line 或 condition。"A state management issue" 不可测试。"Stale cache in `useUser` at `src/hooks/user.ts:42` because the dependency array is missing `userId`" 可测试。如果不能这么具体，就还没有 hypothesis。

## Diagnosis Signals

Hypothesis quality gate：Hypothesis 必须解释所有 observable symptoms，而不只是用户最先报告的那个；只覆盖一部分就是 symptom-level guess，不是 root cause。对 timing-dependent issues（flicker、intermittent failure、race），诊断前先可靠复现。

Rationalization smells："I'll just try this" = 没有 hypothesis，先写出来。"I'm confident" = 运行 instrument 证明它。"Probably the same issue" = 从头重读 execution path。"It works on my machine" = 先枚举每个 env difference 再排除。"One more restart" = 逐字读取 last error；没有 new evidence 时，绝不 restart 超过两次。

## Durable Context Preflight

See [references/durable-context.md](references/durable-context.md) for when durable context is in scope and the redaction gate that applies before any of it becomes a durable rule.

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

- 先保护用户 worktree：`git status --short --branch -uall`。只要存在 modified、staged 或 untracked files，就不要在 current checkout 中 bisect；改在 temporary detached worktree 中运行，完成后移除该 worktree。如果无法创建 temporary worktree，停止并请求 explicit cleanup/stash approval。
- 如果 last-good version 只落后几个 releases，先运行 `git diff <last-good>..HEAD -- <suspect path>` 并阅读 delta。Regression 通常能在这里看到，成本远低于完整 bisect；只有 diff 太大或 culprit 不明显时，才继续 bisect。
- 只有预先定义好 non-interactive pass/fail command 才能 bisect，并始终用 git 记录 bookkeeping（`git bisect good/bad`），直接测试 suspect commit 时也一样。它命名 culprit 后，只读该 diff 并定位 specific line；移除 temporary worktree 前运行 `git bisect reset`。

## Repeated Regression / Screenshot Reference Mode

当用户说同一个 issue 在 fix 后仍然不对，提供 "good" screenshot/version/file，或描述某个 visual result 以前是正确的时激活。

把 reference 当成 evidence，不是 decoration：用用户的具体措辞列出所有 reported 和 visible symptoms（"still slow"、"尖刺"、"先显示上一个内容"）；识别 reference oracle（last-good commit、old build、fixture、screenshot 或描述的 expected state）；编辑前定义 pass/fail check；然后命名 exact current-vs-reference delta。当 evidence 指向 broken render、race、font pipeline 或 state path 时，不要把 visual defect 泛化成 "style polish"。如果 same symptom 在一次 attempted fix 后仍存在，停止并基于 evidence 重建 hypothesis；不要在已被推翻的 explanation 上继续叠 patches。

如果 issue 是纯 subjective UI taste，route to `/ui`。如果是 rendering、state、timing、build output、font generation，或来自 known-good version 的 regression，留在 `/hunt`。

## Scope Blast Mode

在修复 root-cause pattern 后、声明 bug done 前激活；用户说 "举一反三"、"举一反三深入看看" 或 "其他地方有没有同样问题" 时也激活。同一 shape 往往藏在其他 N 个地方；忽略 blast 的 one local fix 会把 N - 1 个 bugs 留在 tree 里。

提取 pattern signature（产生 bug 的 specific function、regex、API call、CSS selector、lock acquisition、validation skip 或 input boundary），然后在 repo 中用 `grep -rn` 查找，排除 generated dirs、build output 和 vendored deps；对 class-of-bug patterns（例如 "any handler missing the lock"），grep surrounding shape，不只 grep literal text。对每个 match 用文字回答：same bug / safe to leave（说明原因）/ unsure（询问用户）。不要静默跳过 match；在 Outcome block 放入 blast report 前，不要声称 "fixed"。Sweep 暴露的 unrelated bugs 只列出，不在本 PR 修复，除非用户同意。

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

如果缺失的证据层来自 reporter 的环境，且本地无法复现，下一个 artifact 应是对方可直接粘贴运行的只读 probe，而不是另一个 hypothesis。让它只输出 environment、有争议的 measurement，以及 hypothesis 所依赖的 state；不要输出任何可能携带 secret 或 private path 的内容。不要假设对方采用你的 layout：install method、directory conventions、locale、shell 和 version 都可能不同，因此应动态发现而非 hardcode。用纯文本交付：一条可复制 command，加一个让对方贴回的 output block。这个流程替代连续两轮只问“能否检查一下……”却不给 probe 的做法。

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

每条 log 都是一个 yes/no question："if this prints X before Y, hypothesis A survives; otherwise A is dead." 不能 rule hypothesis in 或 out 的 log 就是 noise。完成前移除 temporary logs；persistent diagnostics 要 gate 在项目 debug flag 后面。如果添加 log 改变 behavior，这本身就是 timing、lifecycle 或 concurrency problem 的 evidence。完整 playbook 见 `references/logging-techniques.md`。

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
| Fix 只适配 reporter 的 setup，对其他人没有变化，或破坏了 default | Defect report 是 evidence，不是完整 scope。说明 fix 改变的是所有用户的 default experience，还是只有 reporter 的 configuration，并优先修复 default path |
| 切换 theme / mode / locale 后出错，restart 后正常 | Toggle path 没有重新应用 state。先 trace toggle 的 recompute 或 invalidation route；state path 坏着时，不要逐像素调整 styles |
| 改了 algorithm，但 output 仍然错误 | Reader 可能命中了旧代码写入的 persisted output（scan results、analysis cache、带 TTL 的 snapshot）。修改 generated-then-persisted data 时，必须在同一 change 中 invalidate 或 bump 旧 cache version；重新诊断前先确认 runtime 没在读取 stale data |
| Reporter 能复现，本地机器正常，agent 直接盲改 | 先生成一条可 copy-paste 的 diagnostic command（single command、silent collection、one output file，并附 privacy note），再根据返回的 evidence 诊断和修复 |

## Rendering Bug Mode

Activate when: "PDF looks wrong", "page break issue", "font not rendering", broken PDF output, or print layout wrong.

Load `references/rendering-debug.md` for the full diagnosis checklist (WeasyPrint quirks, font loading, page overflow, browser print CSS). Static analysis first, then reproduce if needed.

## IME / Unicode Issues

For input method, character rendering, or text encoding bugs (IME state, cursor drift, emoji splitting, composition events), check `references/ime-unicode.md` first before forming a hypothesis.

## Output

### Success Format

Open the wrap-up with one plain line stating the outcome and whether the changes are committed; the block below supports that line, it does not replace it.

```
Root cause:        [what was wrong, file:line]
Fix:               [what changed, file:line]
Sibling sweep:     [N same-shape sites checked, N fixed / none found / not run, why]
Confirmed:         [evidence or test that proves the fix]
Tests:             [pass/fail count, regression test location]
Regression guard:  [test file:line] or [none, reason]
```

Status：**resolved**、**resolved with caveats**（说明 caveats）或 **blocked**（说明 unknown）。

**Regression guard rule**：对任何复发或之前曾被 "fixed" 的 bug，满足以下条件前 fix 不算 done：
1. 存在 regression test，且它在 unfixed code 上失败、在 fixed code 上通过。
2. 该 test 位于项目 test suite 中，不是 temporary file。
3. Commit message 说明 bug 为什么复发，以及这个 fix 为什么能防止复发。
4. Red-green 必须**实际运行**，不能靠推断：还原 fix（或临时 stash），观察新 test 失败；恢复 fix，再观察它通过。只见过 green 的 regression test 什么也没有锁住。Output 中要写明 red run。两种已经真实发布过的情况会让这一步静默失效：其一，framework 或语法让 test 中段的 failing assertion 不会导致整条 test 失败，只有最后一个 assertion 真正 gate（shell suite 中可能只因 bracket form 不同，一个 keyword 被吞掉，另一个被捕获；应运行两行最小 repro 确认，不能靠推理）；其二，assertion 检查一个错误的 string 不存在，而该 string 在任何 code version 中都从未输出，于是永远通过。任何 negative assertion（“output 不能包含 X”）还必须在同一 test 中配一个 positive case，证明该 assertion 确实可能失败。

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
