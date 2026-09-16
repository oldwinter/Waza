#!/usr/bin/env bash
# README Skills table identity is the install/folder name, not a slash command.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_helpers.sh"

readme="$ROOT/README.md"

section=$(awk '/^## Skills$/{p=1;next} /^## /{if(p) exit} p' "$readme")
test -n "$section"

echo "$section" | grep -q '| Skill | Claude Code |' \
  || { echo "Skills table missing Skill / Claude Code columns"; exit 1; }

# First-column identity must be the on-disk slug, not `/think`.
if echo "$section" | grep -qE '\|\s*\[`/'; then
  echo "Skills table still uses a slash command as the first-column identity"
  exit 1
fi

missing=0
for skill_md in "$ROOT"/skills/*/SKILL.md; do
  slug=$(basename "$(dirname "$skill_md")")
  row=$(echo "$section" | grep -E "^\| \[\`${slug}\`\]\(skills/${slug}/SKILL.md\) \|" || true)
  if [ -z "$row" ]; then
    echo "Skills table missing install-name row for ${slug}"
    missing=1
    continue
  fi
  echo "$row" | grep -Fq "\`/${slug}\`" \
    || { echo "Skills table row for ${slug} missing Claude Code /${slug}"; missing=1; }
  test -f "$ROOT/skills/${slug}/SKILL.md" \
    || { echo "missing skills/${slug}/SKILL.md"; missing=1; }
done

test "$missing" -eq 0

# Codex / Cursor next step is named in the Skills section, not only implied.
echo "$section" | grep -q 'Codex / Cursor' \
  || { echo "Skills section does not name Codex / Cursor call path"; exit 1; }

echo "readme skills table: ok"
