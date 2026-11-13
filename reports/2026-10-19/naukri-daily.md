# Naukri Home Daily — 2026-10-19

Candidate: Mohammed Abdul Rafi Ahmed | Resume: `Rafi_Resume.docx` | Expected 65 LPA / Current 52 LPA | Hyd + Remote  
Source: **home-local** (Windows residential, `CHROME_CDP_MODE=system`)

## STEP 0 — Profile resume refresh
- **profileUpdated:** `true` — Uploaded today (`Rafi_Resume.docx`, 20693 B)
- Preflight + CDP: system Chrome `:9222`, Naukri auth OK
- **Note:** In-runner `ensure_upload_resume` still fails on bare `python3` (exit 9009); preflight rebuilt upload from master. **tailoredApplies: 54** (tailor used `python` probe via `tailor_resume.js`).

## Counts
| Metric | Value |
| --- | --- |
| profileUpdated | true |
| applied (Naukri Quick Apply) | **54** |
| externalCompleted | 0 |
| blocked | 41 |
| skipped | 2898 |
| seen | 403 |
| tailoredApplies | 54 |

Runtime ~2h 35m (`09:00`–`11:35` UTC). Primary ages 1/3/7 + expanded **15/30/60**.

## Applied (Naukri Quick Apply) — sample
Full list in `artifacts/naukri-daily-apply.json` (`applied` array). Highlights:
- TCS Solution Architect; Epam (HCL Commerce, WLC, Senior SA .NET); Infosys (Rubrik / IT Data SA); Autorabit Principal; Ciklum / Mouri / Codeforce SA; Providence / Centific / isolved EM; Highradius / Tanla / Eruvaka EM; Pepsi Cloud Assoc Principal; Nagarro Associate Principal; Verisk / Progress Software Architect; multiple staffing-channel SA/TL roles.

Per-job JD-tailored resume synced to profile before each Quick Apply. `profileResumeRestored.ok: true` at end.

## Blocked (41)
| Reason | Count |
| --- | --- |
| external_incomplete_or_timeout | 25 |
| apply_unconfirmed | 14 |
| external_link_not_opened | 2 |

Sample: Majesco Principal Architect, Thermo Fisher SEM, Aggne Duck Creek, GitLab Sr Manager TPM, Insightsoftware, Jumpcloud PAM — mostly company-site / ATS timeouts; Imedhas external link not opened.

## False-skip / false-apply suspects (review)
- **Snowflake** SA (Codeforce), **Oracle** SA (Optimum), **Python** TA (Publicis Sapient), **Playwright QA** architect, **Ab initio** TL, **Coherent Principal Electrical** — may need title-filter parity with other portals.

## Artifacts
- `artifacts/naukri-profile-resume.json`
- `artifacts/naukri-daily-apply.json`
- `artifacts/naukri-daily-run.json`
- Log: `artifacts/naukri-daily-apply-20261019.log`
