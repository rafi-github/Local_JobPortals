# Job status — 2026-10-31

Home-local **scripts** run on `LAPY` (no Cursor agent). Targets: Expected CTC 65 LPA; Hyderabad + Remote/WFH; resume `Rafi_Resume.docx`.

**Totals today:** applied 31 · external 0 · rejected 0 · blocked 28 · skipped 643.

## Portal results (source: home-local, same-day)

| Portal | Applied | External | Rejected | Blocked | Skipped | Seen | OK | Blocker |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- |
| LinkedIn | 31 | 0 | 0 | 25 | 643 | 659 | yes | Easy Apply time-cap: Locator.inner_text: Timeout 1000ms exceeded.
Call log:
  - waiting for locator("[role='dialog'], .jobs-easy-apply-modal" |
| Foundit | 0 | 0 | 0 | 1 | 0 | 0 | no | scripts_finished_without_same_day_report_exit_0 |
| Cutshort | 0 | 0 | 0 | 1 | 0 | 0 | no | scripts_finished_without_same_day_report_exit_0 |
| Naukri | 0 | 0 | 0 | 0 | 0 | 0 | — | no same-day JSON |
| Instahyre | 0 | 0 | 0 | 0 | 0 | 0 | — | no same-day JSON |
| Indeed | 0 | 0 | 0 | 0 | 0 | 0 | — | no same-day JSON |
| Hirist | 0 | 0 | 0 | 0 | 0 | 0 | — | no same-day JSON |
| Hitech City / Knowledge City | 0 | 0 | 0 | 1 | 0 | 0 | no | scripts_finished_without_same_day_report_exit_3 |

AUTO_FIX / agent recovery was **not** run. For code-fixable blockers, run `bash scripts/portal-home-daily.sh <portal>` or fix manually.
