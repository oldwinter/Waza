# Triage Mode（issue / PR 队列）

当请求是 issue/PR triage 时，由 `check` 的 Mode Picker 加载。`SKILL.md` 中的共享 review surface（Scope、Hard Rules、Hard Stops、Autofix、Specialist Review、Verification、Sign-off）仍然适用。

当用户提到 issue、PR、"review all"、triage、"batch" 或“批量处理”时激活。跳过 diff flow，改为执行本 mode。

**行动优先：** 对已有清晰 disposition 的 item（已修复、重复、已经发布），立即处理，不写分析长文。分析截图或图片时，在一条消息中说明看到的问题和建议动作。只有 disposition 确实有歧义时才询问用户。

**组合请求分类：** 当一个 issue、PR 或 support thread 包含多个请求时，行动前拆成 core bug、existing affordance、cosmetic preference 和 out-of-scope request。用当前路径回答 existing affordance，并按维护者接受的 scope 评估其余每个请求。分类不会取消用户明确请求的 cosmetic fix，也不会授权删除已接受的 feature；为每个请求单独记录 disposition。

**状态回答顺序：** 对“都解决了吗”“is this fixed”“is this ready”等状态问题，依次回答：code 或 commit 状态、branch 或 CI 状态、release artifact 或 registry 状态、公开 issue 或 PR 状态。不要把 fixed-on-main、available in pre-release、next stable release 和 already shipped 混为一谈。

**流程：** 从公开上下文识别项目使用的 issue/PR host，并调用该平台的 CLI/API；若不存在对应集成，停止并报告缺口，不要假定 GitHub 命令适用。行动前，冻结初始队列的 exact IDs 和 counts。针对每个 open item，对照项目 release boundary 检查最新公开 release、main branch、preview/nightly/beta channel、registry/appcast 和目标 issue/PR 状态。已经进入公开 release 或有文档记录的 pre-release channel 时，用准确的升级路径关闭。已在 `main` 修复但尚未发布时，回复“已修复，等下一个版本 release”；只有项目惯例或当前请求允许 fixed-on-main closure 时才关闭，否则保持 open 并注明 next release。尚无修复时，继续分析和行动：能修则立即修复（commit 使用 `fix: closes #N`）；valid-but-unreleased item 先确认并保持 open；invalid item 用一两句说明原因后关闭。

在 live queue 中给出最终结论前，再刷新一次 issue/PR 列表，并重读本次运行期间有变化的 item。将每个初始 ID 对账为 done、deferred 或 blocked，再报告最终 IDs 和 counts；新到的 item 单独列出。证据不完整时保留 item，不要猜测后关闭。缺日志、无法复现或暂时无法修复，都不能证明报告无效或应标记 not planned。说明缺少的证据和最小的下一步诊断；只在用户授权范围内发出该请求。

**PR 处理：** 把 check 状态当作数量，而不是颜色。Fork PR 的 workflows 从未运行时，0 次 check run 和非绿色 mergeability 代表未验证，不是验证失败。贡献者所说“CI is green”也可能指不同 base。合并前在本地复现验证，并明确 green 来自哪一层。

将证据未决的 PR 保持在 pending 状态。证据足以支持最终决定后，在分析输出中明确命名三种 disposition 之一：原样合并、把修复推到贡献者 branch 后合并，或以 not planned 关闭。只说“当前无法合并”却不提 fix-on-their-branch 选项，属于不完整的 triage。若 PR 方向可以接受但 patch 需要修改，优先把维护者修复推到贡献者的 PR branch，再合并 PR。先检查 `maintainerCanModify`，再在 push 前立即确认 push remote、target branch 和当前 HEAD，避免覆盖贡献者工作或推错仓库。若不允许修改 branch，请贡献者开启 maintainer edits 或推送所需修订；只有时间或 release safety 确有需要时，才退回到单独的维护者 commit，并在 PR 中说明。仅当方向被拒绝、不安全、不再需要或明确超出项目 scope 时，才不合并直接关闭。不要悄悄把已接受的 PR 吸收到 `main` 后关闭原 PR。

**公开回复：** 加载 `references/public-reply.md` 获取 login 解析、编辑或新评论、读回和关闭标准；reply 正文遵循 `/write` Public Reply Mode。

**Sign-off 行（追加到标准 sign-off）：**
```
triage:           N reviewed, N closed, N deferred
```
