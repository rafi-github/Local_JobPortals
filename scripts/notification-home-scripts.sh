#!/usr/bin/env bash
# Email daily status from home-local JSON (no Cursor agent).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

LOG_DIR="${HOME_PORTAL_LOG_DIR:-$HOME/.cursor/portal-home-logs/notification}"
mkdir -p "$LOG_DIR" "$ROOT/artifacts" "$ROOT/reports"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG="$LOG_DIR/notification-scripts-$STAMP.log"

exec > >(tee -a "$LOG") 2>&1

echo "=== notification home scripts @ $STAMP (no agent) ==="

DATE="$(TZ=Asia/Kolkata date +%Y-%m-%d)"
REPORT_MD="$ROOT/artifacts/job-status-${DATE}.md"
REPORT_COPY="$ROOT/reports/${DATE}/job-status.md"

node "$ROOT/tools/compile_home_job_status.js" --date "$DATE" --out "$REPORT_MD"
mkdir -p "$(dirname "$REPORT_COPY")"
cp "$REPORT_MD" "$REPORT_COPY"

# shellcheck source=scripts/load-job-secrets.sh
source "$ROOT/scripts/load-job-secrets.sh"

load_env_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  set -a
  # shellcheck disable=SC1090
  source "$f"
  set +a
  echo "Loaded env file (values hidden): $f"
}

HYD_ROOT="${JOBS_HYDERABAD_ROOT:-}"
if [[ -z "$HYD_ROOT" && -d "$ROOT/../Local_JobsHyderabad" ]]; then
  HYD_ROOT="$(cd "$ROOT/../Local_JobsHyderabad" && pwd)"
fi
if [[ -n "$HYD_ROOT" ]]; then
  load_env_file "$HYD_ROOT/.env"
  load_env_file "$HYD_ROOT/data/.secrets.env"
  load_env_file "$HYD_ROOT/job-apply-secrets.env"
  load_env_file "$HYD_ROOT/data/job-apply-secrets.env"
fi
load_env_file "${HOME}/.job-apply-secrets.env"

TO="${JOB_STATUS_EMAIL:-${EMAIL_TO:-rafi.success@gmail.com}}"
SUBJECT="Job status — ${DATE}"

sent=0
if [[ -n "${RESEND_API_KEY:-}" ]]; then
  echo "Sending via Resend to $TO"
  set +e
  node "$ROOT/scripts/send-job-status-email.mjs" \
    --to "$TO" \
    --subject "$SUBJECT" \
    --body-file "$REPORT_MD"
  mail_rc=$?
  set -e
  if [[ "$mail_rc" -eq 0 ]]; then
    sent=1
  else
    echo "WARNING: send-job-status-email.mjs exit $mail_rc — trying Gmail compose"
  fi
else
  echo "RESEND_API_KEY unset — trying Gmail compose in Chrome CDP"
fi

if [[ "$sent" -eq 0 ]]; then
  PY=""
  if [[ -n "${HYD_ROOT:-}" && -x "$HYD_ROOT/.venv/Scripts/python.exe" ]]; then
    PY="$HYD_ROOT/.venv/Scripts/python.exe"
  elif [[ -n "${HYD_ROOT:-}" && -x "$HYD_ROOT/.venv/bin/python" ]]; then
    PY="$HYD_ROOT/.venv/bin/python"
  elif command -v python3 >/dev/null 2>&1; then
    PY="python3"
  elif command -v python >/dev/null 2>&1; then
    PY="python"
  fi
  if [[ -z "$PY" ]]; then
    echo "WARNING: no Python with Playwright for Gmail compose fallback"
  else
    echo "Sending via Gmail compose ($PY)"
    set +e
    "$PY" "$ROOT/scripts/send_job_status_gmail_compose.py" \
      --to "$TO" \
      --subject "$SUBJECT" \
      --body-file "$REPORT_MD"
    mail_rc=$?
    set -e
    if [[ "$mail_rc" -eq 0 ]]; then
      sent=1
    fi
  fi
fi

if [[ "$sent" -eq 0 ]]; then
  echo "WARNING: job status email was not sent. Report: $REPORT_MD"
  exit 1
fi

echo "=== done; log=$LOG ==="
exit 0
