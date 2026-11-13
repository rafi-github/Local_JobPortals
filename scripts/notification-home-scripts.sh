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

# shellcheck source=scripts/lib/chrome-cdp-mode-home.sh
source "$ROOT/scripts/lib/chrome-cdp-mode-home.sh"
chrome_cdp_mode_home_default

sent=0

gmail_compose_send() {
  local py=""
  if [[ -n "${HYD_ROOT:-}" && -x "$HYD_ROOT/.venv/Scripts/python.exe" ]]; then
    py="$HYD_ROOT/.venv/Scripts/python.exe"
  elif [[ -n "${HYD_ROOT:-}" && -x "$HYD_ROOT/.venv/bin/python" ]]; then
    py="$HYD_ROOT/.venv/bin/python"
  else
    PY="$(bash "$ROOT/scripts/resolve-python.sh")"
    if [[ "$PY" == "py" ]]; then
      py="py -3"
    elif [[ -n "$PY" ]]; then
      py="$PY"
    elif command -v python3 >/dev/null 2>&1; then
      py="python3"
    elif command -v python >/dev/null 2>&1; then
      py="python"
    fi
  fi
  if [[ -z "$py" ]]; then
    echo "WARNING: no Python with Playwright for Gmail compose"
    return 1
  fi
  if ! curl -fsS "http://127.0.0.1:9222/json/version" >/dev/null 2>&1; then
    echo "NOTE: launching system Chrome CDP for Gmail compose…"
    set +e
    bash "$ROOT/scripts/launch-chrome-cdp.sh" linkedin
    set -e
  fi
  echo "Sending via Gmail compose ($py)"
  set +e
  if [[ "$py" == "py -3" ]]; then
    py -3 "$ROOT/scripts/send_job_status_gmail_compose.py" \
      --to "$TO" --subject "$SUBJECT" --body-file "$REPORT_MD"
  else
    "$py" "$ROOT/scripts/send_job_status_gmail_compose.py" \
      --to "$TO" --subject "$SUBJECT" --body-file "$REPORT_MD"
  fi
  local mail_rc=$?
  set -e
  return "$mail_rc"
}

prefer_gmail=0
if is_windows_home_shell && [[ "${JOB_STATUS_EMAIL_VIA_GMAIL:-1}" == "1" ]]; then
  prefer_gmail=1
fi

if [[ "$prefer_gmail" -eq 1 ]]; then
  set +e
  gmail_compose_send
  mail_rc=$?
  set -e
  [[ "$mail_rc" -eq 0 ]] && sent=1
fi

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
    echo "WARNING: Resend send failed with exit $mail_rc"
  fi
else
  echo "RESEND_API_KEY is not configured"
fi

if [[ "$sent" -eq 0 && -n "${SMTP_HOST:-}" && -n "${SMTP_USER:-}" && -n "${SMTP_PASSWORD:-}" ]]; then
  echo "Sending via configured SMTP service (credentials hidden)"
  set +e
  PY="$(bash "$ROOT/scripts/resolve-python.sh")"
  if [[ "$PY" == "py" ]]; then
    py -3 "$ROOT/scripts/send-job-status-smtp.py" --to "$TO" --subject "$SUBJECT" --body-file "$REPORT_MD"
  else
    "$PY" "$ROOT/scripts/send-job-status-smtp.py" --to "$TO" --subject "$SUBJECT" --body-file "$REPORT_MD"
  fi
  mail_rc=$?
  set -e
  [[ "$mail_rc" -eq 0 ]] && sent=1
fi

if [[ "$sent" -eq 0 ]]; then
  gmail_fb="${JOB_STATUS_GMAIL_FALLBACK:-0}"
  if is_windows_home_shell && [[ "$gmail_fb" == "0" ]]; then
    gmail_fb=1
  fi
  if [[ "$gmail_fb" == "1" && "$prefer_gmail" -eq 0 ]]; then
    set +e
    gmail_compose_send
    mail_rc=$?
    set -e
    [[ "$mail_rc" -eq 0 ]] && sent=1
  fi
fi

if [[ "$sent" -eq 0 ]]; then
  echo "WARNING: job status email was not sent. Report: $REPORT_MD"
  exit 1
fi

echo "=== done; log=$LOG ==="
exit 0
