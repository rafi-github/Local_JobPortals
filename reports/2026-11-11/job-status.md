# Job status — 2026-11-11

Home-local **scripts** run on `LAPY` (no Cursor agent). Targets: Expected CTC 65 LPA; Hyderabad + Remote/WFH; resume `Rafi_Resume.docx`.

**Totals today (fresh reports from 7/8 portals):** applied 0 · external 0 · rejected 0 · blocked 7 · skipped 0.

## Portal results (source: home-local, same-day)

| Portal | Applied | External | Rejected | Blocked | Skipped | Seen | OK | Blocker |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- |
| LinkedIn | 0 | 0 | 0 | 1 | 0 | 0 | no | CDP connect failed: BrowserType.connect_over_cdp: Timeout 180000ms exceeded.
Call log:
  - <ws preparing> retrieving websocket url from http://127.0.0.1:9222
  - <ws connecting> ws://127.0.0.1:9222/de |
| Foundit | 0 | 0 | 0 | 1 | 0 | 0 | no | scripts_finished_without_same_day_report_exit_0 |
| Cutshort | 0 | 0 | 0 | 1 | 0 | 0 | no | chrome_cdp_port_9222_profile_conflict |
| Naukri | 0 | 0 | 0 | 1 | 0 | 0 | no | chrome_cdp_port_9222_profile_conflict |
| Instahyre | 0 | 0 | 0 | 1 | 0 | 0 | no | scripts_finished_without_same_day_report_exit_0 |
| Indeed | 0 | 0 | 0 | 0 | 0 | 0 | — | no same-day JSON |
| Hirist | 0 | 0 | 0 | 1 | 0 | 0 | no | scripts_finished_without_same_day_report_exit_0 |
| Hitech City / Knowledge City | 0 | 0 | 0 | 1 | 0 | 0 | no | hitechcity_interactive_login_required |

AUTO_FIX / agent recovery was **not** run. For code-fixable blockers, run `bash scripts/portal-home-daily.sh <portal>` or fix manually.
