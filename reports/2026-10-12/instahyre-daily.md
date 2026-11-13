# Instahyre home daily — 2026-10-12

## Summary
- **Preflight:** `live_cdp_instahyre_ok` (system Chrome Default, sessionid via CDP).
- **Blocker (fixed same-day):** Instahyre retired `candidate_opportunity/*` APIs (404 HTML). First pass: **0** applies, **31** `apply_failed` 404.
- **Fix:** `tools/instahyre/daily_apply.js` → `candidate_matching` (`fetch_filter_counts?interest_facet=0`, undecided list, `/apply`).
- **Post-fix run:** **30** Instahyre in-app | **0** external ATS | **642** skipped | **0** blocked | **672** seen.
- **Interested count:** 299 → 328 (+29 net in run; +1 from API probe earlier today).
- **JD tailor + profile upload:** all 30 with `profileResumeUpload.ok: true`.

## Applied (Instahyre express interest)
- **Qapita** — Lead Software Development Engineer | Hyderabad
- **ArcelorMittal** — Lead Analyst - .NET | Hyderabad
- **Infosys** — .NET Developer | Bangalore,Hyderabad,Pune
- **Firstsource** — Dotnet Developer | Work From Home
- **DBSync** — Senior Engineering Manager | Work From Home
- **Klimb.io** — Tech Lead | Hyderabad
- **TA Digital** — Data Solution Architect | Work From Home
- **Tata Group** — Security Architect | Hyderabad
- **Amazon** — Solution Architect | Work From Home (×2 listings)
- **Uber** — Staff Engineer | Work From Home
- **Freehand** — Staff Engineer | Work From Home (×2)
- **NetSpring** — Staff Engineer | Bangalore,Work From Home
- **Entain India** — Principal Engineer | Hyderabad
- **EPAM Systems** — Software Architect | Bangalore,Hyderabad,Pune
- **Accellor** — Lead Full Stack Developer | Hyderabad
- **DataArt** — Senior Platform Developer With AWS | Work From Home
- **Algoworks** — Azure DevOps Engineer | Bangalore,Hyderabad,Pune
- **Arcesium** — Linux AWS Engineer | Hyderabad
- **Accenture** — Software Engineer (AWS) | Chennai,Gurgaon,Hyderabad
- **Yash Technologies** — Consultant - Linux AWS Vmware | Hyderabad,Indore,Pune
- **Intel** — Node.js Developer | Hyderabad
- **Axi** — Backend Engineer | Work From Home
- **NxtWave** — Software Development Engineer 2 | Hyderabad
- **Uber** — SSE (L5) - BE | Bangalore,Hyderabad
- **Nineleaps** — Python Engineer | Bangalore,Hyderabad
- **Incedo** — Python Developer | Hyderabad
- **Helfie.AI** — Principle Engineer | Hyderabad
- **Uber** — Engineering Manage II | Hyderabad

## Top skip reasons
- `location_not_hyd_remote`: 555
- `already_interested`: 51
- `generic_engineering_without_dotnet_cloud`: 12
- `java_primary`: 10
- `pure_ai_data_without_dotnet`: 8

## Artifacts
- `artifacts/instahyre-apply-report.json`
- `artifacts/instahyre-daily-run.json` (home-local schema)
- Logs: `artifacts/instahyre-daily-apply-rerun.log`
