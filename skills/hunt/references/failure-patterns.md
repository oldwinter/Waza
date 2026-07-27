# Failure Pattern Reference

当 bug 反复出现、第一次 fix 没撑住，或 symptom 更像 runtime state 而不是 local code syntax 时使用。

## Stale Verifier Or Tool Cache

Signals：verifier output 指向已删除 temp worktrees、旧 generated files，或 current repo 外的 paths；clean checkout 后 rerun 会改变 file path，但 current code 不变。

Checks：
- 确认 reported path 存在。
- 只有证明 path stale 后，才 clear tool cache。
- 从 current repo root 重新运行同一个 verifier。

## Worker Queue Or DB Boundary

Signals：UI 显示 work is running，但没有 worker 处理；logs 显示 scheduler activity，但没有 queued row；retry 能修一个 item，但修不了 pipeline。

Checks：
- Trace request -> enqueue -> worker pickup -> persistence -> UI refresh。
- 直接 inspect queue rows 或 job state。
- 在 enqueue boundary 周围添加 regression test，不只测 worker body。

## Generated Rebuild Boundary

Signals：source 已改变，但 generated output、app bundle、CLI artifact、archive、checksum 或 release package 仍包含旧 behavior。

Checks：
- 识别 source-to-artifact rule。
- 验证 build system 会 watch source path。
- Inspect generated artifact contents，不只看 source diff。

## Guard Lifetime Race

Signals：permission、auth 或 state guard 本地看起来正确，但 delayed callback、app relaunch 或 alternate entry point 绕过它。

Checks：
- Trace guard creation、retention、invalidation，以及每个 alternate entry point。
- 适用时验证 cold launch、warm launch、deep link/file open 和 retry paths。
- 当 guard 必须 survive relaunch 时，优先 explicit durable state，而不是 transient flags。

## Atomic Temp Filename

Signals：concurrent runs 冲突、cleanup 删除了错误文件，或观察到 partially written output。

Checks：
- 使用 unique temp directories 或 atomic rename。
- cleanup 只限 current run 创建的 files。
- tool 支持时，测试两个 concurrent 或 back-to-back runs。

## Path, Cwd, Or Symlink Escape

Signals：本应作用于一个 root 的 operation 触碰 sibling directory、意外 follow symlink，或在另一个 working directory 中表现不同。

Checks：
- 写入或删除前 resolve 并 compare canonical roots。
- symlink resolution 后 reject allowed root 外的 paths。
- 从 non-default cwd，以及任何会 supply paths 的 UI entry point 复现。

## CLI Effect Scope Drift

Signals：preview、dry-run、size、count 或 report output 由一个 predicate 计算，但 execution mutate 了更宽或不同的 set。

Checks：
- 把 display、dry-run 和 mutation predicates trace 到同一个 source of truth。
- 在 regression test 中比较 planned paths 或 records 与 executor input。
- Assert partial failures 会报告 exact skipped 和 completed items。

## CLI Wrapper Or PATH Drift

Signals：source-tree invocation 能工作，但 installed command、package wrapper、PATH shim、completion 或 package-manager install path 跑的是旧 code 或另一个 binary。

Checks：
- Inspect built package contents、shebang、executable bit 和 wrapper target。
- 通过 temp prefix 或 package-manager install path 复现，不只从 source 复现。
- 检查 PATH order；当 wrappers 不应 intercept 时，使用 absolute system-tool paths。

## Interactive Stdin Or TTY Hang

Signals：CI stalls、spinner 永远不结束、subprocess 从 script body 读取，或 auth prompt 在 non-interactive mode 出现。

Checks：
- stdin redirected 时复现，并分离 TTY/non-TTY paths。
- 在 real prompts 和 system changes 周围添加 test-mode 或 no-auth guards。
- 当 timeout wrappers exec real binaries 时，通过 PATH stub external prompt tools。

## Subprocess Pipe Backpressure

Signals: a long-running child process hangs only on large output, small fixtures pass, or the parent waits for exit before reading stdout/stderr. The child may be blocked on a full pipe buffer while the parent is blocked on `wait`.

Checks:
- Drain stdout and stderr while the process runs, or explicitly inherit/redirect streams when output is not needed.
- Test with output larger than a typical pipe buffer, not only tiny fixtures.
- Preserve stderr tails or structured error output for diagnostics without holding the whole stream in memory.

## Signal Or Partial-Failure Mapping

Signals：cancel、timeout、SIGINT 或 SIGTERM 被报告成 success 或 normal business failure；temp files、locks 或 operation logs 让 retries 看起来 complete。

Checks：
- 把 interrupted execution 与 success 和 expected validation failures 分开分类。
- Assert interruption 后的 temp cleanup、lock release 和 operation-log state。
- 测试 partial write 后的 retry 和 idempotency。

## CLI Stream Contract Regression

