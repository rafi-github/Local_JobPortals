#!/usr/bin/env bash
# Run all home-local portal applies via durable scripts (no Cursor agent), then notification.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PORTALS=(linkedin foundit cutshort naukri instahyre indeed hirist hitechcity)
LOG_DIR="${HOME_PORTAL_LOG_DIR:-$HOME/.cursor/portal-home-logs/_batch}"
mkdir -p "$LOG_DIR"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
BATCH_LOG="$LOG_DIR/run-all-scripts-$STAMP.log"

exec > >(tee -a "$BATCH_LOG") 2>&1

echo "=== run-all-home-scripts @ $STAMP (no agent) ==="
echo "root=$ROOT log=$BATCH_LOG"

restore_main() {
  cd "$ROOT" || return 1
  # Keep this runner local and preserve the caller's current checkout.
}

declare -a FAILED=()
for p in "${PORTALS[@]}"; do
  echo ""
  echo "######## START $p ########"
  restore_main || {
    FAILED+=("$p:restore")
    echo "######## END $p rc=restore ########"
    continue
  }
  set +e
  bash "$ROOT/scripts/portal-home-scripts.sh" "$p"
  rc=$?
  set -e
  restore_main || true
  echo "######## END $p rc=$rc ########"
  if [[ "$rc" -ne 0 ]]; then
    FAILED+=("$p:$rc")
  fi
done

echo ""
echo "######## START notification ########"
restore_main || true
set +e
bash "$ROOT/scripts/notification-home-scripts.sh"
nrc=$?
set -e
restore_main || true
echo "######## END notification rc=$nrc ########"
if [[ "$nrc" -ne 0 ]]; then
  FAILED+=("notification:$nrc")
fi

echo ""
if [[ "${#FAILED[@]}" -gt 0 ]]; then
  echo "Completed with failures: ${FAILED[*]}"
  echo "Batch log: $BATCH_LOG"
  exit 1
fi

echo "All home script automations finished OK"
echo "Batch log: $BATCH_LOG"
exit 0
