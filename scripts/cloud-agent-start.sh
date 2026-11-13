#!/usr/bin/env bash
# Per-boot start hook for the job-apply automation Cloud Agent environment.
#
# Lifecycle split (see automation-prompts/ENV_READINESS.md):
#   install (scripts/cloud-agent-install.sh) builds the DURABLE baseline once —
#     Python + Playwright + Chromium, resume assets, npm tooling, CDP profile dirs.
#     With environment builds it runs at build time and is NOT re-run per pod.
#   start (this script) runs on EVERY boot to prepare non-secret runtime state.
# Portal authentication is completed interactively in each isolated profile.
# Must never block a boot: no `set -e`.
set -uo pipefail
cd "$(dirname "$0")/.."
# Optional local secrets for LinkedIn/Workday/Resend (gitignored file or ~/.cursor).
# Prefer Cursor Environment Secrets for cron durability.
# shellcheck disable=SC1091
source scripts/load-job-secrets.sh 2>/dev/null || true

echo "start: ready."