Signals：human logs、progress output、JSON shape、stdout/stderr routing 或 exit-code behavior 改变后 automation broken。

Checks：
- 在 CLI tests 中分别 assert exit code、stdout 和 stderr。
- 对 machine-readable modes，把 human diagnostics 从 stdout 移开。
- Snapshot 或 parse JSON/schema output，并包含 non-interactive coverage。

## Snapshot Rebuild Drops Carried Field

Signals：live data 在 data source 和 wire 上可见，但 downstream view 看到空值；field 有 default value（`var x: [T] = []`、`var y: Int? = nil`），让 memberwise init 即使漏传也能 compile；symptom 只出现在 snapshot rebuild path（icon resolution、decoration、redaction），fresh fetch 上不出现。

Checks：
- Trace 每个构造 snapshot type 的 code path 是否传入该 field。Swift compiler 不会警告 memberwise init 中漏掉 default-value field。
- 添加 unit test：fetch snapshot，运行 rebuild path，并 assert carried field 等于 input。
- 当只改变一个 field 时，优先 `with(...)` mutating helpers 或 `inout` mutation，而不是 fresh memberwise init。

## Multi-Sample Command Cold Start

Signals：某个接受 `-l N` / `--samples N` / `--repeat N` 的 CLI tool 返回一个 zeros block 和一个 real data block；聚合所有 blocks 会得到 zeros；只有第二个 sample 携带 real measurements。

Checks：
- 阅读 tool 的 man page，确认 cold-start semantics。`top -l 2`、`iostat -d 2`、`vm_stat 1 2` 等都有这种 shape。
- 把 output 切到 latest sample（对 parsed lines 用 `.suffix(perSampleSize)`，或寻找第二次出现的 header row）。
- 不确定时，把 `-l` 提到 3，确认 sample 2 和 3 一致；sample 1 保持 zero。

## Locale-Dependent Subprocess Output

Signals：数字在作者环境中解析正确，但对部分用户返回 zero、truncated 或严重错误的结果；同一个 percentage、size 或 duration 在某个 region 正确，在另一个 region 出错；同一个 parser 已经因为另一个 field 被 patch 过一次。

Checks：
- 对每个需要解析 output 的 subprocess 强制使用固定 locale（`LC_ALL=C` 或平台等价设置），不要逐个修补 parser 来适配逗号小数点、digit grouping 或已翻译的 field label。
- 在 spawn boundary 修复，不要在每个 call site 分别处理。这种 shape 通常会以三四份独立 report 出现（先一个 metric，再另一个，最后是 rendered summary）；每个 pointwise patch 都会掩盖仍有多少 parser 暴露在同一问题下。
- 把 localized output 视为 format change，而不是 string change：field order、unit 和 label name 都可能改变。

## Single-Probe Existence Check

Signals：某个“是否 installed / running / registered / active”的 verdict 对一部分用户判断错误，错误 verdict 随后触发 destructive 或 user-visible action（标为 orphaned、提供 deletion，或静默禁用 feature）。这部分用户共享一种 probe 不认识的 install method、packaging convention 或 OS feature。

Checks：
- 列出 subject 合法存在的所有方式，再确认 probe 能看到每一种。一次 index query、一次 PATH lookup、一个 process name 或一个 interface-name prefix 都只是局部视图：system index 可能被禁用或跳过某种 packaging convention；nested 或 embedded component 不会注册在 top-level component 的位置；OS-owned interface 也可能借用第三方 feature 使用的命名。
- 区分 “probe timed out” 和 “subject absent”。Slow index 代表 unknown，不是 absence 的证据；fast path timeout 后必须 fallback 到 direct check，绝不能直接给 negative verdict。
- 不对称地衡量失败：verdict 如果授权 removal，false “absent” 会毁掉数据，而 false “present” 只会留下一些东西。进入 destructive branch 前，必须有第二个 source 交叉证明。

## Aggregation Key Variant

Signals：count、log roll-up、event tally 或 per-category breakdown 少了一些 entries；missing items 共享某个 trait（system-derived path、localized string、prefixed command name）；base-form key 匹配，但 derived variant（`<base>-system`、suffix、prefix）被静默丢掉。

Checks：
- 添加 category 前，grep 产生这类 key 的每个 write site，枚举真实 variants，而不只是 base form。
- 用 `hasPrefix` / regex / explicit variant list 匹配，不要只对 base key 做 exact equality。
- 为每个 known variant 添加 fixture row，让未来逃过 matcher 的新 key shape 让 test fail，而不是让 aggregate 悄悄变短。

## Whole-Buffer Decode Collapse

Signals：在你的机器上正常工作的 parser，到其他人机器上却返回空值；受影响用户有带 accent 的 device name、non-ASCII filename 或不寻常的 process argument；失败是 total（所有 row 都消失），不是 partial（某一 row 乱码）。这与 pipe backpressure 不同：bytes 已经到达，只是在 decode 时被丢弃。

