#!/usr/bin/env bash
# Run one portal's daily apply on THIS machine (home / residential).
# Usage:
#   bash scripts/portal-home-daily.sh <portal>
# Portals: linkedin | foundit | cutshort | naukri | instahyre | indeed | hitechcity
set -euo pipefail

PORTAL="${1:-}"
case "$PORTAL" in
  linkedin|foundit|cutshort|naukri|instahyre|indeed|hirist|hitechcity) ;;
  *)
    echo "Usage: bash scripts/portal-home-daily.sh <linkedin|foundit|cutshort|naukri|instahyre|indeed|hirist|hitechcity>"
    exit 2
    ;;
esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Windows home: reuse Default Chrome (ABE). Export for child tools.
if [[ -z "${CHROME_CDP_MODE:-}" ]]; then
  case "$(uname -s 2>/dev/null)" in
    MINGW*|MSYS*|CYGWIN*) export CHROME_CDP_MODE=system ;;
  esac
  [[ "${OS:-}" == "Windows_NT" ]] && export CHROME_CDP_MODE=system
fi
# Indeed on Windows home: skip WARP (corp/Zscaler may still CF-block — see preflight).
if [[ "$PORTAL" == "indeed" && -z "${INDEED_SKIP_WARP:-}" && "${CHROME_CDP_MODE:-}" == "system" ]]; then
  export INDEED_SKIP_WARP=1
fi

prompt_file_for() {
  case "$1" in
    linkedin) echo "automation-prompts/01-linkedin.md" ;;
    foundit) echo "automation-prompts/02-foundit.md" ;;
    cutshort) echo "automation-prompts/03-cutshort.md" ;;
    naukri) echo "automation-prompts/04-naukri-general.md" ;;
    instahyre) echo "automation-prompts/05-instahyre.md" ;;
    indeed) echo "automation-prompts/06-indeed.md" ;;
    hirist) echo "automation-prompts/09-hirist.md" ;;
    hitechcity) echo "automation-prompts/08-hitech-city.md" ;;
  esac
}
PROMPT_MD="$(prompt_file_for "$PORTAL")"

LOG_DIR="${HOME_PORTAL_LOG_DIR:-$ROOT/artifacts/home-logs/$PORTAL}"
mkdir -p "$LOG_DIR" "$ROOT/artifacts"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG="$LOG_DIR/$PORTAL-$STAMP.log"
REPORT_CLOUD="/opt/cursor/artifacts/${PORTAL}-daily-run.json"
REPORT_LOCAL="$ROOT/artifacts/${PORTAL}-daily-run.json"
REPORT_HOME="$LOG_DIR/${PORTAL}-daily-run.json"
REPORT_TOOL="$ROOT/tools/home_run_report.js"

# Indeed keeps its specialized normalizer for backward compatibility.
if [[ "$PORTAL" == "indeed" && -f "$ROOT/tools/indeed/daily_run_report.js" ]]; then
  REPORT_TOOL="$ROOT/tools/indeed/daily_run_report.js"
fi

exec > >(tee -a "$LOG") 2>&1

echo "=== $PORTAL home daily @ $STAMP ==="
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

# Indeed Cloudflare gate (residential IP required).
# Home Windows: skip WARP — residential IP is the Cloudflare bypass.
if [[ "$PORTAL" == "indeed" ]]; then
  is_win=0
  [[ "${OS:-}" == "Windows_NT" || -n "${MSYSTEM:-}" || "$(uname -s 2>/dev/null)" == MINGW* ]] && is_win=1
  if [[ "$is_win" -eq 1 ]]; then
    export INDEED_SKIP_WARP="${INDEED_SKIP_WARP:-1}"
    echo "NOTE: Windows home Indeed — INDEED_SKIP_WARP=${INDEED_SKIP_WARP}"
  fi
