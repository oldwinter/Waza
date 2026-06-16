# Read Methods Reference

## Proxy Cascade

按顺序尝试。Success = 有可读内容的非空输出。如果 proxy 返回空内容、error page，或少于 5 行，就视为失败并尝试下一个：

### 1. defuddle.md

```bash
curl -sL "https://defuddle.md/{url}"
```

输出更干净，并带 YAML frontmatter。优先尝试它。

### 2. r.jina.ai

```bash
curl -sL "https://r.jina.ai/{url}"
```

覆盖范围广，会保留 image links。defuddle.md 返回空内容或 errors 时使用。

### 3. Web search plugin reader (if available)

如果安装了 web search plugin（例如 PipeLLM），cascade 会在 local fallback 前尝试它的 reader tool。它比 free proxies 更擅长处理 JavaScript-rendered pages。

### 4. Local tools

```bash
npx agent-fetch "{url}" --json
# or
defuddle parse "{url}" -m
```

两个 proxies 都失败时的 last resort。`agent-fetch --json` 返回 JSON，所以在返回或保存结果前要提取包含 Markdown 的 field。`defuddle parse -m` 直接输出 Markdown。Raw JSON 不是 `/read` 的 valid final output。

## GitHub URLs

GitHub file URLs（`github.com/user/repo/blob/...`）会 render heavy HTML。proxy cascade 经常返回 partial 或 nav-heavy content。优先使用：

```bash
# Raw file content (fastest)
curl -sL "https://raw.githubusercontent.com/{user}/{repo}/{branch}/{path}"

# Via gh CLI (works with private repos)
gh api repos/{user}/{repo}/contents/{path} --jq '.content' | base64 -d
```

只有对不是 raw file views 的 GitHub pages（例如 issue threads、README renders），才把 proxy cascade 作为 fallback。

## PDF to Markdown

### Remote PDF URL

r.jina.ai 可以直接处理 PDF URLs：

```bash
curl -sL "https://r.jina.ai/{pdf_url}"
```

如果失败，download 后在本地 extract：

```bash
curl -sL "{pdf_url}" -o /tmp/input.pdf
pdftotext -layout /tmp/input.pdf -
```

### Local PDF file

```bash
# Best quality (requires: pip install marker-pdf)
marker_single /path/to/file.pdf --output_dir "${READ_OUTPUT_DIR:-/tmp/waza-read}"

# Fast, text-heavy PDFs (requires: brew install poppler)
pdftotext -layout /path/to/file.pdf - | sed 's/\f/\n---\n/g'

# No-dependency fallback
python3 -c "
import pypdf, sys
r = pypdf.PdfReader(sys.argv[1])
print('\n\n'.join(p.extract_text() for p in r.pages))
" /path/to/file.pdf
```

layout 重要时（papers、tables）使用 `marker`。需要速度时使用 `pdftotext`。

## Feishu / Lark Document

先 resolve built-in helper script directory 一次。single-skill install、packaged dispatcher 或 source repo root 下都可用：

```bash
READ_SCRIPT_DIR=""
for candidate in \
  "${CLAUDE_SKILL_DIR:+$CLAUDE_SKILL_DIR/scripts}" \
  "${CLAUDE_SKILL_DIR:+$CLAUDE_SKILL_DIR/skills/read/scripts}" \
  "./skills/read/scripts"; do
  if [ -n "$candidate" ] && [ -f "$candidate/fetch_feishu.py" ]; then
    READ_SCRIPT_DIR="$candidate"
    break
  fi
done
if [ -z "$READ_SCRIPT_DIR" ]; then
  echo "read helper scripts not found; set CLAUDE_SKILL_DIR or run from the Waza repo root" >&2
  exit 1
fi
```

需要 `requests` 和 Feishu app credentials：

```bash
pip install requests  # one-time setup
export FEISHU_APP_ID=your_app_id
export FEISHU_APP_SECRET=your_app_secret
python3 "$READ_SCRIPT_DIR/fetch_feishu.py" "{url}"
```

Supports：docx 和 wiki pages。Legacy `/docs/` pages 不受此 script 支持；先把它们 convert 成 docx，或在 document 无需 API 即可访问时使用 public-page fallback。App 需要 `docx:document:readonly` 和 `wiki:wiki:readonly` permissions。
Output：YAML frontmatter（title、document_id、url）+ Markdown body。

## WeChat Public Account

使用 proxy cascade（r.jina.ai / defuddle.md）。多数 articles 不需要额外 tools 就可用。

如果 proxy 被阻止，把 built-in Playwright script 作为 last resort（需要约 300 MB one-time install）：

```bash
pip install playwright beautifulsoup4 lxml && playwright install chromium
python3 "$READ_SCRIPT_DIR/fetch_weixin.py" "{url}"
```
