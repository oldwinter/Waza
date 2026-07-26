# Release 价值分析与 Ship 后续操作

当用户询问“是否值得发版”，或要求 commit / push / publish / tag / issue closure 等后续操作时，由 `check` 的 Mode Picker 加载。Ship 扩展 review，不替代 review。

## Release Worthiness Analysis

当用户询问“深入分析 X 是不是值得发新版本”“is this worth a new release”“值不值得发版”等问题时激活。

以最后一个已发布 tag 为基线，而不是 local VERSION file，对此后的每个 commit 分类，然后输出：

- **Commit summary**：自上次 release 后有 N 个 feat、N 个 fix、N 个 chore
- **Verdict**：release / skip，一行
- **Recommended version bump**：只有 fix 为 patch，包含 feat 为 minor，存在 breaking change 为 major
- **Key risk**：用一句话说明本批次最大风险

若 verdict 为 `release`，提出可以进入 Ship mode。

## Ship / Release Follow-through

当 change 已准备好，用户要求 commit、tag、release、publish、push、回复 issue/PR 或关闭 issue 时激活。

本 mode 扩展 review，不跳过 review。执行任何公开或不可逆操作前：

1. 从公开项目上下文提取 release rules：README、manifest、CI workflow、release note、package script、changelog，以及当前对话中的明确指示。
2. 填写 `references/project-context.md` 中的 Release Gate 2.0 matrix。先运行 `python3 <skill-base-dir>/scripts/release_gate.py --root <project>`，为确定性行（worktree state、remote sync、tag baseline、version field sync、changelog mention）生成初始证据并粘贴 status lines；其余行（generated artifact、package/archive contents、release asset、registry/appcast/CI、公开 issue/PR state）仍需分别判断并提供证据。
3. 验证 generated 或 bundled outputs、version fields、release notes、package contents 和必需 artifacts 保持同步。生态提供 dry-run 时优先使用。起草 release notes 或 update-feed 文案时，遵循 `/write` 的 release-note mode；中文文案要在初稿前加载中文 release-note 规则，翻译腔是缺陷，不是后续润色项。
   起草前阅读仓库上一次已发布 release（GitHub 使用 `gh release view` 查看最新 tag），把 title convention、item count、每项长度和语言布局视为硬模板，只替换内容，不另造格式。
   Generated deliverables 包括 tracked archive、ignored dist file、appcast、site/download copy、registry package、checksum 和 release asset。项目文档要求时，即使被 Git 忽略也必须重新生成、检查、stage 或上传；不能仅凭 source tests 判断 ready。对远端资产，优先下载或读回发布产物并比较 entries、checksum 或 manifest；release page 文本、文件大小或 workflow success 都不能单独证明 artifact 正确。
   项目存在 preview、beta、nightly、stable 或 App Store lane 时，明确指出 lane。不能用 preview/beta artifact 证明 stable release ready，也不能在仅请求 preview 时触碰 stable appcast、registry 或 download surface，除非项目文档要求。
   得出 live 状态前，按部署 surface 分类每项变更：打包进 app binary、bundled CLI 或 release archive 的代码要等下一次 release 才到达用户；site、serverless function、CDN config 和 infrastructure 可能在 default branch 更新后自动部署。同一批变更可能在一个 surface 尚未发布、在另一个 surface 已上线，必须分开说明。
4. 只提交预期文件。保留无关 dirty work，串行执行 Git 操作以避免 index lock 或重叠 add，并在 push 前重新检查 HEAD/status，避免夹带并发 agent 或维护者的 commit。
5. 只有用户明确批准，才执行 push、publish、tag 或 create release。若 auth、OTP、CI、registry 或 network state 阻塞，暂停并报告准确阻塞项。
6. 处理 issue/PR 前，使用 host 的读取命令确认 item 身份。GitHub 使用 `gh issue view` 或 `gh pr view`；其他 host 使用项目文档或当前请求指定的 CLI/API。公开回复采用 `references/public-reply.md` 的模板和关闭标准。
7. 只有项目上下文或当前请求明确要求时，才执行 GitHub release reaction 后续操作。release 存在且所需 asset 已验证后，从 tag 解析 release id，用 `gh api` 或可用 GitHub tool 向 `repos/<owner>/<repo>/releases/<id>/reactions` POST 全部正面 reaction，并重新读取确认。正面 reaction 为 `+1`、`laugh`、`heart`、`hooray`、`rocket` 和 `eyes`。
8. 网络或 API 失败后重新读取最终状态，不要假定成功或失败。

### Reworked Or Cancelled Release Gate

当 release candidate 被取消、preview/beta 经历多轮 bug-fix churn，或用户询问延迟的 release 是否终于安全时，激活此 gate。加载 `references/release-surfaces.md` 中的 Reworked Or Cancelled Release Gate：从最后一个公开 stable tag 到 `HEAD`，按实际交付风险 surface 完整 review，并分别判断 preview/beta 是否可以继续接收用户测试，以及 stable release 准备是否可以开始。

先给明确的 go / no-go verdict（ship，或列出 blockers），再给 concrete shipped state：commit hash、tag、release URL、registry/version result、pushed branch、release asset state、release reaction state、issue/PR state 和任何 remaining blockers。不适用字段省略。
