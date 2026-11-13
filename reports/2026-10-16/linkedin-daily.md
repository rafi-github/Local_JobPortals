# LinkedIn daily — 2026-10-16 (home-local)

## Status
**OK** — restriction clear. **15** Easy Apply confirmations (`Application submitted`). **0** external ATS completions.

## Preflight / CDP
- Initial preflight: `cdp_connect_failed` (Chrome not up); resume rebuilt (`Rafi_Resume.docx` 20KB from master).
- `bash scripts/launch-chrome-cdp.sh linkedin` → CDP on system Chrome profile; `has_li_at` + feed verified.

## Totals
| Path | Count |
| --- | --- |
| Easy Apply submitted | **15** |
| External / ATS completed | **0** |
| Easy Apply blocked | 6 |
| External blocked | 23 |
| Skipped (scan) | 491 + 17 external |

## Submitted (Easy Apply)
| Company | Role | Job ID |
| --- | --- | --- |
| GSPANN Technologies | Azure Cloud Native Architect | 4474123513 |
| Talentgigs | Technical Lead | 4479303923 |
| Kandou AI | Principal Linux Kernel Engineer | 4480338925 |
| DAZN | Senior Software Engineer (C#, .Net) | 4480337936 |
| Maganti IT Resources | Senior Dotnet Developer | 4477384134 |
| Tanla Platforms | Senior Engineering Manager | 4479352223 |
| HighRadius | Director of Engineering | 4477083039 |
| insightsoftware | Engineering Manager | 4468506906 |
| Weekday AI | Principal Software Engineer | 4480353374 |
| The buildworkshop | Fresher architect | 4477378531 |
| IIC Technologies | Program Director | 4477387437 |
| OSF Digital | Technical Architect - Revenue Cloud | 4478514056 |
| Marriott Tech Accelerator | Senior Engineering Manager Redwood UX | 4478788716 |
| DataM Intelligence | International Sales & BD Manager | 4477385346 |
| Virtusa | AWS Bedrock Architect | 4477043720 |

## External pass
- `linkedin_external_apply.py`: **0** submitted; **23** blocked (`did not leave LinkedIn`, `external_incomplete_or_timeout`, `no_ats_form`).
- Sample blocked: Druva GH (8720275002), Nasuni, Microsoft, Zscaler EM roles.

## False-skip / false-apply suspects
- **False applies (review filters):** Kandou Linux kernel; “Fresher architect”; DataM Sales/BD; Virtusa Bedrock/GenAI title.
- **Location:** remote India search skips roles that show “India” without remote pill — Jobgether Chief TA (4479197601) skipped on view.

## Artifacts
- `artifacts/apply-report.json`
- `artifacts/external-apply-report.json`
- `artifacts/linkedin-daily-run.json`
- Logs: `artifacts/_linkedin_easy_apply_run.log`, `artifacts/_linkedin_external_apply_run.log`
