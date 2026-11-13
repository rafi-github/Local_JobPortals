# Foundit daily — 2026-10-19 (home-local)

## Summary
- **Preflight:** resume OK (`Rafi_Resume.docx` rebuilt from master); Foundit **MSSOAT** on system Chrome Default (ABE).
- **CDP:** `launch-chrome-cdp.sh foundit` — reused `:9222` system profile.
- **Login:** `loggedIn=true`, `jwtOk=true`, dashboard (`hasRafi` false — cookie+onApp accepted).
- **Applied tab (authoritative run):** **312 → 312** (`appliedDelta` 0; **0 intentional** applies).
- **Inventory:** Raven scan through **3650d**; **103** eligible Hyd/remote .NET-arch roles **already applied** (`userJobInfo` duplicates); **1132** skipped by filters; **0** blocked on final pass.
- **JD tailor:** fixed mid-run — `resume_tailor.js` now uses **`py -3`** on Windows (Store `python3` stub had skipped tailor on first pass).

## Intentional applies
None — no new Falcon/ATS confirmations (`linkedin_easy_apply_ok` / `ats_submitted`). Eligible inventory is largely prior Virtusa / Jobgether / NTT / right advisors volume.

## First-pass note (pre tailor fix)
Initial run bumped Applied tab **297 → 312** with **15** incomplete Falcon redirects (mostly NTT Data iCIMS — `ats_error` / `external_ats_incomplete`). Those are **not** counted as applies per HARD rule. Re-run after tailor fix: **312 → 312**, **0** blocked.

## Already applied (eligible sample)
- **Jobgether** — Lead Engineer/ Architect (.NET) - Industrial
- **Virtusa** — Lead Software Engineer / Architect / Systems Architect (multiple)
- **NTT Data** — Sr Dev .Net Fullstack + Cloud (duplicate listings — partial Falcon stage-one from first pass; ATS not confirmed)
- **right advisors private limited** — Sr. Principal(C , .NET) Desktop Application Development Architect
- **Hyland** — Software Security Architect
- **State Street** — Senior Application Architect - AVP

## Skip drivers (top)
- No .NET on title+skills (~337)
- Location not Hyd/remote — Bangalore (~177)
- No seniority on title (~103)
- Singapore / SAP-without-.NET / pure-AI bands

## LinkedIn referral drafts
None generated this run (no new redirect completes). Prior draft still valid: **bet technology** — Remote Principal Software Engineer (C .NET) — see `foundit-apply-report.json` `referralDrafts` from 2026-10-19 first pass if needed.

## Code fix (local, not merged)
- `tools/resume_tailor.js` — Windows `py -3` probe (log: `automation-prompts/issues/foundit.md` 2026-10-19).

## Artifacts
- `artifacts/foundit-apply-report.json` (final pass)
- `artifacts/foundit-daily-run.json`
- Logs: `artifacts/foundit-daily-apply-20261019.log`, `artifacts/foundit-daily-apply-20261019-r2.log`
