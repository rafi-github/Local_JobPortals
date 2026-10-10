#!/usr/bin/env bash
# Home/local Notification Job — email daily status from all portal home runs.
# Intended for Task Scheduler after portal jobs finish (default 11:30).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

LOG_DIR="${HOME_PORTAL_LOG_DIR:-$ROOT/artifacts/home-logs/notification}"
mkdir -p "$LOG_DIR" "$ROOT/artifacts"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG="$LOG_DIR/notification-$STAMP.log"

exec > >(tee -a "$LOG") 2>&1

echo "=== notification home daily @ $STAMP ==="

PORTALS=(linkedin foundit cutshort naukri instahyre indeed hirist hitechcity)
for p in "${PORTALS[@]}"; do
  echo "--- fetch $p ---"
  bash scripts/fetch-home-result.sh "$p" --today || true
done

export HOME_LOCAL=1
unset CURSOR_API_KEY CURSOR_AGENT_BIN || true
# shellcheck disable=SC1091
source "$ROOT/scripts/load-job-secrets.sh" || true

TODAY="$(date -u +%Y-%m-%d)"
REPORT="$(node "$ROOT/scripts/compose-job-status.mjs" "$ROOT")"
echo "Wrote $REPORT"

if [[ -n "${RESEND_API_KEY:-}" ]]; then
  node "$ROOT/scripts/send-job-status-email.mjs" \
    --to "${JOB_STATUS_EMAIL:-rafi.success@gmail.com}" \
    --subject "Job status — ${TODAY}" \
    --body-file "$REPORT"
else
  echo "RESEND_API_KEY unset — status file written, email skipped."
fi

echo "=== done; log=$LOG report=$REPORT ==="
