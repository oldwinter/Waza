# Specialist Reviewer Activation Catalog

Orchestrator 读取 full diff，并用 judgment（不是 keyword matching）决定激活哪些 specialists。本 catalog 定义需要 reasoning 的 signals。

## Review Coordination

base `/check` skill always-on 运行；specialist reviewers 是 additive。

按下面的 activation signals 判断。环境提供 agent 或 sub-agent facility 时，并行启动所有被激活的 specialists，每个都拿到 full diff 和自己的 persona brief。没有并行 reviewer facility 时，在同一 session 中串行执行 specialist passes。

合并 findings：两个 specialists 指向同一 code location 时，保留较高 severity，并注明 cross-reviewer agreement。不同 code locations 上的 findings 即使主题相同，也绝不是 duplicates。

每个 specialist finding 都是待验证的 claim，不是可以直接行动的事实。对 HIGH 和 CRITICAL claims，在 agent facility 允许时，为每个 finding 启动一个独立 skeptic，其唯一任务是依据实际 code 反驳它；被 skeptic 直接读 code 反驳掉的 finding，无论来自哪个 persona，都要丢弃或降级。没有该 facility 时，自己执行 skeptic pass：在本轮重读被引用的 code，确认 claim 真实且仍然存在、没有在别处处理过、不是 by design，也不是把 latent-only risk 标成 live bug。并行 reviewers 会因 name-based inference 和 partial context 过度报告；直接读 code 后站不住的 findings 要丢弃，路由到 Autofix 或 sign-off 前先给出 verification path。

## Conditional Specialists

### Security Reviewer

**Agent file:** `agents/reviewer-security.md`
**Activate at:** Standard or Deep depth

当 diff 修改 attacker 可以触达或影响的代码时激活：trust-boundary input、auth 或 crypto、credentials，或 query/shell/path construction。

**Do not activate** for：pure UI changes、config file updates、test-only changes、documentation。

### Architecture Reviewer

**Agent file:** `agents/reviewer-architecture.md`
**Activate at:** Standard or Deep depth

当 diff 改变 module 之间的关系时激活：boundaries、public APIs 或 signatures、cross-module dependencies，或 major dependency；而不是只改一个 module 内的 logic。

**Do not activate** for：single-file bug fixes、test additions、style changes、documentation updates。

## Adversarial Pass (Deep only)

没有 dedicated agent file。环境提供 agent facility 时，orchestrator 将四个 angles 作为彼此看不到 findings 的 parallel agents 运行；否则在收集所有 findings 后进行额外 reasoning pass。

**Activate at:** 仅 Deep depth；Deep criteria 以 SKILL.md 的 Scope table 为准。

Adversarial pass 询问："If I wanted to break this system through this specific diff, what would I do?"

四个 attack angles：
1. **Assumption violation** -- 这段 code 假设什么永远为真？（format、ordering、range）当它不为真时会发生什么？
2. **Composition failures** -- 当 new code 在 concurrent load 或 partial failure 下与 existing system 交互时，什么会坏？
3. **Cascade construction** -- 哪一串 valid operations 会导向 invalid state？
4. **Abuse cases** -- 第 1000 个 request、deployment 期间，或两个 users 同时编辑同一 resource 时会发生什么？

Adversarial findings 要附上支持它的 evidence；哪些能留下由 SKILL.md 的 Finding Quality Gate 决定。
