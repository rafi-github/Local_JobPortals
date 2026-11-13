# Naukri Home Daily — 2026-10-15

Candidate: Mohammed Abdul Rafi Ahmed | Resume: `Rafi_Resume.docx` | Expected 65 LPA / Current 52 LPA | Hyd + Remote  
Source: **home-local** (Windows residential, `CHROME_CDP_MODE=system`)

## STEP 0 — Profile resume refresh
- **profileUpdated:** `true`
- **verify:** Uploaded today (`Rafi_Resume.docx`, 20693 B)
- Preflight: `live_cdp_naukri_ok` (system Chrome :9222)
- **Note:** `ensure_upload_resume.py` failed in-runner (`python3` not on PATH); preflight had already rebuilt upload from master. **tailoredApplies: 0** — JD tailor needs `py -3` / `PYTHON` on Windows home.

## Counts
| Metric | Value |
| --- | --- |
| profileUpdated | true |
| applied (Naukri Quick Apply) | **28** |
| externalCompleted | 0 |
| blocked | 35 |
| skipped | 1238 |
| seen | 207 |
| tailoredApplies | 0 |

Runtime ~77 min (`06:26`–`07:43` UTC). Ages 1d → 3d → 7d + expand queries.

## Applied (Naukri Quick Apply)
| Company | Role | Location |
| --- | --- | --- |
| Innominds Software | Solution Architect (Hyderabad) | Hyderabad |
| Cognizant | Lead Software Engineer | Hyderabad |
| EY | Manager - AI Data Platform Architecture | Hyderabad |
| EY | BCM-Technical Architect-Banking Domain-Manager | Hyderabad |
| Genpact | GCP Cloud Automation/GCP Architect | Hyderabad |
| Capgemini | Architect | Hyd/BLR/Mumbai |
| (IT Services) | Snowflake Architect | Hyderabad |
| Sonata Software | SF Architect | Hyderabad |
| NTT DATA | Technical Lead | Hyd/Chennai/BLR |
| Cognizant | Technical Lead- OneTrust | Hyd/Pune/BLR |
| Epam Systems | Senior Solution Architect - .NET Full Stack with Cloud | Hyd/Chennai/BLR |
| Principal Financial Group | Delivery Manager - Engineering | Hyderabad |
| MNC GCC | Full Stack Lead | Hybrid Hyderabad |
| Epam Systems | Solution Architecture - HCL Commerce | Hyd/Chennai/BLR |
| (Recruitment) | HV Engineering Manager | Remote |
| EXL | GCP Solution Architect | Hybrid Hyd/Pune/NCR |
| Luxoft | Insurance Solution Architect | Hyderabad |
| (IT Services) | Solution Architect - Informatica MDM | Hyd/Indore/Pune |
| Hiringhood | Senior Engineering Manager | Hybrid Hyderabad |
| Sonata Software | Senior Digital Architect | Hyderabad |
| Phenom People | Principal Engineer | Hyderabad |
| Cotiviti | IT Manager _.NET Full Stack & Azure Cloud | Hybrid Hyderabad |
| Valuelabs | Azure Architect | Hyd/Chennai/BLR |
| Naukri Assist | Solution Architect | Hyd/Kolkata/BLR |
| (FinTech) | Global Solution Architect - P2P | Hybrid Hyderabad |
| Talent Et Au Dela | Technical Lead - Full Stack Engineering | Hybrid Hyderabad |
| TCS | Staff Software Engineer (.NET, AWS & DevSecOps) | Hyd/Chennai/BLR |
| Tek Ninjas | Principal Engineer Architect | Hyderabad |

Canonical upload `resumes/Rafi_Resume.docx` (no per-job tailor this run).

## Blocked (sample)
| Company | Reason |
| --- | --- |
| Aspire Systems | external_incomplete_or_timeout |
| UST | external_incomplete_or_timeout |
| Cyberproof | external_incomplete_or_timeout |
| Nagarro | external_incomplete_or_timeout |
| Pepsico | apply_unconfirmed |
| F5 | apply_unconfirmed |
| EY | exception (duplicate apply path) |

## Notes
- `profileResumeRestored.ok: false` in apply JSON — verify profile still shows canonical CV after run.
- Several applies are GCP/Snowflake/Informatica/insurance-primary titles; filters allowed under Arch/Lead volume bias.
- **Follow-up:** set `PYTHON=py` (or fix `daily_apply.js` / `tailor_resume.js` to probe `py -3`) so master rebuild + JD tailor work in Git Bash without relying on preflight.

## Artifacts
- `artifacts/naukri-profile-resume.json`
- `artifacts/naukri-daily-apply.json`
- `artifacts/naukri-daily-run.json`
- `artifacts/naukri-daily-apply-20261015T062624Z.log`
- `~/.cursor/portal-home-logs/naukri/naukri-daily-run.json`