fi
if [[ "$PORTAL" == "indeed" ]] && command -v node >/dev/null 2>&1 && [[ -f tools/indeed/preflight.js ]]; then
  set +e
  node tools/indeed/preflight.js
  pf=$?
  set -e
  if [[ "$pf" -eq 5 ]]; then
    echo "ERROR: Indeed Cloudflare block on this IP. Use home Wi‑Fi, not datacenter VPN/cloud."
    write_empty "indeed_cloudflare_private_worker_required" "$REPORT_LOCAL" || true
    cp "$REPORT_LOCAL" "$REPORT_HOME" 2>/dev/null || true
    bash scripts/publish-home-result.sh indeed "$REPORT_LOCAL" || true
    exit 5
  fi
  if [[ "$pf" -ne 0 ]]; then
    echo "WARNING: indeed preflight exit $pf — continuing to agent."
  fi
fi

EXTRA_STEPS=""
case "$PORTAL" in
  linkedin|naukri|indeed|hitechcity)
    EXTRA_STEPS="Then: bash scripts/launch-chrome-cdp.sh $PORTAL"
    ;;
esac
if [[ "$PORTAL" == "naukri" ]]; then
  EXTRA_STEPS="$EXTRA_STEPS
CRITICAL STEP 0 before applies: node tools/naukri/update_profile_resume.js (profileUpdated: true)."
fi
if [[ "$PORTAL" == "hitechcity" ]]; then
  EXTRA_STEPS="$EXTRA_STEPS
Run: python tools/hitechcity/daily_apply.py (or py -3). Every daily run uses parallel multi-tab careers (HITECHCITY_PARALLEL_TABS=10 by default) — do not set tabs=1. Write artifacts/hitechcity-daily.json AND artifacts/hitechcity-daily-run.json (home schema)."
fi

# Local runners only. Do not start the Cursor CLI or call the Cursor API.
export HOME_LOCAL=1
export PORTAL
unset CURSOR_API_KEY CURSOR_AGENT_BIN || true
export CURSOR_ARTIFACTS_DIR="$ROOT/artifacts"
# shellcheck disable=SC1091
source "$ROOT/scripts/load-job-secrets.sh" || true

export LINKEDIN_APPLY_REPORT="$ROOT/artifacts/linkedin-apply-report.json"
export LINKEDIN_EXTERNAL_REPORT="$ROOT/artifacts/linkedin-external-apply-report.json"
export FOUNDIT_REPORT="$ROOT/artifacts/foundit-apply-report.json"
export INSTAHYRE_REPORT="$ROOT/artifacts/instahyre-apply-report.json"
export HIRIST_REPORT="$ROOT/artifacts/hirist-apply-report.json"
export INDEED_REPORT="$ROOT/artifacts/indeed-apply-report.json"
export NAUKRI_APPLY_REPORT="$ROOT/artifacts/naukri-daily-apply.json"
export CUTSHORT_HOME_REPORT="$ROOT/artifacts/cutshort-daily-run.json"
export HITECHCITY_REPORT="$ROOT/artifacts/hitechcity-daily.json"

run_py() {
  local py
  py="$(bash "$ROOT/scripts/resolve-python.sh")"
  if [[ "$py" == "py" ]]; then
    py -3 "$@"
  else
    "$py" "$@"
  fi
}

echo "Local apply (no Cursor): portal=$PORTAL prompt_ref=$PROMPT_MD"
if [[ -n "$EXTRA_STEPS" ]]; then
  echo "Runner notes:"
  printf '%s\n' "$EXTRA_STEPS"
fi

set +e
run_rc=0
case "$PORTAL" in
  linkedin)
    bash "$ROOT/scripts/preflight-portal-run.sh" linkedin || run_rc=$?
    if [[ "$run_rc" -eq 0 ]]; then
      bash "$ROOT/scripts/launch-chrome-cdp.sh" linkedin || run_rc=$?
    fi
    if [[ "$run_rc" -eq 0 ]]; then
      run_py "$ROOT/tools/linkedin/linkedin_easy_apply.py" || run_rc=$?
      run_py "$ROOT/tools/linkedin/linkedin_external_apply.py" || run_rc=$?
    fi
    ;;
  foundit|cutshort|naukri|instahyre|hirist)
    bash "$ROOT/scripts/preflight-portal-run.sh" "$PORTAL" || run_rc=$?
    if [[ "$run_rc" -eq 0 ]]; then
      bash "$ROOT/scripts/launch-chrome-cdp.sh" "$PORTAL" || run_rc=$?
    fi
    if [[ "$run_rc" -eq 0 ]]; then
      node "$ROOT/tools/$PORTAL/daily_apply.js" || run_rc=$?
    fi
    ;;
  indeed)
    bash "$ROOT/scripts/preflight-portal-run.sh" indeed || true
    node "$ROOT/tools/indeed/daily_apply.js" || run_rc=$?
    ;;
  hitechcity)
    bash "$ROOT/scripts/preflight-portal-run.sh" hitechcity || run_rc=$?
    if [[ "$run_rc" -eq 0 ]]; then
      bash "$ROOT/scripts/launch-chrome-cdp.sh" hitechcity || run_rc=$?
    fi
    if [[ "$run_rc" -eq 0 ]]; then
      HITECHCITY_CAREERS_ONLY="${HITECHCITY_CAREERS_ONLY:-1}" \
        run_py "$ROOT/tools/hitechcity/daily_apply.py" || run_rc=$?
    fi
    ;;
