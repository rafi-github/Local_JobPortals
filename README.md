# MyRepo

Job-apply automation assets for Mohammed Abdul Rafi Ahmed.

## Resume

Owner source: [`resumes/Mohammed_Abdul_Rafi_Ahmed_Resume.docx`](resumes/Mohammed_Abdul_Rafi_Ahmed_Resume.docx)

Canonical upload path for all daily apply automations (LinkedIn Easy Apply label, ATS `set_input_files`, profile refresh): [`resumes/Rafi_Resume.docx`](resumes/Rafi_Resume.docx) — same bytes as the owner source. JD tailor (`tools/resume_tailor.py` / `.js`) rewrites headline/summary/skill order on top of this file per job; output keeps the `Rafi_Resume.docx` filename.

```bash
bash scripts/bootstrap-job-assets.sh
```

## Agent instructions

See [`automation-prompts/README.md`](automation-prompts/README.md).

Shared targets: **Expected CTC 65 LPA**, **Hyderabad + Remote/WFH**, **Rafi_Resume.docx** (from Mohammed_Abdul_Rafi_Ahmed_Resume.docx), company-website/ATS completion (not Easy Apply only).

Campus-focused daily: **Hitech City / Knowledge City** (`automation-prompts/08-hitech-city.md`, `tools/hitechcity/`) — Knowledge City, Knowledge Park, Mindspace Madhapur and peer Grade-A Madhapur tenants via career portals + LinkedIn referrals.

Issue log: [`automation-prompts/ISSUES_AND_FIXES.md`](automation-prompts/ISSUES_AND_FIXES.md).

## Portal login (required for daily cron)

If automations stop at Sign-in pages, the saved environment snapshot is missing auth cookies.

```bash
bash scripts/open-portal-login-tabs.sh          # Desktop Chrome tabs
bash scripts/verify-portal-logins.sh --strict   # must show all 6 OK
```

Then **Save / Update snapshot** on the environment dashboard. Details: [`automation-prompts/ENV_READINESS.md`](automation-prompts/ENV_READINESS.md).

## Daily automation readiness

Before saving a daily automation snapshot, log into each portal in Desktop Chrome
Default, then run:

```bash
bash scripts/sync-chrome-sessions.sh --strict
node tools/chrome_session.js status
```

Disable the duplicate General Daily automation
`30e2c023-9067-11f1-ba66-0e7d0216e441`; Naukri Daily owns that flow.

## Daily run on this PC

One Windows Task Scheduler job runs every portal with the local Python and Node
tools. It does not start the Cursor CLI and does not call the Cursor API.

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install-all-home-tasks.ps1
```

Default time is **09:00** local. The task name is `LocalJobPortals-Daily`.
See [`automation-prompts/HOME_AUTOMATIONS.md`](automation-prompts/HOME_AUTOMATIONS.md).
