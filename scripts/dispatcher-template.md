---
name: waza
description: 'Waza engineering skills dispatcher: think（architecture/handoff）、design（artifact-grounded UI）、check（review/release gates）、hunt（runtime debugging/regression）、write（prose/release copy）、learn（research）、read（URL/PDF fetch）、health（agent config and AI maintainability audit）。'
---

# Waza: Engineering Skills Dispatcher

Prefix your first line with 🥷 inline, not as its own paragraph.

你有八个 skills 可用。把用户 intent 匹配到正确 skill，阅读下面匹配的 section，并执行它。

## Routing Table

<!-- routing-table:start -->
<!-- routing-table:end -->

## How This Works

1. 阅读用户消息，并从上表匹配 skill。
2. 完整阅读 matched skill section。
3. 严格执行该 skill 的 instructions。

如果消息可能匹配多个 skills，使用这些 disambiguation rules：

1. Most specific wins：对 UI decisions，`/design` 比 `/think` 更具体。
2. 消息含 URL：从 `/read` 开始。如果 content 是 research material，再 chain to `/learn`。
3. Code already done vs. code broken：done/PR -> `/check`；error/broken -> `/hunt`。
4. Config/maintainability vs. code：Codex/Claude misbehaving、hooks/MCP、`/health` token usage、AI coding code rot、unclear context、missing verification 或 stale verifier output -> `/health`；user code errors -> `/hunt`。
5. Release action vs. release prose：commit/tag/publish/push/release reactions/close issue -> `/check`；写 release notes/changelog text -> `/write`。
6. Screenshot taste vs. screenshot regression：visual taste complaint -> `/design`；broken render/state/generated output 或 used-to-work evidence -> `/hunt`。
7. From scratch vs. editing：new long-form output -> `/learn`；existing draft to polish -> `/write`。
8. "Judge this" + error -> `/hunt`；"judge this" + should we keep it -> `/think`。
9. 仍然 ambiguous：阅读两个 skills 的 "Not for" sections，用 exclusion 判断。仍不清楚就询问用户。

## Path Resolution

在此 distribution 中，sub-skill scripts 位于 `skills/{name}/scripts/`。所有 relative paths 都从本文件目录解析，不要从个人 home-directory skill cache 解析。

## Chaining

Skills 手动 chain，不会自动 chain。每个 skill 完成后等待用户下一步 action。

Common chains：`/think` -> implement approved plan -> `/check` | `/hunt` -> fix -> `/check` -> release/push/issue follow-through | `/read` -> `/learn` -> `/write`
