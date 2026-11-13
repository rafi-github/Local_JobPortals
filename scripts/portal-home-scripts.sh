#!/usr/bin/env bash
# Run one portal's daily apply on THIS machine using durable scripts only (no Cursor agent).
# Usage:
#   bash scripts/portal-home-scripts.sh <portal>
set -euo pipefail

PORTAL="${1:-}"
case "$PORTAL" in
  linkedin|foundit|cutshort|naukri|instahyre|indeed|hirist|hitechcity) ;;
  *)
    echo "Usage: bash scripts/portal-home-scripts.sh <linkedin|foundit|cutshort|naukri|instahyre|indeed|hirist|hitechcity>"
    exit 2
    ;;
esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# shellcheck source=scripts/lib/chrome-cdp-mode-home.sh
source "$ROOT/scripts/lib/chrome-cdp-mode-home.sh"
chrome_cdp_mode_home_default
if [[ "$PORTAL" == "indeed" && -z "${INDEED_SKIP_WARP:-}" && "${CHROME_CDP_MODE:-}" == "system" ]]; then
  export INDEED_SKIP_WARP=1
fi
if [[ "$PORTAL" == "indeed" ]]; then
  # Use the user's normal connection; do not proxy-rotate or automate challenges.
  export INDEED_SKIP_WARP=1
  export INDEED_SKIP_UC_BYPASS=1
fi

LOG_DIR="${HOME_PORTAL_LOG_DIR:-$HOME/.cursor/portal-home-logs/$PORTAL}"
mkdir -p "$LOG_DIR" "$ROOT/artifacts"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG="$LOG_DIR/$PORTAL-scripts-$STAMP.log"
REPORT_LOCAL="$ROOT/artifacts/${PORTAL}-daily-run.json"
REPORT_HOME="$LOG_DIR/${PORTAL}-daily-run.json"
REPORT_TOOL="$ROOT/tools/home_run_report.js"

if [[ "$PORTAL" == "indeed" && -f "$ROOT/tools/indeed/daily_run_report.js" ]]; then
  REPORT_TOOL="$ROOT/tools/indeed/daily_run_report.js"
fi

exec > >(tee -a "$LOG") 2>&1

echo "=== $PORTAL home scripts @ $STAMP (no agent) ==="
echo "cwd=$ROOT host=$(hostname)"

write_empty() {
  local reason="$1"
  local out="$2"
  if [[ "$REPORT_TOOL" == *home_run_report.js ]]; then
    node "$REPORT_TOOL" empty --portal "$PORTAL" --reason "$reason" --source home-local --log "$LOG" --out "$out"
  else
    node "$REPORT_TOOL" empty --reason "$reason" --source home-local --log "$LOG" --out "$out"
  fi
}

normalize_report() {
  local inn="$1"
  local out="$2"
  if [[ "$REPORT_TOOL" == *home_run_report.js ]]; then
    node "$REPORT_TOOL" write --portal "$PORTAL" --in "$inn" --source home-local --log "$LOG" --out "$out"
  else
    node "$REPORT_TOOL" write --in "$inn" --source home-local --log "$LOG" --out "$out"
  fi
}

export HOME_LOCAL=1
export PORTAL
export PORTAL_APPLY_LOG="$LOG"
export PORTAL_RUN_DATE="$(TZ=Asia/Kolkata date +%Y-%m-%d)"
RUN_STARTED_MS="$(node -p 'Date.now()')"
# Node helpers (Naukri tailor/ensure_upload_resume) must not call bare python3 on Windows.
PY_RESOLVED="$(bash "$ROOT/scripts/resolve-python.sh")"
if [[ "$PY_RESOLVED" == "py" ]]; then
  export PYTHON_BIN="py"
else
  export PYTHON_BIN="$PY_RESOLVED"
fi

# shellcheck source=scripts/lib/portal-apply-once.sh
source "$ROOT/scripts/lib/portal-apply-once.sh"

set +e
portal_apply_once "$PORTAL"
apply_rc=$?
set -e

if [[ "$PORTAL" == "indeed" && "$apply_rc" -eq 5 ]]; then
  echo "Indeed denied access or automated applications are disabled; skipping without bypass."
  write_empty "indeed_cloudflare_or_automation_disabled_compliant_access_only" "$REPORT_LOCAL" || true
  cp "$REPORT_LOCAL" "$REPORT_HOME" 2>/dev/null || true
  exit 5
fi

TODAY="$PORTAL_RUN_DATE"
is_same_day_report() {
  local f="$1"
  [[ -f "$f" ]] || return 1
  node -e "
    const fs = require('fs');
    try {
      const j = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
      const fresh = fs.statSync(process.argv[1]).mtimeMs >= Number(process.argv[3]);
      process.exit(j.date === process.argv[2] && fresh ? 0 : 1);
    } catch {
      process.exit(1);
    }
  " "$f" "$TODAY" "$RUN_STARTED_MS"
}

FINAL_REPORT=""
for cand in "$REPORT_LOCAL" "$REPORT_HOME"; do
  if is_same_day_report "$cand"; then
    FINAL_REPORT="$cand"
    break
  fi
done

if [[ -z "$FINAL_REPORT" ]]; then
  echo "WARNING: no fresh ${PORTAL}-daily-run.json for $TODAY after scripts (rc=$apply_rc)"
  failure_reason="scripts_finished_without_same_day_report_exit_${apply_rc}"
  if grep -Eqi 'ECONNREFUSED.*9222|CDP did not become ready' "$LOG"; then
    failure_reason="chrome_cdp_unavailable_port_9222"
  elif grep -Eqi 'different profile.*9222|CDP port 9222 is serving' "$LOG"; then
    failure_reason="chrome_cdp_port_9222_profile_conflict"
  elif grep -Eqi 'login_required|still not logged in|sign in interactively' "$LOG"; then
    failure_reason="${PORTAL}_interactive_login_required"
  elif [[ "$PORTAL" == "indeed" && "$apply_rc" -eq 5 ]]; then
    failure_reason="indeed_access_blocked_or_automation_disabled_compliant_access_only"
  fi
  write_empty "$failure_reason" "$REPORT_LOCAL" || true
  FINAL_REPORT="$REPORT_LOCAL"
fi

normalize_report "$FINAL_REPORT" "$REPORT_LOCAL"
cp "$REPORT_LOCAL" "$REPORT_HOME" 2>/dev/null || true

echo "Remote publishing is disabled for local daily runs. Report saved locally: $REPORT_LOCAL"

echo "=== done; log=$LOG report=$REPORT_LOCAL apply_rc=$apply_rc ==="
exit "$apply_rc"
