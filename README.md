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

## Portal login (required before running a portal)

Each portal keeps a separate persistent Chrome profile. On Windows, sign in once
interactively to each portal; credentials and cookies are never copied from your
regular Chrome profile. Close any other CDP-enabled Chrome using port 9222 first.

```bash
bash scripts/home-headed-login.sh linkedin
bash scripts/home-headed-login.sh naukri
bash scripts/home-headed-login.sh foundit
bash scripts/home-headed-login.sh cutshort
bash scripts/home-headed-login.sh instahyre
bash scripts/home-headed-login.sh indeed
bash scripts/home-headed-login.sh hirist
bash scripts/home-headed-login.sh hitechcity
```

Complete each sign-in, including MFA, in the visible Chrome window. The profiles
are stored under `%LOCALAPPDATA%\Codex\Chrome CDP Profiles`. If a portal asks
you to sign in again, repeat its command. Do not use the cookie sync or session
snapshot scripts; these are intentionally disabled.

## Indeed access

Indeed automation stops when it returns a 403 or security challenge and skips
applications without proxy rotation or challenge automation. Automated Indeed
applications are disabled until an officially supported access method is
available. Use Indeed manually through its official site in the meantime.

## Email notifications

Set `RESEND_API_KEY` and (if needed) `RESEND_FROM_EMAIL` in the local secrets
file for Resend. Alternatively configure `SMTP_HOST`, `SMTP_PORT` (default
587), `SMTP_USER`, `SMTP_PASSWORD`, and optionally `SMTP_FROM`. Secrets stay in
your local environment. Gmail browser sending is disabled unless explicitly
enabled with `JOB_STATUS_GMAIL_FALLBACK=1`.

## Daily automation readiness

Before saving a daily automation snapshot, log into each portal in Desktop Chrome
Default, then run:

```bash
bash scripts/sync-chrome-sessions.sh --strict
node tools/chrome_session.js status
```

Disable the duplicate General Daily automation
`30e2c023-9067-11f1-ba66-0e7d0216e441`; Naukri Daily owns that flow.

## Home-local evening replicas (cloud can stay ON)

Second daily pass at **5 PM** on this PC (Task Scheduler + Cursor CLI). Cloud
morning automations can remain enabled.

See [`automation-prompts/HOME_AUTOMATIONS.md`](automation-prompts/HOME_AUTOMATIONS.md).

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install-all-home-tasks.ps1
```

## Windows private worker (My Machines)

Native Windows `agent worker start` currently crashes with `better-sqlite3`
NODE_MODULE_VERSION 127 vs 137. Use WSL:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\fix-windows-agent-worker.ps1 -LaunchWsl
```

Or inside Ubuntu WSL: `bash scripts/setup-wsl-agent-worker.sh --name job-apply-laptop`
