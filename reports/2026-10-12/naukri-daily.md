# Naukri Home Daily — 2026-10-12

Candidate: Mohammed Abdul Rafi Ahmed | Resume: `Rafi_Resume.docx` | Expected 65 LPA / Current 52 LPA | Hyd + Remote  
Source: **home-local** (Windows residential, `CHROME_CDP_MODE=system`)

## STEP 0 — Profile resume refresh
- **profileUpdated:** `true`
- **verify:** Uploaded today (`Rafi_Resume.docx`, 20693 B from master)
- Preflight: `live_cdp_naukri_ok` (system Chrome :9222)

## Counts
| Metric | Value |
| --- | --- |
| profileUpdated | true |
| applied (Naukri Quick Apply) | **10** |
| externalCompleted | 0 |
| blocked | 8 |
| skipped | 126 |
| seen | 60 |
| tailoredApplies | 10 |

Run stopped early (~23 min): Chrome/CDP context closed during age-expand pass after hitting **10** confirmed applies (`MAX_APPLIES` not reached; expand queries aborted).

## Applied (Naukri Quick Apply)
| Company | Role | Location | CTA |
| --- | --- | --- | --- |
| Epam Systems | Solution Architecture - HCL Commerce | Hyd/Chennai/Bengaluru | chatbot:responses_thanks |
| Highradius | Technical Account Manager / Forward Deployed Architect | Hyderabad | chatbot:responses_thanks |
| Valuelabs | Dot Net Technical Architect | Hyderabad | chatbot:responses_thanks |
| Intellics Global Services | Urgent Hiring For Cryptography Architect | Hybrid Hyd/Pune/Chennai | chatbot:responses_thanks |
| Valuelabs | Purview Architect | Remote | chatbot:responses_thanks |
| iitjobs | Incorta Architect - Hyderabad | Hybrid Hyderabad | view_applied_jobs |
| Epam Systems | Senior Solution Architect - .NET Full Stack with Cloud | Hyd/Chennai/Bengaluru | chatbot:responses_thanks |
| GSPANN | Contentful Architect | Hyd/Noida/Gurugram | chatbot:responses_thanks |
| Genpact | Urgent Opening For MSD 365 F&O Side Architect | Hybrid Hyd/BLR/NCR | view_applied_jobs |
| Hiring for an IT Services company | Dell Boomi Architect/Developer - Hyderabad | Hyderabad | view_applied_jobs |

All used per-job tailored `Rafi_Resume.docx` under `\tmp\naukri-tailored\`.

## Blocked (sample)
| Company | Role | Reason |
| --- | --- | --- |
| Coinbase India Services | Sr Engineering Manager | external_incomplete_or_timeout (Greenhouse) |
| AsentechLLC | Sr Business Development Manager | external_incomplete_or_timeout |
| Imedhas | Dot Net Architect | external_link_not_opened |
| Wissen Infotech | Architect | apply_unconfirmed (no_chat) |
| Capgemini | Architect | apply_unconfirmed (no_chat) |
| TechBlocks | IDP Architect | apply_unconfirmed (no_chat) |
| Grid Dynamics | .NET Developer | apply_unconfirmed (no_chat) |
| (confidential) | .NET Full Stack Lead | exception — browser closed |

## Notes
- Profile canonical CV restore: see `profileResumeRestored` in `artifacts/naukri-daily-apply.json`.
- Several applies are non-primary-stack titles (Cryptography, Purview, Incorta, Contentful, D365 F&O, Boomi) — consider title-skip tightening if owner wants stricter .NET-only volume.

## Artifacts
- `artifacts/naukri-profile-resume.json`
- `artifacts/naukri-daily-apply.json`
- `artifacts/naukri-daily-run.json`
- `~/.cursor/portal-home-logs/naukri/naukri-daily-run.json`
