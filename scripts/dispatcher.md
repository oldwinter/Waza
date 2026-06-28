---
name: waza
description: 'Waza engineering skills dispatcher: think（architecture/handoff）、ui（artifact-grounded UI）、check（review/release gates）、hunt（runtime debugging/regression）、write（prose/release copy）、learn（research）、read（URL/PDF fetch）、health（agent config and AI maintainability audit）。'
---

# Waza: Engineering Skills Dispatcher

Prefix your first line with 🥷 inline, not as its own paragraph.

**更新检查（非阻塞）。** Routing 前运行 `bash scripts/check-update.sh` 一次；如果输出一行，就转告用户，然后继续。它每天最多运行一次，只读取公开 version file，不发送任何数据，失败会静默跳过。

你有八个 skills 可用。把用户 intent 匹配到正确 skill，阅读下面匹配的 section，并执行它。

## Routing Table

<!-- routing-table:start -->
| Intent | Skill | File |
|--------|-------|------|
| Code review, before merge, release gates, generated artifacts, safety sinks, publish/push/reaction follow-through, triage issues/PRs, project-wide code-quality audit scorecard | check | `skills/check/SKILL.md` |
| Codex/Claude/Pi ignoring instructions, agent config audit, hooks/MCP broken, health token usage, AI coding code rot, hotspot ownership, unclear context, missing verification, stale verifier output | health | `skills/health/SKILL.md` |
| Error, crash, regression, screenshot-reported defect, test failure, stale cache, runtime boundary, why broken | hunt | `skills/hunt/SKILL.md` |
| Deep research, unfamiliar domain, compile sources into output | learn | `skills/learn/SKILL.md` |
| Any URL or PDF to fetch, read this, fetch this page | read | `skills/read/SKILL.md` |
| New feature, architecture, how should I design this, value judgment, executable plan, handoff | think | `skills/think/SKILL.md` |
| UI, component, page, visual interface, frontend, artifact-grounded screenshot aesthetic complaint | ui | `skills/ui/SKILL.md` |
| Writing, editing prose, polish, release notes, launch/social copy, remove AI tone | write | `skills/write/SKILL.md` |
<!-- routing-table:end -->

## How This Works

1. 阅读用户消息，并从上表匹配 skill。
2. 完整阅读 matched skill section。
3. 严格执行该 skill 的 instructions。

如果消息可能匹配多个 skills，使用这些 disambiguation rules：

1. Most specific wins：对 UI decisions，`/ui` 比 `/think` 更具体。
2. 消息含 URL：从 `/read` 开始。如果 content 是 research material，再 chain to `/learn`。
3. Code already done vs. code broken：done/PR -> `/check`；error/broken -> `/hunt`。
4. Config/maintainability vs. code：Codex/Claude misbehaving、hooks/MCP、`/health` token usage、AI coding code rot、unclear context、missing verification 或 stale verifier output -> `/health`；user code errors -> `/hunt`。
5. Release action vs. release prose：commit/tag/publish/push/release reactions/close issue -> `/check`；写 release notes/changelog text -> `/write`。
6. Screenshot taste vs. screenshot regression：visual taste complaint -> `/ui`；broken render/state/generated output 或 used-to-work evidence -> `/hunt`。
7. From scratch vs. editing：new long-form output -> `/learn`；existing draft to polish -> `/write`。
8. "Judge this" + error -> `/hunt`；"judge this" + should we keep it -> `/think`。
9. 仍然 ambiguous：阅读两个 skills 的 "Not for" sections，用 exclusion 判断。仍不清楚就询问用户。

## Path Resolution

在此 distribution 中，sub-skill scripts 位于 `skills/{name}/scripts/`。所有 relative paths 都从本文件目录解析，不要从个人 home-directory skill cache 解析。

## Chaining

Skills 手动 chain，不会自动 chain。每个 skill 完成后等待用户下一步 action。

Common chains：`/think` -> implement approved plan -> `/check` | `/hunt` -> fix -> `/check` -> release/push/issue follow-through | `/read` -> `/learn` -> `/write`