Checks：
- 找出对 child process、device 或 filesystem 产生的 bytes 所做的每个 strict decode（`String(data:encoding:)`、`from_utf8`、未设置 `errors=` 的 `decode('utf-8')`）。一个 invalid byte 就会让整个 buffer 变成 nil；caller 再把 nil 合并为空值，就会把它解释成“command 没有产生 output”。
- 只要 bytes 是待解析的 report，就做 lenient decode；只有当 bytes 是需要验证的 signature 或 checksum 时才保留 strict decode，并在那里 fail closed。同一 codebase 可以因 call site 不同同时需要这两种立场。
- 检查 empty result 在 downstream 中代表什么。Safety guard 若把空 process list 读成“没有东西在运行”，就会 fail open；在 destructive path 上，这是危险方向。
- 真正的 failure 由 exit status 和 timeout 报告，不由 decode 是否成功决定。让 caller 依赖前两者。

## Denied Read Returns A Plausible Value

Signals：某个 metric 对部分 subject 正确，对另一些错误，分界与 ownership 一致：自己的 process/file 正确，root-owned 或其他用户的结果是 zero、stale 或 absent。API 给出了 response，因此没有 error log。

Checks：
- 实测 boundary，不要只读 docs：对 owned 和 non-owned subject 分别调用并统计成功数量。“自己的 33/33，root 的 0/5”才是 evidence，猜测不是。
- 检查 denied read 的 fallback 与 primary source 是否表达同一含义。即使每个 value 单独看都说得通，同一 column 混入两种含义仍然是 bug。
- 优先使用能对所有 subject 一致回答的 source（例如不区分 owner、报告全部 process 的 tool），不要选一个更精确但会对部分 subject 静默降级的 source。

## Recovery Gated On The Artifact It Restores

Signals：repair、reinstall 或 self-heal path 无论运行多少次都报告同一个 dead end；broken state 跨 reinstall 持续存在；repair “一直都在那里”，却没有任何 evidence 证明它成功过。

Checks：
- 阅读 repair path 自己的 precondition，问它在需要被修复的 broken state 中是否成立。Recovery 如果 gate 在那个已经缺失的 file 上，就永远不会触发。
- 验证 repair command 中每个 absolute tool path 都真实存在于目标平台。Wrong path 会 non-zero exit，`&&` chain 随即静默停止，repair 就会永远在每台机器上 no-op。添加 test，遍历 command 中每个 path 并 assert 它可执行。
- 不要让 test assert repair command 的 source shape；那会把 broken form 锁成正确。改为 assert observable end state（service 已注册、file 已存在、probe 有响应）。
- 让 repair 对 outcome 负责，不要假定成功：写入 artifact 后查询系统证明它存在，并记录 query 的 raw output，不要丢弃。

## Watchdog Tuned To The Fast Path

Signals：实际健康的 operation 被报告为 failed、stalled 或 “no progress”；report 来自 slow link、cold cache、network volume 或 large payload 用户；每次 retry 都在同一个 elapsed time 失败。

Checks：
- 对每个 timeout constant，命名最慢的*健康* case（slow link 上数百 MB download、每天第一次 index rebuild、cleanup 后 tool 重建 cache），并确认 constant 留有余量地覆盖它。这与 magic-wait coupling 相反：前者 timer 太松，不能作为真实 signal；这里 timer 太紧，容不下健康的慢路径。
- 用真实 liveness probe（持续增长的 temp file、byte counter、heartbeat）替换“N 秒无 output”，只把 timeout 保留为真正的 stall guard。
- 对每个 watchdog，枚举它所守护区域的所有 exit，包括 thrown error 和 fork 到 alternate path。若 watchdog 在 fork 后仍存活，它会在替代路径执行到一半时触发。
- 检查是否已有第二个 bound 覆盖真正 hung 的 run。如果有，额外 timer 只可能提前误触发。

## Display-String Comparison

Signals：基于 user-facing text 的 comparison 产生永远无法收敛的 verdict：持续显示却什么也不安装的 “update available”、永远报告 changed 的 diff、永远不触发的 match。两侧只是用不同 format 表示同一个 underlying value。

Checks：
- 先问被比较 value 的 *format* 是 contract 的一部分，还是 producer 可以任意调整的展示形式。Version display string、从 URL tail 派生的 filename 和 localized label 都是 free-form。
- 找到平台用于 ordering 或 equality 的 machine-facing identity（build number、content hash、id）并比较它；只有任一侧缺少 identity 时才 fallback 到 display form。
- 必须保留 fallback 时，如果两个 string 只是以不同排列携带完全相同的 token sequence，就 suppress verdict；真正更新或变化的 value 不可能满足这个条件。
- 修复所有重复这段 comparison 的 channel，不要只修产生 report 的那一个。这种 shape 几乎总是 duplicated。
