#!/usr/bin/env node
/**
 * Build the daily job-status markdown from local portal reports.
 * Prints the written file path. Does not call any Cursor API.
 */
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const root = process.argv[2] || process.cwd();
const portals = [
  "linkedin",
  "foundit",
  "cutshort",
  "naukri",
  "instahyre",
  "indeed",
  "hirist",
  "hitechcity",
];
const today = new Date().toISOString().slice(0, 10);
const lines = [
  `# Job status — ${today}`,
  "",
  "Source: local scheduled task. Counts come only from same-day JSON reports.",
  "",
];

for (const portal of portals) {
  const file = join(root, "artifacts", `${portal}-daily-run.json`);
  lines.push(`## ${portal}`);
  if (!existsSync(file)) {
    lines.push("- No report file.", "");
    continue;
  }
  let report;
  try {
    report = JSON.parse(readFileSync(file, "utf8"));
  } catch {
    lines.push("- Report file is not valid JSON.", "");
    continue;
  }
  if (report.date && report.date !== today) {
    lines.push(`- Stale report (${report.date}), ignored.`, "");
    continue;
  }
  const counts = report.counts || {};
  lines.push(
    `- applied ${counts.applied || 0}, external ${counts.external || 0}, rejected ${counts.rejected || 0}, blocked ${counts.blocked || 0}, skipped ${counts.skipped || 0}, seen ${counts.seen || 0}`,
  );
  if (report.blockerSummary) lines.push(`- blocker: ${report.blockerSummary}`);
  lines.push("");
}

const outDir = join(root, "artifacts");
mkdirSync(outDir, { recursive: true });
const out = join(outDir, `job-status-${today}.md`);
writeFileSync(out, `${lines.join("\n")}\n`);
process.stdout.write(`${out}\n`);
