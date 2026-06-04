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
