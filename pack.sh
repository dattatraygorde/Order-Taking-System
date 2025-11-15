#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="${1:-order-taking.zip}"
cd "$ROOT_DIR"
# Ensure 'zip' is installed (macOS: brew install zip, Debian/Ubuntu: sudo apt-get install zip)
zip -r "$OUT" . \
  -x "target/*" ".git/*" ".idea/*" ".vscode/*" "*.log" "db_data/*" "node_modules/*" ".DS_Store" "*.iml"
echo "Created $OUT"