esac
set -e
cd "$ROOT"

TODAY_UTC="$(date -u +%Y-%m-%d)"
is_same_day_report() {
  local f="$1"
  [[ -f "$f" ]] || return 1
  node -e "
    const fs = require('fs');
    try {
      const j = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
      process.exit(j.date === process.argv[2] ? 0 : 1);
    } catch {
      process.exit(1);
    }
  " "$f" "$TODAY_UTC"
}

RAW="$ROOT/artifacts/${PORTAL}-raw.json"
RAW="$RAW" node -e "
const fs = require('fs');
const parts = [];
for (const p of process.argv.slice(1)) {
  try { parts.push(JSON.parse(fs.readFileSync(p, 'utf8'))); } catch {}
}
if (!parts.length) process.exit(2);
const merged = { portal: process.env.PORTAL, source: 'home-local', finishedAt: new Date().toISOString() };
for (const key of ['applied','submitted','external','rejected','blocked','skipped','seen']) {
  const lists = parts.map((p) => (Array.isArray(p[key]) ? p[key] : []));
  if (lists.some((l) => l.length)) merged[key] = lists.flat();
}
if (merged.submitted && !merged.applied) merged.applied = merged.submitted;
const withCounts = parts.find((p) => p.counts && typeof p.counts === 'object');
if (withCounts) merged.counts = withCounts.counts;
const blocker = parts.map((p) => p.blockerSummary || p.reason).find(Boolean);
if (blocker) merged.blockerSummary = blocker;
fs.mkdirSync(require('path').dirname(process.env.RAW), { recursive: true });
fs.writeFileSync(process.env.RAW, JSON.stringify(merged, null, 2));
" \
  "$ROOT/artifacts/${PORTAL}-daily-run.json" \
  "$ROOT/artifacts/${PORTAL}-apply-report.json" \
  "$ROOT/artifacts/${PORTAL}-daily.json" \
  "$ROOT/artifacts/${PORTAL}-daily-apply.json" \
  "$LINKEDIN_APPLY_REPORT" \
  "$LINKEDIN_EXTERNAL_REPORT" \
  || true

FINAL_REPORT=""
for cand in "$REPORT_LOCAL" "$REPORT_HOME" "$RAW"; do
  if is_same_day_report "$cand"; then
    FINAL_REPORT="$cand"
    break
  fi
done

if [[ -z "$FINAL_REPORT" && -f "$RAW" ]]; then
  FINAL_REPORT="$RAW"
fi

if [[ -z "$FINAL_REPORT" ]]; then
  echo "WARNING: no ${PORTAL} report after local runner (rc=$run_rc)"
  write_empty "local_runner_exit_${run_rc}" "$REPORT_LOCAL" || true
  FINAL_REPORT="$REPORT_LOCAL"
fi

normalize_report "$FINAL_REPORT" "$REPORT_LOCAL"
cp "$REPORT_LOCAL" "$REPORT_HOME" 2>/dev/null || true

echo "Publishing ${PORTAL} home results for daily mail…"
bash scripts/publish-home-result.sh "$PORTAL" "$REPORT_LOCAL"

echo "=== done; log=$LOG report=$REPORT_LOCAL run_rc=$run_rc ==="
exit "$run_rc"
