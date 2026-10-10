# Daily applies on this PC

One Windows scheduled task runs the local portal scripts. It does not start the
Cursor CLI and does not call the Cursor API, so the run does not use Cursor
billing or usage.

1. Windows Task Scheduler (`LocalJobPortals-Daily`, default 09:00)
2. `scripts/run-all-home-now.sh` → each `scripts/portal-home-daily.sh`
3. Local tools under `tools/<portal>/` and a local status email

Portals run one after another so they do not share Chrome at the same time. On Windows they use system Chrome (`CHROME_CDP_MODE=system`).

## What gets installed

| Scheduled task | Default time (local) | Script |
| --- | --- | --- |
| LocalJobPortals-Daily | 09:00 | `run-all-home-now.sh` (every portal, then the status mail) |

The installer removes the older `HomeDaily-*` and `IndeedHomeDaily` tasks.
GitHub Actions **Daily Apply Portals** no longer starts cloud jobs.

## One-time setup (this PC)

```powershell
# Git for Windows (Git Bash) is required by the scheduled task.
cd C:\Code\Local_JobPortals
powershell -ExecutionPolicy Bypass -File scripts\install-all-home-tasks.ps1
```

Optional time:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install-all-home-tasks.ps1 -Time "09:00"
```

## Run all portals now (sequential)

```powershell
& "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe" scripts/run-all-home-now.sh
```

## Test one portal

```powershell
& "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe" scripts/portal-home-daily.sh linkedin
```

Logs: `artifacts/home-logs/<portal>/`  
JSON: `artifacts/<portal>-daily-run.json` (also published to git branch `automation-results`)

## Indeed on this work laptop

`ZSATunnel` / Zscaler is often running — Indeed may report Cloudflare even on
“home” Wi‑Fi because egress looks like a corporate/datacenter IP. For Indeed:

1. Disconnect Zscaler (or use pure home network without corp proxy), **or**
2. Set `INDEED_HTTP_PROXY` to a residential proxy.

Other portals usually work once signed into system Chrome Default.

Task Scheduler cannot run if the machine is asleep. Use:

- Windows → Power → never sleep on AC (or schedule wake)
- Or run a portal manually when you are at the desk

## Portal login on this PC

Home runs use **per-portal CDP profiles** under
`%USERPROFILE%\.cursor\chrome-cdp-profiles\<portal>` — not a copy of Desktop Chrome.

Chrome 127+ **App-Bound Encryption** prevents copying cookies from Desktop Default into
another `--user-data-dir`. Do this once per portal:

1. Close all Chrome windows.
2. Prefer: `bash scripts/home-headed-login.sh linkedin` (opens login, waits for Enter, live-verifies).
   Or: `bash scripts/launch-chrome-cdp.sh linkedin` then sign in in the headed window.
3. Leave that CDP profile logged in (`%USERPROFILE%\.cursor\chrome-cdp-profiles\linkedin`).
4. Repeat for foundit / cutshort / naukri / instahyre / indeed.
5. Re-run `bash scripts/preflight-portal-run.sh <portal>` — SQLite may show `destHasAuth: true`, but
   LinkedIn also needs a live CDP check (`node tools/linkedin/wait_for_cdp_login.js`).

Do **not** rely on Desktop Default cookie sync on Windows for CDP automation.
SQLite cookie **names** alone can be stale under App-Bound Encryption — Chrome may drop them on load.

## Notification email

After the portals finish, `notification-home-daily.sh` writes
`artifacts/job-status-YYYY-MM-DD.md` and sends it with `RESEND_API_KEY` when that
variable is set.

## Uninstall

```powershell
Unregister-ScheduledTask -TaskName LocalJobPortals-Daily -Confirm:$false
```
