#!/bin/bash
# Usage: curl -sSL https://raw.githubusercontent.com/nik121212T/ultra-review-lite/main/install.sh | bash

set -e

SKILLS_DIR="$HOME/.claude/skills"
REPO="https://github.com/nik121212T/ultra-review-lite.git"
TMP=$(mktemp -d)

echo "Installing custom Claude skills..."
mkdir -p "$SKILLS_DIR"
git clone --depth=1 "$REPO" "$TMP"

for skill_dir in "$TMP"/*/; do
  skill_name=$(basename "$skill_dir")
  [ "$skill_name" = "install.sh" ] && continue
  if [ -d "$SKILLS_DIR/$skill_name" ]; then
    echo "  update: $skill_name"
  else
    echo "  install: $skill_name"
  fi
  cp -r "$skill_dir" "$SKILLS_DIR/"
done

rm -rf "$TMP"
echo "Done. Restart Claude Code to load new skills."
