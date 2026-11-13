#!/usr/bin/env node
/**
 * Merge linkedin_easy_apply + external reports into home-local linkedin-daily-run.json.
 */
"use strict";

const fs = require("fs");
const path = require("path");
const os = require("os");

const REPO = path.join(__dirname, "..", "..");
const { artifactPaths } = require("../artifact_path");

function readJson(p) {
  try {
    return JSON.parse(fs.readFileSync(p, "utf8"));
  } catch {
    return null;
  }
}

function pickList(obj, keys) {
  if (!obj || typeof obj !== "object") return [];
  for (const k of keys) {
    if (Array.isArray(obj[k])) return obj[k];
  }
  return [];
}

function argValue(flag) {
  const i = process.argv.indexOf(flag);
  if (i === -1 || i + 1 >= process.argv.length) return null;
  return process.argv[i + 1];
}

const artDir = path.join(REPO, "artifacts");
const easy = readJson(path.join(artDir, "apply-report.json")) || {};
const ext = readJson(path.join(artDir, "external-apply-report.json")) || {};

const applied = pickList(easy, ["applied", "submitted"]);
const external = pickList(ext, ["submitted", "external", "applied"]);
const blocked = [
  ...pickList(easy, ["blocked"]),
  ...pickList(ext, ["blocked"]),
];
const skipped = [
  ...pickList(easy, ["skipped", "skips"]),
  ...pickList(ext, ["skipped", "skips"]),
];
const seen = pickList(easy, ["seen", "scanned"]);

const ec = easy.counts || {};
const xc = ext.counts || {};
const extCount =
  Number(xc.external) ||
  (Array.isArray(xc.submitted) ? xc.submitted.length : external.length);
const counts = {
  applied: Number(ec.applied ?? ec.submitted ?? applied.length) || 0,
  external: extCount,
  rejected: Number(ec.rejected ?? 0) || 0,
  blocked:
    blocked.length ||
    (Number(ec.blocked ?? 0) + Number(xc.blocked ?? 0)),
  skipped:
    skipped.length ||
    (Number(ec.skipped ?? 0) + Number(xc.skipped ?? 0)),
  seen: Number(ec.seen ?? seen.length) || 0,
};

const finishedAt = new Date().toISOString();
const logPath = argValue("--log");

const report = {
  portal: "linkedin",
  source: "home-local",
  date: finishedAt.slice(0, 10),
  finishedAt,
  host: os.hostname(),
  ok: counts.applied > 0 || counts.external > 0 || counts.blocked === 0,
  counts,
  applied,
  external,
  rejected: pickList(easy, ["rejected"]),
  blocked,
  skipped,
  seen,
  blockerSummary: blocked[0]?.reason || null,
  logPath,
};

const outName = "linkedin-daily-run.json";
const body = JSON.stringify(report, null, 2) + "\n";
for (const p of artifactPaths(outName)) {
  fs.mkdirSync(path.dirname(p), { recursive: true });
  fs.writeFileSync(p, body);
}
console.log(body);
