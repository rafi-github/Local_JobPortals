# Naukri Home Daily — 2026-10-16

Candidate: Mohammed Abdul Rafi Ahmed | Resume: `Rafi_Resume.docx` | Expected 65 LPA / Current 52 LPA | Hyd + Remote  
Source: **home-local** (Windows residential, `CHROME_CDP_MODE=system`)

## STEP 0 — Profile resume refresh
- **profileUpdated:** `true`
- **verify:** Uploaded today (`Rafi_Resume.docx`, 20693 B)
- Preflight: `live_cdp_naukri_ok` (system Chrome :9222)
- **Note:** In-runner `ensure_upload_resume` still calls `python3` (exit 9009 on Git Bash); preflight rebuilt upload from master. **tailoredApplies: 12** with `PYTHON` set to Python 3.12 for this run.

## Counts
| Metric | Value |
| --- | --- |
| profileUpdated | true |
| applied (Naukri Quick Apply) | **12** |
| externalCompleted | 0 |
| blocked | 6 |
| skipped | 1277 |
| seen | 202 |
| tailoredApplies | 12 |

Runtime ~29 min (`14:25`–`14:55` UTC). Primary ages 1d searches + expand queries.

## Applied (Naukri Quick Apply)
| Company | Role | Location |
| --- | --- | --- |
| Tata Consultancy Services | IMS Solution Architect | Hyd/BLR/NCR |
| Labcorp Endpoint | Principal Software Engineer | Hybrid Hyd/BLR |
| NTT DATA BUSINESS SOLUTIONS | Business Development Manager-ERP/Enterprise IT Sales | Hybrid Hyd/NCR |
| Three Across | Data Governance Technology Lead | Hybrid Hyderabad |
| Epam Systems | Solution Architecture - HCL Commerce | Hyd/Chennai/BLR |
| Tata Consultancy Services | GCP Migration Architect | Hyd/Chennai/BLR |
| Epam Systems | Lead Software Engineer - Camunda | Hyd/Chennai/BLR |
| (IT Services) | Principal Linux Platform Engineer - GPFS/OpenShift | Remote |
| (IT Services) | Software Architect | Remote |
| Top MNC | Azure Cloud Engineer & Architect | Hyderabad |
| Leading Agrochemical Company | Principal Investigator- Process Engineer | Hyderabad |
| NewVision Software (SoftServe) | Test Architect - Playwright Automation | Hybrid Hyd/Bhopal/Pune |

Per-job JD-tailored `Rafi_Resume.docx` uploaded to profile before each Quick Apply.

## Blocked
| Company | Role | Reason |
| --- | --- | --- |
| Hitachi Vantara | Presales Solution Architect | apply_unconfirmed |
| Simcorp | Lead Software Engineer - C# .net | external_incomplete_or_timeout |
| Imedhas | Dot Net Architect | external_link_not_opened |
| Wells Fargo | Software Engineering Senior Manager | external_incomplete_or_timeout |
| Nagarro | Associate Principal Engineer (Integration Architect) | external_incomplete_or_timeout |
| Silicon Labs | Lead Engineer - SW Design | external_incomplete_or_timeout |

## Notes
- `profileResumeRestored.ok: true` — canonical CV restored after run.
- Lower apply volume vs 2026-10-15 (28): more external attempts timed out on 1d inventory; no external completes this pass.
- **Follow-up:** wire `PYTHON3`/`python` probe in `daily_apply.js` bootstrap (or export in `portal-home-daily.sh`) so `ensure_upload_resume` does not depend on preflight on Windows.

## Artifacts
- `artifacts/naukri-profile-resume.json`
- `artifacts/naukri-daily-apply.json`
- `artifacts/naukri-daily-run.json`
- `~/.cursor/portal-home-logs/naukri/naukri-20261016T142547Z.log`
- `~/.cursor/portal-home-logs/naukri/naukri-daily-run.json`
