#!/usr/bin/env bash
# Run one portal's durable apply helpers (no Cursor agent).
# Caller must set ROOT to repo root and cd there.
# Returns the apply helper exit code.
portal_apply_once() {
  local portal="$1"
  local py rc=0
  # shellcheck source=scripts/lib/python-utf8.sh
  source "$ROOT/scripts/lib/python-utf8.sh"
  py="$(bash "$ROOT/scripts/resolve-python.sh")"

  case "$portal" in
    linkedin)
      bash "$ROOT/scripts/preflight-portal-run.sh" linkedin || return $?
      bash "$ROOT/scripts/launch-chrome-cdp.sh" linkedin || return $?
      set +e
      if [[ "$py" == "py" ]]; then
        py -3 "$ROOT/tools/linkedin/linkedin_easy_apply.py"
      else
        "$py" "$ROOT/tools/linkedin/linkedin_easy_apply.py"
      fi
      rc=$?
      if [[ "$py" == "py" ]]; then
        py -3 "$ROOT/tools/linkedin/linkedin_external_apply.py"
      else
        "$py" "$ROOT/tools/linkedin/linkedin_external_apply.py"
      fi
      rc=$((rc | $?))
      set -e
      node "$ROOT/tools/linkedin/merge_home_daily_run.js" --log "${PORTAL_APPLY_LOG:-}" || true
      return "$rc"
      ;;
    foundit|cutshort|instahyre|hirist)
      bash "$ROOT/scripts/preflight-portal-run.sh" "$portal" || return $?
      bash "$ROOT/scripts/launch-chrome-cdp.sh" "$portal" || return $?
      set +e
      node "$ROOT/tools/$portal/daily_apply.js"
      rc=$?
      set -e
      return "$rc"
      ;;
    naukri)
      bash "$ROOT/scripts/preflight-portal-run.sh" naukri || return $?
      bash "$ROOT/scripts/launch-chrome-cdp.sh" naukri || return $?
      set +e
      node "$ROOT/tools/naukri/update_profile_resume.js"
      profile_rc=$?
      if [[ "$profile_rc" -ne 0 ]]; then
        echo "WARN: Naukri profile resume not confirmed Updated today (exit $profile_rc)" >&2
      fi
      node "$ROOT/tools/naukri/daily_apply.js"
      rc=$?
      set -e
      return "$rc"
      ;;
    indeed)
      if command -v node >/dev/null 2>&1 && [[ -f "$ROOT/tools/indeed/preflight.js" ]]; then
        set +e
        node "$ROOT/tools/indeed/preflight.js"
        local pf=$?
        set -e
        if [[ "$pf" -eq 5 ]]; then
          return 5
        fi
      fi
      bash "$ROOT/scripts/preflight-portal-run.sh" indeed || return $?
      set +e
      node "$ROOT/tools/indeed/daily_apply.js"
      rc=$?
      set -e
      return "$rc"
      ;;
    hitechcity)
      bash "$ROOT/scripts/preflight-portal-run.sh" hitechcity || return $?
      bash "$ROOT/scripts/launch-chrome-cdp.sh" hitechcity || true
      export HITECHCITY_PARALLEL_TABS="${HITECHCITY_PARALLEL_TABS:-10}"
      set +e
      if [[ "$py" == "py" ]]; then
        py -3 "$ROOT/tools/hitechcity/daily_apply.py"
      else
        "$py" "$ROOT/tools/hitechcity/daily_apply.py"
      fi
      rc=$?
      set -e
      return "$rc"
      ;;
    *)
      echo "portal_apply_once: unknown portal: $portal" >&2
      return 2
      ;;
  esac
}
