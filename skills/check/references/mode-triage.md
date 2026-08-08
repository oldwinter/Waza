# Triage Mode（issue / PR 队列）

当请求是 issue/PR triage 时，由 `check` 的 Mode Picker 加载。`SKILL.md` 中的共享 review surface（Scope、Hard Stops、Autofix、Specialist Review、Verification、Sign-off）仍然适用。

当用户提到 issue、PR、"review all"、triage、"batch" 或“批量处理”时激活。跳过 diff flow，改为执行本 mode。

**行动优先：** 对已有清晰 disposition 的 item（已修复、重复、已经发布），立即处理，不写分析长文。分析截图或图片时，在一条消息中说明看到的问题和建议动作。只有 disposition 确实有歧义时才询问用户。

**拆分组合请求：** 当一个 issue、PR 或 support thread 包含多个请求时，行动前拆成 core bug、existing affordance、cosmetic preference 和 out-of-scope request。只修复或关闭已验证的 core bug；用现有使用路径回答 existing affordance；延后或拒绝 cosmetic 和 out-of-scope 请求，不要把整份报告都当作待办清单。

**状态回答顺序：** 对“都解决了吗”“is this fixed”“is this ready”等状态问题，依次回答：code 或 commit 状态、branch 或 CI 状态、release artifact 或 registry 状态、公开 issue 或 PR 状态。不要把 fixed-on-main、available in pre-release、next stable release 和 already shipped 混为一谈。

**流程：** 从公开上下文识别项目使用的 issue/PR host，并调用该平台的 CLI/API；若不存在对应集成，停止并报告缺口，不要假定 GitHub 命令适用。针对每个 open item，对照项目 release boundary 检查最新公开 release、main branch、preview/nightly/beta channel、registry/appcast 和目标 issue/PR 状态。已经进入公开 release 或有文档记录的 pre-release channel 时，用准确的升级路径关闭。已在 `main` 修复但尚未发布时，回复“已修复，等下一个版本 release”；只有项目惯例或当前请求允许 fixed-on-main closure 时才关闭，否则保持 open 并注明 next release。尚无修复时，继续分析和行动：能修则立即修复（commit 使用 `fix: closes #N`）；valid-but-unreleased item 先确认并保持 open；invalid item 用一两句说明原因后关闭。

在 live queue 中给出最终结论前，再刷新一次 issue/PR 列表，并重读本次运行期间有变化的 item。证据不完整时保留 item，不要猜测后关闭。

**PR 处理：** 把 check 状态当作数量，而不是颜色。Fork PR 的 workflows 从未运行时，会显示 0 次 check run 和非绿色 mergeability；这不代表验证失败，而是从未验证。贡献者所说“CI is green”也可能指其上游 base，而不是当前 patch。合并前先在本地复现验证，并明确 green 来自哪一层。

**PR 处理：** 每个 PR 只能有三种处置，并且必须在请求授权前的分析输出中明确命名：原样合并、把修复推到贡献者 branch 后合并，或以 not planned 关闭。只说“当前无法合并”却不提 fix-on-their-branch 选项，属于不完整的 triage；patch 的缺陷最显眼，因此这个选项也最容易被漏掉。若 PR 方向可以接受但 patch 需要修改，优先把维护者修复推到贡献者的 PR branch，再合并 PR。先检查 `maintainerCanModify`，紧接着在 push 前确认 push remote、target branch 和当前 HEAD，避免覆盖贡献者工作或把维护者修复推错仓库。若不允许修改 branch，请贡献者开启 maintainer edits 或推送所需修订；只有时间或 release safety 确有需要时，才退回到单独的维护者 commit，并在 PR 中说明。仅当方向被拒绝、不安全、不再需要或明确超出项目 scope 时，才不合并直接关闭。不要悄悄把已接受的 PR 吸收到 `main` 后再关闭原 PR。

**公开回复格式：** 加载 `references/public-reply.md` 获取完整模板（mention、一次感谢、事实段落、next-release step、编辑规则和关闭标准）。Ship Mode 使用同一模板；该文件是唯一 source of truth。

**Sign-off 行（追加到标准 sign-off）：**
```
triage:           N reviewed, N closed, N deferred
```
