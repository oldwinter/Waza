#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helpers.sh"

llms="$ROOT/llms.txt"
package="$ROOT/package.json"

# This fork's LLM guide must name oldwinter/Waza as the source repo.
# Upstream tw93/Waza stays labeled separately so Pi / Claude Desktop can
# still point at the upstream distribution, not this Chinese runtime.
source_line=$(awk '/^源代码：/{print; exit}' "$llms")
test "$source_line" = "源代码：https://github.com/oldwinter/Waza"

upstream_line=$(awk '/^上游：/{print; exit}' "$llms")
test "$upstream_line" = "上游：https://github.com/tw93/Waza"

if awk '/^源代码：/{print; exit}' "$llms" | grep -q 'tw93/Waza'; then
  echo "llms.txt source line still names tw93/Waza"; exit 1
fi

grep -q 'npx skills add oldwinter/Waza' "$llms"

# Upstream-only install paths remain labeled as not this fork's runtime.
grep -q 'pi install npm:@tw93/waza' "$llms"
grep -q 'https://github.com/tw93/Waza/releases/latest/download/waza.zip' "$llms"
grep -q '上游包，不是本 fork 的中文 runtime' "$llms"
grep -q '上游 ZIP，不是本 fork 的中文 runtime' "$llms"

# Issue scope: do not rewrite package.json repository to this fork.
test "$(jq -r '.repository.url' "$package")" = "git+https://github.com/tw93/Waza.git"

echo "llms.txt fork source: ok"
