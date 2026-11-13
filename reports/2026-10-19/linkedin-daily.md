# LinkedIn daily — 2026-10-19 (home-local)

## Status
**OK** — restriction clear. **13** Easy Apply confirmations (`Application submitted`). **0** external ATS completions.

## Preflight / CDP
- Preflight: resume rebuilt (`Rafi_Resume.docx` from master); initial `cdp_connect_failed` (Chrome not up).
- `bash scripts/launch-chrome-cdp.sh linkedin` → system Chrome profile; `has_li_at` + feed verified (WARP skipped on Windows home).

## Totals
| Path | Count |
| --- | --- |
| Easy Apply submitted | **13** |
| External / ATS completed | **0** |
| Easy Apply blocked | 8 |
| External blocked | 24 |
| Skipped (scan) | 475 + 16 external |

## Submitted (Easy Apply)
| Company | Role | Job ID |
| --- | --- | --- |
| r3 Consultant | Agentic AI Platform Architect & Product Lead | 4480931633 |
| Talentgigs | Technical Lead | 4479942988 |
| Teamified | Principal Full Stack Engineer (Fully Remote- India) | 4480948027 |
| Kandou AI | Software Architect | 4472293294 |
| Mulya Technologies | Customer Platform, SDK & Interoperability Architect | 4480862489 |
| Mulya Technologies | Customer Platform, SDK & Interoperability Architect | 4480872215 |
| Backbase | Solution Architect | 4477765972 |
| Trianz | Senior Technical Lead - IDMC Admin | 4479952928 |
| Mulya Technologies | Customer Platform, SDK & Interoperability Architect | 4480874162 |
| iLabs Capital | Associate Director of Sales | 4478260045 |
| Tytan Technology Inc. | Senior Software Engineer | 4478244759 |
| NLB Services | Quantexa Technical Lead | 4479958944 |
| NoBroker.com | Business Development Manager | 4479958941 |

## Easy Apply blocked (sample)
- SPADTEK / Team Geek / profitvoice.in / isolved / Cyara / MyCareernet — `exceeded Easy Apply steps`
- ESS ESS KAY — Sales/Marketing Manager (modal did not open)

## External pass
- `linkedin_external_apply.py`: **0** submitted; **24** blocked (`did_not_leave_linkedin`, `external_incomplete_or_timeout`, `no_ats_form`).
- LTM Senior Software Engineer (4478257030): ASK_OWNER wait → `external_incomplete_or_timeout`.
- End-of-queue Wipro SA L1, TidyHire EM, UST testing architect — no ATS completion.

## False-skip / false-apply suspects
- **False applies (tighten title filter):** iLabs Associate Director of Sales; NoBroker BDM; r3 “Agentic AI” if pure-AI policy should block without .NET on title.
- **Duplicates:** three Mulya listings same role (likely duplicate postings).
- **Location:** many “India” / non-remote pills skipped on view (Jobgether, crewlia, Valiance) — expected per Hyd/remote-only rule.

## Artifacts
- `artifacts/linkedin-daily-run.json`
- `artifacts/apply-report.json`
- `artifacts/external-apply-report.json`
- Logs: `artifacts/_linkedin_easy_apply_run.log`, `artifacts/_linkedin_external_apply_run.log`
