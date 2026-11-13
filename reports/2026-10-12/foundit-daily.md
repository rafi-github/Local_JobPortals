# Foundit daily — 2026-10-12 (home)

## Summary
- **Preflight:** `live_cdp_foundit_ok` (system Chrome Default, MSSOAT).
- **Login:** `loggedIn=true`, `jwtOk=true`, dashboard URL; greeting not “Hi, Rafi” (`hasRafi=false`) — cookie+app accepted.
- **Applied tab:** before **241**; after **not read** (run hit 30m wall before final `readAppliedCount`; incremental artifact saved).
- **Logged Falcon applies:** **6** → **4 false** (filter miss) + **2 intentional** (Deloitte .NET architect, Socnet resident SA).
- **Inventory:** d1=27, d3=166, d7=227, d14=268, d30=275; age window **30d**.
- **Skips:** 805 | **Blocked:** 48 (all `external_ats_incomplete` — mostly LinkedIn no Easy Apply) | duplicates: 8.

## Applied (intentional)
- **Deloitte** — Application Architect .Net -Lead Architect | `Foundit Falcon` NORMAL | profile upload OK
- **Socnet Technologies** — Resident solution architect | `Foundit Falcon` NORMAL | profile upload OK

## False applies (same run — fixed on branch)
- **TCS** — Solution Architect - EPC & 5G Core Networks → `telecom/5G without .NET on title`
- **L&T Technology Services** — Technical Lead Graphics → `graphics/GPU without .NET on title`
- **Infosys** — IT & Data Solution Architect - Supply Chain Planning → `ERP/supply-chain data architect without .NET on title`
- **Infosys** — IT Data Solution Architect P2P → same

**Fix:** branch `cursor/foundit-filter-telecom-graphics-erp-20261012` (pushed). Merge PR when `gh` is authed, or open: https://github.com/rafi-github/Local_JobPortals/pull/new/cursor/foundit-filter-telecom-graphics-erp-20261012

## Blocked (sample — LinkedIn handoff)
- **relq technologies** — Senior .NET Full Stack Developer- Angular - Remote | `linkedin_no_easy_apply`
- **Larsen & Toubro** — RCF_IC_Engineering Manager | `linkedin_no_easy_apply`
- **Jobgether** — Solutions Architect | `linkedin_ats_cap_or_incomplete`
- **lancesoft** — Senior .Net Developer | `linkedin_no_easy_apply`
- **Nasuni** — Principal Software Engineer - C .NET | `linkedin_no_easy_apply`

## Top 3 LinkedIn referral drafts
### relq technologies — Senior .NET Full Stack Developer- Angular - Remote

Hi — I'm applying for Senior .NET Full Stack Developer- Angular - Remote at relq technologies. 15+ yrs Solutions Architect / Tech Lead (.NET, Azure/AWS), Hyderabad/remote, immediate. Current 52 LPA → expected 65 LPA. Happy to share Rafi_Resume.docx — could you refer me to the hiring manager? Thanks, Rafi Ahmed (rafi.success@gmail.com / +91 8790251698)

### Larsen & Toubro — RCF_IC_Engineering Manager

Hi — I'm applying for RCF_IC_Engineering Manager at Larsen & Toubro. 15+ yrs Solutions Architect / Tech Lead (.NET, Azure/AWS), Hyderabad/remote, immediate. Current 52 LPA → expected 65 LPA. Happy to share Rafi_Resume.docx — could you refer me to the hiring manager? Thanks, Rafi Ahmed (rafi.success@gmail.com / +91 8790251698)

### Jobgether — Solutions Architect

Hi — I'm applying for Solutions Architect at Jobgether. 15+ yrs Solutions Architect / Tech Lead (.NET, Azure/AWS), Hyderabad/remote, immediate. Current 52 LPA → expected 65 LPA. Happy to share Rafi_Resume.docx — could you refer me to the hiring manager? Thanks, Rafi Ahmed (rafi.success@gmail.com / +91 8790251698)

## Notes
- Artifact: `artifacts/foundit-apply-report.json`
- Resume: JD-tailored per apply + `update_profile_resume` before Falcon
- Post-fix re-run deferred until PR merged / `gh auth login` on this machine
