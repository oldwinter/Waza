# Logging Techniques for Debugging

每条 log 都要回答关于 hypothesis 的 yes/no question："if this prints X before Y, hypothesis A holds; otherwise A is dead." 不能 rule hypothesis in 或 out 的 log 就是 noise。

## Discriminating Content

只记录能区分 hypotheses 的内容：ordering（sequence number 或 timestamp）、input identity key、branch taken、old-vs-new state transition，以及 error code 和 context。Log 要放在 behavior 应该 predictable 的 boundaries（handler 入口/出口、带 key 的 cache hit/miss、带 old value 和 caller 的 state setter、async callback entry、external API result），而不是 tight-loop interiors。绝不记录 credentials、PII 或完整 request/response bodies。

对 race conditions、flicker 或 intermittent failures，还要捕捉 event identity、monotonic ordering、start 和 end（不只是 "it ran"），以及 thread/task/queue identity。如果添加 log 改变 behavior，这就是 timing、lifecycle 或 concurrency problem 的 evidence，不是可以忽略的 "logging side effects"。

## Runner-Only Failures

When a script fails only under a specific runner (make target, CI job, test harness, cron) but passes standalone, do not edit the script with debug hacks you might forget to remove. Inject tracing from the outside via the environment the runner already passes through:

```bash
# xtrace-env.sh: sourced by every non-interactive bash via BASH_ENV
exec 19>>/path/to/persistent/xtrace.log
export BASH_XTRACEFD=19
export PS4='+ [$0:$LINENO] '
set -x
```

Run the failing pipeline as `BASH_ENV=/path/to/xtrace-env.sh make test` (or the runner's equivalent). Every bash the runner spawns appends `file:line`-stamped traces to one persistent file, surviving the runner's temp-dir cleanup, so the exact dying line is on record even when the failure needs the full pipeline to reproduce. Guard the injection with a sentinel variable if nested shells would re-source it, and delete the env file when done.
