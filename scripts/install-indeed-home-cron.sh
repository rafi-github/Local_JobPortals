#!/usr/bin/env bash
# Install a daily home cron for Indeed (macOS/Linux/WSL).
# Usage:
#   bash scripts/install-indeed-home-cron.sh [HH:MM]
# Default time: 09:00 local.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TIME="${1:-09:00}"
HOUR="${TIME%%:*}"
MIN="${TIME##*:}"
SCRIPT="$ROOT/scripts/indeed-home-daily.sh"
chmod +x "$SCRIPT" "$ROOT/scripts/indeed-home-daily.sh"

MARKER="# indeed-home-daily local"
LINE="$MIN $HOUR * * * cd $ROOT && /usr/bin/env bash $SCRIPT $MARKER"

existing="$(crontab -l 2>/dev/null || true)"
filtered="$(printf '%s\n' "$existing" | grep -v 'indeed-home-daily cursor' | grep -v 'indeed-home-daily local' || true)"

{
  printf '%s\n' "$filtered"
  echo "$LINE"
} | grep -v '^$' | crontab -

echo "Installed cron entry for Indeed home daily at $TIME local (local script, no Cursor CLI):"
crontab -l | grep 'indeed-home-daily' || crontab -l | tail -5
echo
echo "Test now: bash $SCRIPT"
echo "Remove: crontab -l | grep -v indeed-home-daily | crontab -"
