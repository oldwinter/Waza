# Specialist Reviewer Activation Catalog

Orchestrator 读取 full diff，并用 judgment（不是 keyword matching）决定激活哪些 specialists。本 catalog 定义需要 reasoning 的 signals。

## Always-On (no condition required)

base `/check` skill always-on 运行。Specialist reviewers 是 additive。

## Conditional Specialists

### Security Reviewer

**Agent file:** `agents/reviewer-security.md`
**Activate at:** Standard or Deep depth

当 diff 触碰以下内容时激活：
- Authentication 或 authorization logic（middleware、guards、JWT handling、session management）
- Cryptographic operations（hashing、signing、encryption）
- Trust boundaries 上的 input handling（form fields、API request bodies、URL parameters）
- User-controlled paths 上的 file system operations
- Shell 或 subprocess execution
- Third-party credential 或 API key handling
- SQL queries 或 raw database access

**Do not activate** for：pure UI changes、config file updates、test-only changes、documentation。

### Architecture Reviewer

**Agent file:** `agents/reviewer-architecture.md`
**Activate at:** Standard or Deep depth

当 diff 符合以下条件时激活：
- 添加 new module、package 或 service boundary
- 改变 public API、exported type 或 function signature
- 引入之前不存在的 cross-module import
- 跨不同 directories 修改超过 10 个 files
- 添加或移除 major dependency
- 重构 components 之间的调用方式

**Do not activate** for：single-file bug fixes、test additions、style changes、documentation updates。

## Adversarial Pass (Deep only)

没有 separate agent。Orchestrator 在收集所有 findings 后，把它作为 extra reasoning pass 运行。

**Activate at:** 仅 Deep depth（500+ lines changed，或 explicit high-risk signals：auth、payments、data mutation、external API integration）。

Adversarial pass 询问："If I wanted to break this system through this specific diff, what would I do?"

四个 attack angles：
1. **Assumption violation** -- 这段 code 假设什么永远为真？（format、ordering、range）当它不为真时会发生什么？
2. **Composition failures** -- 当 new code 在 concurrent load 或 partial failure 下与 existing system 交互时，什么会坏？
3. **Cascade construction** -- 哪一串 valid operations 会导向 invalid state？
4. **Abuse cases** -- 第 1000 个 request、deployment 期间，或两个 users 同时编辑同一 resource 时会发生什么？

报告 adversarial findings 时附 confidence score。Suppress 0.60 以下的 findings。
