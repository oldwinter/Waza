# Product Localization Copy Review

用于 review product pages、release notes、app strings、runtime notifications、appcast 或 update feeds、docs/help pages、legal/privacy copy，以及其他 localized product surfaces。

## Core Principles

1. **编辑前先拆分 surfaces。** Release feed、website page、runtime catalog、help article 和 legal page 可能有意支持不同的 locale sets。不要强迫每个 surface 都对齐最宽的 locale coverage。
2. **固定 product facts。** 除非用户要求修改，否则保留 versions、dates、item order、links、placeholders、keyboard shortcuts、product names、bundle IDs 和 behavior claims。
3. **把 source files 当作编辑目标，不要直接改 generated output。** 只有当项目明确把 generated pages 当 source 时，才 patch generated pages。否则先找到 template、locale JSON、string catalog 或 content partial，然后 rebuild。
4. **review 最终 rendered 或 generated surface。** 翻译在 source file 里可能看起来没问题，但在 button、menu、release feed、notification 或 generated HTML page 里会坏掉。
5. **不要 polish 成通用 marketing。** Native localization 是句子听起来像本地产品，而不是像流畅的销售页。

## High-Signal Failure Patterns

- **Chinese**：literal possessives，比如 plain "Mac" 或 "本机" 就够时却写成 "你的 Mac" 或 "你的设备"；结果句更自然时仍使用机器输出式动词，比如 "检测到"；punctuation 混用；已经有稳定中文对应词的 English words。
- **Traditional Chinese**：把 Mainland phrasing 直接复制到 Traditional copy；stale locale URLs；对目标 audience 来说过于大陆化或过口语的词。
- **Japanese**：English noun compounds 翻得过紧；项目 style 需要时，product terms 周围缺少 spaces；UI strings 听起来像 manual 而不是 Mac app。
- **Korean**：platform terms 不一致，尤其是 menu bar / menu item wording；过于字面化的第二人称句子。
- **German**：ASCII fallbacks，例如 `fuer`、`Pruef`、`Eintraege`、`Menue`、`Luefter`；user-facing copy 中出现 English developer nouns，比如 "binary"。
- **Spanish**：missing accents，例如 `gestion`、`analisis`、`menus`、`suscripcion`；机械替换导致 invalid forms，比如 `actualizaciónes`。
- **French**：missing apostrophes 或 accents，例如 `L app`、`memoire`、`desinstallation`、`defaut`；当周围文本已使用 French conventions 时，标点前空格也应遵循。
- **Italian**：missing accents 和 articles，例如 `piu`、`non e`、`un app`；机械替换导致 invalid forms，比如 `puòi`。

## Review Procedure

1. 识别 scope 内所有 source 和 generated surfaces。网站包括 templates、locale JSON、content partials、generated pages、language switchers、canonical links 和 route rewrites。App 包括 runtime catalogs、permission strings、update feeds 和 notification copy。
2. 选择 factual source of truth。Release notes 通常跟随 English release page 或 changelog；runtime copy 跟随当前 app behavior 和 placeholders。
3. 第一轮检查 local voice：移除 translationese，恢复本地 punctuation，并保持 product names 稳定。
4. 第二轮检查 mechanical artifacts：missing accents、stale paths、invalid plural forms、malformed placeholders，以及误把 path 翻译了。
5. Rebuild generated files，并重新运行相关 project checks。如果用户只要求 review，列出需要的 checks，不要声称已经运行。

## Rewrite Rules

- Placeholders 必须原样保留，包括顺序和类型：`%@`、`%d`、`%1$@`、`{name}` 以及类似 tokens。
- 不要在 code 或 copy 中用 punctuation 拼接 translated fragments。每个 locale 使用完整 sentence 或 format string 更安全。
- 避免 broad find-and-replace，除非随后做 residual scan。大范围 accent fixes 可能产生 broken words。
- 当产品本身这样使用时，product names 和 established UI names 保留英文。
- Legal 和 privacy copy 应保持 plain 且 accurate。不要为了更友好而削弱 obligations、data collection boundaries、refund terms 或 third-party roles。
- Release feed localization 可以比 website localization 更窄。尊重 surface-specific product decision。

## Output Guidance

Rewrite requests 返回编辑后的 localized copy。Review requests 先按 surface 分组，再按 locale 分组。当 copy 误述 product behavior、privacy、legal terms、version history 或 update availability 时，明确标为 blocker。
