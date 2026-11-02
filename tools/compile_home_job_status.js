#!/usr/bin/env node
/**
 * Build a markdown job-status summary from home-local *-daily-run.json files.
 *
 * Usage:
 *   node tools/compile_home_job_status.js --date 2026-10-21 --out artifacts/job-status-2026-10-21.md
 */
"use strict";

const fs = require("fs");
const path = require("path");
const os = require("os");

const REPO = path.join(__dirname, "..");
const PORTALS = [
  { key: "linkedin", label: "LinkedIn" },
  { key: "foundit", label: "Foundit" },
  { key: "cutshort", label: "Cutshort" },
  { key: "naukri", label: "Naukri" },
  { key: "instahyre", label: "Instahyre" },
  { key: "indeed", label: "Indeed" },
  { key: "hirist", label: "Hirist" },
  { key: "hitechcity", label: "Hitech City / Knowledge City" },
];

function argValue(flag) {
  const i = process.argv.indexOf(flag);
  if (i === -1 || i + 1 >= process.argv.length) return null;
  return process.argv[i + 1];
}

function todayIst() {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Kolkata",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(new Date());
}

function readReport(portal, date) {
  const candidates = [
    path.join(REPO, "artifacts", `${portal}-daily-run.json`),
    path.join(
      os.homedir(),
      ".cursor",
      "portal-home-logs",
      portal,
      `${portal}-daily-run.json`,
    ),
  ];
  for (const p of candidates) {
    if (!fs.existsSync(p)) continue;
    try {
      const j = JSON.parse(fs.readFileSync(p, "utf8"));
      if (!date || j.date === date) return { path: p, data: j };
    } catch {
      /* skip */
    }
  }
  return { path: null, data: null };
}

function sum(rows, field) {
  return rows.reduce((n, r) => n + (r.counts?.[field] ?? 0), 0);
}

const date = argValue("--date") || todayIst();
const out =
  argValue("--out") || path.join(REPO, "artifacts", `job-status-${date}.md`);

const rows = PORTALS.map(({ key, label }) => {
  const { path: jsonPath, data } = readReport(key, date);
  const c = data?.counts || {};
  return {
    key,
    label,
    jsonPath,
    data,
    counts: {
      applied: c.applied ?? 0,
      external: c.external ?? 0,
      rejected: c.rejected ?? 0,
      blocked: c.blocked ?? 0,
      skipped: c.skipped ?? 0,
      seen: c.seen ?? 0,
    },
    ok: data?.ok,
    blocker: data?.blockerSummary || (jsonPath ? "—" : "no same-day JSON"),
  };
});

const totals = {
  applied: sum(rows, "applied"),
  external: sum(rows, "external"),
  rejected: sum(rows, "rejected"),
  blocked: sum(rows, "blocked"),
  skipped: sum(rows, "skipped"),
};

const lines = [];
lines.push(`# Job status — ${date}`);
lines.push("");
lines.push(
  `Home-local **scripts** run on \`${os.hostname()}\` (no Cursor agent). ` +
    `Targets: Expected CTC 65 LPA; Hyderabad + Remote/WFH; resume \`Rafi_Resume.docx\`.`,
);
lines.push("");
lines.push(
  `**Totals today:** applied ${totals.applied} · external ${totals.external} · ` +
    `rejected ${totals.rejected} · blocked ${totals.blocked} · skipped ${totals.skipped}.`,
);
lines.push("");
lines.push("## Portal results (source: home-local, same-day)");
lines.push("");
lines.push(
  "| Portal | Applied | External | Rejected | Blocked | Skipped | Seen | OK | Blocker |",
);
lines.push("| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- |");
for (const r of rows) {
  const okCell =
    r.data == null ? "—" : r.ok === true ? "yes" : r.ok === false ? "no" : "—";
  lines.push(
    `| ${r.label} | ${r.counts.applied} | ${r.counts.external} | ${r.counts.rejected} | ` +
      `${r.counts.blocked} | ${r.counts.skipped} | ${r.counts.seen} | ${okCell} | ${r.blocker} |`,
  );
}
lines.push("");
lines.push(
  "AUTO_FIX / agent recovery was **not** run. For code-fixable blockers, run " +
    "`bash scripts/portal-home-daily.sh <portal>` or fix manually.",
);
lines.push("");

fs.mkdirSync(path.dirname(out), { recursive: true });
fs.writeFileSync(out, lines.join("\n"));
console.log(`Wrote ${out}`);
