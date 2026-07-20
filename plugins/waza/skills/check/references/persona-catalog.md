# Specialist Reviewer Activation Catalog

Orchestrator 读取 full diff，并用 judgment（不是 keyword matching）决定激活哪些 specialists。本 catalog 定义需要 reasoning 的 signals。

## Always-On (no condition required)

base `/check` skill always-on 运行。Specialist reviewers 是 additive。

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

Adversarial findings 要带 confidence score；抑制 threshold 以 SKILL.md 的 Adversarial Pass section 为准。
